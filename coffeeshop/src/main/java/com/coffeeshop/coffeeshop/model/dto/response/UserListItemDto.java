package com.coffeeshop.coffeeshop.model.dto.response;

import com.coffeeshop.coffeeshop.model.enums.UserType;

import java.util.List;
import java.util.UUID;

public class UserListItemDto {
    private UUID id;
    private String name;
    private String email;
    private UserType userType;
    private List<RoleResponseDto> roles;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(final UserType userType) {
        this.userType = userType;
    }

    public List<RoleResponseDto> getRoles() {
        return roles;
    }

    public void setRoles(final List<RoleResponseDto> roles) {
        this.roles = roles;
    }
}
