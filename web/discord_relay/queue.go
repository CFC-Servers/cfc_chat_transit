package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/bwmarrin/discordgo"
	"github.com/cfc-servers/cfc_chat_transit/voice"
	"github.com/cfc-servers/cfc_chat_transit/webhook"
)

var discord *discordgo.Session

type EventStruct struct {
	Data  EventData
	Type  string
	Realm string
}

type EventData struct {
	Type               string
	Content            string
	Avatar             string
	SteamName          string
	SteamId            string
	IrisId             string
	PlayerCountMax     float32
	PlayerCountCurrent float32
}

type VoiceMessageOperation struct {
	Message   string
	MessageId string
	SteamId   string
	SteamName string
	Avatar    string
	IsFinal   bool
}

var MessageQueue = make(chan []byte, 10000)

var VoiceWebhookId string = os.Getenv("VOICE_WEBHOOK_ID")
var VoiceWebhookSecret string = os.Getenv("VOICE_WEBHOOK_SECRET")

var DiscordToken string = os.Getenv("DISCORD_TOKEN")

const urlRegexString = `https?:\/\/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)`

const (
	EMOJI_JOIN           = "<:green_cross_cir:654105378933571594>"
	EMOJI_LEAVE          = "<:circle_red:855605697978957854>"
	EMOJI_HALTED         = "<:halted:398133588010336259>"
	EMOJI_BUILD          = "<:build:933512140395012107>"
	EMOJI_PVP            = "<:bk:812130062379515906>"
	EMOJI_PLAY           = "<:playbuttonsmaller:1017716044485382154>"
	EMOJI_MAP            = "🗺️"
	EMOJI_CONNECT        = "📡"
	EMOJI_ULX            = "⌨️"
	EMOJI_VOICE          = "🗣️"
	EMOJI_ROUND_MODIFIER = "🔵"

	COLOR_RED    = 0xE7373E
	COLOR_GREEN  = 0x37E73E
	COLOR_ORANGE = 0xE78837
	COLOR_BLUE   = 0x3796E7
	COLOR_YELLOW = 0xE7E037
)

var urlPattern = regexp.MustCompile(urlRegexString)

func escapeUrl(message string) string {
	return "<" + message + ">"
}

func steamLinkMessage(event EventStruct, message string) string {
	steamId := event.Data.SteamId

	if steamId == "" {
		return message
	}

	steamLink := "https://steamid.gay/user/" + steamId
	return "[" + message + "](" + steamLink + ")"
}

func sendMessage(discord *discordgo.Session, message EventStruct) {
	messageContent := urlPattern.ReplaceAllStringFunc(message.Data.Content, escapeUrl)

	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   messageContent,
		Username:  message.Data.SteamName,
		AvatarURL: message.Data.Avatar,
	}

	realm := message.Realm
	webhookInfo := webhook.Get(realm)

	_, err := discord.WebhookExecute(webhookInfo.ID, webhookInfo.Secret, true, params)
	if err != nil {
		log.Println("WebhookExecute errored: ", err)
	}
}

func sendEvent(discord *discordgo.Session, event EventStruct, eventText string, color int, emoji string) *discordgo.Message {
	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Username:  event.Data.SteamName,
		AvatarURL: event.Data.Avatar,
		Embeds: []*discordgo.MessageEmbed{
			{
				Description: fmt.Sprintf("%v ***%v***", emoji, eventText),
				Color:       color,
			},
		},
	}

	realm := event.Realm
	webhookInfo := webhook.Get(realm)

	message, err := discord.WebhookExecute(webhookInfo.ID, webhookInfo.Secret, true, params)

	if err != nil {
		log.Println(err)
	}

	return message
}

func sendConnectMessage(discord *discordgo.Session, event EventStruct) {
	message := steamLinkMessage(event, "Connected to the server")
	message = message + fmt.Sprintf(" %v/%v", event.Data.PlayerCountCurrent, event.Data.PlayerCountMax)
	sendEvent(discord, event, message, COLOR_GREEN, EMOJI_CONNECT)
}

func sendSpawnMessage(discord *discordgo.Session, event EventStruct) {
	message := steamLinkMessage(event, "Spawned in the server")
	sendEvent(discord, event, message, COLOR_GREEN, EMOJI_JOIN)
}

func sendDisconnectMessage(discord *discordgo.Session, event EventStruct) {
	reason := event.Data.Content
	message := steamLinkMessage(event, "Disconnected from the server")
	message = message + fmt.Sprintf(" %v/%v", event.Data.PlayerCountCurrent, event.Data.PlayerCountMax)

	if strings.Contains(reason, "\n") {
		message = message + "\n```" + reason + "\n```"
	} else {
		if len(reason) > 35 {
			message = message + "\n"
		}

		reason = " (" + reason + ")"
		message = message + reason
	}

	sendEvent(discord, event, message, COLOR_ORANGE, EMOJI_LEAVE)
}

func sendMapMessage(discord *discordgo.Session, event EventStruct) {
	sendEvent(discord, event, event.Data.Content, COLOR_GREEN, EMOJI_MAP)
}

func sendAnticrashMessage(discord *discordgo.Session, event EventStruct) {
	sendEvent(discord, event, event.Data.Content, COLOR_RED, EMOJI_HALTED)
}

func sendUlxAction(discord *discordgo.Session, event EventStruct) {
	sendEvent(discord, event, event.Data.Content, COLOR_BLUE, EMOJI_ULX)
}

func sendRoundModifierEnabled(discord *discordgo.Session, event EventStruct) {
	sendEvent(discord, event, event.Data.Content, COLOR_BLUE, EMOJI_ROUND_MODIFIER)
}

func sendPvpStatusChange(discord *discordgo.Session, event EventStruct) {
	var emoji string
	var color int

	content := event.Data.Content

	if strings.HasSuffix(content, "PvP mode") {
		emoji = EMOJI_PVP
		color = COLOR_RED
	} else if strings.HasSuffix(content, "Build mode") {
		emoji = EMOJI_BUILD
		color = COLOR_BLUE
	}

	sendEvent(discord, event, event.Data.Content, color, emoji)
}

func sendVoiceText(discord *discordgo.Session, data *voice.Session) string {
	transcript := data.Message
	steamName := data.SteamName
	avatar := data.Avatar
	// fileName := data.FileName
	messageId := data.MessageId
	// isFinal := data.Finished

	// var voiceLink string
	// if len(fileName) > 0 {
	// 	voiceLink = fmt.Sprintf("https://larynx.cfcservers.org/%v.ogg", fileName)
	// }

	// var description string

	// if isFinal && len(voiceLink) > 0 {
	// 	description = fmt.Sprintf("%v [%v](%v) %v", EMOJI_VOICE, EMOJI_PLAY, voiceLink, transcript)
	// } else {
	// 	description = fmt.Sprintf("%v %v", EMOJI_VOICE, transcript)
	// }

	description := fmt.Sprintf("%v %v", EMOJI_VOICE, transcript)

	embeds := []*discordgo.MessageEmbed{
		{
			Description: description,
			Color:       COLOR_BLUE,
		},
	}

	if len(messageId) == 0 {
		log.Println("Creating new message for voice")
		params := &discordgo.WebhookParams{
			AllowedMentions: &discordgo.MessageAllowedMentions{
				Parse: []discordgo.AllowedMentionType{},
			},
			Username:  steamName,
			AvatarURL: avatar,
			Embeds:    embeds,
		}

		message, err := discord.WebhookExecute(VoiceWebhookId, VoiceWebhookSecret, true, params)

		if err != nil {
			log.Println("Error sending webhook message create")
			log.Println(err)
			return ""
		}

		return message.ID
	} else {
		log.Println("Updating existing message for voice")
		params := &discordgo.WebhookEdit{
			Embeds: embeds,
		}

		log.Println(messageId)
		log.Println(params.Embeds[0].Description)

		message, err := discord.WebhookMessageEdit(VoiceWebhookId, VoiceWebhookSecret, messageId, params)
		if err != nil {
			log.Println("Error sending webhook message edit")
			log.Println(err)
		}

		return message.ID
	}
}

func processVoiceText(queueVoiceText func(string, string, string, string), event EventStruct) {
	steamId := event.Data.SteamId
	steamName := event.Data.SteamName
	avatar := event.Data.Avatar
	data := event.Data.Content
	log.Println(data)

	queueVoiceText(steamId, steamName, avatar, data)
}

func queueGroomer() {
	discord, err := discordgo.New(DiscordToken)
	voiceManager := voice.NewManager(discord, sendVoiceText)

	if err != nil {
		log.Fatal("error connecting:", err)
		return
	}

	log.Println("Successfully connected to Discord")

	for {
		rawMessage := <-MessageQueue
		log.Println("Received message from queue: ", string(rawMessage))
		var message EventStruct

		if err := json.Unmarshal(rawMessage, &message); err != nil {
			log.Printf("Error unmarshalling json: %v", err)
			continue
		}

		log.Println(message.Type, message.Data.SteamName, message.Data.SteamId, message.Data.Content)

		switch message.Type {
		case "message":
			sendMessage(discord, message)
		case "connect":
			sendConnectMessage(discord, message)
		case "spawn":
			sendSpawnMessage(discord, message)
		case "disconnect":
			sendDisconnectMessage(discord, message)
		case "map_init":
			sendMapMessage(discord, message)
		case "anticrash_event":
			sendAnticrashMessage(discord, message)
		case "ulx_action":
			sendUlxAction(discord, message)
		case "pvp_status_change":
			sendPvpStatusChange(discord, message)
		case "round_modifier_enabled":
			sendRoundModifierEnabled(discord, message)
		case "voice_transcript":
			processVoiceText(voiceManager.ReceiveVoiceTranscript, message)
		}

	}
}
