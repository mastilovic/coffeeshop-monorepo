package middleware

import (
	"net/http"
	"strings"
)

// PublicBearerSkip mirrors Java's PublicEndpointBearerTokenResolver.
// On public endpoints, invalid Bearer tokens are silently ignored (no 401).
// On protected endpoints, the request passes through to the JWT middleware.
func PublicBearerSkip(jwtMw *JWTMiddleware) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if isPublicEndpoint(r) {
				jwtMw.OptionalAuth(next).ServeHTTP(w, r)
				return
			}
			jwtMw.Authenticate(next).ServeHTTP(w, r)
		})
	}
}

func isPublicEndpoint(r *http.Request) bool {
	path := r.URL.Path
	method := r.Method

	if strings.HasPrefix(path, "/health") {
		return true
	}

	if method == http.MethodGet && path == "/api/v2/shop" {
		page := r.URL.Query().Get("page")
		return page == ""
	}

	if method == http.MethodGet && strings.HasPrefix(path, "/api/v2/") {
		return path != "/api/v2/profile" &&
			path != "/api/v2/reservation-request" &&
			!strings.HasPrefix(path, "/api/v2/reservation-request/") &&
			path != "/api/v2/shop/mine" &&
			path != "/api/v2/shop"
	}

	if method == http.MethodPost {
		switch path {
		case "/api/v2/auth/login", "/api/v2/auth/register",
			"/api/v2/auth/refresh", "/api/v2/auth/logout":
			return true
		}
	}

	return false
}
