package com.coffeeshop.coffeeshop.model.dto.request;

import com.coffeeshop.coffeeshop.validation.ValidSerbiaCity;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

import java.util.UUID;

public class ShopCreateRequest {
    private String name;
    private String address;
    @NotBlank
    @ValidSerbiaCity
    private String city;
    private String phoneNumber;
    @Schema(
            requiredMode = Schema.RequiredMode.NOT_REQUIRED,
            deprecated = true,
            description = "Ignored on create. Shop email is set from the authenticated user's account email.")
    private String email;
    @Schema(
            requiredMode = Schema.RequiredMode.NOT_REQUIRED,
            deprecated = true,
            description = "Ignored on create. Shop owner is set from the authenticated user.")
    private UUID createdByUserId;
    @Schema(
            requiredMode = Schema.RequiredMode.NOT_REQUIRED,
            description = "Optional. ID of an existing menu to link; omit or null if the shop has no menu yet.")
    private UUID menuId;
    @Schema(
            requiredMode = Schema.RequiredMode.NOT_REQUIRED,
            description = "Optional. ID of an existing loyalty plan to link; omit or null if none.")
    private UUID loyaltyPlanId;

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(final String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(final String city) {
        this.city = city;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(final String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public UUID getCreatedByUserId() {
        return createdByUserId;
    }

    public void setCreatedByUserId(final UUID createdByUserId) {
        this.createdByUserId = createdByUserId;
    }

    public UUID getMenuId() {
        return menuId;
    }

    public void setMenuId(final UUID menuId) {
        this.menuId = menuId;
    }

    public UUID getLoyaltyPlanId() {
        return loyaltyPlanId;
    }

    public void setLoyaltyPlanId(final UUID loyaltyPlanId) {
        this.loyaltyPlanId = loyaltyPlanId;
    }
}
