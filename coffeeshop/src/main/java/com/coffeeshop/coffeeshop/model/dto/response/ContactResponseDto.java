package com.coffeeshop.coffeeshop.model.dto.response;

import java.util.UUID;

public class ContactResponseDto {
    private UUID id;
    private UUID shopId;

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
}
