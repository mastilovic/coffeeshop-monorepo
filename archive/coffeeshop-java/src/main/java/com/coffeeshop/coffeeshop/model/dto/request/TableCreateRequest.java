package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class TableCreateRequest {
    private int number;
    private int capacity;
    private UUID shopId;

    public int getNumber() {
        return number;
    }

    public void setNumber(final int number) {
        this.number = number;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(final int capacity) {
        this.capacity = capacity;
    }

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }
}
