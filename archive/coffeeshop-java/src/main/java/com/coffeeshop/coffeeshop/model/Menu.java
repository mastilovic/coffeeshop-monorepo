package com.coffeeshop.coffeeshop.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Entity
public class Menu {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    private String label;

    @Column(nullable = false, updatable = false)
    private Instant createdAt;

    @JsonIgnoreProperties(value = {"menus", "currentMenu", "events", "tables", "reviews", "contacts", "users"})
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @JsonIgnoreProperties(value = {"menu"})
    @OneToMany(mappedBy = "menu", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<MenuItem> items;

    public Menu() {
    }

    @PrePersist
    void onCreate() {
        if (createdAt == null) {
            createdAt = Instant.now();
        }
    }

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(final String label) {
        this.label = label;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(final Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(final Shop shop) {
        this.shop = shop;
    }

    public List<MenuItem> getItems() {
        return items;
    }

    public void setItems(final List<MenuItem> items) {
        this.items = items;
    }
}
