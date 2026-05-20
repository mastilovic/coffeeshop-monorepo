package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class EventUpdateRequest {
    private String eventName;
    private String eventDate;
    private String description;
    private UUID shopId;

    public String getEventName() {
        return eventName;
    }

    public void setEventName(final String eventName) {
        this.eventName = eventName;
    }

    public String getEventDate() {
        return eventDate;
    }

    public void setEventDate(final String eventDate) {
        this.eventDate = eventDate;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(final String description) {
        this.description = description;
    }

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }
}
