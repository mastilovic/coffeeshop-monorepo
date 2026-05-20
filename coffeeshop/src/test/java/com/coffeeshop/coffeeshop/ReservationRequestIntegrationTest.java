package com.coffeeshop.coffeeshop;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class ReservationRequestIntegrationTest {


    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    @SuppressWarnings("unchecked")
    void createRequest_thenAccept_createsReservationLinkedToRequest() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Reservation Request Owner", "reservation-request-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Reservation Request User", "reservation-request-user@example.com", "CUSTOMER");

        final UUID shopId = createShop(headers, "Reservation Request Shop", ownerId);
        final String eventId = createEvent(headers, "Reservation Request Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 4), headers),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(requestResponse.getBody()).isNotNull();
        assertThat(requestResponse.getBody().get("status")).isEqualTo("PENDING");
        assertThat(requestResponse.getBody().get("reservationId")).isNull();
        assertThat(requestResponse.getBody().get("eventId")).isEqualTo(eventId);
        final UUID requestId = UUID.fromString(requestResponse.getBody().get("id").toString());

        final ResponseEntity<List<Map<String, Object>>> listResponse = restTemplate.exchange(
                "/api/v1/reservation-request",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {});
        assertThat(listResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(listResponse.getBody()).hasSize(1);
        assertThat(listResponse.getBody().get(0).get("id").toString()).isEqualTo(requestId.toString());

        final ResponseEntity<Map> acceptResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request/" + requestId + "/accept",
                new HttpEntity<>(Map.of("tableId", tableId), headers),
                Map.class);
        assertThat(acceptResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(acceptResponse.getBody()).isNotNull();
        assertThat(acceptResponse.getBody().get("status")).isEqualTo("ACCEPTED");
        assertThat(acceptResponse.getBody().get("reservationId")).isNotNull();
        assertThat(acceptResponse.getBody().get("eventId")).isEqualTo(eventId);
        final UUID bookingId = UUID.fromString(acceptResponse.getBody().get("reservationId").toString());

        final ResponseEntity<Map> bookingResponse = restTemplate.getForEntity(
                "/api/v1/reservation/" + bookingId,
                Map.class);
        assertThat(bookingResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(bookingResponse.getBody()).isNotNull();
        assertThat(bookingResponse.getBody().get("table")).isNotNull();
        assertThat(bookingResponse.getBody().get("eventId")).isEqualTo(eventId);
        assertThat(UUID.fromString(bookingResponse.getBody().get("reservationRequestId").toString())).isEqualTo(requestId);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createRequest_thenDeny_returnsDeniedWithoutReservation() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Deny Flow Owner", "reservation-deny-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final ResponseEntity<Map> userResponse = restTemplate.postForEntity(
                "/api/v1/user",
                new HttpEntity<>(Map.of(
                        "name", "Deny Flow User",
                        "username", "reservation_deny_user",
                        "email", "reservation-deny-user@example.com",
                        "password", "secret",
                        "userType", "CUSTOMER"), headers),
                Map.class);
        assertThat(userResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID userId = UUID.fromString(userResponse.getBody().get("id").toString());
        linkKeycloakSubject(userId);

        final UUID shopId = createShop(headers, "Deny Flow Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Deny Flow Event", shopId);

        final HttpHeaders ownerHeaders = new HttpHeaders();
        ownerHeaders.setContentType(MediaType.APPLICATION_JSON);
        ownerHeaders.setBearerAuth(ownerId.toString());

        final HttpHeaders customerHeaders = new HttpHeaders();
        customerHeaders.setContentType(MediaType.APPLICATION_JSON);
        customerHeaders.setBearerAuth(userId.toString());

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", userId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 1), customerHeaders),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID requestId = UUID.fromString(requestResponse.getBody().get("id").toString());

        final ResponseEntity<Map> denyResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request/" + requestId + "/deny",
                new HttpEntity<>(ownerHeaders),
                Map.class);
        assertThat(denyResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(denyResponse.getBody()).isNotNull();
        assertThat(denyResponse.getBody().get("status")).isEqualTo("DENIED");
        assertThat(denyResponse.getBody().get("reservationId")).isNull();
    }

    @Test
    @SuppressWarnings("unchecked")
    void listByShopId_asCustomer_isForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID customerId = createUser(headers, "List Customer", "list-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final UUID ownerId = createUser(headers, "List Shop Owner", "list-shop-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "List Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "List Customer Event", shopId);

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<String> listByShopResponse = restTemplate.exchange(
                "/api/v1/reservation-request?shopId=" + shopId,
                HttpMethod.GET,
                new HttpEntity<>(headers),
                String.class);
        assertThat(listByShopResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void listByShopId_asShopOwner_returnsShopRequests() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Shop Owner", "list-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID shopId = createShop(headers, "Owner Shop", ownerId);
        final String eventId = createEvent(headers, "Owner Shop Event", shopId);

        final UUID customerId = createUser(headers, "Other Customer", "list-other-customer@example.com", "CUSTOMER");

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 3), headers),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID requestId = UUID.fromString(requestResponse.getBody().get("id").toString());

        final ResponseEntity<List<Map<String, Object>>> listResponse = restTemplate.exchange(
                "/api/v1/reservation-request?shopId=" + shopId,
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {});
        assertThat(listResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(listResponse.getBody()).hasSize(1);
        assertThat(listResponse.getBody().get(0).get("id").toString()).isEqualTo(requestId.toString());
    }

    @Test
    @SuppressWarnings("unchecked")
    void createRequest_withoutEventId_returnsBadRequest() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Missing Event Owner", "missing-event-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Missing Event Customer", "missing-event-customer@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Missing Event Shop", ownerId);

        final ResponseEntity<String> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "partySize", 2), headers),
                String.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createRequest_withEventFromDifferentShop_returnsBadRequest() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Wrong Event Owner", "wrong-event-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Wrong Event Customer", "wrong-event-customer@example.com", "CUSTOMER");
        final UUID otherOwnerId = createUser(headers, "Wrong Event Other Owner", "wrong-event-other-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Wrong Event Shop A", ownerId);
        final UUID otherShopId = createShop(headers, "Wrong Event Shop B", otherOwnerId);
        final String eventId = createEventWithOwner(otherOwnerId, "Wrong Event Shop B Event", otherShopId);

        final ResponseEntity<String> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                String.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createRequest_withUnknownEventId_returnsNotFound() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Unknown Event Owner", "unknown-event-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Unknown Event Customer", "unknown-event-customer@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Unknown Event Shop", ownerId);

        final ResponseEntity<String> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "eventId", "nonexistent-event-id",
                        "partySize", 2), headers),
                String.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }

    @Test
    @SuppressWarnings("unchecked")
    void ownerCreateRequest_forGuest_returnsCreated() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "On Behalf Owner", "on-behalf-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "On Behalf Guest", "on-behalf-guest@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "On Behalf Shop", ownerId);
        final String eventId = createEvent(headers, "On Behalf Event", shopId);

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(requestResponse.getBody()).isNotNull();
        assertThat(requestResponse.getBody().get("status")).isEqualTo("PENDING");
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerCreateRequest_forAnotherUser_returnsForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID customerId = createUser(headers, "Self Only Customer", "self-only-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final UUID otherCustomerId = createUser(headers, "Self Only Other", "self-only-other@example.com", "CUSTOMER");
        final UUID ownerId = createUser(headers, "Self Only Owner", "self-only-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Self Only Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Self Only Event", shopId);

        final ResponseEntity<String> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", otherCustomerId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                String.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void ownerCreateRequest_forShopNotOwned_returnsForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Not Owned Owner", "not-owned-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID otherOwnerId = createUser(headers, "Not Owned Other Owner", "not-owned-other@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Not Owned Guest", "not-owned-guest@example.com", "CUSTOMER");
        final UUID otherShopId = createShop(headers, "Not Owned Shop", otherOwnerId);
        final String eventId = createEventWithOwner(otherOwnerId, "Not Owned Event", otherShopId);

        final ResponseEntity<String> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", customerId,
                        "shopId", otherShopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                String.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void ownerCreateRequest_forSelf_atShopNotOwned_returnsCreated() {
        final HttpHeaders headers = authHeaders();

        final UUID travelingOwnerId = createUser(headers, "Traveling Owner", "traveling-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(travelingOwnerId);
        headers.setBearerAuth(travelingOwnerId.toString());

        final UUID hostOwnerId = createUser(headers, "Host Owner", "host-owner@example.com", "SHOP_OWNER");
        final UUID hostShopId = createShop(headers, "Host Shop", hostOwnerId);
        final String eventId = createEventWithOwner(hostOwnerId, "Host Event", hostShopId);

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", travelingOwnerId,
                        "shopId", hostShopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(requestResponse.getBody().get("userId")).isEqualTo(travelingOwnerId.toString());
        assertThat(requestResponse.getBody().get("shopId")).isEqualTo(hostShopId.toString());
    }

    @Test
    @SuppressWarnings("unchecked")
    void ownerListRequests_includesOwnRequestAtOtherShop() {
        final HttpHeaders headers = authHeaders();

        final UUID travelingOwnerId = createUser(headers, "List Traveling Owner", "list-traveling-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(travelingOwnerId);
        headers.setBearerAuth(travelingOwnerId.toString());

        final UUID hostOwnerId = createUser(headers, "List Host Owner", "list-host-owner@example.com", "SHOP_OWNER");
        final UUID hostShopId = createShop(headers, "List Host Shop", hostOwnerId);
        final String eventId = createEventWithOwner(hostOwnerId, "List Host Event", hostShopId);

        final ResponseEntity<Map> createResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", travelingOwnerId,
                        "shopId", hostShopId,
                        "eventId", eventId,
                        "partySize", 3), headers),
                Map.class);
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final String requestId = createResponse.getBody().get("id").toString();

        final ResponseEntity<List> listResponse = restTemplate.exchange(
                "/api/v1/reservation-request",
                org.springframework.http.HttpMethod.GET,
                new HttpEntity<>(headers),
                List.class);
        assertThat(listResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(listResponse.getBody()).isNotEmpty();
        assertThat(listResponse.getBody().stream()
                .map(item -> ((Map<?, ?>) item).get("id").toString())
                .anyMatch(requestId::equals)).isTrue();
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerSecondRequestWhilePending_returnsConflict() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Dup Pending Owner", "dup-pending-owner@example.com", "SHOP_OWNER");
        final UUID customerId = createUser(headers, "Dup Pending Customer", "dup-pending-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShop(headers, "Dup Pending Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Dup Pending Event", shopId);

        final HttpHeaders customerHeaders = new HttpHeaders();
        customerHeaders.setContentType(MediaType.APPLICATION_JSON);
        customerHeaders.setBearerAuth(customerId.toString());

        final Map<String, Object> body = Map.of(
                "userId", customerId,
                "shopId", shopId,
                "eventId", eventId,
                "partySize", 2);

        final ResponseEntity<Map> first = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(body, customerHeaders),
                Map.class);
        assertThat(first.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<String> second = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(body, customerHeaders),
                String.class);
        assertThat(second.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerCanRequestAgainAfterDenied() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Retry Owner", "retry-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(headers, "Retry Customer", "retry-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShop(headers, "Retry Shop", ownerId);
        final String eventId = createEventWithOwner(ownerId, "Retry Event", shopId);

        final HttpHeaders ownerHeaders = new HttpHeaders();
        ownerHeaders.setContentType(MediaType.APPLICATION_JSON);
        ownerHeaders.setBearerAuth(ownerId.toString());

        final HttpHeaders customerHeaders = new HttpHeaders();
        customerHeaders.setContentType(MediaType.APPLICATION_JSON);
        customerHeaders.setBearerAuth(customerId.toString());

        final Map<String, Object> body = Map.of(
                "userId", customerId,
                "shopId", shopId,
                "eventId", eventId,
                "partySize", 2);

        final ResponseEntity<Map> first = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(body, customerHeaders),
                Map.class);
        assertThat(first.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID requestId = UUID.fromString(first.getBody().get("id").toString());

        final ResponseEntity<Map> denyResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request/" + requestId + "/deny",
                new HttpEntity<>(ownerHeaders),
                Map.class);
        assertThat(denyResponse.getStatusCode()).isEqualTo(HttpStatus.OK);

        final ResponseEntity<Map> retry = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(body, customerHeaders),
                Map.class);
        assertThat(retry.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerSecondRequestAfterAccepted_returnsConflict() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Dup Accept Owner", "dup-accept-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID customerId = createUser(headers, "Dup Accept Customer", "dup-accept-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShop(headers, "Dup Accept Shop", ownerId);
        final String eventId = createEvent(headers, "Dup Accept Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final HttpHeaders customerHeaders = new HttpHeaders();
        customerHeaders.setContentType(MediaType.APPLICATION_JSON);
        customerHeaders.setBearerAuth(customerId.toString());

        final Map<String, Object> body = Map.of(
                "userId", customerId,
                "shopId", shopId,
                "eventId", eventId,
                "partySize", 2);

        final ResponseEntity<Map> requestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(body, customerHeaders),
                Map.class);
        assertThat(requestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID requestId = UUID.fromString(requestResponse.getBody().get("id").toString());

        final ResponseEntity<Map> acceptResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request/" + requestId + "/accept",
                new HttpEntity<>(Map.of("tableId", tableId), headers),
                Map.class);
        assertThat(acceptResponse.getStatusCode()).isEqualTo(HttpStatus.OK);

        final ResponseEntity<String> second = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(body, customerHeaders),
                String.class);
        assertThat(second.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    @SuppressWarnings("unchecked")
    void listEventsByShopId_returnsOnlyShopEvents() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Event List Owner", "event-list-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID otherOwnerId = createUser(headers, "Event List Other Owner", "event-list-other-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Event List Shop A", ownerId);
        final UUID otherShopId = createShop(headers, "Event List Shop B", otherOwnerId);
        final String eventA = createEvent(headers, "Event A", shopId);
        createEventWithOwner(otherOwnerId, "Event B", otherShopId);

        final ResponseEntity<List<Map<String, Object>>> listResponse = restTemplate.exchange(
                "/api/v1/event?shopId=" + shopId,
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {});
        assertThat(listResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(listResponse.getBody()).hasSize(1);
        assertThat(listResponse.getBody().get(0).get("eventId").toString()).isEqualTo(eventA);
    }

    @Test
    void acceptRequest_whenEventAtCapacity_returnsConflict() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Capacity Req Owner", "capacity-req-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID firstGuestId = createUser(headers, "Capacity Req Guest One", "capacity-req-guest-one@example.com", "CUSTOMER");
        final UUID secondGuestId = createUser(headers, "Capacity Req Guest Two", "capacity-req-guest-two@example.com", "CUSTOMER");
        final UUID shopId = createShop(headers, "Capacity Req Shop", ownerId);
        final String eventId = createEvent(headers, "Capacity Req Event", shopId);

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 6,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<Map> firstRequestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", firstGuestId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                Map.class);
        assertThat(firstRequestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID firstRequestId = UUID.fromString(firstRequestResponse.getBody().get("id").toString());

        final ResponseEntity<Map> secondRequestResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request",
                new HttpEntity<>(Map.of(
                        "userId", secondGuestId,
                        "shopId", shopId,
                        "eventId", eventId,
                        "partySize", 2), headers),
                Map.class);
        assertThat(secondRequestResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID secondRequestId = UUID.fromString(secondRequestResponse.getBody().get("id").toString());

        final ResponseEntity<Map> acceptResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request/" + firstRequestId + "/accept",
                new HttpEntity<>(Map.of("tableId", tableId), headers),
                Map.class);
        assertThat(acceptResponse.getStatusCode()).isEqualTo(HttpStatus.OK);

        final ResponseEntity<String> secondAcceptResponse = restTemplate.postForEntity(
                "/api/v1/reservation-request/" + secondRequestId + "/accept",
                new HttpEntity<>(Map.of("tableId", tableId), headers),
                String.class);
        assertThat(secondAcceptResponse.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    private HttpHeaders authHeaders() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("integration-test-token");
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

    private String createEvent(final HttpHeaders headers, final String eventName, final UUID shopId) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", eventName,
                        "eventDate", "2026-06-01",
                        "description", "Test event",
                        "shopId", shopId), headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return response.getBody().get("eventId").toString();
    }

    private String createEventWithOwner(final UUID ownerId, final String eventName, final UUID shopId) {
        final HttpHeaders ownerHeaders = new HttpHeaders();
        ownerHeaders.setContentType(MediaType.APPLICATION_JSON);
        ownerHeaders.setBearerAuth(ownerId.toString());
        return createEvent(ownerHeaders, eventName, shopId);
    }

    private UUID createShop(final HttpHeaders headers, final String name, final UUID ownerId) {
        linkKeycloakSubject(ownerId);
        final HttpHeaders ownerHeaders = new HttpHeaders();
        ownerHeaders.setContentType(MediaType.APPLICATION_JSON);
        ownerHeaders.setBearerAuth(ownerId.toString());
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop",
                new HttpEntity<>(Map.of(
                        "name", name,
                        "address", "1 Test Ave",
                        "city", "Beograd",
                        "phoneNumber", "+1-555-0100"), ownerHeaders),
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
