package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.dto.response.MenuResponseDto;
import org.springframework.stereotype.Service;

@Service
public class MenuMapper {

    private final MenuItemMapper menuItemMapper;

    public MenuMapper(final MenuItemMapper menuItemMapper) {
        this.menuItemMapper = menuItemMapper;
    }

    public MenuResponseDto toMenuResponse(final Menu menu) {
        return toMenuResponse(menu, null);
    }

    public MenuResponseDto toMenuResponse(final Menu menu, final Shop shop) {
        if (menu == null) {
            return null;
        }
        final MenuResponseDto dto = new MenuResponseDto();
        dto.setId(menu.getId());
        dto.setLabel(menu.getLabel());
        dto.setCreatedAt(menu.getCreatedAt());
        if (menu.getShop() != null) {
            dto.setShopId(menu.getShop().getId());
        } else if (shop != null) {
            dto.setShopId(shop.getId());
        }
        if (shop != null && shop.getCurrentMenu() != null) {
            dto.setCurrent(menu.getId().equals(shop.getCurrentMenu().getId()));
        }
        dto.setItems(MappingUtils.mapList(menu.getItems(), menuItemMapper::toMenuItemResponse));
        return dto;
    }

    public Menu newMenu() {
        return new Menu();
    }
}
