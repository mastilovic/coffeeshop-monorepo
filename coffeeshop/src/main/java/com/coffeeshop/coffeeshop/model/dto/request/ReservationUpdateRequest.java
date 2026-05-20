package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class ReservationUpdateRequest {
    private UUID userId;
    private UUID tableId;

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
}
