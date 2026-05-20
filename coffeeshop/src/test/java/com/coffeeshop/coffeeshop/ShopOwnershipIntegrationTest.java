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
class ShopOwnershipIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @Test
    void updateShop_asOwner_returnsOk() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Shop Own Owner", "shop-own-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Shop Own Shop");

        final ResponseEntity<Map> response = restTemplate.exchange(
                "/api/v1/shop/" + shopId,
                HttpMethod.PUT,
                new HttpEntity<>(Map.of("name", "Updated Shop", "city", "Beograd"), ownerHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void updateShop_asOtherShopOwner_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Shop Forbidden Owner", "shop-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID otherOwnerId = createUser(headers, "Shop Forbidden Other", "shop-forbidden-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Shop Forbidden Shop");

        final ResponseEntity<String> response = restTemplate.exchange(
                "/api/v1/shop/" + otherShopId,
                HttpMethod.PUT,
                new HttpEntity<>(Map.of("name", "Hijacked", "city", "Beograd"), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void deleteShop_asOtherShopOwner_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Shop Delete Forbidden Owner", "shop-delete-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID otherOwnerId = createUser(headers, "Shop Delete Forbidden Other", "shop-delete-forbidden-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Shop Delete Forbidden Shop");

        final ResponseEntity<String> response = restTemplate.exchange(
                "/api/v1/shop/" + otherShopId,
                HttpMethod.DELETE,
                new HttpEntity<>(ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void deleteShop_asOwner_returnsNoContent() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Shop Delete Owner", "shop-delete-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Shop Delete Shop");

        final ResponseEntity<Void> response = restTemplate.exchange(
                "/api/v1/shop/" + shopId,
                HttpMethod.DELETE,
                new HttpEntity<>(ownerHeaders(ownerId)),
                Void.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);
    }

    @Test
    void updateShop_asAdmin_onOtherOwnersShop_returnsOk() {
        final HttpHeaders headers = authHeaders();
        final UUID adminId = createUser(headers, "Shop Admin", "shop-admin@example.com", "ADMIN");
        final UUID otherOwnerId = createUser(headers, "Shop Admin Other", "shop-admin-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(adminId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Shop Admin Shop");

        final ResponseEntity<Map> response = restTemplate.exchange(
                "/api/v1/shop/" + otherShopId,
                HttpMethod.PUT,
                new HttpEntity<>(Map.of("name", "Admin Updated", "city", "Beograd"), ownerHeaders(adminId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void createMenuItem_onOtherOwnersMenu_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu Item Forbidden Owner", "menu-item-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID otherOwnerId = createUser(headers, "Menu Item Forbidden Other", "menu-item-forbidden-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Menu Item Forbidden Shop");
        final UUID menuId = createMenuForShop(otherOwnerId, otherShopId);

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/menu-item",
                new HttpEntity<>(Map.of(
                        "name", "Forbidden Item",
                        "price", 5.99,
                        "priceCurrency", "USD",
                        "menuId", menuId), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createMenu_forOwnShop_returnsCreatedAndSetsCurrent() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu Create Owner", "menu-create-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Menu Create Shop");

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/menus",
                new HttpEntity<>(Map.of("label", "Spring Menu"), ownerHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("current")).isEqualTo(true);
        assertThat(response.getBody().get("label")).isEqualTo("Spring Menu");

        final ResponseEntity<Map> shopResponse = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId, Map.class);
        assertThat(shopResponse.getBody().get("currentMenu")).isNotNull();
    }

    @Test
    void createMenu_asOtherOwner_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu Forbidden Owner", "menu-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID otherOwnerId = createUser(headers, "Menu Forbidden Other", "menu-forbidden-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Menu Forbidden Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + otherShopId + "/menus",
                new HttpEntity<>(Map.of(), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    void createMenu_asCustomer_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID customerId = createUser(headers, "Menu Customer", "menu-customer@example.com", "CUSTOMER");
        final UUID ownerId = createUser(headers, "Menu Customer Owner", "menu-customer-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(customerId);
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Menu Customer Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/menus",
                new HttpEntity<>(Map.of(), ownerHeaders(customerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createSecondMenu_promotesNewMenuAndKeepsHistory() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu History Owner", "menu-history-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Menu History Shop");
        final UUID firstMenuId = createMenuForShop(ownerId, shopId);

        final ResponseEntity<Map> secondResponse = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/menus",
                new HttpEntity<>(Map.of("label", "Summer Menu"), ownerHeaders(ownerId)),
                Map.class);
        assertThat(secondResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<Map> shopResponse = restTemplate.getForEntity(
                "/api/v1/shop/" + shopId, Map.class);
        final Map<String, Object> currentMenu = (Map<String, Object>) shopResponse.getBody().get("currentMenu");
        assertThat(currentMenu.get("id").toString()).isEqualTo(secondResponse.getBody().get("id").toString());

        final java.util.List<Map<String, Object>> history =
                (java.util.List<Map<String, Object>>) shopResponse.getBody().get("menuHistory");
        assertThat(history).hasSize(1);
        assertThat(history.get(0).get("id").toString()).isEqualTo(firstMenuId.toString());
    }

    @Test
    void createMenuItem_onHistoricalMenu_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu Historical Owner", "menu-historical-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Menu Historical Shop");
        final UUID historicalMenuId = createMenuForShop(ownerId, shopId);
        createMenuForShop(ownerId, shopId);

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/menu-item",
                new HttpEntity<>(Map.of(
                        "name", "Old Item",
                        "price", 3.50,
                        "priceCurrency", "USD",
                        "menuId", historicalMenuId), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
    }

    @Test
    @SuppressWarnings("unchecked")
    void createMenuItem_onCurrentMenu_returnsCreated() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu Item Current Owner", "menu-item-current-owner@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Menu Item Current Shop");
        final UUID menuId = createMenuForShop(ownerId, shopId);

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/menu-item",
                new HttpEntity<>(Map.of(
                        "name", "Latte",
                        "price", 4.50,
                        "priceCurrency", "USD",
                        "menuId", menuId,
                        "itemType", "DRINK"), ownerHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("itemType")).isEqualTo("DRINK");
    }

    @Test
    @SuppressWarnings("unchecked")
    void createMenuItem_withoutItemType_defaultsToFood() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Menu Item Default Type Owner", "menu-item-default-type@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        final UUID shopId = createShopWithOwner(ownerId, "Menu Item Default Type Shop");
        final UUID menuId = createMenuForShop(ownerId, shopId);

        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/menu-item",
                new HttpEntity<>(Map.of(
                        "name", "Sandwich",
                        "price", 8.99,
                        "priceCurrency", "USD",
                        "menuId", menuId), ownerHeaders(ownerId)),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("itemType")).isEqualTo("FOOD");
    }

    @Test
    void createTable_onOtherOwnersShop_returnsForbidden() {
        final HttpHeaders headers = authHeaders();
        final UUID ownerId = createUser(headers, "Table Forbidden Owner", "table-forbidden-owner@example.com", "SHOP_OWNER");
        final UUID otherOwnerId = createUser(headers, "Table Forbidden Other", "table-forbidden-other@example.com", "SHOP_OWNER");
        linkKeycloakSubject(ownerId);
        linkKeycloakSubject(otherOwnerId);
        final UUID otherShopId = createShopWithOwner(otherOwnerId, "Table Forbidden Shop");

        final ResponseEntity<String> response = restTemplate.postForEntity(
                "/api/v1/table",
                new HttpEntity<>(Map.of(
                        "number", 1,
                        "capacity", 4,
                        "shopId", otherShopId), ownerHeaders(ownerId)),
                String.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
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

    private UUID createMenuForShop(final UUID ownerId, final UUID shopId) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/shop/" + shopId + "/menus",
                new HttpEntity<>(Map.of(), ownerHeaders(ownerId)),
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
