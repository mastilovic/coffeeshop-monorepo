package util

import "testing"

func TestNormalizeForSearch(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"", ""},
		{"Beograd", "beograd"},
		{"Niš", "nis"},
		{"Čačak", "cacak"},
		{"Đorđe", "djordje"},
		{"ŠABAC", "sabac"},
		{"Žitorađa", "zitoradja"},
		{"Café", "cafe"},
		{"Ćuprija", "cuprija"},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			result := NormalizeForSearch(tt.input)
			if result != tt.expected {
				t.Errorf("NormalizeForSearch(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}
