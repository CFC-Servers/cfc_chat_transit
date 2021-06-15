package main

import (
	"encoding/json"
	"github.com/bwmarrin/discordgo"
	"log"
	"os"
	"strings"
)

var discord *discordgo.Session

type MessageStruct struct {
	Realm     string
	Type 	  string
	Content   string
	Avatar    string
	SteamName string
	SteamId   string
	IrisId    string
}

var MessageQueue = make(chan []byte, 100)

var WebhookId string = os.Getenv("WEBHOOK_ID")
var WebhookSecret string = os.Getenv("WEBHOOK_SECRET")

const (
	JOIN_EMOJI = "<:bk:812130062379515906>"
	STEAM_EMOJI = "<:steamsquare:812130007701782588>"
)

func sendMessage(discord *discordgo.Session, message MessageStruct) {
	//profileUrl := "https://steamcommunity.com/profiles/" + message.SteamId
	//joinUrl := "https://cfcservers.org/" + strings.ToLower(message.Realm) + "/join"

	var contentBuilder strings.Builder
	//contentBuilder.WriteString(fmt.Sprintf("[%v](<%v>) ", JOIN_EMOJI, joinUrl))
	//contentBuilder.WriteString(fmt.Sprintf("[%v](<%v>) ", STEAM_EMOJI, profileUrl))
	contentBuilder.WriteString(message.Content)

	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   contentBuilder.String(),
		Username:  message.SteamName,
		AvatarURL: message.Avatar,
	}

	discord.WebhookExecute(WebhookId, WebhookSecret, true, params)
}

func sendConnect(discord *discordgo.Session, message MessageStruct) {
	var contentBuilder strings.Builder
	contentBuilder.WriteString(message.Content)

	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   contentBuilder.String(),
		Username:  "Relay",
	}

	discord.WebhookExecute(WebhookId, WebhookSecret, true, params)
}

func sendConnectMessage(discord *discordgo.Session, message MessageStruct) {
	var contentBuilder strings.Builder
	contentBuilder.WriteString(message.Content)

	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   message.SteamName + " | " + message.SteamId + " has connected to the server." ,
		Username:  "Relay",
	}

	discord.WebhookExecute(WebhookId, WebhookSecret, true, params)
}

func sendDisconnectMessage(discord *discordgo.Session, message MessageStruct) {
	var contentBuilder strings.Builder
	contentBuilder.WriteString(message.Content)

	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   message.SteamName + " | " + message.SteamId + " has disconnected to the server." ,
		Username:  "Relay",
	}

	discord.WebhookExecute(WebhookId, WebhookSecret, true, params)
}

func queueGroomer() {
	discord, err := discordgo.New("")

	log.Print(WebhookId, WebhookSecret)

	if err != nil {
		log.Fatal("error connecting:", err)
		return
	}

	log.Print("Successfully connected to Discord")

	for {
		rawMessage := <-MessageQueue
		log.Print("Received message from queue: ", string(rawMessage))
		var message MessageStruct

		if err := json.Unmarshal(rawMessage, &message); err != nil {
			log.Printf("Error unmarshalling json: %v", err)
			return
		}

		log.Print(message.Type, message.SteamName, message.SteamId, message.Content)

		switch message.Type{
		case "message":
			sendMessage(discord, message)
		case "connect":
			sendConnectMessage(discord, message)
		case "disconnect":
			sendDisconnectMessage(discord, message)
		}
	}
}
