package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Shop;

import java.util.List;
import java.util.UUID;

public interface ShopService {

    List<Shop> findAll();

    List<Shop> findByCurrentUser();

    Shop getById(UUID id);

    Shop create(Shop entity);

    Shop update(UUID id, Shop entity);

    void deleteById(UUID id);

    Shop addFavourite(UUID shopId);

    Shop removeFavourite(UUID shopId);
}
