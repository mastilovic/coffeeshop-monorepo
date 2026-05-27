package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class ReservationCreateRequest {
    private UUID userId;
    private UUID tableId;
    private String eventId;
    private int partySize;

    public UUID getUserId() {
        return userId;
    }

    public void setUserId(final UUID userId) {
        this.userId = userId;
    }

    public UUID getTableId() {
        return tableId;
    }

    public void setTableId(final UUID tableId) {
        this.tableId = tableId;
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
