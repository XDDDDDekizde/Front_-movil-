package websocket

import (
	"encoding/json"
	"log"
	"time"

	"github.com/MelusineZoe/backend/internal/model"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"gorm.io/gorm"
)

// Client representa una conexión WebSocket de un usuario
type Client struct {
	ID     uuid.UUID
	UserID uuid.UUID
	RoomID uuid.UUID
	Conn   *websocket.Conn
	Send   chan []byte // canal para enviar mensajes al cliente
}

const (
	// Time allowed to write a message to the peer
	writeWait = 10 * time.Second

	// Time allowed to read the next pong message from the peer
	pongWait = 60 * time.Second

	// Send pings to peer with this period
	pingPeriod = (pongWait * 9) / 10

	// Maximum message size allowed from peer
	maxMessageSize = 2048
)

// writePump envía mensajes al cliente
func (c *Client) writePump() {
	ticker := time.NewTicker(websocket.PingPeriod)
	defer func() {
		ticker.Stop()
		c.Conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.Send:
			c.Conn.SetWriteDeadline(time.Now().Add(websocket.WriteWait))
			if !ok {
				c.Conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.Conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// Agregar mensajes pendientes
			n := len(c.Send)
			for i := 0; i < n; i++ {
				w.Write(<-c.Send)
			}

			if err := w.Close(); err != nil {
				return
			}
		case <-ticker.C:
			c.Conn.SetWriteDeadline(time.Now().Add(websocket.WriteWait))
			if err := c.Conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

// readPump lee mensajes del cliente y los guarda + broadcast
func (c *Client) readPump(hub *websocket.Hub, db *gorm.DB) {
	defer func() {
		hub.unregister <- c
		c.Conn.Close()
	}()

	c.Conn.SetReadLimit(websocket.MaxMessageSize)
	c.Conn.SetReadDeadline(time.Now().Add(websocket.PongWait))
	c.Conn.SetPongHandler(func(string) error {
		c.Conn.SetReadDeadline(time.Now().Add(websocket.PongWait))
		return nil
	})

	for {
		_, msg, err := c.Conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				log.Printf("error: %v", err)
			}
			break
		}

		// Parsear mensaje simple (puedes mejorar con un struct DTO)
		var incoming struct {
			Content string `json:"content"`
		}
		if json.Unmarshal(msg, &incoming) != nil {
			continue
		}

		// Guardar en base de datos
		message := model.Message{
			ID:      uuid.New(),
			RoomID:  c.RoomID,
			UserID:  c.UserID,
			Content: incoming.Content,
		}

		if err := db.Create(&message).Error; err != nil {
			log.Println("Error guardando mensaje:", err)
			continue
		}

		// Cargar username para el broadcast
		var user model.User
		db.First(&user, "id = ?", c.UserID)

		// Crear mensaje para broadcast
		broadcastMsg := &websocket.Message{
			ID:        message.ID,
			RoomID:    message.RoomID,
			UserID:    message.UserID,
			Username:  user.Username,
			Content:   message.Content,
			CreatedAt: message.CreatedAt.Format(time.RFC3339),
		}

		// Enviar al hub para broadcast
		hub.broadcast <- broadcastMsg
	}
}

func toJSON(msg *websocket.Message) []byte {
	data, _ := json.Marshal(msg)
	return data
}
