package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type RoomType string

const (
	RoomTypePublic  RoomType = "public"
	RoomTypePrivate RoomType = "private"
)

type Room struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	Name      string         `gorm:"size:100;not null" json:"name" validate:"required,min=3,max=100"`
	Type      RoomType       `gorm:"type:varchar(20);not null;default:'public'" json:"type" validate:"required,oneof=public private"`
	CreatedBy uuid.UUID      `gorm:"type:uuid;not null" json:"created_by"`
	CreatedAt time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// Relaciones
	CreatedByUser User      `gorm:"foreignKey:CreatedBy" json:"created_by_user,omitempty"`
	Messages      []Message `gorm:"foreignKey:RoomID" json:"-"`
	Members       []User    `gorm:"many2many:room_members;" json:"members,omitempty"`
}

func (Room) TableName() string {
	return "rooms"
}
