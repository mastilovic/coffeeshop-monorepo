package auth

import (
	"context"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/middleware"
	"gorm.io/gorm"
)

type User struct {
	ID              string `gorm:"column:id;primaryKey" json:"id"`
	Name            string `gorm:"column:name" json:"name"`
	Username        string `gorm:"column:username" json:"username"`
	Email           string `gorm:"column:email" json:"email"`
	Password        string `gorm:"column:password" json:"-"`
	UserType        string `gorm:"column:user_type" json:"userType"`
	KeycloakSubject string `gorm:"column:keycloak_subject" json:"-"`
}

func (User) TableName() string {
	return "users"
}

type CurrentUserService struct {
	db *gorm.DB
}

func NewCurrentUserService(db *gorm.DB) *CurrentUserService {
	return &CurrentUserService{db: db}
}

func (s *CurrentUserService) RequireCurrentUser(ctx context.Context) (*User, error) {
	claims := middleware.GetUserClaims(ctx)
	if claims == nil {
		return nil, apperror.Unauthorized("Bearer token required")
	}

	var user User
	result := s.db.Where("keycloak_subject = ?", claims.Subject).First(&user)
	if result.Error != nil {
		return nil, apperror.NotFound("No local profile linked to this account; complete registration first")
	}
	return &user, nil
}

func (s *CurrentUserService) GetCurrentUser(ctx context.Context) *User {
	claims := middleware.GetUserClaims(ctx)
	if claims == nil {
		return nil
	}

	var user User
	result := s.db.Where("keycloak_subject = ?", claims.Subject).First(&user)
	if result.Error != nil {
		return nil
	}
	return &user
}
