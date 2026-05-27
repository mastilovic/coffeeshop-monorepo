package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.UserShopRelationshipType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.UUID;

@Entity
@jakarta.persistence.Table(
        name = "user_shop",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "shop_id"}))
public class UserShop {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @JsonIgnoreProperties(value = {"userShops", "reviews", "reservations", "role"})
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @JsonIgnoreProperties(value = {"userShops", "menus", "events", "tables", "reviews", "contacts"})
    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "shop_id", nullable = false)
    private Shop shop;

    @Enumerated(EnumType.STRING)
    @Column(name = "relationship_type", nullable = false)
    private UserShopRelationshipType relationshipType;

    public UserShop() {
    }

    public UserShop(final User user, final Shop shop, final UserShopRelationshipType relationshipType) {
        this.user = user;
        this.shop = shop;
        this.relationshipType = relationshipType;
    }

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(final User user) {
        this.user = user;
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(final Shop shop) {
        this.shop = shop;
    }

    public UserShopRelationshipType getRelationshipType() {
        return relationshipType;
    }

    public void setRelationshipType(final UserShopRelationshipType relationshipType) {
        this.relationshipType = relationshipType;
    }
}
