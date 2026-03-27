package service

import (
	"errors"
	"time"

	"github.com/MelusineZoe/backend/internal/dto"
	"github.com/MelusineZoe/backend/internal/model"
	"github.com/MelusineZoe/backend/internal/repository"

	"github.com/google/uuid"
)

type RoomService struct {
	roomRepo    repository.RoomRepository
	messageRepo repository.MessageRepository
}

func NewRoomService(roomRepo repository.RoomRepository, messageRepo repository.MessageRepository) *RoomService {
	return &RoomService{
		roomRepo:    roomRepo,
		messageRepo: messageRepo,
	}
}

func (s *RoomService) CreateRoom(userID uuid.UUID, req dto.CreateRoomRequest) (*dto.RoomResponse, error) {
	room := &model.Room{
		ID:        uuid.New(),
		Name:      req.Name,
		Type:      req.Type,
		CreatedBy: userID,
	}

	if err := s.roomRepo.Create(room); err != nil {
		return nil, err
	}

	// Si es sala privada, agregar automáticamente al creador como miembro
	if req.Type == model.RoomTypePrivate {
		if err := s.roomRepo.AddMember(room.ID, userID); err != nil {
			return nil, err
		}
	}

	return &dto.RoomResponse{
		ID:        room.ID,
		Name:      room.Name,
		Type:      room.Type,
		CreatedBy: room.CreatedBy,
		CreatedAt: room.CreatedAt.Format(time.RFC3339),
	}, nil
}

func (s *RoomService) GetPublicRooms() ([]dto.RoomResponse, error) {
	rooms, err := s.roomRepo.GetPublicRooms()
	if err != nil {
		return nil, err
	}

	var responses []dto.RoomResponse
	for _, r := range rooms {
		responses = append(responses, dto.RoomResponse{
			ID:        r.ID,
			Name:      r.Name,
			Type:      r.Type,
			CreatedBy: r.CreatedBy,
			CreatedAt: r.CreatedAt.Format(time.RFC3339),
		})
	}
	return responses, nil
}

func (s *RoomService) JoinRoom(userID, roomID uuid.UUID) error {
	room, err := s.roomRepo.FindByID(roomID)
	if err != nil {
		return errors.New("sala no encontrada")
	}

	if room.Type == model.RoomTypePrivate {
		isMember, err := s.roomRepo.IsMember(roomID, userID)
		if err != nil {
			return err
		}
		if isMember {
			return nil // ya es miembro
		}
		return s.roomRepo.AddMember(roomID, userID)
	}

	// Salas públicas: no se necesita guardar miembro
	return nil
}

func (s *RoomService) GetRoomHistory(roomID uuid.UUID, limit int) ([]dto.MessageResponse, error) {
	messages, err := s.messageRepo.GetByRoomID(roomID, limit)
	if err != nil {
		return nil, err
	}

	var responses []dto.MessageResponse
	for _, m := range messages {
		responses = append(responses, dto.MessageResponse{
			ID:        m.ID,
			RoomID:    m.RoomID,
			UserID:    m.UserID,
			Username:  m.User.Username,
			Content:   m.Content,
			CreatedAt: m.CreatedAt.Format(time.RFC3339),
		})
	}

	// Los mensajes ya vienen ordenados ASC gracias al repository
	return responses, nil
}
