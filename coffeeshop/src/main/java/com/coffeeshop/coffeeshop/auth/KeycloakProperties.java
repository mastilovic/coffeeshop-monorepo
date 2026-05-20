package com.coffeeshop.coffeeshop.auth;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "coffeeshop.keycloak")
public class KeycloakProperties {

    private String serverUrl = "http://localhost:8080";
    private String realm = "coffeeshop";
    private String clientId = "coffeeshop-backend";
    private String clientSecret = "local-backend-secret";
    private String adminUsername = "admin";
    private String adminPassword = "admin";

    public String tokenUri() {
        return serverUrl + "/realms/" + realm + "/protocol/openid-connect/token";
    }

    public String logoutUri() {
        return serverUrl + "/realms/" + realm + "/protocol/openid-connect/logout";
    }

    public String adminTokenUri() {
        return serverUrl + "/realms/master/protocol/openid-connect/token";
    }

    public String adminUsersBaseUri() {
        return serverUrl + "/admin/realms/" + realm + "/users";
    }

    public String adminRoleUri(final String roleName) {
        return serverUrl + "/admin/realms/" + realm + "/roles/" + roleName;
    }

    public String getServerUrl() {
        return serverUrl;
    }

    public void setServerUrl(final String serverUrl) {
        this.serverUrl = serverUrl;
    }

    public String getRealm() {
        return realm;
    }

    public void setRealm(final String realm) {
        this.realm = realm;
    }

    public String getClientId() {
        return clientId;
    }

    public void setClientId(final String clientId) {
        this.clientId = clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public void setClientSecret(final String clientSecret) {
        this.clientSecret = clientSecret;
    }

    public String getAdminUsername() {
        return adminUsername;
    }

    public void setAdminUsername(final String adminUsername) {
        this.adminUsername = adminUsername;
    }

    public String getAdminPassword() {
        return adminPassword;
    }

    public void setAdminPassword(final String adminPassword) {
        this.adminPassword = adminPassword;
    }
}
