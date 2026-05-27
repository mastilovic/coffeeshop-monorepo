package main

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/getsentry/sentry-go"
	"github.com/go-chi/chi/v5"
	"github.com/mastilovic/coffeeshop-go/internal/auth"
	"github.com/mastilovic/coffeeshop-go/internal/config"
	"github.com/mastilovic/coffeeshop-go/internal/handler"
	"github.com/mastilovic/coffeeshop-go/internal/middleware"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo})))

	cfg, err := config.Load()
	if err != nil {
		slog.Error("failed to load config", "error", err)
		os.Exit(1)
	}

	if cfg.SentryDSN != "" {
		if err := sentry.Init(sentry.ClientOptions{
			Dsn:              cfg.SentryDSN,
			TracesSampleRate: 0.2,
		}); err != nil {
			slog.Error("failed to initialize Sentry", "error", err)
		} else {
			slog.Info("sentry initialized")
		}
		defer sentry.Flush(2 * time.Second)
	}

	db, err := connectDB(cfg.DatabaseURL)
	if err != nil {
		slog.Error("failed to connect to database", "error", err)
		os.Exit(1)
	}

	r := setupRouter(db, cfg)

	srv := &http.Server{
		Addr:         fmt.Sprintf(":%d", cfg.Port),
		Handler:      r,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		slog.Info("starting server", "port", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server failed", "error", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("shutting down server")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		slog.Error("server forced shutdown", "error", err)
	}
	slog.Info("server stopped")
}

func connectDB(dsn string) (*gorm.DB, error) {
	var db *gorm.DB
	var err error

	for i := range 5 {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Silent),
		})
		if err == nil {
			sqlDB, dbErr := db.DB()
			if dbErr != nil {
				return nil, dbErr
			}
			sqlDB.SetMaxOpenConns(25)
			sqlDB.SetMaxIdleConns(5)
			sqlDB.SetConnMaxLifetime(5 * time.Minute)
			return db, nil
		}
		slog.Warn("database connection attempt failed, retrying", "attempt", i+1, "error", err)
		time.Sleep(2 * time.Second)
	}
	return nil, fmt.Errorf("failed to connect after retries: %w", err)
}

func setupRouter(db *gorm.DB, cfgs ...config.Config) *chi.Mux {
	r := chi.NewRouter()

	var resolvedCfg config.Config
	if len(cfgs) > 0 {
		resolvedCfg = cfgs[0]
	} else {
		resolvedCfg = config.Config{
			CORSAllowedOrigins:    "http://localhost:4200",
			KeycloakJWTIssuerURI:  "http://localhost:8080/realms/coffeeshop",
			KeycloakBaseURL:       "http://localhost:8080",
			KeycloakRealm:         "coffeeshop",
			KeycloakClientID:      "coffeeshop-backend",
			KeycloakClientSecret:  "local-backend-secret",
			KeycloakAdminUser:     "admin",
			KeycloakAdminPassword: "admin",
		}
	}

	corsOrigins := resolvedCfg.CORSAllowedOrigins
	jwtIssuer := resolvedCfg.KeycloakJWTIssuerURI

	r.Use(middleware.Recover)
	r.Use(middleware.SentryCapture)
	r.Use(middleware.RequestID)
	r.Use(middleware.Logging)
	r.Use(middleware.CORS(corsOrigins))

	r.Get("/api/v2/openapi.yaml", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "api/openapi.yaml")
	})

	health := handler.NewHealthHandler(db)
	r.Get("/health/ready", health.Ready)
	r.Get("/health/live", health.Live)

	jwtMw := middleware.NewJWTMiddleware(jwtIssuer)

	tokenClient := auth.NewKeycloakTokenClient(resolvedCfg)
	adminClient := auth.NewKeycloakAdminClient(resolvedCfg)
	currentUserSvc := auth.NewCurrentUserService(db)
	authHandler := handler.NewAuthHandler(tokenClient, adminClient, db)
	profileHandler := handler.NewProfileHandler(currentUserSvc)

	r.Route("/api/v2", func(v2 chi.Router) {
		v2.Use(middleware.PublicBearerSkip(jwtMw))

		v2.Post("/auth/login", authHandler.Login)
		v2.Post("/auth/register", authHandler.Register)
		v2.Post("/auth/refresh", authHandler.Refresh)
		v2.Post("/auth/logout", authHandler.Logout)

		v2.Get("/profile", profileHandler.GetProfile)

		referenceHandler := handler.NewReferenceHandler()
		v2.Get("/reference/serbia-cities", referenceHandler.GetSerbiaCities)

		roleHandler := handler.NewRoleHandler(db)
		v2.Get("/role", roleHandler.GetAll)
		v2.Get("/role/{id}", roleHandler.GetByID)
		v2.Post("/role", roleHandler.Create)
		v2.Put("/role/{id}", roleHandler.Update)
		v2.Delete("/role/{id}", roleHandler.Delete)

		contactHandler := handler.NewContactHandler(db)
		v2.Get("/contact", contactHandler.GetAll)
		v2.Get("/contact/{id}", contactHandler.GetByID)
		v2.Post("/contact", contactHandler.Create)
		v2.Put("/contact/{id}", contactHandler.Update)
		v2.Delete("/contact/{id}", contactHandler.Delete)

		tableHandler := handler.NewTableHandler(db)
		v2.Get("/table", tableHandler.GetAll)
		v2.Get("/table/{id}", tableHandler.GetByID)
		v2.Post("/table", tableHandler.Create)
		v2.Put("/table/{id}", tableHandler.Update)
		v2.Delete("/table/{id}", tableHandler.Delete)

		loyaltyPlanHandler := handler.NewLoyaltyPlanHandler(db)
		v2.Get("/loyalty-plan", loyaltyPlanHandler.GetAll)
		v2.Get("/loyalty-plan/{id}", loyaltyPlanHandler.GetByID)
		v2.Post("/loyalty-plan", loyaltyPlanHandler.Create)
		v2.Put("/loyalty-plan/{id}", loyaltyPlanHandler.Update)
		v2.Delete("/loyalty-plan/{id}", loyaltyPlanHandler.Delete)

		menuHandler := handler.NewMenuHandler(db)
		v2.Get("/menu", menuHandler.GetAll)
		v2.Get("/menu/{id}", menuHandler.GetByID)
		v2.Post("/menu", menuHandler.Create)
		v2.Put("/menu/{id}", menuHandler.Update)
		v2.Delete("/menu/{id}", menuHandler.Delete)

		menuItemHandler := handler.NewMenuItemHandler(db)
		v2.Get("/menu-item", menuItemHandler.GetAll)
		v2.Get("/menu-item/{id}", menuItemHandler.GetByID)
		v2.Post("/menu-item", menuItemHandler.Create)
		v2.Put("/menu-item/{id}", menuItemHandler.Update)
		v2.Delete("/menu-item/{id}", menuItemHandler.Delete)

		userHandler := handler.NewUserHandler(db)
		v2.Get("/user", userHandler.GetAll)
		v2.Get("/user/{id}", userHandler.GetByID)
		v2.Post("/user", userHandler.Create)
		v2.Put("/user/{id}", userHandler.Update)
		v2.Delete("/user/{id}", userHandler.Delete)

		shopHandler := handler.NewShopHandler(db, currentUserSvc)
		v2.Get("/shop/mine", shopHandler.GetMine)
		v2.Get("/shop", shopHandler.GetShops)
		v2.Get("/shop/{id}", shopHandler.GetByID)
		v2.Post("/shop", shopHandler.Create)
		v2.Put("/shop/{id}", shopHandler.Update)
		v2.Delete("/shop/{id}", shopHandler.Delete)
		v2.Post("/shop/{shopId}/favourite", shopHandler.AddFavourite)
		v2.Delete("/shop/{shopId}/favourite", shopHandler.RemoveFavourite)
		v2.Get("/shop/{shopId}/menus", shopHandler.GetMenus)
		v2.Post("/shop/{shopId}/menus", shopHandler.CreateMenu)
		eventHandler := handler.NewEventHandler(db)
		v2.Get("/event", eventHandler.GetAll)
		v2.Get("/event/{eventId}", eventHandler.GetByID)
		v2.Post("/event", eventHandler.Create)
		v2.Put("/event/{eventId}", eventHandler.Update)
		v2.Delete("/event/{eventId}", eventHandler.Delete)

		reservationHandler := handler.NewReservationHandler(db)
		v2.Get("/reservation", reservationHandler.GetAll)
		v2.Get("/reservation/{id}", reservationHandler.GetByID)
		v2.Post("/reservation", reservationHandler.Create)
		v2.Put("/reservation/{id}", reservationHandler.Update)
		v2.Delete("/reservation/{id}", reservationHandler.Delete)

		reservationRequestHandler := handler.NewReservationRequestHandler(db, currentUserSvc)
		v2.Get("/reservation-request", reservationRequestHandler.List)
		v2.Post("/reservation-request", reservationRequestHandler.Create)
		v2.Post("/reservation-request/{id}/accept", reservationRequestHandler.Accept)
		v2.Post("/reservation-request/{id}/deny", reservationRequestHandler.Deny)

		reviewHandler := handler.NewReviewHandler(db, currentUserSvc)
		v2.Get("/review", reviewHandler.GetAll)
		v2.Get("/review/{id}", reviewHandler.GetByID)
		v2.Post("/review", reviewHandler.Create)
		v2.Put("/review/{id}", reviewHandler.Update)
		v2.Delete("/review/{id}", reviewHandler.Delete)
		v2.Get("/review/{reviewId}/comments", reviewHandler.GetComments)
		v2.Post("/review/{reviewId}/comments", reviewHandler.CreateComment)

		communityHandler := handler.NewCommunityHandler(db, currentUserSvc)
		v2.Get("/shop/{shopId}/community/posts", communityHandler.GetPosts)
		v2.Get("/shop/{shopId}/community/members", communityHandler.GetMembers)
		v2.Post("/shop/{shopId}/community/announcements", communityHandler.CreateAnnouncement)
		v2.Delete("/shop/{shopId}/community/posts/{postId}", communityHandler.DeletePost)
	})

	return r
}

