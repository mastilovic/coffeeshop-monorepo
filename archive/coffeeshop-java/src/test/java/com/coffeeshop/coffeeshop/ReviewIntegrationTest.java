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
class ReviewIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    @SuppressWarnings("unchecked")
    void customerCreateReview_appearsOnShop() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Review Owner", "review-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Review Shop", ownerId);

        final UUID customerId = createUser(headers, "Review Customer", "review-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final ResponseEntity<Map> reviewResponse = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Great coffee and atmosphere",
                        "rating", 5,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(reviewResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(reviewResponse.getBody()).isNotNull();
        assertThat(reviewResponse.getBody().get("rating")).isEqualTo(5);
        assertThat(reviewResponse.getBody().get("description")).isEqualTo("Great coffee and atmosphere");
        assertThat(reviewResponse.getBody().get("user")).isNotNull();

        final ResponseEntity<Map> shopResponse = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId,
                Map.class);
        assertThat(shopResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(shopResponse.getBody()).isNotNull();
        final List<Map<String, Object>> reviews = (List<Map<String, Object>>) shopResponse.getBody().get("reviews");
        assertThat(reviews).hasSize(1);
        assertThat(reviews.get(0).get("rating")).isEqualTo(5);
        assertThat(shopResponse.getBody().get("reviewCount")).isEqualTo(1);
        assertThat(shopResponse.getBody().get("averageRating")).isEqualTo(5.0);
    }

    @Test
    @SuppressWarnings("unchecked")
    void shopWithNoReviews_hasZeroCountAndNullAverage() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "No Review Owner", "no-review-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "No Review Shop", ownerId);

        final ResponseEntity<Map> shopResponse = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId,
                Map.class);
        assertThat(shopResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(shopResponse.getBody()).isNotNull();
        assertThat(shopResponse.getBody().get("reviewCount")).isEqualTo(0);
        assertThat(shopResponse.getBody().get("averageRating")).isNull();
    }

    @Test
    @SuppressWarnings("unchecked")
    void multipleReviews_computesAverageRating() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Multi Review Owner", "multi-review-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Multi Review Shop", ownerId);

        final UUID customerOneId = createUser(headers, "Multi Customer One", "multi-customer-one@example.com", "CUSTOMER");
        linkKeycloakSubject(customerOneId);
        headers.setBearerAuth(customerOneId.toString());

        final ResponseEntity<Map> firstReview = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Great",
                        "rating", 5,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(firstReview.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final UUID customerTwoId = createUser(headers, "Multi Customer Two", "multi-customer-two@example.com", "CUSTOMER");
        linkKeycloakSubject(customerTwoId);
        headers.setBearerAuth(customerTwoId.toString());

        final ResponseEntity<Map> secondReview = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Okay",
                        "rating", 3,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(secondReview.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<Map> shopResponse = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId,
                Map.class);
        assertThat(shopResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(shopResponse.getBody()).isNotNull();
        assertThat(shopResponse.getBody().get("reviewCount")).isEqualTo(2);
        assertThat(shopResponse.getBody().get("averageRating")).isEqualTo(4.0);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createReview_invalidRating_returnsUnprocessableEntity() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Invalid Rating Owner", "invalid-rating-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Invalid Rating Shop", ownerId);

        final UUID customerId = createUser(headers, "Invalid Rating Customer", "invalid-rating-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final ResponseEntity<String> tooLow = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Bad",
                        "rating", 0,
                        "shopId", shopId), headers),
                String.class);
        assertThat(tooLow.getStatusCode().value()).isEqualTo(422);

        final ResponseEntity<String> tooHigh = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Bad",
                        "rating", 6,
                        "shopId", shopId), headers),
                String.class);
        assertThat(tooHigh.getStatusCode().value()).isEqualTo(422);
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerSecondReviewForSameShop_returnsConflict() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Duplicate Owner", "duplicate-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Duplicate Shop", ownerId);

        final UUID customerId = createUser(headers, "Duplicate Customer", "duplicate-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);
        headers.setBearerAuth(customerId.toString());

        final ResponseEntity<Map> first = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "First visit",
                        "rating", 4,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(first.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<String> second = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Second visit",
                        "rating", 5,
                        "shopId", shopId), headers),
                String.class);
        assertThat(second.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    @SuppressWarnings("unchecked")
    void shopOwnerCannotReviewOwnShop_returnsForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Self Review Owner", "self-review-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final UUID shopId = createShop(headers, "Self Review Shop", ownerId);

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "My own shop",
                        "rating", 5,
                        "shopId", shopId), headers),
                String.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void customerCannotUpdateAnotherUsersReview_returnsForbidden() {
        final HttpHeaders headers = authHeaders();

        final UUID ownerId = createUser(headers, "Update Owner", "update-owner@example.com", "SHOP_OWNER");
        final UUID shopId = createShop(headers, "Update Shop", ownerId);

        final UUID customerOneId = createUser(headers, "Update Customer One", "update-customer-one@example.com", "CUSTOMER");
        linkKeycloakSubject(customerOneId);
        headers.setBearerAuth(customerOneId.toString());

        final ResponseEntity<Map> reviewResponse = restTemplate.postForEntity(
                "/api/v1/review",
                new HttpEntity<>(Map.of(
                        "description", "Nice place",
                        "rating", 4,
                        "shopId", shopId), headers),
                Map.class);
        assertThat(reviewResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        final UUID reviewId = UUID.fromString(reviewResponse.getBody().get("id").toString());

        final UUID customerTwoId = createUser(headers, "Update Customer Two", "update-customer-two@example.com", "CUSTOMER");
        linkKeycloakSubject(customerTwoId);
        headers.setBearerAuth(customerTwoId.toString());

        final ResponseEntity<String> updateResponse = restTemplate.exchange(
                "/api/v1/review/" + reviewId,
                HttpMethod.PUT,
                new HttpEntity<>(Map.of(
                        "description", "Hijacked",
                        "rating", 1), headers),
                String.class);
        assertThat(updateResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
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
