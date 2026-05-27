package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/mastilovic/coffeeshop-go/internal/util"
)

var serbiaCities = []string{
	"Aleksinac", "Apatin", "Aranđelovac", "Bačka Palanka", "Bečej",
	"Beograd", "Bor", "Čačak", "Dimitrovgrad", "Inđija",
	"Jagodina", "Kanjiža", "Kikinda", "Kraljevo", "Kragujevac",
	"Kruševac", "Kula", "Leskovac", "Loznica", "Negotin",
	"Niš", "Novi Pazar", "Novi Sad", "Pančevo", "Paraćin",
	"Pirot", "Požarevac", "Priboj", "Prijepolje", "Prokuplje",
	"Ruma", "Senta", "Sjenica", "Smederevo", "Sombor",
	"Sremska Mitrovica", "Subotica", "Surdulica", "Šabac", "Svilajnac",
	"Tutin", "Užice", "Valjevo", "Vlasotince", "Vranje",
	"Vrbas", "Vršac", "Zaječar", "Zrenjanin", "Ćuprija",
}

type ReferenceHandler struct{}

func NewReferenceHandler() *ReferenceHandler {
	return &ReferenceHandler{}
}

func (h *ReferenceHandler) GetSerbiaCities(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")

	var result []string
	if q == "" || strings.TrimSpace(q) == "" {
		result = serbiaCities
	} else {
		normalizedQuery := util.NormalizeForSearch(q)
		for _, city := range serbiaCities {
			if strings.Contains(util.NormalizeForSearch(city), normalizedQuery) {
				result = append(result, city)
			}
		}
		if result == nil {
			result = []string{}
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}
