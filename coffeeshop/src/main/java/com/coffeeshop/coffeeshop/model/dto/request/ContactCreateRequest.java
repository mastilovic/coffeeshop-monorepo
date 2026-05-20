package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class ContactCreateRequest {
    private UUID shopId;

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }
}
