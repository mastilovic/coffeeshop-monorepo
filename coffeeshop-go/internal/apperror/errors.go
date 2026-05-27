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
