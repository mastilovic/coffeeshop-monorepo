package com.coffeeshop.coffeeshop.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@jakarta.persistence.Table(name = "review_comment")
public class ReviewComment {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(nullable = false, length = 2000)
    private String body;

    @Column(nullable = false)
    private Instant createdAt;

    @JsonIgnoreProperties(value = {"reviews", "shops", "reservations"})
    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id")
    private User user;

    @JsonIgnoreProperties(value = {"comments", "user", "shop"})
    @ManyToOne(optional = false)
    @JoinColumn(name = "review_id")
    private Review review;

    public ReviewComment() {
    }

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

    public User getUser() {
        return user;
    }

    public void setUser(final User user) {
        this.user = user;
    }

    public Review getReview() {
        return review;
    }

    public void setReview(final Review review) {
        this.review = review;
    }
}
