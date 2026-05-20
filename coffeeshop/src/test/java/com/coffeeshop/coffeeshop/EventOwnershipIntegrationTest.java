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
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class EventOwnershipIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    void createEvent_onOwnShop_returnsCreated() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Event Own Owner", "event-own-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Event Own Shop");

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Own Event",
                        "eventDate", "2026-06-01",
                        "description", "Test",
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createEvent_onOtherOwnersShop_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Event Forbidden Owner", "event-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID otherOwnerId = createUser(headers, "Event Forbidden Other", "event-forbidden-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Event Forbidden Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Forbidden Event",
                        "eventDate", "2026-06-01",
                        "description", "Test",
                        "shopId", otherShopId), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void createEvent_asCustomer_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Event Customer Block Owner", "event-customer-block-owner@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Event Customer Block", "event-customer-block@example.com", "CUSTOMER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(customerId);
        final UUID shopId = createShopWithOwner(ownerId, "Event Customer Block Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Customer Event",
                        "eventDate", "2026-06-01",
                        "description", "Test",
                        "shopId", shopId), ownerHeaders(customerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void updateEvent_asCustomer_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Event Update Customer Owner", "event-update-customer-owner@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Event Update Customer", "event-update-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(customerId);
        final UUID shopId = createShopWithOwner(ownerId, "Event Update Customer Shop");
        final String eventId = createEvent(ownerId, shopId, "Existing Event");

        final ResponseEntity<String> response = restTemplate.exchange(
                "/api/v1/event/" + eventId,
                HttpMethod.PUT,
                new HttpEntity<>(Map.of(
                        "eventName", "Updated",
                        "eventDate", "2026-07-01",
                        "description", "Test",
                        "shopId", shopId), ownerHeaders(customerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void deleteEvent_asCustomer_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Event Delete Customer Owner", "event-delete-customer-owner@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Event Delete Customer", "event-delete-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(customerId);
        final UUID shopId = createShopWithOwner(ownerId, "Event Delete Customer Shop");
        final String eventId = createEvent(ownerId, shopId, "Delete Target Event");

        final ResponseEntity<String> response = restTemplate.exchange(
                "/api/v1/event/" + eventId,
                HttpMethod.DELETE,
                new HttpEntity<>(ownerHeaders(customerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void createEvent_asAdmin_onOtherOwnersShop_returnsCreated() {
        final HttpHeaders headers = authHeaders();
        final UUID adminId = createUser(headers, "Event Admin", "event-admin@example.com", "ADMIN");
        final UUID otherOwnerId = createUser(headers, "Event Admin Other", "event-admin-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(adminId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Event Admin Shop");

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Admin Event",
                        "eventDate", "2026-06-01",
                        "description", "Test",
                        "shopId", otherShopId), ownerHeaders(adminId)),
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
                        "email", email,
                        "password", "secret",
                        "userType", userType), headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return UUID.fromString(response.getBody().get("id").toString());
    }

    private String createEvent(final UUID ownerId, final UUID shopId, final String eventName) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", eventName,
                        "eventDate", "2026-06-01",
                        "description", "Test",
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return response.getBody().get("eventId").toString();
    }

    private UUID createShopWithOwner(final UUID ownerId, final String name) {
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
