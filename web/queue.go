package main

import (
	"encoding/json"
	"github.com/bwmarrin/discordgo"
	"log"
	"os"
)

var discord *discordgo.Session

type MessageStruct struct {
	Realm     string
	Content   string
	RankColor int
	Avatar    string
	SteamName string
	SteamId   string
	IrisId    string
}

var MessageQueue = make(chan []byte, 100)

var WebhookId string = os.Getenv("WEBHOOK_ID")
var WebhookSecret string = os.Getenv("WEBHOOK_SECRET")

func sendEmbed(discord *discordgo.Session, message MessageStruct) {

	params := &discordgo.WebhookParams{
		Content: "",
		Embeds: []*discordgo.MessageEmbed{
			{
				Title:       "Said on " + message.Realm,
				Description: message.Content,
				Color:       message.RankColor,
				Author: &discordgo.MessageEmbedAuthor{
					URL:     "https://steamcommunity.com/profiles/" + message.SteamId,
					Name:    message.SteamName,
					IconURL: message.Avatar,
				},
			},
		},
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
			panic(err)
		}

		log.Print(message.SteamName, message.SteamId, message.Content)

		sendEmbed(discord, message)
	}
}
