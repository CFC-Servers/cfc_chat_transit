package main

import (
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var upgrader = websocket.Upgrader{}

func relay(w http.ResponseWriter, r *http.Request) {
	// TODO: Prevent multiple clients here

	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}

	defer c.Close()

	for {
		_, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}

		select {
		case MessageQueue <- message:
			// okay
		default:
			log.Print("Queue was full, could not add message!", string(message))
		}
	}
}
