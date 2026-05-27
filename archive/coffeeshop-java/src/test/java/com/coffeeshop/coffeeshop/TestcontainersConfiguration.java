package com.coffeeshop.coffeeshop;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.DockerImageName;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@TestConfiguration(proxyBeanMethods = false)
class TestcontainersConfiguration {

	@Bean
	@ServiceConnection
	PostgreSQLContainer postgresContainer() {
		return new PostgreSQLContainer(DockerImageName.parse("postgres:latest"));
	}

	@Bean
	@Primary
	JwtDecoder jwtDecoder(final UserRepository userRepository) {
		return token -> {
			final String subject;
			String email;
			if ("integration-test-token".equals(token)) {
				subject = "550e8400-e29b-41d4-a716-446655440000";
				email = "jwt-test-subject@example.com";
			} else if ("email-not-in-database".equals(token)) {
				subject = UUID.randomUUID().toString();
				email = "no-local-user@example.com";
			} else {
				subject = token;
				email = "jwt-test-subject@example.com";
				try {
					final UUID userId = UUID.fromString(subject);
					final Optional<User> user = userRepository.findByKeycloakSubject(subject)
							.or(() -> userRepository.findById(userId));
					if (user.isPresent() && user.get().getEmail() != null) {
						email = user.get().getEmail();
					}
				} catch (final IllegalArgumentException ignored) {
				}
			}
			return Jwt.withTokenValue(token)
					.header("alg", "none")
					.subject(subject)
					.issuedAt(Instant.now())
					.expiresAt(Instant.now().plusSeconds(3600))
					.issuer("http://localhost:8080/realms/coffeeshop")
					.claim("email", email)
					.build();
		};
	}

}
