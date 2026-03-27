package handler

import (
	"log"
	"net/http"

	"github.com/MelusineZoe/backend/internal/config"
	"github.com/MelusineZoe/backend/internal/model"
	"github.com/MelusineZoe/backend/internal/websocket"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // En producción pon aquí los dominios de tus frontends
	},
}

type WebSocketHandler struct {
	hub *websocket.Hub
	db  *gorm.DB
}

func NewWebSocketHandler(db *gorm.DB, cfg *config.Config) *WebSocketHandler {
	hub := websocket.NewHub(db)
	go hub.Run() // Inicia el hub
	return &WebSocketHandler{hub: hub, db: db}
}

// WebSocketHandler es el endpoint /ws?room_id=xxx&token=yyy (mejor pasar room_id por query)
func WebSocketConnect(c *gin.Context) {
	// Extraer user_id del middleware JWT (ya está en el contexto)
	userIDStr, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Usuario no autenticado"})
		return
	}
	userID := userIDStr.(uuid.UUID) // el middleware lo guarda como interface{}, conviértelo

	roomIDStr := c.Query("room_id")
	if roomIDStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "room_id es requerido"})
		return
	}
	roomID, err := uuid.Parse(roomIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "room_id inválido"})
		return
	}

	// Verificar que la sala existe y que el usuario puede unirse (público o miembro)
	var room model.Room
	if err := h.db.First(&room, "id = ?", roomID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Sala no encontrada"})
		return
	}

	// Para salas privadas: verificar si es miembro (puedes agregar lógica aquí más adelante)

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		log.Println("Error al hacer upgrade:", err)
		return
	}

	client := &websocket.Client{
		ID:     uuid.New(),
		UserID: userID,
		RoomID: roomID,
		Conn:   conn,
		Send:   make(chan []byte, 256),
	}

	// Registrar cliente en el hub
	h.hub.register <- client

	// Goroutine para escribir mensajes al cliente
	go client.writePump()

	// Goroutine para leer mensajes del cliente
	go client.readPump(h.hub, h.db)
}
