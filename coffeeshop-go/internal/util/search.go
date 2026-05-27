package util

import (
	"strings"
	"unicode"

	"golang.org/x/text/unicode/norm"
)

var serbianReplacements = []struct {
	from string
	to   string
}{
	{"đ", "dj"}, {"Đ", "dj"},
	{"č", "c"}, {"Č", "c"},
	{"ć", "c"}, {"Ć", "c"},
	{"š", "s"}, {"Š", "s"},
	{"ž", "z"}, {"Ž", "z"},
}

func NormalizeForSearch(value string) string {
	if value == "" {
		return ""
	}

	result := value
	for _, r := range serbianReplacements {
		result = strings.ReplaceAll(result, r.from, r.to)
	}

	result = strings.ToLower(result)

	decomposed := norm.NFD.String(result)

	var builder strings.Builder
	for _, r := range decomposed {
		if !unicode.Is(unicode.Mn, r) {
			builder.WriteRune(r)
		}
	}
	return builder.String()
}
