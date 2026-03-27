package dto

import (
	"github.com/MelusineZoe/backend/internal/model"

	"github.com/google/uuid"
)

type CreateRoomRequest struct {
	Name string         `json:"name" validate:"required,min=3,max=100"`
	Type model.RoomType `json:"type" validate:"required,oneof=public private"`
}

type RoomResponse struct {
	ID        uuid.UUID      `json:"id"`
	Name      string         `json:"name"`
	Type      model.RoomType `json:"type"`
	CreatedBy uuid.UUID      `json:"created_by"`
	CreatedAt string         `json:"created_at"`
}

type JoinRoomRequest struct {
	RoomID uuid.UUID `json:"room_id" validate:"required"`
}
