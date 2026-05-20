package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class TableUpdateRequest {
    private Integer number;
    private Integer capacity;
    private UUID shopId;

    public Integer getNumber() {
        return number;
    }

    public void setNumber(final Integer number) {
        this.number = number;
    }

    public Integer getCapacity() {
        return capacity;
    }

    public void setCapacity(final Integer capacity) {
        this.capacity = capacity;
    }

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }
}
