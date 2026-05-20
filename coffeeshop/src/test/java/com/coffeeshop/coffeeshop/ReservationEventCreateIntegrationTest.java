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

import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class ReservationEventCreateIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    @SuppressWarnings("unchecked")
    void ownerDirectCreate_withEvent_returnsCreated() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Direct Owner", "direct-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Direct Guest", "direct-guest@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Direct Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Direct Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<Map> reservationResponse = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "tableId", tableId,
                        "eventId", eventId,
                        "partySize", 4), headers),
                Map.class);
        assertThat(reservationResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(reservationResponse.getBody()).isNotNull();
        assertThat(reservationResponse.getBody().get("eventId")).isEqualTo(eventId);
    }

    @Test
    @SuppressWarnings("unchecked")
    void ownerSecondDirectReservationForSameUserEvent_returnsConflict() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Dup Direct Owner", "dup-direct-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Dup Direct Guest", "dup-direct-guest@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Dup Direct Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Dup Direct Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final Map<String, Object> body = Map.of(
                "userId", customerId,
                "tableId", tableId,
                "eventId", eventId,
                "partySize", 4);

        final ResponseEntity<Map> first = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(body, headers),
                Map.class);
        assertThat(first.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<String> second = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(body, headers),
                String.class);
        assertThat(second.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerDirectCreate_returnsForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Direct Forbidden Owner", "direct-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Direct Forbidden Customer", "direct-forbidden-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final UUID shopId = createShopWithOwner(ownerId, "Direct Forbidden Shop");
        final String eventId = createEventWithOwner(ownerId, "Direct Forbidden Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<String> reservationResponse = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "tableId", tableId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                String.class);
        assertThat(reservationResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void ownerDirectCreate_withEventFromWrongShop_returnsBadRequest() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Direct Wrong Event Owner", "direct-wrong-event-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID otherOwnerId = createUser(headers, "Direct Wrong Event Other", "direct-wrong-event-other@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Direct Wrong Event Guest", "direct-wrong-event-guest@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Direct Wrong Event Shop A", ownerId);
        final UUID otherShopId = createShop(headers, "Direct Wrong Event Shop B", otherOwnerId);
        final String eventId = createEventWithOwner(otherOwnerId, "Direct Wrong Event", otherShopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<String> reservationResponse = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "tableId", tableId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                String.class);
        assertThat(reservationResponse.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    void ownerDirectCreate_whenEventAtCapacity_returnsConflict() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Capacity Owner", "capacity-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID firstGuestId = createUser(headers, "Capacity Guest One", "capacity-guest-one@example.com", "CUSTOMER");
        final UUID secondGuestId = createUser(headers, "Capacity Guest Two", "capacity-guest-two@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Capacity Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Capacity Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<Map> firstReservation = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(Map.of(
                        "userId", firstGuestId,
                        "tableId", tableId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                Map.class);
        assertThat(firstReservation.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<String> secondReservation = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(Map.of(
                        "userId", secondGuestId,
                        "tableId", tableId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                String.class);
        assertThat(secondReservation.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
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

    private UUID createShop(final HttpHeaders headers, final String name, final UUID ownerId) {
        return createShopWithOwner(ownerId, name);
    }

    private UUID createShopWithOwner(final UUID ownerId, final String name) {
        linkKeycloakSubject(ownerId);
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

    private String createEventWithOwner(final UUID ownerId, final String eventName, final UUID shopId) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", eventName,
                        "eventDate", "2026-06-01",
                        "description", "Test event",
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return response.getBody().get("eventId").toString();
    }

    private void linkKeycloakSubject(final UUID userId) {
        final User user = userRepository.findById(userId).orElseThrow();
        user.setKeycloakSubject(userId.toString());
        userRepository.save(user);
    }
}
