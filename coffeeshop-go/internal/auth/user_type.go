package auth

import "strings"

// NormalizeUserType maps legacy / numeric user_type values to canonical strings.
// It is defensive against different casings and simple numeric codes.
func NormalizeUserType(raw string) string {
	v := strings.TrimSpace(raw)
	if v == "" {
		return v
	}

	switch strings.ToUpper(v) {
	case "0":
		return "CUSTOMER"
	case "1":
		return "SHOP_OWNER"
	case "CUSTOMER":
		return "CUSTOMER"
	case "SHOP_OWNER":
		return "SHOP_OWNER"
	case "ADMIN":
		return "ADMIN"
	}

	switch strings.ToLower(v) {
	case "customer":
		return "CUSTOMER"
	case "shop_owner":
		return "SHOP_OWNER"
	case "admin":
		return "ADMIN"
	}

	return v
}

