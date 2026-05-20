package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.MenuItem;
import com.coffeeshop.coffeeshop.model.enums.MenuItemType;
import com.coffeeshop.coffeeshop.model.dto.request.MenuItemCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.MenuItemUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.MenuItemResponseDto;
import org.springframework.stereotype.Service;

@Service
public class MenuItemMapper {

    public MenuItemResponseDto toMenuItemResponse(final MenuItem item) {
        if (item == null) {
            return null;
        }
        final MenuItemResponseDto dto = new MenuItemResponseDto();
        dto.setId(item.getId());
        dto.setName(item.getName());
        dto.setDescription(item.getDescription());
        dto.setPrice(item.getPrice());
        dto.setPriceCurrency(item.getPriceCurrency());
        dto.setImageUrl(item.getImageUrl());
        dto.setMenuId(item.getMenu() != null ? item.getMenu().getId() : null);
        dto.setItemType(item.getItemType());
        return dto;
    }

    public MenuItem toMenuItem(final MenuItemCreateRequest request) {
        final MenuItem item = new MenuItem();
        item.setName(request.getName());
        item.setDescription(request.getDescription());
        item.setPrice(request.getPrice());
        item.setPriceCurrency(request.getPriceCurrency());
        item.setImageUrl(request.getImageUrl());
        item.setItemType(resolveItemType(request.getItemType()));
        if (request.getMenuId() != null) {
            final Menu menu = new Menu();
            menu.setId(request.getMenuId());
            item.setMenu(menu);
        }
        return item;
    }

    public MenuItem toMenuItem(final MenuItemUpdateRequest request) {
        final MenuItem item = new MenuItem();
        item.setName(request.getName());
        item.setDescription(request.getDescription());
        item.setPrice(request.getPrice());
        item.setPriceCurrency(request.getPriceCurrency());
        item.setImageUrl(request.getImageUrl());
        item.setItemType(request.getItemType());
        if (request.getMenuId() != null) {
            final Menu menu = new Menu();
            menu.setId(request.getMenuId());
            item.setMenu(menu);
        }
        return item;
    }

    private MenuItemType resolveItemType(final MenuItemType itemType) {
        return itemType != null ? itemType : MenuItemType.FOOD;
    }
}
