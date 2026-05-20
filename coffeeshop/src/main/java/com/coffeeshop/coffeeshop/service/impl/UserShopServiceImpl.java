package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.UserShop;
import com.coffeeshop.coffeeshop.model.enums.UserShopRelationshipType;
import com.coffeeshop.coffeeshop.repository.UserShopRepository;
import com.coffeeshop.coffeeshop.repository.UserShopSpecifications;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
public class UserShopServiceImpl implements UserShopService {

    private final UserShopRepository userShopRepository;

    public UserShopServiceImpl(final UserShopRepository userShopRepository) {
        this.userShopRepository = userShopRepository;
    }

    @Override
    public void assignOwner(final User user, final Shop shop) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("Owner user must have an ID");
        }
        if (shop == null || shop.getId() == null) {
            throw new IllegalArgumentException("Shop must be persisted before assigning an owner");
        }
        if (userShopRepository.countByShop_IdAndRelationshipType(shop.getId(), UserShopRelationshipType.OWNER) > 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Shop already has an owner");
        }
        if (userShopRepository.existsByUser_IdAndShop_IdAndRelationshipType(
                user.getId(), shop.getId(), UserShopRelationshipType.OWNER)) {
            return;
        }
        final var existing = userShopRepository.findByUser_IdAndShop_Id(user.getId(), shop.getId());
        if (existing.isPresent()) {
            final UserShop link = existing.get();
            link.setRelationshipType(UserShopRelationshipType.OWNER);
            userShopRepository.save(link);
            return;
        }
        userShopRepository.save(new UserShop(user, shop, UserShopRelationshipType.OWNER));
    }

    @Override
    public void replaceOwner(final Shop shop, final User newOwner) {
        if (shop == null || shop.getId() == null) {
            throw new IllegalArgumentException("Shop must have an ID");
        }
        if (newOwner == null || newOwner.getId() == null) {
            throw new IllegalArgumentException("New owner must have an ID");
        }
        userShopRepository.deleteByShop_IdAndRelationshipType(shop.getId(), UserShopRelationshipType.OWNER);
        assignOwner(newOwner, shop);
    }

    @Override
    public void setFavouriteShops(final User user, final List<Shop> shops) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("User must have an ID");
        }
        userShopRepository.deleteByUser_IdAndRelationshipType(user.getId(), UserShopRelationshipType.FAVOURITE);
        if (shops == null || shops.isEmpty()) {
            return;
        }
        for (final Shop shop : shops) {
            if (shop == null || shop.getId() == null) {
                throw new IllegalArgumentException("Each favourite shop must have an ID");
            }
            if (userShopRepository.existsByUser_IdAndShop_IdAndRelationshipType(
                    user.getId(), shop.getId(), UserShopRelationshipType.OWNER)) {
                continue;
            }
            if (!userShopRepository.existsByUser_IdAndShop_IdAndRelationshipType(
                    user.getId(), shop.getId(), UserShopRelationshipType.FAVOURITE)) {
                userShopRepository.save(new UserShop(user, shop, UserShopRelationshipType.FAVOURITE));
            }
        }
    }

    @Override
    public boolean isOwner(final User user, final Shop shop) {
        if (user == null || user.getId() == null || shop == null || shop.getId() == null) {
            return false;
        }
        return userShopRepository.existsByUser_IdAndShop_IdAndRelationshipType(
                user.getId(), shop.getId(), UserShopRelationshipType.OWNER);
    }

    @Override
    public boolean ownsAnyShop(final UUID userId) {
        if (userId == null) {
            return false;
        }
        return userShopRepository.existsByUser_IdAndRelationshipType(userId, UserShopRelationshipType.OWNER);
    }

    @Override
    public User resolveOwner(final Shop shop) {
        if (shop == null || shop.getId() == null) {
            return null;
        }
        return userShopRepository
                .findByShop_IdAndRelationshipType(shop.getId(), UserShopRelationshipType.OWNER)
                .map(UserShop::getUser)
                .orElse(null);
    }

    @Override
    public List<User> findFavouriteUsers(final Shop shop) {
        if (shop == null || shop.getId() == null) {
            return List.of();
        }
        return userShopRepository.findUsersByShopIdAndRelationshipType(shop.getId(), UserShopRelationshipType.FAVOURITE);
    }

    @Override
    public Page<User> findFavouriteUsers(
            final UUID shopId,
            final Optional<String> query,
            final Pageable pageable) {
        if (shopId == null) {
            return Page.empty(pageable);
        }
        return userShopRepository
                .findAll(UserShopSpecifications.forFavouriteMembers(shopId, query), pageable)
                .map(UserShop::getUser);
    }

    @Override
    public List<Shop> findFavouriteShops(final User user) {
        if (user == null || user.getId() == null) {
            return List.of();
        }
        return userShopRepository.findShopsByUserIdAndRelationshipType(user.getId(), UserShopRelationshipType.FAVOURITE);
    }

    @Override
    public List<Shop> findOwnedShops(final UUID userId) {
        if (userId == null) {
            return List.of();
        }
        return new ArrayList<>(userShopRepository.findShopsByUserIdAndRelationshipType(userId, UserShopRelationshipType.OWNER));
    }

    @Override
    public void addFavourite(final User user, final Shop shop) {
        if (user == null || user.getId() == null) {
            throw new IllegalArgumentException("User must have an ID");
        }
        if (shop == null || shop.getId() == null) {
            throw new IllegalArgumentException("Shop must have an ID");
        }
        if (isOwner(user, shop)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Shop owners cannot favourite their own shop");
        }
        if (isFavourite(user, shop)) {
            return;
        }
        userShopRepository.save(new UserShop(user, shop, UserShopRelationshipType.FAVOURITE));
    }

    @Override
    public void removeFavourite(final User user, final Shop shop) {
        if (user == null || user.getId() == null || shop == null || shop.getId() == null) {
            return;
        }
        userShopRepository.deleteByUser_IdAndShop_IdAndRelationshipType(
                user.getId(), shop.getId(), UserShopRelationshipType.FAVOURITE);
    }

    @Override
    public boolean isFavourite(final User user, final Shop shop) {
        if (user == null || user.getId() == null || shop == null || shop.getId() == null) {
            return false;
        }
        return userShopRepository.existsByUser_IdAndShop_IdAndRelationshipType(
                user.getId(), shop.getId(), UserShopRelationshipType.FAVOURITE);
    }
}
