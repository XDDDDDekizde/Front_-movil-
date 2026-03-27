package database

import (
	"fmt"
	"log"

	"github.com/MelusineZoe/backend/internal/config"
	"github.com/MelusineZoe/backend/internal/model"
	impl "github.com/MelusineZoe/backend/internal/repository/impl"

	"github.com/MelusineZoe/backend/internal/repository"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Connect(cfg *config.Config) *gorm.DB {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=UTC",
		cfg.DBHost,
		cfg.DBUser,
		cfg.DBPassword,
		cfg.DBName,
		cfg.DBPort,
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Error al conectar con la base de datos:", err)
	}

	log.Println("✅ Conexión a PostgreSQL exitosa")
	return db
}

func AutoMigrate(db *gorm.DB) {
	err := db.AutoMigrate(model.Models...)
	if err != nil {
		log.Fatal("Error en AutoMigrate:", err)
	}
	log.Println("✅ Migración de tablas completada")
}

// NewRepositories crea todas las implementaciones de repositories
type Repositories struct {
	User    repository.UserRepository
	Room    repository.RoomRepository
	Message repository.MessageRepository
}

func NewRepositories(db *gorm.DB) *Repositories {
	return &Repositories{
		User:    impl.NewUserRepository(db),
		Room:    impl.NewRoomRepository(db),
		Message: impl.NewMessageRepository(db),
	}
}
