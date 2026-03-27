package impl

import (
	"github.com/MelusineZoe/backend/internal/model"
	"github.com/MelusineZoe/backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type roomRepository struct {
	db *gorm.DB
}

func NewRoomRepository(db *gorm.DB) repository.RoomRepository {
	return &roomRepository{db: db}
}

func (r *roomRepository) Create(room *model.Room) error {
	return r.db.Create(room).Error
}

func (r *roomRepository) FindByID(id uuid.UUID) (*model.Room, error) {
	var room model.Room
	err := r.db.Preload("CreatedByUser").First(&room, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &room, nil
}

func (r *roomRepository) GetPublicRooms() ([]model.Room, error) {
	var rooms []model.Room
	err := r.db.Where("type = ?", model.RoomTypePublic).Find(&rooms).Error
	return rooms, err
}

func (r *roomRepository) AddMember(roomID, userID uuid.UUID) error {
	member := model.RoomMember{
		RoomID: roomID,
		UserID: userID,
	}
	return r.db.Create(&member).Error
}

func (r *roomRepository) IsMember(roomID, userID uuid.UUID) (bool, error) {
	var count int64
	err := r.db.Model(&model.RoomMember{}).
		Where("room_id = ? AND user_id = ?", roomID, userID).
		Count(&count).Error
	return count > 0, err
}
