package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class ReservationRequestCreateRequest {
    private UUID userId;
    private UUID shopId;
    private String eventId;
    private int partySize;

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(final UUID userId) {
        this.userId = userId;
    }

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(final String eventId) {
        this.eventId = eventId;
    }

    public int getPartySize() {
        return partySize;
    }

    public void setPartySize(final int partySize) {
        this.partySize = partySize;
    }
}
