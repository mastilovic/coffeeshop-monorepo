package apperror

import "net/http"

type AppError struct {
	Message    string `json:"message"`
	StatusCode int    `json:"-"`
}

func (e *AppError) Error() string {
	return e.Message
}

func NotFound(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusNotFound}
}

func BadRequest(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusBadRequest}
}

func Validation(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusUnprocessableEntity}
}

func Unauthorized(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusUnauthorized}
}

func Forbidden(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusForbidden}
}

func Internal(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusInternalServerError}
}

func Conflict(message string) *AppError {
	return &AppError{Message: message, StatusCode: http.StatusConflict}
}

type PaymentRequiredPayload struct {
	Message          string
	RequiredPlan     *string
	RequiredFeatures []string
	Limit            *string
	Used             *int
	Max              *int
}

type PaymentRequiredError struct {
	Message          string   `json:"message"`
	RequiredPlan     *string  `json:"requiredPlan,omitempty"`
	RequiredFeatures []string `json:"requiredFeatures,omitempty"`
	Limit            *string  `json:"limit,omitempty"`
	Used             *int     `json:"used,omitempty"`
	Max              *int     `json:"max,omitempty"`
	StatusCode       int      `json:"-"`
}

func (e *PaymentRequiredError) Error() string {
	return e.Message
}

func PaymentRequired(payload PaymentRequiredPayload) *PaymentRequiredError {
	return &PaymentRequiredError{
		Message:          payload.Message,
		RequiredPlan:     payload.RequiredPlan,
		RequiredFeatures: payload.RequiredFeatures,
		Limit:            payload.Limit,
		Used:             payload.Used,
		Max:              payload.Max,
		StatusCode:       http.StatusPaymentRequired,
	}
}
