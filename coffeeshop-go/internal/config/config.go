package config

import "github.com/caarlos0/env/v11"

type Config struct {
	Port                  int    `env:"PORT" envDefault:"8080"`
	DatabaseURL           string `env:"DATABASE_URL" envDefault:"postgres://coffeeshop:coffeeshop_dev_password@localhost:25432/coffeeshop?sslmode=disable"`
	KeycloakBaseURL       string `env:"KEYCLOAK_BASE_URL" envDefault:"http://localhost:8080"`
	KeycloakRealm         string `env:"KEYCLOAK_REALM" envDefault:"coffeeshop"`
	KeycloakClientID      string `env:"KEYCLOAK_BACKEND_CLIENT_ID" envDefault:"coffeeshop-backend"`
	KeycloakClientSecret  string `env:"KEYCLOAK_BACKEND_CLIENT_SECRET" envDefault:"local-backend-secret"`
	KeycloakJWTIssuerURI  string `env:"KEYCLOAK_JWT_ISSUER_URI" envDefault:"http://localhost:8080/realms/coffeeshop"`
	KeycloakAdminUser     string `env:"KEYCLOAK_ADMIN_USER" envDefault:"admin"`
	KeycloakAdminPassword string `env:"KEYCLOAK_ADMIN_PASSWORD" envDefault:"admin"`
	CORSAllowedOrigins    string `env:"CORS_ALLOWED_ORIGINS" envDefault:"http://localhost:4200"`
	SentryDSN             string `env:"SENTRY_DSN" envDefault:""`
	RunMigrations         bool   `env:"RUN_MIGRATIONS" envDefault:"false"`
	MigrationsPath        string `env:"MIGRATIONS_PATH" envDefault:"migrations"`
}

func Load() (Config, error) {
	var cfg Config
	if err := env.Parse(&cfg); err != nil {
		return Config{}, err
	}
	return cfg, nil
}
