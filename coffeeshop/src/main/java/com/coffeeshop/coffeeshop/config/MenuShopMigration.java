package com.coffeeshop.coffeeshop.config;

import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.MenuItem;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.enums.MenuItemType;
import com.coffeeshop.coffeeshop.repository.MenuItemRepository;
import com.coffeeshop.coffeeshop.repository.MenuRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class MenuShopMigration {

    private final ShopRepository shopRepository;
    private final MenuRepository menuRepository;
    private final MenuItemRepository menuItemRepository;

    public MenuShopMigration(
            final ShopRepository shopRepository,
            final MenuRepository menuRepository,
            final MenuItemRepository menuItemRepository) {
        this.shopRepository = shopRepository;
        this.menuRepository = menuRepository;
        this.menuItemRepository = menuItemRepository;
    }

    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void backfillMenuShopLinks() {
        for (final Shop shop : shopRepository.findAll()) {
            final Menu current = shop.getCurrentMenu();
            if (current != null && current.getShop() == null) {
                current.setShop(shop);
                menuRepository.save(current);
            }
        }
        for (final Menu menu : menuRepository.findAll()) {
            if (menu.getShop() == null) {
                shopRepository.findAll().stream()
                        .filter(s -> s.getCurrentMenu() != null && s.getCurrentMenu().getId().equals(menu.getId()))
                        .findFirst()
                        .ifPresent(shop -> {
                            menu.setShop(shop);
                            menuRepository.save(menu);
                        });
            }
        }
        backfillMenuItemTypes();
    }

    private void backfillMenuItemTypes() {
        for (final MenuItem item : menuItemRepository.findAll()) {
            if (item.getItemType() == null) {
                item.setItemType(MenuItemType.FOOD);
                menuItemRepository.save(item);
            }
        }
    }
}
