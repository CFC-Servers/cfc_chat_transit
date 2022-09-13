package voice

import (
	"encoding/json"
	"github.com/bwmarrin/discordgo"
	"log"
	"sync"
	"time"
)

type Session struct {
	SteamId   string
	SteamName string
	Message   string
	MessageId string
	FileName  string
	Avatar    string
	Finished  bool
}

type Operation struct {
	Session *Session
}

type Manager struct {
	Sessions    map[string]*Session
	Operations  []*Operation
	discord     *discordgo.Session
	opmutex     *sync.Mutex
	sendMessage func(*discordgo.Session, *Session) string
}

// MessageData The "Content" key of the Event that comes into the Main package
type MessageData struct {
	Message   string `json:"transcript"`
	FileName  string `json:"file_name"`
	SessionID string `json:"session_id"`
	IsFinal   bool   `json:"is_final"`
}

func (v *Manager) runSendQueue() {
	bucket := v.discord.Ratelimiter.GetBucket("voiceTranscriptions")

	wait := func() {
		time.Sleep(time.Millisecond * 100)
	}

	for {
		wait()

		// This should be a blocking call
		// Unblocks when bucket has bandwidth
		v.discord.Ratelimiter.LockBucketObject(bucket).Unlock()

		if len(v.Operations) == 0 {
			wait()
			continue
		}

		v.opmutex.Lock()

		var firstOperation *Operation
		firstOperation, v.Operations = v.Operations[0], v.Operations[1:]

		session := firstOperation.Session
		description := session.Message

		if len(description) == 0 {
			// What is this? Why are you showing this to me
			v.opmutex.Unlock()
			continue
		}

		messageId := v.sendMessage(v.discord, session)

		if len(messageId) == 0 {
			// Failed to send/update message, send to back of queue
			v.Operations = append(v.Operations, firstOperation)
			v.opmutex.Unlock()
			continue
		} else {
			session.MessageId = messageId
		}

		v.opmutex.Unlock()
	}
}

func (v *Manager) ReceiveVoiceTranscript(steamId string, steamName string, avatar string, data string) {
	messageData := MessageData{}
	err := json.Unmarshal([]byte(data), &messageData)
	if err != nil {
		log.Printf("Error parsing voice message: %v", err)
		return
	}

	newMessage := messageData.Message
	isFinal := messageData.IsFinal
	fileName := messageData.FileName
	sessionId := messageData.SessionID

	session, ok := v.Sessions[sessionId]

	if !ok {
		session = &Session{
			SteamId:   steamId,
			SteamName: steamName,
			Message:   newMessage,
			MessageId: "",
			Finished:  isFinal,
			Avatar:    avatar,
			FileName:  fileName,
		}

		v.Sessions[sessionId] = session
	} else {
		session.Message = newMessage
		session.Finished = isFinal
		session.FileName = fileName
	}

	if isFinal {
		// Final message for this transcription, we can stop tracking it
		// TODO: do I use delete here?
		v.Sessions[sessionId] = nil
	}

	v.opmutex.Lock()
	defer v.opmutex.Unlock()

	if ok {
		// Session already existed for sessionID
		// Do we already have a pending Operation?
		for _, operation := range v.Operations {
			if operation.Session == session {
				// If so, we don't need to add another operation
				return
			}
		}
	}

	v.Operations = append(v.Operations, &Operation{
		Session: session,
	})
}

func NewManager(discord *discordgo.Session, sendMessage func(*discordgo.Session, *Session) string) *Manager {
	manager := &Manager{
		Sessions:    make(map[string]*Session),
		Operations:  make([]*Operation, 0),
		discord:     discord,
		opmutex:     &sync.Mutex{},
		sendMessage: sendMessage,
	}

	go manager.runSendQueue()
	return manager
}
