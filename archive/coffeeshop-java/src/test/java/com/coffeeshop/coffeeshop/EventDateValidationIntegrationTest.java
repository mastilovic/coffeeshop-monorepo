package com.coffeeshop.coffeeshop;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class EventDateValidationIntegrationTest {

    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    void createEvent_withPastDate_returnsBadRequest() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Past Date Owner", "past-date-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Past Date Shop");

        final String pastDate = LocalDateTime.now().minusDays(1).format(FORMAT);
        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Past Event",
                        "eventDate", pastDate,
                        "description", "Test",
                        "shopId", shopId), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).contains("future");
    }

    @Test
    void createEvent_withFutureDate_returnsCreated() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Future Date Owner", "future-date-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Future Date Shop");

        final String futureDate = LocalDateTime.now().plusDays(2).format(FORMAT);
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Future Event",
                        "eventDate", futureDate,
                        "description", "Test",
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    private HttpHeaders authHeaders() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("integration-test-token");
        return headers;
    }

    private HttpHeaders ownerHeaders(final UUID ownerId) {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(ownerId.toString());
        return headers;
    }

    private UUID createUser(
            final HttpHeaders headers,
            final String name,
            final String email,
            final String userType) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/user",
                new HttpEntity<>(Map.of(
                        "name", name,
                        "username", IntegrationTestUsers.usernameFromEmail(email),
                        "email", email,
                        "password", "secret",
                        "userType", userType), headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return UUID.fromString(response.getBody().get("id").toString());
    }

    private UUID createShop(final UUID ownerId, final String name) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop",
                new HttpEntity<>(Map.of(
                        "name", name,
                        "address", "1 Test Ave",
                        "city", "Beograd",
                        "phoneNumber", "+1-555-0100"), ownerHeaders(ownerId)),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return UUID.fromString(response.getBody().get("id").toString());
    }

    private void linkKeycloakSubject(final UUID userId) {
        final User user = userRepository.findById(userId).orElseThrow();
        user.setKeycloakSubject(userId.toString());
        userRepository.save(user);
    }
}
