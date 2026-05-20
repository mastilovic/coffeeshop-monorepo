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
class ReviewCommentIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    @SuppressWarnings("unchecked")
    void postComment_whenEnabled_appearsOnShop() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Comment Owner", "comment-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Comment Shop", ownerId);

        final UUID customerId = createUser(headers, "Comment Customer", "comment-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final ResponseEntity<Map> reviewResponse = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Lovely place",
                        "rating", 5,
                        "shopId", shopId,
                        "commentsEnabled", true), headers),
                Map.class);
        assertThat(reviewResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID reviewId = UUID.fromString(reviewResponse.getBody().get("id").toString());

        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final ResponseEntity<Map> commentResponse = restTemplate.postForEntity(
                "/api/v1/review/" + reviewId + "/comments",
                new HttpEntity<>(Map.of("body", "Thanks for visiting!"), headers),
                Map.class);
        assertThat(commentResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<Map> shopResponse = restTemplate.getForEntity("/api/v1/shop/" + shopId, Map.class);
        assertThat(shopResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        final List<Map<String, Object>> reviews = (List<Map<String, Object>>) shopResponse.getBody().get("reviews");
        assertThat(reviews).hasSize(1);
        assertThat(reviews.get(0).get("commentsEnabled")).isEqualTo(true);
        final List<Map<String, Object>> comments = (List<Map<String, Object>>) reviews.get(0).get("comments");
        assertThat(comments).hasSize(1);
        assertThat(comments.get(0).get("body")).isEqualTo("Thanks for visiting!");
    }

    @Test
    @SuppressWarnings("unchecked")
    void postComment_whenDisabled_returnsForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Disabled Owner", "disabled-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Disabled Shop", ownerId);

        final UUID customerId = createUser(headers, "Disabled Customer", "disabled-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final ResponseEntity<Map> reviewResponse = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Quiet visit",
                        "rating", 3,
                        "shopId", shopId,
                        "commentsEnabled", false), headers),
                Map.class);
        assertThat(reviewResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID reviewId = UUID.fromString(reviewResponse.getBody().get("id").toString());

        final ResponseEntity<String> commentResponse = restTemplate.postForEntity(
                "/api/v1/review/" + reviewId + "/comments",
                new HttpEntity<>(Map.of("body", "Should fail"), headers),
                String.class);
        assertThat(commentResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void authorDisablesComments_blocksNewComments() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Toggle Owner", "toggle-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Toggle Shop", ownerId);

        final UUID customerId = createUser(headers, "Toggle Customer", "toggle-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final ResponseEntity<Map> reviewResponse = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Good",
                        "rating", 4,
                        "shopId", shopId,
                        "commentsEnabled", true), headers),
                Map.class);
        assertThat(reviewResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID reviewId = UUID.fromString(reviewResponse.getBody().get("id").toString());

        final ResponseEntity<Map> updateResponse = restTemplate.exchange(
                "/api/v1/review/" + reviewId,
                HttpMethod.PUT,
                new HttpEntity<>(Map.of("commentsEnabled", false), headers),
                Map.class);
        assertThat(updateResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(updateResponse.getBody().get("commentsEnabled")).isEqualTo(false);

        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final ResponseEntity<String> commentResponse = restTemplate.postForEntity(
                "/api/v1/review/" + reviewId + "/comments",
                new HttpEntity<>(Map.of("body", "Too late"), headers),
                String.class);
        assertThat(commentResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
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
                        "email", email,
                        "password", "secret",
                        "userType", userType), headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return UUID.fromString(response.getBody().get("id").toString());
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
