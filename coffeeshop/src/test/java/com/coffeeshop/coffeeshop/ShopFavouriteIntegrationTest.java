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

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class ShopFavouriteIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    @SuppressWarnings("unchecked")
    void addFavourite_asCustomer_addsToProfileAndShopResponse() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Fav Owner", "fav-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(adminHeaders, "Fav Customer", "fav-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShopWithOwner(ownerId, "Favourite Test Shop");

        final ResponseEntity<Map> favouriteResponse = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(customerHeaders(customerId)),
                Map.class);

        assertThat(favouriteResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(favouriteResponse.getBody().get("favouriteByCurrentUser")).isEqualTo(true);

        final ResponseEntity<Map> profileResponse = restTemplate.exchange(
                "/profile",
                HttpMethod.GET,
                new HttpEntity<>(customerHeaders(customerId)),
                Map.class);

        assertThat(profileResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        final List<Map<String, Object>> favouriteShops =
                (List<Map<String, Object>>) profileResponse.getBody().get("favouriteShops");
        assertThat(favouriteShops).hasSize(1);
        assertThat(favouriteShops.get(0).get("id").toString()).isEqualTo(shopId.toString());
    }

    @Test
    void removeFavourite_asCustomer_removesFromProfile() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Unfav Owner", "unfav-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(adminHeaders, "Unfav Customer", "unfav-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShopWithOwner(ownerId, "Unfavourite Test Shop");

        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(customerHeaders(customerId)),
                Map.class);

        final ResponseEntity<Map> removeResponse = restTemplate.exchange(
                "/api/v1/shop/" + shopId + "/favourite",
                HttpMethod.DELETE,
                new HttpEntity<>(customerHeaders(customerId)),
                Map.class);

        assertThat(removeResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(removeResponse.getBody().get("favouriteByCurrentUser")).isEqualTo(false);

        final ResponseEntity<Map> profileResponse = restTemplate.exchange(
                "/profile",
                HttpMethod.GET,
                new HttpEntity<>(customerHeaders(customerId)),
                Map.class);

        assertThat(profileResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat((List<?>) profileResponse.getBody().get("favouriteShops")).isEmpty();
    }

    @Test
    void addFavourite_asOwner_returnsConflict() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Self Fav Owner", "self-fav-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID shopId = createShopWithOwner(ownerId, "Owner Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    void addFavourite_withoutAuth_returnsUnauthorized() {
        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + UUID.randomUUID() + "/favourite",
                HttpEntity.EMPTY,
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
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
