package com.coffeeshop.coffeeshop.model.dto.response;

import com.coffeeshop.coffeeshop.model.enums.MenuItemType;

import java.math.BigDecimal;
import java.util.UUID;

public class MenuItemResponseDto {
    private UUID id;
    private String name;
    private String description;
    private BigDecimal price;
    private String priceCurrency;
    private String imageUrl;
    private UUID menuId;
    private MenuItemType itemType;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(final String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(final BigDecimal price) {
        this.price = price;
    }

    public String getPriceCurrency() {
        return priceCurrency;
    }

    public void setPriceCurrency(final String priceCurrency) {
        this.priceCurrency = priceCurrency;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(final String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public UUID getMenuId() {
        return menuId;
    }

    public void setMenuId(final UUID menuId) {
        this.menuId = menuId;
    }

    public MenuItemType getItemType() {
        return itemType;
    }

    public void setItemType(final MenuItemType itemType) {
        this.itemType = itemType;
    }
}
