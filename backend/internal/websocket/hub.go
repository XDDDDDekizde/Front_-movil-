package websocket

import (
	"log"
	"sync"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Hub mantiene todas las conexiones activas y maneja el broadcast
type Hub struct {
	clients    map[uuid.UUID]*Client          // todos los clientes conectados (por Client ID)
	rooms      map[uuid.UUID]map[*Client]bool // clientes por sala
	broadcast  chan *Message                  // canal para mensajes entrantes
	register   chan *Client                   // registrar nuevo cliente
	unregister chan *Client                   // desconectar cliente
	db         *gorm.DB
	mu         sync.RWMutex
}

type Message struct {
	ID        uuid.UUID `json:"id"`
	RoomID    uuid.UUID `json:"room_id"`
	UserID    uuid.UUID `json:"user_id"`
	Username  string    `json:"username"`
	Content   string    `json:"content"`
	CreatedAt string    `json:"created_at"`
}

func NewHub(db *gorm.DB) *Hub {
	return &Hub{
		clients:    make(map[uuid.UUID]*Client),
		rooms:      make(map[uuid.UUID]map[*Client]bool),
		broadcast:  make(chan *Message),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		db:         db,
	}
}

// Run inicia el hub en un goroutine (se llama desde main)
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			h.clients[client.ID] = client
			if h.rooms[client.RoomID] == nil {
				h.rooms[client.RoomID] = make(map[*Client]bool)
			}
			h.rooms[client.RoomID][client] = true
			h.mu.Unlock()

			log.Printf("Cliente conectado: %s en sala %s", client.UserID, client.RoomID)

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client.ID]; ok {
				delete(h.clients, client.ID)
				if roomClients, ok := h.rooms[client.RoomID]; ok {
					delete(roomClients, client)
					if len(roomClients) == 0 {
						delete(h.rooms, client.RoomID)
					}
				}
				close(client.Send)
			}
			h.mu.Unlock()

			log.Printf("Cliente desconectado: %s", client.UserID)

		case message := <-h.broadcast:
			h.mu.RLock()
			if clients, ok := h.rooms[message.RoomID]; ok {
				for client := range clients {
					select {
					case client.Send <- toJSON(message):
					default:
						close(client.Send)
						delete(clients, client)
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}
