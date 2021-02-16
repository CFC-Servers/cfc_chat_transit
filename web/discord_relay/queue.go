package main

import (
	"encoding/json"
	"fmt"
	"github.com/bwmarrin/discordgo"
	"log"
	"os"
	"strings"
)

var discord *discordgo.Session

type MessageStruct struct {
	Realm     string
	Content   string
	RankColor float64
	Avatar    string
	SteamName string
	SteamId   string
	IrisId    string
}

var MessageQueue = make(chan []byte, 100)

var WebhookId string = os.Getenv("WEBHOOK_ID")
var WebhookSecret string = os.Getenv("WEBHOOK_SECRET")

const (
	JOIN_EMOJI  = "🎮"
	STEAM_EMOJI = "<:steam:675847621054824455>"
)

func sendMessage(discord *discordgo.Session, message MessageStruct) {
	profileUrl := "https://steamcommunity.com/profiles/" + message.SteamId
	joinUrl := "https://cfcservers.org/" + strings.ToLower(message.Realm) + "/join"

	var contentBuilder strings.Builder
	contentBuilder.WriteString(message.Content)
	contentBuilder.WriteByte('\n')
	contentBuilder.WriteString(fmt.Sprintf("[%v](%v)", JOIN_EMOJI, joinUrl))
	contentBuilder.WriteString(fmt.Sprintf("[%v](%v)", STEAM_EMOJI, profileUrl))

	params := &discordgo.WebhookParams{
		Content:   contentBuilder.String(),
		Username:  fmt.Sprintf("[%v] %v", strings.ToUpper(message.Realm), message.SteamName),
		AvatarURL: message.Avatar,
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

		log.Print(message.SteamName, message.SteamId, message.Content)

		sendMessage(discord, message)
	}
}
