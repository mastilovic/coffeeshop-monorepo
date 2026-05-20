package com.coffeeshop.coffeeshop.model.dto.request;

import com.coffeeshop.coffeeshop.model.enums.LoyaltyPlanType;

public class LoyaltyPlanCreateRequest {
    private String name;
    private String description;
    private LoyaltyPlanType type;

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(final String description) {
        this.description = description;
    }

    public LoyaltyPlanType getType() {
        return type;
    }

    public void setType(final LoyaltyPlanType type) {
        this.type = type;
    }
}
