package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	Username  string         `gorm:"size:50;unique;not null" json:"username" validate:"required,min=3,max=50"`
	Email     string         `gorm:"size:100;unique;not null" json:"email" validate:"required,email"`
	Password  string         `gorm:"size:255;not null" json:"-"` // nunca devolver la contraseña
	CreatedAt time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`

	// Relaciones
	Messages []Message `gorm:"foreignKey:UserID" json:"-"`
	Rooms    []Room    `gorm:"foreignKey:CreatedBy" json:"-"`
}

func (User) TableName() string {
	return "users"
}
