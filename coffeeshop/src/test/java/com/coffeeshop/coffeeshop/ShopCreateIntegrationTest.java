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
class ShopCreateIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    @SuppressWarnings("unchecked")
    void createShop_withoutEmailOrCreatedByUserId_setsOwnerAndEmailFromJwt() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Shop Create Owner", "shop-create-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        headers.setBearerAuth(ownerId.toString());

        final Map<String, Object> body = Map.of(
                "name", "Test Shop",
                "address", "1 Test Street",
                "city", "Beograd",
                "phoneNumber", "+1-555-0100");

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop", new HttpEntity<>(body, headers), Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("city")).isEqualTo("Beograd");
        assertThat(response.getBody().get("email")).isEqualTo("shop-create-owner@example.com");
        assertThat(response.getBody().get("currentMenu")).isNull();
        assertThat(response.getBody().get("loyaltyPlan")).isNull();
        final Map<String, Object> createdBy = (Map<String, Object>) response.getBody().get("createdBy");
        assertThat(createdBy).isNotNull();
        assertThat(createdBy.get("id").toString()).isEqualTo(ownerId.toString());
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

    private void linkKeycloakSubject(final UUID userId) {
        final User user = userRepository.findById(userId).orElseThrow();
        user.setKeycloakSubject(userId.toString());
        userRepository.save(user);
    }
}
