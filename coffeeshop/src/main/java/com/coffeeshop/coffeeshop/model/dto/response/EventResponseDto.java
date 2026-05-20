package com.coffeeshop.coffeeshop.model.dto.response;

import java.util.UUID;

public class EventResponseDto {
    private String eventId;
    private String eventName;
    private String eventDate;
    private String description;
    private UUID shopId;
    private String shopName;
    private String shopCity;
    private long totalTables;
    private long reservedTables;
    private long freeTables;
    private Boolean isFull;

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

    public String getShopName() {
        return shopName;
    }

    public void setShopName(final String shopName) {
        this.shopName = shopName;
    }

    public String getShopCity() {
        return shopCity;
    }

    public void setShopCity(final String shopCity) {
        this.shopCity = shopCity;
    }

    public long getTotalTables() {
        return totalTables;
    }

    public void setTotalTables(final long totalTables) {
        this.totalTables = totalTables;
    }

    public long getReservedTables() {
        return reservedTables;
    }

    public void setReservedTables(final long reservedTables) {
        this.reservedTables = reservedTables;
    }

    public long getFreeTables() {
        return freeTables;
    }

    public void setFreeTables(final long freeTables) {
        this.freeTables = freeTables;
    }

    public Boolean getIsFull() {
        return isFull;
    }

    public void setIsFull(final Boolean isFull) {
        this.isFull = isFull;
    }
}
