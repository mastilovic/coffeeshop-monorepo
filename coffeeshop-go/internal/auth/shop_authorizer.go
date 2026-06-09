package auth

import (
	"context"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/middleware"
	"github.com/mastilovic/coffeeshop-go/internal/model"
	"gorm.io/gorm"
)

type ShopAuthorizer struct {
	db             *gorm.DB
	currentUserSvc *CurrentUserService
}

func NewShopAuthorizer(db *gorm.DB, currentUserSvc *CurrentUserService) *ShopAuthorizer {
	return &ShopAuthorizer{db: db, currentUserSvc: currentUserSvc}
}

func (a *ShopAuthorizer) IsAdmin(ctx context.Context) bool {
	claims := middleware.GetUserClaims(ctx)
	if claims == nil {
		return false
	}
	for _, role := range claims.Roles {
		if role == "admin" {
			return true
		}
	}
	return false
}

func (a *ShopAuthorizer) IsShopOwner(ctx context.Context, shopID string) bool {
	user := a.currentUserSvc.GetCurrentUser(ctx)
	if user == nil {
		return false
	}
	var count int64
	a.db.WithContext(ctx).
		Model(&model.UserShop{}).
		Where("user_id = ? AND shop_id = ? AND relationship_type = ?", user.ID, shopID, model.RelationshipTypeOwner).
		Count(&count)
	return count > 0
}

func (a *ShopAuthorizer) IsShopOwnerOrEmployee(ctx context.Context, shopID string) bool {
	user := a.currentUserSvc.GetCurrentUser(ctx)
	if user == nil {
		return false
	}
	var count int64
	a.db.WithContext(ctx).
		Model(&model.UserShop{}).
		Where("user_id = ? AND shop_id = ? AND relationship_type IN ?",
			user.ID, shopID, []string{model.RelationshipTypeOwner, model.RelationshipTypeEmployee}).
		Count(&count)
	return count > 0
}

func (a *ShopAuthorizer) RequireShopOwnerOrAdmin(ctx context.Context, shopID string) error {
	if a.IsAdmin(ctx) || a.IsShopOwner(ctx, shopID) {
		return nil
	}
	return apperror.Forbidden("Only the shop owner or an admin can perform this action")
}

func (a *ShopAuthorizer) RequireShopOwnerOrEmployeeOrAdmin(ctx context.Context, shopID string) error {
	if a.IsAdmin(ctx) || a.IsShopOwnerOrEmployee(ctx, shopID) {
		return nil
	}
	return apperror.Forbidden("Only the shop owner, an employee, or an admin can perform this action")
}

func (a *ShopAuthorizer) RequireShopOwnerOrAdminForUser(ctx context.Context, shopID string) (*User, error) {
	user, err := a.currentUserSvc.RequireCurrentUser(ctx)
	if err != nil {
		return nil, err
	}

	if a.IsAdmin(ctx) || a.IsShopOwner(ctx, shopID) {
		return user, nil
	}
	return nil, apperror.Forbidden("Only the shop owner or an admin can perform this action")
}

func (a *ShopAuthorizer) RequireShopOwnerOrEmployeeOrAdminForUser(ctx context.Context, shopID string) (*User, error) {
	user, err := a.currentUserSvc.RequireCurrentUser(ctx)
	if err != nil {
		return nil, err
	}

	if a.IsAdmin(ctx) || a.IsShopOwnerOrEmployee(ctx, shopID) {
		return user, nil
	}
	return nil, apperror.Forbidden("Only the shop owner, an employee, or an admin can perform this action")
}
