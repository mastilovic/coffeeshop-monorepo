package com.coffeeshop.coffeeshop.model.dto.response;

import java.util.List;
import java.util.UUID;

public class TableResponseDto {
    private UUID id;
    private int number;
    private int capacity;
    private UUID shopId;
    private List<ReservationResponseDto> reservations;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

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

    public List<ReservationResponseDto> getReservations() {
        return reservations;
    }

    public void setReservations(final List<ReservationResponseDto> reservations) {
        this.reservations = reservations;
    }
}
