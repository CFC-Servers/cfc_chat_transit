package main

import (
	"encoding/json"
	"github.com/bwmarrin/discordgo"
	"strconv"
	"log"
	"os"
)

var discord *discordgo.Session

type MessageStruct struct {
	Realm     string
	Content   string
	RankColor string
	Avatar    string
	SteamName string
	SteamId   string
	IrisId    string
}

var MessageQueue = make(chan []byte, 100)

var WebhookId string = os.Getenv("WEBHOOK_ID")
var WebhookSecret string = os.Getenv("WEBHOOK_SECRET")

func sendEmbed(discord *discordgo.Session, message MessageStruct) {

    color, err := strconv.Atoi(message.RankColor)

    if err != nil {
        log.Fatal("Couldn't convert given color into an int!", err)
        return
    }

	params := &discordgo.WebhookParams{
		Content: "",
		Embeds: []*discordgo.MessageEmbed{
			{
				Title:       "Said on " + message.Realm,
				Description: message.Content,
				Color:       color,
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
