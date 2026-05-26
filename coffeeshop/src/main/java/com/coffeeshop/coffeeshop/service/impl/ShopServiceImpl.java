package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.auth.ShopOwnershipService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.LoyaltyPlan;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.repository.LoyaltyPlanRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.repository.ShopSpecifications;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import com.coffeeshop.coffeeshop.service.ReviewCommentLoader;
import com.coffeeshop.coffeeshop.service.ShopService;
import com.coffeeshop.coffeeshop.service.UserService;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
public class ShopServiceImpl implements ShopService {

    private final ShopRepository shopRepository;
    private final UserRepository userRepository;
    private final LoyaltyPlanRepository loyaltyPlanRepository;
    private final CurrentUserService currentUserService;
    private final UserService userService;
    private final ShopOwnershipService shopOwnershipService;
    private final ReviewCommentLoader reviewCommentLoader;
    private final UserShopService userShopService;

    public ShopServiceImpl(
            final ShopRepository shopRepository,
            final UserRepository userRepository,
            final LoyaltyPlanRepository loyaltyPlanRepository,
            final CurrentUserService currentUserService,
            final UserService userService,
            final ShopOwnershipService shopOwnershipService,
            final ReviewCommentLoader reviewCommentLoader,
            final UserShopService userShopService) {
        this.shopRepository = shopRepository;
        this.userRepository = userRepository;
        this.loyaltyPlanRepository = loyaltyPlanRepository;
        this.currentUserService = currentUserService;
        this.userService = userService;
        this.shopOwnershipService = shopOwnershipService;
        this.reviewCommentLoader = reviewCommentLoader;
        this.userShopService = userShopService;
    }

    @Override
    public List<Shop> findAll() {
        return shopRepository.findAll();
    }

    @Override
    public Page<Shop> search(final Optional<String> query, final Pageable pageable) {
        final Optional<UUID> favouriteUserId = currentUserService.getCurrentUser().map(User::getId);
        return shopRepository.findAll(ShopSpecifications.search(query, favouriteUserId), pageable);
    }

    @Override
    public List<Shop> findByCurrentUser() {
        final User user = currentUserService.requireCurrentUser();
        return userShopService.findOwnedShops(user.getId());
    }

    @Override
    public Shop getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Shop ID cannot be null");
        }
        final Shop shop = shopRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + id));
        if (shop.getReviews() != null) {
            reviewCommentLoader.loadCommentsForReviews(shop.getReviews());
        }
        return shop;
    }

    @Override
    public Shop create(final Shop entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Shop ID must be null on create");
        }
        rejectNonEmptyOwnedCollectionsOnCreate(entity);
        User owner = currentUserService.requireCurrentUser();
        if (!shopOwnershipService.isAdmin(owner) && owner.getUserType() != UserType.SHOP_OWNER) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only shop owners can create shops");
        }
        if (entity.getOwnerUserIdForCreate() != null) {
            if (!shopOwnershipService.isAdmin(owner)
                    && !entity.getOwnerUserIdForCreate().equals(owner.getId())) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "createdByUserId must match the authenticated user");
            }
            owner = resolveUser(entity.getOwnerUserIdForCreate());
        }
        entity.setEmail(owner.getEmail());
        if (entity.getLoyaltyPlan() != null) {
            entity.setLoyaltyPlan(resolveLoyaltyPlan(entity.getLoyaltyPlan()));
        }
        final Shop saved = shopRepository.save(entity);
        userShopService.assignOwner(owner, saved);
        return saved;
    }

    @Override
    public Shop update(final UUID id, final Shop entity) {
        final Shop existing = getById(id);
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertOwned(existing, currentUser);
        if (entity.getName() != null) {
            existing.setName(entity.getName());
        }
        if (entity.getAddress() != null) {
            existing.setAddress(entity.getAddress());
        }
        if (entity.getCity() != null) {
            existing.setCity(entity.getCity());
        }
        if (entity.getPhoneNumber() != null) {
            existing.setPhoneNumber(entity.getPhoneNumber());
        }
        if (entity.getEmail() != null) {
            existing.setEmail(entity.getEmail());
        }
        if (entity.getNewOwnerUserIdForUpdate() != null && shopOwnershipService.isAdmin(currentUser)) {
            userShopService.replaceOwner(existing, resolveUser(entity.getNewOwnerUserIdForUpdate()));
        }
        if (entity.getLoyaltyPlan() != null) {
            existing.setLoyaltyPlan(resolveLoyaltyPlan(entity.getLoyaltyPlan()));
        }
        return shopRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Shop ID cannot be null");
        }
        final Shop shop = getById(id);
        shopOwnershipService.assertOwned(shop, currentUserService.requireCurrentUser());
        shopRepository.deleteById(id);
    }

    @Override
    public Shop addFavourite(final UUID shopId) {
        final User user = currentUserService.requireCurrentUser();
        final Shop shop = getById(shopId);
        userShopService.addFavourite(user, shop);
        return getById(shopId);
    }

    @Override
    public Shop removeFavourite(final UUID shopId) {
        final User user = currentUserService.requireCurrentUser();
        final Shop shop = getById(shopId);
        userShopService.removeFavourite(user, shop);
        return getById(shopId);
    }

    private void rejectNonEmptyOwnedCollectionsOnCreate(final Shop entity) {
        if (entity.getEvents() != null && !entity.getEvents().isEmpty()) {
            throw new IllegalArgumentException("Shop events cannot be set on create");
        }
        if (entity.getTables() != null && !entity.getTables().isEmpty()) {
            throw new IllegalArgumentException("Shop tables cannot be set on create");
        }
        if (entity.getReviews() != null && !entity.getReviews().isEmpty()) {
            throw new IllegalArgumentException("Shop reviews cannot be set on create");
        }
        if (entity.getContacts() != null && !entity.getContacts().isEmpty()) {
            throw new IllegalArgumentException("Shop contacts cannot be set on create");
        }
    }

    private User resolveUser(final UUID userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
    }

    private User resolveUser(final User ref) {
        if (ref.getId() == null) {
            throw new IllegalArgumentException("User reference must have an ID");
        }
        return resolveUser(ref.getId());
    }

    private LoyaltyPlan resolveLoyaltyPlan(final LoyaltyPlan ref) {
        if (ref.getId() == null) {
            throw new IllegalArgumentException("Loyalty plan reference must have an ID");
        }
        return loyaltyPlanRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Loyalty plan not found with id: " + ref.getId()));
    }
}
