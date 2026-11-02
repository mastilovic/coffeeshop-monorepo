package middleware

import (
	"net/http"
	"strings"
)

func matchOrigin(allowed, origin string) bool {
	if allowed == "*" {
		return true
	}
	if strings.HasSuffix(allowed, "*") {
		return strings.HasPrefix(origin, strings.TrimSuffix(allowed, "*"))
	}
	return allowed == origin
}

func allowAllOrigins(origins []string) bool {
	for _, allowed := range origins {
		if allowed == "*" {
			return true
		}
	}
	return false
}

func CORS(allowedOrigins string) func(http.Handler) http.Handler {
	origins := strings.Split(allowedOrigins, ",")
	for i := range origins {
		origins[i] = strings.TrimSpace(origins[i])
	}
	allowAll := allowAllOrigins(origins)

	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			origin := r.Header.Get("Origin")

			// Not a cross-origin request — pass through without CORS headers.
			if origin == "" {
				next.ServeHTTP(w, r)
				return
			}

			// Determine if this origin is allowed.
			var allowed bool
			if allowAll {
				allowed = true
			} else {
				for _, o := range origins {
					if matchOrigin(o, origin) {
						allowed = true
						break
					}
				}
			}

			if allowed {
				w.Header().Set("Access-Control-Allow-Origin", origin)
				w.Header().Set("Access-Control-Allow-Credentials", "true")
				w.Header().Set("Vary", "Origin")
			}

			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type, X-Request-ID")
			w.Header().Set("Access-Control-Expose-Headers", "X-Request-ID")
			w.Header().Set("Access-Control-Max-Age", "3600")

			if r.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
