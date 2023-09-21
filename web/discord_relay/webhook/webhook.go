package webhook

import (
	"fmt"
	"os"
	"sync"
)

type WebhookInfo struct {
	ID     string
	Secret string
}

var cache = make(map[string]*WebhookInfo)
var mu sync.Mutex

func Get(realm string) *WebhookInfo {
	mu.Lock()
	defer mu.Unlock()

	if info, exists := cache[realm]; exists {
		return info
	}

	// Expects cfc3_WEBHOOK_ID / cfc3_WEBHOOK_SECRET
	idEnv := fmt.Sprintf("%s_WEBHOOK_ID", realm)
	secretEnv := fmt.Sprintf("%s_WEBHOOK_SECRET", realm)

	id := os.Getenv(idEnv)
	secret := os.Getenv(secretEnv)

	info := &WebhookInfo{
		ID:     id,
		Secret: secret,
	}

	cache[realm] = info
	return info
}
