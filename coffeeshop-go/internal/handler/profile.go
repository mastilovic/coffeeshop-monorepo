package handler

import (
	"encoding/json"
	"net/http"

	"github.com/mastilovic/coffeeshop-go/internal/apperror"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
)

type ProfileHandler struct {
	currentUser *auth.CurrentUserService
}

func NewProfileHandler(currentUser *auth.CurrentUserService) *ProfileHandler {
	return &ProfileHandler{currentUser: currentUser}
}

func (h *ProfileHandler) GetProfile(w http.ResponseWriter, r *http.Request) {
	user, err := h.currentUser.RequireCurrentUser(r.Context())
	if err != nil {
		apperror.WriteError(w, err)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"id":       user.ID,
		"name":     user.Name,
		"username": user.Username,
		"email":    user.Email,
		"userType": auth.NormalizeUserType(user.UserType),
	})
}
