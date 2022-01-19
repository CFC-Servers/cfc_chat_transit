package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/bwmarrin/discordgo"
)

var discord *discordgo.Session

type EventStruct struct {
	Type  string
	Data  EventData
	Realm string
}

type EventData struct {
	Type      string
	Content   string
	Avatar    string
	SteamName string
	SteamId   string
	IrisId    string
}

var MessageQueue = make(chan []byte, 100)

var WebhookId string = os.Getenv("WEBHOOK_ID")
var WebhookSecret string = os.Getenv("WEBHOOK_SECRET")

const urlRegexString = `https?:\/\/[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)`

const (
	JOIN_EMOJI   = "<:green_cross_cir:654105378933571594>"
	LEAVE_EMOJI  = "<:circle_red:855605697978957854>"
	HALTED_EMOJI = "<:halted:398133588010336259>"
	COP_EMOJI    = "👮"
)

var urlPattern = regexp.MustCompile(urlRegexString)

func escapeUrl(message string) string {
	return "<" + message + ">"
}

func steamLinkMessage(event EventStruct, message string) string {
	steamLink := "https://steamid.io/lookup/" + event.Data.SteamId
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

	_, err := discord.WebhookExecute(WebhookId, WebhookSecret, true, params)

	if err != nil {
		log.Println(err)
	}
}

func sendEvent(discord *discordgo.Session, event EventStruct, eventText string, color int, emoji string) {
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

	_, err := discord.WebhookExecute(WebhookId, WebhookSecret, true, params)

	if err != nil {
		log.Println(err)
	}
}

func sendConnectMessage(discord *discordgo.Session, event EventStruct) {
	message := steamLinkMessage(event, "Connected to the server")
	sendEvent(discord, event, message, 0x009900, JOIN_EMOJI)
}

func sendSpawnMessage(discord *discordgo.Session, event EventStruct) {
	message := steamLinkMessage(event, "Spawned in the server")
	sendEvent(discord, event, message, 0x009900, JOIN_EMOJI)
}

func sendDisconnectMessage(discord *discordgo.Session, event EventStruct) {
	reason := event.Data.Content
	message := steamLinkMessage(event, "Disconnected from the server")

	if strings.Contains(reason, "\n") {
		message = message + "\n```" + reason + "\n```"
	} else {
		message = message + " (" + reason + ")"
	}

	sendEvent(discord, event, message, 0x990000, LEAVE_EMOJI)
}

func sendAnticrashMessage(discord *discordgo.Session, event EventStruct) {
	sendEvent(discord, event, event.Data.Content, 0xE7373E, HALTED_EMOJI)
}

func sendUlxAction(discord *discordgo.Session, event EventStruct) {
	sendEvent(discord, event, event.Data.Content, 0xE7373E, COP_EMOJI)
}

func queueGroomer() {
	discord, err := discordgo.New("")

	log.Println(WebhookId, WebhookSecret)

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
			sendConnectMessage(discord, message)
		case "disconnect":
			sendDisconnectMessage(discord, message)
		case "anticrash_event":
			sendAnticrashMessage(discord, message)
		case "ulx_action":
			sendUlxAction(discord, message)
		}
	}
}
