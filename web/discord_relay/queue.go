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
	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Content:   message.Data.Content,
		Username:  message.Data.SteamName,
		AvatarURL: message.Data.Avatar,
	}

    _, err := discord.WebhookExecute(WebhookId, WebhookSecret, true, params)

    if err != nil {
        log.Print(err)
    }
}

func sendConnectMessage(discord *discordgo.Session, message MessageStruct) {
	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Username:  message.Data.SteamName,
		AvatarURL: message.Data.Avatar,
		Embeds: []*discordgo.MessageEmbed{
			{
				Description: fmt.Sprintf("%v ***Spawned in the server***", JOIN_EMOJI),
				Color:       0x009900,
			},
		},
	}

    _, err := discord.WebhookExecute(WebhookId, WebhookSecret, true, params)

    if err != nil {
        log.Print(err)
    }
}

func sendDisconnectMessage(discord *discordgo.Session, message MessageStruct) {
	params := &discordgo.WebhookParams{
		AllowedMentions: &discordgo.MessageAllowedMentions{
			Parse: []discordgo.AllowedMentionType{},
		},
		Username:  message.Data.SteamName,
		AvatarURL: message.Data.Avatar,
		Embeds: []*discordgo.MessageEmbed{
			{
				Description: fmt.Sprintf("%v ***Disconnected from the server***", LEAVE_EMOJI),
				Color:       0x167116,
			},
		},
	}

    _, err := discord.WebhookExecute(WebhookId, WebhookSecret, true, params)

    if err != nil {
        log.Print(err)
    }
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
