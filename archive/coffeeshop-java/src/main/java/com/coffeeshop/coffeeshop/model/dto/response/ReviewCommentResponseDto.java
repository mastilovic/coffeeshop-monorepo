package com.coffeeshop.coffeeshop.model.dto.response;

import java.time.Instant;
import java.util.UUID;

public class ReviewCommentResponseDto {
    private UUID id;
    private String body;
    private Instant createdAt;
    private UserSummaryDto user;

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

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(final Instant createdAt) {
        this.createdAt = createdAt;
    }

    public UserSummaryDto getUser() {
        return user;
    }

    public void setUser(final UserSummaryDto user) {
        this.user = user;
    }
}
