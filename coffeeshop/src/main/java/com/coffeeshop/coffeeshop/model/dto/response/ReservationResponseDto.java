package com.coffeeshop.coffeeshop.model.dto.response;

import java.util.UUID;

public class ReservationResponseDto {
    private UUID id;
    private UserSummaryDto user;
    private ShopSummaryDto shop;
    private int partySize;
    private UUID reservationRequestId;
    private TableSummaryDto table;
    private String eventId;
    private String eventName;
    private String eventDate;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public UserSummaryDto getUser() {
        return user;
    }

    public void setUser(final UserSummaryDto user) {
        this.user = user;
    }

    public ShopSummaryDto getShop() {
        return shop;
    }

    public void setShop(final ShopSummaryDto shop) {
        this.shop = shop;
    }

    public int getPartySize() {
        return partySize;
    }

    public void setPartySize(final int partySize) {
        this.partySize = partySize;
    }

    public UUID getReservationRequestId() {
        return reservationRequestId;
    }

    public void setReservationRequestId(final UUID reservationRequestId) {
        this.reservationRequestId = reservationRequestId;
    }

    public TableSummaryDto getTable() {
        return table;
    }

    public void setTable(final TableSummaryDto table) {
        this.table = table;
    }

    public String getEventId() {
        return eventId;
    }

    public void setEventId(final String eventId) {
        this.eventId = eventId;
    }

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
}
