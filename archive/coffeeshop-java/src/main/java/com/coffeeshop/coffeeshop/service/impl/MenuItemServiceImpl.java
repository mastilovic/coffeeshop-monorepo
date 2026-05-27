package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.auth.ShopOwnershipService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.MenuItem;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.MenuItemRepository;
import com.coffeeshop.coffeeshop.repository.MenuRepository;
import com.coffeeshop.coffeeshop.service.MenuItemService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class MenuItemServiceImpl implements MenuItemService {

    private final MenuItemRepository menuItemRepository;
    private final MenuRepository menuRepository;
    private final ShopOwnershipService shopOwnershipService;
    private final CurrentUserService currentUserService;

    public MenuItemServiceImpl(
            final MenuItemRepository menuItemRepository,
            final MenuRepository menuRepository,
            final ShopOwnershipService shopOwnershipService,
            final CurrentUserService currentUserService) {
        this.menuItemRepository = menuItemRepository;
        this.menuRepository = menuRepository;
        this.shopOwnershipService = shopOwnershipService;
        this.currentUserService = currentUserService;
    }

    @Override
    public List<MenuItem> findAll() {
        return menuItemRepository.findAll();
    }

    @Override
    public MenuItem getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Menu item ID cannot be null");
        }
        return menuItemRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Menu item not found with id: " + id));
    }

    @Override
    public MenuItem create(final MenuItem entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Menu item ID must be null on create");
        }
        final Menu menu = resolveMenu(entity.getMenu());
        assertMenuMutable(menu);
        entity.setMenu(menu);
        return menuItemRepository.save(entity);
    }

    @Override
    public MenuItem update(final UUID id, final MenuItem entity) {
        final MenuItem existing = getById(id);
        assertMenuMutable(existing.getMenu());
        if (entity.getName() != null) {
            existing.setName(entity.getName());
        }
        if (entity.getDescription() != null) {
            existing.setDescription(entity.getDescription());
        }
        if (entity.getPrice() != null) {
            existing.setPrice(entity.getPrice());
        }
        if (entity.getPriceCurrency() != null) {
            existing.setPriceCurrency(entity.getPriceCurrency());
        }
        if (entity.getImageUrl() != null) {
            existing.setImageUrl(entity.getImageUrl());
        }
        if (entity.getItemType() != null) {
            existing.setItemType(entity.getItemType());
        }
        if (entity.getMenu() != null) {
            final Menu menu = resolveMenu(entity.getMenu());
            assertMenuMutable(menu);
            existing.setMenu(menu);
        }
        return menuItemRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Menu item ID cannot be null");
        }
        final MenuItem item = getById(id);
        assertMenuMutable(item.getMenu());
        menuItemRepository.deleteById(id);
    }

    private void assertMenuMutable(final Menu menu) {
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertShopOwnerOrAdmin(currentUser);
        final Shop shop = requireShopForMenu(menu);
        shopOwnershipService.assertOwned(shop, currentUser);
        if (shop.getCurrentMenu() == null || !shop.getCurrentMenu().getId().equals(menu.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Menu items can only be modified on the current menu");
        }
    }

    private Shop requireShopForMenu(final Menu menu) {
        if (menu.getShop() == null) {
            throw new ResourceNotFoundException("Shop not found for menu id: " + menu.getId());
        }
        return menu.getShop();
    }

    private Menu resolveMenu(final Menu ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("Menu is required with an ID");
        }
        return menuRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Menu not found with id: " + ref.getId()));
    }
}
