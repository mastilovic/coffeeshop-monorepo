package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.LoyaltyPlanType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.UUID;

@Entity
public class LoyaltyPlan {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String name;
    private String description;
    private LoyaltyPlanType type;
    @JsonIgnoreProperties(value = {"loyaltyPlan"})
    @OneToOne(mappedBy = "loyaltyPlan")
    private Shop shop;

    public LoyaltyPlan() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public LoyaltyPlanType getType() {
        return type;
    }

    public void setType(LoyaltyPlanType type) {
        this.type = type;
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(Shop shop) {
        this.shop = shop;
    }
}
