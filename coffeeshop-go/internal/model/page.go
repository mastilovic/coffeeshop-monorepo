package model

type PageResponse[T any] struct {
	Content       []T   `json:"content"`
	Page          int   `json:"page"`
	Size          int   `json:"size"`
	TotalElements int64 `json:"totalElements"`
	TotalPages    int   `json:"totalPages"`
}

func NewPageResponse[T any](content []T, page, size int, totalElements int64) PageResponse[T] {
	totalPages := 0
	if size > 0 {
		totalPages = int((totalElements + int64(size) - 1) / int64(size))
	}
	if content == nil {
		content = []T{}
	}
	return PageResponse[T]{
		Content:       content,
		Page:          page,
		Size:          size,
		TotalElements: totalElements,
		TotalPages:    totalPages,
	}
}
