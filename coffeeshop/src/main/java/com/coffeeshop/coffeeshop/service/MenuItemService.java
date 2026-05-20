package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.MenuItem;

import java.util.List;
import java.util.UUID;

public interface MenuItemService {

    List<MenuItem> findAll();

    MenuItem getById(UUID id);

    MenuItem create(MenuItem entity);

    MenuItem update(UUID id, MenuItem entity);

    void deleteById(UUID id);
}
