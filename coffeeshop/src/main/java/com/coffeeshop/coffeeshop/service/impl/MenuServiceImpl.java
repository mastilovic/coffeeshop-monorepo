package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.auth.ShopOwnershipService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.MenuRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.service.MenuService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class MenuServiceImpl implements MenuService {

    private static final DateTimeFormatter LABEL_FORMAT =
            DateTimeFormatter.ofPattern("MMM d, yyyy").withZone(ZoneId.systemDefault());

    private final MenuRepository menuRepository;
    private final ShopRepository shopRepository;
    private final ShopOwnershipService shopOwnershipService;
    private final CurrentUserService currentUserService;

    public MenuServiceImpl(
            final MenuRepository menuRepository,
            final ShopRepository shopRepository,
            final ShopOwnershipService shopOwnershipService,
            final CurrentUserService currentUserService) {
        this.menuRepository = menuRepository;
        this.shopRepository = shopRepository;
        this.shopOwnershipService = shopOwnershipService;
        this.currentUserService = currentUserService;
    }

    @Override
    public List<Menu> findAll() {
        return menuRepository.findAll();
    }

    @Override
    public Menu getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Menu ID cannot be null");
        }
        return menuRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Menu not found with id: " + id));
    }

    @Override
    public List<Menu> findByShopId(final UUID shopId) {
        if (shopId == null) {
            throw new IllegalArgumentException("Shop ID cannot be null");
        }
        getShop(shopId);
        return menuRepository.findByShop_IdOrderByCreatedAtDesc(shopId);
    }

    @Override
    public Menu createForShop(final UUID shopId, final String label) {
        if (shopId == null) {
            throw new IllegalArgumentException("Shop ID cannot be null");
        }
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertShopOwnerOrAdmin(currentUser);
        final Shop shop = getShop(shopId);
        shopOwnershipService.assertOwned(shop, currentUser);

        final Menu menu = new Menu();
        menu.setShop(shop);
        menu.setCreatedAt(Instant.now());
        menu.setLabel(label != null && !label.isBlank() ? label.trim() : defaultLabel(menu.getCreatedAt()));
        final Menu saved = menuRepository.save(menu);
        shop.setCurrentMenu(saved);
        shopRepository.save(shop);
        return saved;
    }

    @Override
    public Menu create(final Menu entity) {
        throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Use POST /api/v1/shop/{shopId}/menus to create a menu for a shop");
    }

    @Override
    public Menu update(final UUID id, final Menu entity) {
        if (entity == null) {
            throw new IllegalArgumentException("Menu payload cannot be null");
        }
        final Menu existing = getById(id);
        assertMenuMutable(existing);
        return menuRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Menu ID cannot be null");
        }
        final Menu menu = getById(id);
        assertMenuMutable(menu);
        final Shop shop = menu.getShop();
        if (shop != null && shop.getCurrentMenu() != null && shop.getCurrentMenu().getId().equals(id)) {
            shop.setCurrentMenu(null);
            shopRepository.save(shop);
        }
        menuRepository.deleteById(id);
    }

    private void assertMenuMutable(final Menu menu) {
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertShopOwnerOrAdmin(currentUser);
        final Shop shop = requireShopForMenu(menu);
        shopOwnershipService.assertOwned(shop, currentUser);
    }

    private Shop requireShopForMenu(final Menu menu) {
        if (menu.getShop() == null) {
            throw new ResourceNotFoundException("Shop not found for menu id: " + menu.getId());
        }
        return menu.getShop();
    }

    private Shop getShop(final UUID shopId) {
        return shopRepository.findById(shopId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + shopId));
    }

    private static String defaultLabel(final Instant createdAt) {
        return "Menu – " + LABEL_FORMAT.format(createdAt);
    }
}
