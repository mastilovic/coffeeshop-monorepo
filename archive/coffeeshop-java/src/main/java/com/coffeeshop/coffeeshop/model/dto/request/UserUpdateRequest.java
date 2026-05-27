package com.coffeeshop.coffeeshop.model.dto.request;

import com.coffeeshop.coffeeshop.model.enums.UserType;

import java.util.List;
import java.util.UUID;

public class UserUpdateRequest {
    private String name;
    private String username;
    private String email;
    private String password;
    private UserType userType;
    private List<UUID> roleIds;
    private List<UUID> favouriteShopIds;

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(final String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(final String password) {
        this.password = password;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(final UserType userType) {
        this.userType = userType;
    }

    public List<UUID> getRoleIds() {
        return roleIds;
    }

    public void setRoleIds(final List<UUID> roleIds) {
        this.roleIds = roleIds;
    }

    public List<UUID> getFavouriteShopIds() {
        return favouriteShopIds;
    }

    public void setFavouriteShopIds(final List<UUID> favouriteShopIds) {
        this.favouriteShopIds = favouriteShopIds;
    }
}
