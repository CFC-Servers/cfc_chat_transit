package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/bwmarrin/discordgo"
)

var discord *discordgo.Session

type MessageStruct struct {
	Type string
	Data MessageData
}

type MessageData struct {
	Realm     string
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

const (
	JOIN_EMOJI  = "<:green_cross_cir:654105378933571594>"
	LEAVE_EMOJI = "<:circle_red:855605697978957854>"
)

func sendMessage(discord *discordgo.Session, message MessageStruct) {
	//profileUrl := "https://steamcommunity.com/profiles/" + message.SteamId
	//joinUrl := "https://cfcservers.org/" + strings.ToLower(message.Realm) + "/join"
	//contentBuilder.WriteString(fmt.Sprintf("[%v](<%v>) ", JOIN_EMOJI, joinUrl))
	//contentBuilder.WriteString(fmt.Sprintf("[%v](<%v>) ", STEAM_EMOJI, profileUrl))

	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   message.Data.Content,
		Username:  message.Data.SteamName,
		AvatarURL: message.Data.Avatar,
	}

	discord.WebhookExecute(WebhookId, WebhookSecret, true, params)
}

func sendConnectMessage(discord *discordgo.Session, message MessageStruct) {
	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:  fmt.Sprintf("%v %v | %v has connected to the server", JOIN_EMOJI, message.Data.SteamName, message.Data.SteamId),
		Username: "Relay",
	}

	discord.WebhookExecute(WebhookId, WebhookSecret, true, params)
}

func sendDisconnectMessage(discord *discordgo.Session, message MessageStruct) {
	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:  fmt.Sprintf("%v %v | %v has disconnected from the server", LEAVE_EMOJI, message.Data.SteamName, message.Data.SteamId),
		Username: "Relay",
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

		log.Println(message.Type, message.Data.SteamName, message.Data.SteamId, message.Data.Content)

		switch message.Type {
		case "message":
			sendMessage(discord, message)
		case "connect":
			sendConnectMessage(discord, message)
		case "disconnect":
			sendDisconnectMessage(discord, message)
		}
	}
}
