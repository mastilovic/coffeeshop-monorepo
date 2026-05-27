package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Menu;

import java.util.List;
import java.util.UUID;

public interface MenuService {

    List<Menu> findAll();

    Menu getById(UUID id);

    List<Menu> findByShopId(UUID shopId);

    Menu createForShop(UUID shopId, String label);

    Menu create(Menu entity);

    Menu update(UUID id, Menu entity);

    void deleteById(UUID id);
}
