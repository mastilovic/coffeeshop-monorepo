package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Shop;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ShopService {

    List<Shop> findAll();

    Page<Shop> search(Optional<String> query, Pageable pageable);

    List<Shop> findByCurrentUser();

    Shop getById(UUID id);

    Shop create(Shop entity);

    Shop update(UUID id, Shop entity);

    void deleteById(UUID id);

    Shop addFavourite(UUID shopId);

    Shop removeFavourite(UUID shopId);
}
