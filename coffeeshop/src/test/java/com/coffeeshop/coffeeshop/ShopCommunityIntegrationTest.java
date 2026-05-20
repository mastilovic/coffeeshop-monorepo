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
import org.springframework.core.ParameterizedTypeReference;
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
class ShopCommunityIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    void announcement_asFavouritedCustomer_returnsForbidden() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Comm Owner", "comm-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(adminHeaders, "Comm Member", "comm-member@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShopWithOwner(ownerId, "Community Test Shop");

        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(userHeaders(customerId)),
                Map.class);

        final ResponseEntity<String> postResponse = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "Hello community!"), userHeaders(customerId)),
                String.class);

        assertThat(postResponse.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void announcement_withoutJoin_returnsForbidden() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "No Join Owner", "nojoin-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(adminHeaders, "No Join Customer", "nojoin-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShopWithOwner(ownerId, "No Join Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "Should fail"), userHeaders(customerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void announcement_asAdminNotOwner_returnsForbidden() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Admin Test Owner", "admintest-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID adminId = createUser(adminHeaders, "Admin Test Admin", "admintest-admin@example.com", "ADMIN");
        linkKeycloakSubject(adminId);

        final UUID shopId = createShopWithOwner(ownerId, "Admin Test Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "Admin should not post"), userHeaders(adminId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void announcement_asOwner_succeedsAndIsPinned() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Ann Owner", "ann-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID shopId = createShopWithOwner(ownerId, "Announcement Shop");

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "We are open late tonight!"), userHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody().get("type")).isEqualTo("ANNOUNCEMENT");
        assertThat(response.getBody().get("pinned")).isEqualTo(true);
    }

    @Test
    void announcement_asCustomer_returnsForbidden() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Ann Cust Owner", "anncust-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID customerId = createUser(adminHeaders, "Ann Cust Customer", "anncust-customer@example.com", "CUSTOMER");
        linkKeycloakSubject(customerId);

        final UUID shopId = createShopWithOwner(ownerId, "Ann Cust Shop");

        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(userHeaders(customerId)),
                Map.class);

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "Not allowed"), userHeaders(customerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void feed_ordersPinnedAnnouncementFirst() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Feed Owner", "feed-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID shopId = createShopWithOwner(ownerId, "Feed Order Shop");

        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "Older announcement"), userHeaders(ownerId)),
                Map.class);

        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/community/announcements",
                new HttpEntity<>(Map.of("body", "Pinned announcement"), userHeaders(ownerId)),
                Map.class);

        final ResponseEntity<Map> feedResponse = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId + "/community/posts?page=0&size=20",
                Map.class);

        assertThat(feedResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        final List<Map<String, Object>> content =
                (List<Map<String, Object>>) feedResponse.getBody().get("content");
        assertThat(content).hasSizeGreaterThanOrEqualTo(2);
        assertThat(content.get(0).get("type")).isEqualTo("ANNOUNCEMENT");
        assertThat(content.get(0).get("pinned")).isEqualTo(true);
    }

    @Test
    void members_searchByName_returnsMatchingPage() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Members Owner", "members-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);

        final UUID aliceId = createUser(adminHeaders, "Alice Member", "alice-member@example.com", "CUSTOMER");
        linkKeycloakSubject(aliceId);
        final UUID bobId = createUser(adminHeaders, "Bob Member", "bob-member@example.com", "CUSTOMER");
        linkKeycloakSubject(bobId);

        final UUID shopId = createShopWithOwner(ownerId, "Members Search Shop");

        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(userHeaders(aliceId)),
                Map.class);
        restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/favourite",
                new HttpEntity<>(userHeaders(bobId)),
                Map.class);

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/shop/" + shopId + "/community/members?q=alice&page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(authHeaders()),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(1);
        assertThat(content.get(0).get("name")).isEqualTo("Alice Member");
    }

    @Test
    void getPosts_withoutAuth_isPublic() {
        final HttpHeaders adminHeaders = authHeaders();
        final UUID ownerId = createUser(adminHeaders, "Public Feed Owner", "publicfeed-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Public Feed Shop");

        final ResponseEntity<Map> response = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId + "/community/posts",
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    private HttpHeaders authHeaders() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("integration-test-token");
        return headers;
    }

    private HttpHeaders userHeaders(final UUID userId) {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(userId.toString());
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

    private UUID createShopWithOwner(final UUID ownerId, final String name) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop",
                new HttpEntity<>(Map.of(
                        "name", name,
                        "address", "1 Test Ave",
                        "city", "Beograd",
                        "phoneNumber", "+1-555-0100"), userHeaders(ownerId)),
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
