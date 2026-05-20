package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;

import java.util.List;
import java.util.UUID;

public interface UserShopService {

    void assignOwner(User user, Shop shop);

    void replaceOwner(Shop shop, User newOwner);

    void setFavouriteShops(User user, List<Shop> shops);

    boolean isOwner(User user, Shop shop);

    boolean ownsAnyShop(UUID userId);

    User resolveOwner(Shop shop);

    List<User> findFavouriteUsers(Shop shop);

    List<Shop> findFavouriteShops(User user);

    List<Shop> findOwnedShops(UUID userId);

    void addFavourite(User user, Shop shop);

    void removeFavourite(User user, Shop shop);

    boolean isFavourite(User user, Shop shop);
}
