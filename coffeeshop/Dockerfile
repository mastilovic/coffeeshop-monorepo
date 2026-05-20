# syntax=docker/dockerfile:1

FROM gradle:9.2.1-jdk25 AS build
WORKDIR /workspace

COPY gradlew ./
COPY gradle gradle
COPY settings.gradle build.gradle ./

RUN chmod +x gradlew

RUN --mount=type=cache,target=/root/.gradle \
    --mount=type=cache,target=/workspace/.gradle \
    ./gradlew dependencies --no-daemon

COPY src src

RUN --mount=type=cache,target=/root/.gradle \
    --mount=type=cache,target=/workspace/.gradle \
    ./gradlew bootJar --no-daemon

FROM eclipse-temurin:25-jre
WORKDIR /app
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /workspace/build/libs/*.jar /app/app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=docker
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
