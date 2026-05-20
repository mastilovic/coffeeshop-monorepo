package com.coffeeshop.coffeeshop.model.dto.response;

import com.coffeeshop.coffeeshop.model.enums.ReservationStatus;

import java.util.UUID;

public class ReservationRequestResponseDto {
    private UUID id;
    private UserSummaryDto user;
    private ShopSummaryDto shop;
    private int partySize;
    private ReservationStatus status;
    private UUID reservationId;
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

    public ReservationStatus getStatus() {
        return status;
    }

    public void setStatus(final ReservationStatus status) {
        this.status = status;
    }

    public UUID getReservationId() {
        return reservationId;
    }

    public void setReservationId(final UUID reservationId) {
        this.reservationId = reservationId;
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
