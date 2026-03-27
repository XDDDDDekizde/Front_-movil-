package repository

import (
	"github.com/MelusineZoe/backend/internal/model"

	"github.com/google/uuid"
)

// UserRepository define las operaciones de usuarios
type UserRepository interface {
	Create(user *model.User) error
	FindByEmail(email string) (*model.User, error)
	FindByID(id uuid.UUID) (*model.User, error)
}

// RoomRepository define las operaciones de salas
type RoomRepository interface {
	Create(room *model.Room) error
	FindByID(id uuid.UUID) (*model.Room, error)
	GetPublicRooms() ([]model.Room, error)
	AddMember(roomID, userID uuid.UUID) error
	IsMember(roomID, userID uuid.UUID) (bool, error)
}

// MessageRepository define las operaciones de mensajes
type MessageRepository interface {
	Create(message *model.Message) error
	GetByRoomID(roomID uuid.UUID, limit int) ([]model.Message, error)
}
