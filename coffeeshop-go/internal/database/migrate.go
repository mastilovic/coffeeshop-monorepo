package database

import (
	"errors"
	"fmt"
	"log/slog"

	"github.com/golang-migrate/migrate/v4"
	_ "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func RunMigrations(databaseURL, migrationsPath string) error {
	if migrationsPath == "" {
		migrationsPath = "migrations"
	}

	source := fmt.Sprintf("file://%s", migrationsPath)
	m, err := migrate.New(source, databaseURL)
	if err != nil {
		return fmt.Errorf("create migrate instance: %w", err)
	}
	defer m.Close()

	if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
		return fmt.Errorf("run migrations: %w", err)
	}

	version, dirty, verr := m.Version()
	if verr != nil && !errors.Is(verr, migrate.ErrNilVersion) {
		slog.Warn("could not read migration version", "error", verr)
	} else {
		slog.Info("database migrations applied", "version", version, "dirty", dirty)
	}
	return nil
}
