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
class EventSearchIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    void searchByEventName_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search Name Owner", "search-name-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Search Name Shop", "Beograd");
        createEvent(ownerId, shopId, "Jazz Night", "Live jazz");
        createEvent(ownerId, shopId, "Poetry Reading", "Spoken word");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=jazz&page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(1);
        assertThat(content.get(0).get("eventName")).isEqualTo("Jazz Night");
        assertThat(content.get(0).get("shopName")).isEqualTo("Search Name Shop");
        assertThat(content.get(0).get("shopCity")).isEqualTo("Beograd");
    }

    @Test
    void searchByShopName_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search Shop Owner", "search-shop-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Corner Roastery", "Novi Sad");
        createEvent(ownerId, shopId, "Cupping Session", "Coffee tasting");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=roastery",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
    }

    @Test
    void searchByCity_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search City Owner", "search-city-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "City Shop", "Niš");
        createEvent(ownerId, shopId, "Open Mic", "Local artists");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=nis",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
    }

    @Test
    void searchByCityAsciiDjMapping_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search Dj Owner", "search-dj-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Dj Shop", "Inđija");
        createEvent(ownerId, shopId, "Folk Night", "Traditional music");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=indjija",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
    }

    @Test
    void searchByDescription_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search Desc Owner", "search-desc-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Desc Shop", "Beograd");
        createEvent(ownerId, shopId, "Workshop", "Latte art masterclass");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=masterclass",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
    }

    @Test
    void listWithoutQuery_defaultsToPageSizeTen() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search Page Owner", "search-page-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Page Shop", "Beograd");
        for (int i = 0; i < 12; i++) {
            createEvent(ownerId, shopId, "PageSizeTestEvent " + i, "Description " + i);
        }

        final ResponseEntity<Map<String, Object>> firstPage = restTemplate.exchange(
                "/api/v1/event?q=PageSizeTestEvent&page=0",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(firstPage.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(firstPage.getBody()).isNotNull();
        assertThat(firstPage.getBody().get("size")).isEqualTo(10);
        assertThat(firstPage.getBody().get("totalElements")).isEqualTo(12);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> firstContent =
                (List<Map<String, Object>>) firstPage.getBody().get("content");
        assertThat(firstContent).hasSize(10);

        final ResponseEntity<Map<String, Object>> secondPage = restTemplate.exchange(
                "/api/v1/event?q=PageSizeTestEvent&page=1",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });
        assertThat(secondPage.getBody()).isNotNull();
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> secondContent =
                (List<Map<String, Object>>) secondPage.getBody().get("content");
        assertThat(secondContent).hasSize(2);
    }

    @Test
    void searchByDateFrom_filtersEventsOnOrAfterDate() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Date From Owner", "date-from-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Date From Shop", "Beograd");
        createEvent(ownerId, shopId, "DateFilterEarly", "2026-06-01", "early");
        createEvent(ownerId, shopId, "DateFilterMid", "2026-06-15", "mid");
        createEvent(ownerId, shopId, "DateFilterLate", "2026-07-01", "late");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=DateFilter&dateFrom=2026-06-10",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(2);
    }

    @Test
    void searchByDateTo_filtersEventsOnOrBeforeDate() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Date To Owner", "date-to-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "Date To Shop", "Beograd");
        createEvent(ownerId, shopId, "DateToFilterEarly", "2026-06-01", "early");
        createEvent(ownerId, shopId, "DateToFilterMid", "2026-06-15", "mid");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/event?q=DateToFilter&dateTo=2026-06-10",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
    }

    @Test
    void listByShopId_returnsListNotPage() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Search ShopId Owner", "search-shopid-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShop(ownerId, "ShopId Shop", "Beograd");
        createEvent(ownerId, shopId, "Single Event", "One");

        final ResponseEntity<List<Map<String, Object>>> response = restTemplate.exchange(
                "/api/v1/event?shopId=" + shopId,
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).hasSize(1);
        assertThat(response.getBody().get(0).get("eventName")).isEqualTo("Single Event");
    }

    @Test
    void getById_includesAvailabilityFields() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Availability Owner", "availability-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID guestId = createUser(headers, "Availability Guest", "availability-guest@example.com", "CUSTOMER");
        final UUID shopId = createShop(ownerId, "Availability Shop", "Beograd");

        final ResponseEntity<Map> eventResponse = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", "Availability Event",
                        "eventDate", "2026-06-01",
                        "description", "Availability test",
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);
        assertThat(eventResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final String eventId = eventResponse.getBody().get("eventId").toString();

        final ResponseEntity<Map> tableResponse = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 4,
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);
        assertThat(tableResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID tableId = UUID.fromString(tableResponse.getBody().get("id").toString());

        final ResponseEntity<Map> reservationResponse = restTemplate.postForEntity(
                "/api/v1/reservation",
                new HttpEntity<>(Map.of(
                        "userId", guestId,
                        "tableId", tableId,
                        "eventId", eventId,
                        "partySize", 2), ownerHeaders(ownerId)),
                Map.class);
        assertThat(reservationResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<Map<String, Object>> getByIdResponse = restTemplate.exchange(
                "/api/v1/event/" + eventId,
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(getByIdResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getByIdResponse.getBody()).isNotNull();
        assertThat(getByIdResponse.getBody().get("totalTables")).isEqualTo(1);
        assertThat(getByIdResponse.getBody().get("reservedTables")).isEqualTo(1);
        assertThat(getByIdResponse.getBody().get("freeTables")).isEqualTo(0);
        assertThat(getByIdResponse.getBody().get("isFull")).isEqualTo(true);
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

    private UUID createShop(final UUID ownerId, final String name, final String city) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop",
                new HttpEntity<>(Map.of(
                        "name", name,
                        "address", "1 Test Ave",
                        "city", city,
                        "phoneNumber", "+1-555-0100"), ownerHeaders(ownerId)),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return UUID.fromString(response.getBody().get("id").toString());
    }

    private void createEvent(
            final UUID ownerId,
            final UUID shopId,
            final String eventName,
            final String description) {
        createEvent(ownerId, shopId, eventName, "2026-06-01", description);
    }

    private void createEvent(
            final UUID ownerId,
            final UUID shopId,
            final String eventName,
            final String eventDate,
            final String description) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/event",
                new HttpEntity<>(Map.of(
                        "eventName", eventName,
                        "eventDate", eventDate,
                        "description", description,
                        "shopId", shopId), ownerHeaders(ownerId)),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    private void linkKeycloakSubject(final UUID userId) {
        final User user = userRepository.findById(userId).orElseThrow();
        user.setKeycloakSubject(userId.toString());
        userRepository.save(user);
    }
}
