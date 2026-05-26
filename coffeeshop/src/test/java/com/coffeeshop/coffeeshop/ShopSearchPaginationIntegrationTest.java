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
class ShopSearchPaginationIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    void searchByCity_returnsMatchingPage() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Shop Search Owner", "shop-search-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        createShop(ownerId, "SearchUnique Alpha Cafe", "Beograd");
        createShop(ownerId, "SearchUnique Beta Bistro", "Novi Sad");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/shop?q=searchunique+alpha&page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(adminHeaders),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(1);
        assertThat(content.get(0).get("name")).isEqualTo("SearchUnique Alpha Cafe");
    }

    @Test
    void paginatedWithoutQuery_returnsPage() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Shop Page Owner", "shop-page-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        createShop(ownerId, "PageOnly Shop One", "Beograd");
        createShop(ownerId, "PageOnly Shop Two", "Beograd");
        createShop(ownerId, "PageOnly Shop Three", "Beograd");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/shop?q=pageonly&page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(adminHeaders),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(3);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(3);
        assertThat(response.getBody().get("size")).isEqualTo(10);
        assertThat(response.getBody().get("totalPages")).isEqualTo(1);
    }

    @Test
    void paginatedWithSize25_returnsPageWithSize25() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Size25 Owner", "size25-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        createShop(ownerId, "Size25 Unique Shop", "Beograd");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/shop?q=size25+unique&page=0&size=25",
                HttpMethod.GET,
                new HttpEntity<>(adminHeaders),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("size")).isEqualTo(25);
    }

    @Test
    void paginatedWithInvalidSize_returnsBadRequest() {
        final ResponseEntity<String> response = restTemplate.exchange(
                "/api/v1/shop?page=0&size=12",
                HttpMethod.GET,
                new HttpEntity<>(authHeaders()),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }

    @Test
    void getAllWithoutPage_returnsArray() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Unpaginated Owner", "unpaginated-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        createShop(ownerId, "Unpaginated Shop", "Beograd");

        final ResponseEntity<List> response = restTemplate.exchange(
                "/api/v1/shop",
                HttpMethod.GET,
                new HttpEntity<>(adminHeaders),
                List.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody()).isInstanceOf(List.class);
    }

    @Test
    @SuppressWarnings("unchecked")
    void paginatedAsCustomer_favouriteShopAppearsFirst() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Fav Sort Owner", "fav-sort-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(adminHeaders, "Fav Sort Customer", "fav-sort-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID favouriteShopId = createShop(ownerId, "Zebra Favourite Shop", "Beograd");
        createShop(ownerId, "Alpha Other Shop", "Beograd");

        restTemplate.postForEntity(
                "/api/v1/shop/" + favouriteShopId + "/favourite",
                new HttpEntity<>(customerHeaders(customerId)),
                Map.class);

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/shop?page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(customerHeaders(customerId)),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).isNotEmpty();
        assertThat(content.get(0).get("id").toString()).isEqualTo(favouriteShopId.toString());
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

    private HttpHeaders customerHeaders(final UUID customerId) {
        return ownerHeaders(customerId);
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

    private void linkKeycloakSubject(final UUID userId) {
        final User user = userRepository.findById(userId).orElseThrow();
        user.setKeycloakSubject(userId.toString());
        userRepository.save(user);
    }
}
