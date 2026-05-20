package com.coffeeshop.coffeeshop.model.dto.request;

/**
 * Optional label when creating a menu for a shop via {@code POST /api/v1/shop/{shopId}/menus}.
 */
public class MenuCreateRequest {

    private String label;

    public String getLabel() {
        return label;
    }

    public void setLabel(final String label) {
        this.label = label;
    }
}
