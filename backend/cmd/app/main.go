package main

import (
	"log"

	"github.com/MelusineZoe/backend/internal/config"
	"github.com/MelusineZoe/backend/internal/database"
	"github.com/MelusineZoe/backend/internal/handler"
	"github.com/MelusineZoe/backend/internal/middleware"

	"github.com/gin-gonic/gin"
)

func main() {
	cfg := config.LoadConfig()

	db := database.Connect(cfg)
	database.AutoMigrate(db)

	// Crear repositories
	repos := database.NewRepositories(db)

	// Crear handlers
	authHandler := handler.NewAuthHandler(repos.User, cfg)
	roomHandler := handler.NewRoomHandler(repos.Room, repos.Message)

	r := gin.Default()

	// Middlewares globales
	r.Use(middleware.CORS())
	r.Use(middleware.Logger())

	// Rutas públicas de autenticación
	r.POST("/api/auth/register", authHandler.Register)
	r.POST("/api/auth/login", authHandler.Login)

	// Rutas protegidas con JWT
	protected := r.Group("/api")
	protected.Use(middleware.JWTAuth(cfg.JWTSecret))
	{
		protected.POST("/rooms", roomHandler.CreateRoom)
		protected.GET("/rooms/public", roomHandler.GetPublicRooms)
		protected.POST("/rooms/join", roomHandler.JoinRoom)
		protected.GET("/rooms/:room_id/messages", roomHandler.GetRoomHistory)

		// Ruta de prueba
		protected.GET("/me", func(c *gin.Context) {
			c.JSON(200, gin.H{"message": "Estás autenticado correctamente"})
		})
	}

	// WebSocket protegido
	r.GET("/ws", middleware.JWTAuth(cfg.JWTSecret), handler.WebSocketConnect)

	log.Printf("🚀 Servidor backend corriendo en http://localhost:%s", cfg.ServerPort)
	if err := r.Run(":" + cfg.ServerPort); err != nil {
		log.Fatal("Error al iniciar el servidor:", err)
	}
}
