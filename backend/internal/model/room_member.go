package model

import (
	"time"

	"github.com/google/uuid"
)

type RoomMember struct {
	RoomID   uuid.UUID `gorm:"type:uuid;primaryKey" json:"room_id"`
	UserID   uuid.UUID `gorm:"type:uuid;primaryKey" json:"user_id"`
	JoinedAt time.Time `gorm:"autoCreateTime" json:"joined_at"`

	// Relaciones (opcional, para precarga)
	Room Room `gorm:"foreignKey:RoomID" json:"-"`
	User User `gorm:"foreignKey:UserID" json:"-"`
}

func (RoomMember) TableName() string {
	return "room_members"
}
