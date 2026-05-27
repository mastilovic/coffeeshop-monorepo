package com.coffeeshop.coffeeshop.model.dto.request;

import java.util.UUID;

public class ReservationAcceptRequest {
    private UUID tableId;

    public UUID getTableId() {
        return tableId;
    }

    public void setTableId(final UUID tableId) {
        this.tableId = tableId;
    }
}
