package com.coffeeshop.coffeeshop.model.dto.response;

import com.coffeeshop.coffeeshop.model.enums.RoleType;

import java.util.UUID;

public class RoleResponseDto {
    private UUID id;
    private String name;
    private RoleType type;

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

    public RoleType getType() {
        return type;
    }

    public void setType(final RoleType type) {
        this.type = type;
    }
}
