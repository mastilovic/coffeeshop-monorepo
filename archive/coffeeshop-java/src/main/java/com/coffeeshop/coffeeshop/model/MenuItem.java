package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.MenuItemType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@jakarta.persistence.Table(name = "menu_item")
public class MenuItem {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String name;
    private String description;
    @Column(precision = 12, scale = 2)
    private BigDecimal price;
    private String priceCurrency;
    private String imageUrl;
    @Enumerated(EnumType.STRING)
    @Column(name = "item_type", nullable = false)
    private MenuItemType itemType = MenuItemType.FOOD;
    @JsonIgnoreProperties(value = {"items", "shop"})
    @ManyToOne
    @JoinColumn(name = "menu_id")
    private Menu menu;

    public MenuItem() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public Menu getMenu() {
        return menu;
    }

    public void setMenu(Menu menu) {
        this.menu = menu;
    }

    public String getPriceCurrency() {
        return priceCurrency;
    }

    public void setPriceCurrency(String priceCurrency) {
        this.priceCurrency = priceCurrency;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public MenuItemType getItemType() {
        return itemType;
    }

    public void setItemType(final MenuItemType itemType) {
        this.itemType = itemType;
    }
}
