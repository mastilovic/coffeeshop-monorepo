package com.coffeeshop.coffeeshop.model.dto.request;

import com.coffeeshop.coffeeshop.model.enums.RoleType;

public class RoleCreateRequest {
    private String name;
    private RoleType type;

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
