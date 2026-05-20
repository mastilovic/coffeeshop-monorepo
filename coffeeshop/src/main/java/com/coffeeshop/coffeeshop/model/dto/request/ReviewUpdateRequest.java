package com.coffeeshop.coffeeshop.model.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public class ReviewUpdateRequest {
    private String title;
    private String description;

    @Min(1)
    @Max(5)
    private Integer rating;

    private Boolean commentsEnabled;

    public String getTitle() {
        return title;
    }

    public void setTitle(final String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(final String description) {
        this.description = description;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(final Integer rating) {
        this.rating = rating;
    }

    public Boolean getCommentsEnabled() {
        return commentsEnabled;
    }

    public void setCommentsEnabled(final Boolean commentsEnabled) {
        this.commentsEnabled = commentsEnabled;
    }
}
