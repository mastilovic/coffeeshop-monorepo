---
name: Faster Docker Gradle builds
overview: Your current Dockerfile invalidates the Gradle build on every source change and does not persist Gradle caches between `docker compose build` runs. Reordering layers, enabling BuildKit cache mounts, and adding a `.dockerignore` are the highest-impact fixes.
todos:
  - id: dockerfile-layers
    content: "Refactor Dockerfile: copy gradle wrapper + build files, warm dependencies, copy src, bootJar with ./gradlew"
    status: completed
  - id: buildkit-cache
    content: Add RUN --mount=type=cache for /root/.gradle (and workspace .gradle if needed)
    status: completed
  - id: dockerignore
    content: Add .dockerignore (build/, .git/, .gradle/, IDE, etc.)
    status: completed
isProject: false
---

# Speed up `docker compose up --build` for this project

## What makes builds slow today

In [`Dockerfile`](/Users/amastilovic/Desktop/dev/coffeeshop/Dockerfile) the build stage does:

```dockerfile
COPY . .
RUN gradle bootJar --no-daemon
```

- **Single `COPY . .`**: Any change anywhere in the repo invalidates this layer and forces a full **`gradle bootJar`** on the next build. Dependency resolution and compilation run again even when only `build.gradle` / lockfiles did not change in a way that would require a full redownload (Gradle is smart locally, but Docker layer cache is not unless you split layers).
- **No Gradle cache between builds**: Each clean build inside Docker repopulates Gradle’s cache under `/root/.gradle` inside the container; that directory is thrown away when the build container exits.
- **No [`.dockerignore`](/Users/amastilovic/Desktop/dev/coffeeshop/.dockerignore)**: The build context may include `build/`, `.git`, IDE folders, etc., which increases **context transfer time** and can accidentally affect cache keys if those paths are copied.

[`docker-compose.yaml`](/Users/amastilovic/Desktop/dev/coffeeshop/docker-compose.yaml) only builds the `backend` service from this Dockerfile; Postgres/Keycloak/Valkey use prebuilt images, so optimizing the **backend image** is where you win time.

## Recommended changes (in order of impact)

### 1. Split dependency resolution from compilation (layer caching)

Copy only Gradle entry points first, run a command that **resolves dependencies** (without needing `src/`), then copy `src/` and run `bootJar`.

Typical pattern with your repo layout:

- Copy: `gradlew`, `gradle/wrapper/`, `settings.gradle`, `build.gradle`, and `gradle.properties` if present.
- Run something like `./gradlew dependencies --no-daemon` or `./gradlew bootJar --dry-run` (or a dedicated `resolveDependencies` task if you add one) so Docker caches a layer that only invalidates when Gradle files change.
- Then `COPY src src` and run `./gradlew bootJar --no-daemon`.

You already have [`gradlew`](/Users/amastilovic/Desktop/dev/coffeeshop/gradlew) and [`settings.gradle`](/Users/amastilovic/Desktop/dev/coffeeshop/settings.gradle); prefer **`./gradlew`** in the Dockerfile so the wrapper pins the Gradle version consistently with local dev (you can keep or drop the `gradle:*` image in favor of a JDK-only base for the build stage—optional).

### 2. Enable BuildKit cache mounts for Gradle (`RUN --mount=type=cache`)

With Docker BuildKit (default in recent Docker Desktop / Engine), add cache mounts so **`/root/.gradle`** (and optionally **`/workspace/.gradle`**) persist across builds:

```dockerfile
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew bootJar --no-daemon
```

Apply the same mount to the dependency-warmup step. This dramatically cuts repeated dependency download and some incremental work.

Ensure BuildKit is on (usually `DOCKER_BUILDKIT=1` or default on modern installs).

### 3. Add a `.dockerignore`

Exclude at least: `build/`, `.gradle/` (local), `.git/`, IDE dirs, `*.md`, test reports, etc. This speeds **context upload** and avoids copying junk into `COPY` layers.

### 4. Workflow tips (no Dockerfile change)

- Use **`docker compose up`** without `--build` when you did not change the backend; Compose will use the existing image.
- Use **`docker compose build backend`** when iterating on the app, then **`docker compose up`**—same rebuild behavior, clearer intent.
- For day-to-day Java iteration, **`./gradlew bootJar`** (or bootRun) on the host is often faster than a full image rebuild; use Docker mainly for integration with Postgres/Keycloak/Valkey.

## Optional follow-ups

- **Gradle build cache**: `./gradlew bootJar` already benefits from Gradle’s build cache when the cache dir is preserved; the Docker cache mount addresses that.
- **Smaller/faster base**: A distroless or slim JRE image does not speed the *build* stage much but can speed **pulls** and slightly shrink final image; separate concern from compile time.

## Summary

| Issue | Fix |
|-------|-----|
| One `COPY . .` before Gradle | Copy Gradle files → resolve deps → copy `src` → `bootJar` |
| Gradle cache lost each build | `RUN --mount=type=cache,target=/root/.gradle,...` |
| Fat build context | Add `.dockerignore` |

No changes to [`docker-compose.yaml`](/Users/amastilovic/Desktop/dev/coffeeshop/docker-compose.yaml) are required unless you want to document `DOCKER_BUILDKIT=1` for teammates on older Docker versions.
