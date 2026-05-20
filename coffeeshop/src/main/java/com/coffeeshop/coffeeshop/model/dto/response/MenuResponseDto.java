package com.coffeeshop.coffeeshop.model.dto.response;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class MenuResponseDto {
    private UUID id;
    private UUID shopId;
    private String label;
    private Instant createdAt;
    private boolean current;
    private List<MenuItemResponseDto> items;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(final String label) {
        this.label = label;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(final Instant createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isCurrent() {
        return current;
    }

    public void setCurrent(final boolean current) {
        this.current = current;
    }

    public List<MenuItemResponseDto> getItems() {
        return items;
    }

    public void setItems(final List<MenuItemResponseDto> items) {
        this.items = items;
    }
}
