package com.coffeeshop.coffeeshop.model.dto.response;

import com.coffeeshop.coffeeshop.model.enums.CommunityPostType;

import java.time.Instant;
import java.util.UUID;

public class CommunityPostResponseDto {

    private UUID id;
    private String body;
    private CommunityPostType type;
    private boolean pinned;
    private Instant createdAt;
    private UserSummaryDto author;
    private UUID shopId;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public String getBody() {
        return body;
    }

    public void setBody(final String body) {
        this.body = body;
    }

    public CommunityPostType getType() {
        return type;
    }

    public void setType(final CommunityPostType type) {
        this.type = type;
    }

    public boolean isPinned() {
        return pinned;
    }

    public void setPinned(final boolean pinned) {
        this.pinned = pinned;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(final Instant createdAt) {
        this.createdAt = createdAt;
    }

    public UserSummaryDto getAuthor() {
        return author;
    }

    public void setAuthor(final UserSummaryDto author) {
        this.author = author;
    }

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }
}
