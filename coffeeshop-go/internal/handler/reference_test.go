package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/go-chi/chi/v5"
)

func TestGetSerbiaCities_All(t *testing.T) {
	r := chi.NewRouter()
	h := NewReferenceHandler()
	r.Get("/api/v2/reference/serbia-cities", h.GetSerbiaCities)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/reference/serbia-cities", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var cities []string
	json.NewDecoder(w.Body).Decode(&cities)
	if len(cities) != 50 {
		t.Errorf("expected 50 cities, got %d", len(cities))
	}
}

func TestGetSerbiaCities_Search(t *testing.T) {
	r := chi.NewRouter()
	h := NewReferenceHandler()
	r.Get("/api/v2/reference/serbia-cities", h.GetSerbiaCities)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/reference/serbia-cities?q=nis", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var cities []string
	json.NewDecoder(w.Body).Decode(&cities)
	if len(cities) == 0 {
		t.Error("expected at least one city matching 'nis'")
	}

	found := false
	for _, c := range cities {
		if c == "Niš" {
			found = true
			break
		}
	}
	if !found {
		t.Error("expected Niš in results for query 'nis'")
	}
}

func TestGetSerbiaCities_SearchSerbian(t *testing.T) {
	r := chi.NewRouter()
	h := NewReferenceHandler()
	r.Get("/api/v2/reference/serbia-cities", h.GetSerbiaCities)

	req := httptest.NewRequest(http.MethodGet, "/api/v2/reference/serbia-cities?q=čač", nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	var cities []string
	json.NewDecoder(w.Body).Decode(&cities)
	if len(cities) == 0 {
		t.Error("expected Čačak in results for query 'čač'")
	}
}
