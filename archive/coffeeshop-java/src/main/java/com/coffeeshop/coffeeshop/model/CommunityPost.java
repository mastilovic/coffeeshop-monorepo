package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.CommunityPostType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@jakarta.persistence.Table(name = "community_post")
public class CommunityPost {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(nullable = false, length = 2000)
    private String body;

    @Column(nullable = false)
    private Instant createdAt;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CommunityPostType type;

    @Column(nullable = false)
    private boolean pinned;

    @JsonIgnoreProperties(value = {"reviews", "shops", "reservations"})
    @ManyToOne(optional = false)
    @JoinColumn(name = "author_id")
    private User author;

    @JsonIgnoreProperties(value = {"users", "reviews", "tables", "events"})
    @ManyToOne(optional = false)
    @JoinColumn(name = "shop_id")
    private Shop shop;

    public CommunityPost() {
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

    public User getAuthor() {
        return author;
    }

    public void setAuthor(final User author) {
        this.author = author;
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(final Shop shop) {
        this.shop = shop;
    }
}
