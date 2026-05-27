package middleware

import (
	"net/http"

	"github.com/getsentry/sentry-go"
)

func SentryCapture(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hub := sentry.CurrentHub().Clone()
		hub.Scope().SetRequest(r)

		defer func() {
			if rec := recover(); rec != nil {
				hub.RecoverWithContext(r.Context(), rec)
				panic(rec)
			}
		}()

		next.ServeHTTP(w, r)
	})
}
