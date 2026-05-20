package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Role;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.RoleRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import com.coffeeshop.coffeeshop.repository.UserSpecifications;
import com.coffeeshop.coffeeshop.service.UserService;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ShopRepository shopRepository;
    private final UserShopService userShopService;

    public UserServiceImpl(
            final UserRepository userRepository,
            final RoleRepository roleRepository,
            final ShopRepository shopRepository,
            final UserShopService userShopService) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.shopRepository = shopRepository;
        this.userShopService = userShopService;
    }

    @Override
    public List<User> findAll() {
        return userRepository.findAll();
    }

    @Override
    public Page<User> search(final Optional<String> query, final Pageable pageable) {
        return userRepository.findAll(UserSpecifications.search(query), pageable);
    }

    @Override
    public User getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        return userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + id));
    }

    @Override
    public User getByEmail(final String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email cannot be null or blank");
        }
        return userRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
    }

    @Override
    public User create(final User entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("User ID must be null on create");
        }
        if (entity.getReviews() != null && !entity.getReviews().isEmpty()) {
            throw new IllegalArgumentException("Reviews cannot be set on user create");
        }
        if (entity.getReservations() != null && !entity.getReservations().isEmpty()) {
            throw new IllegalArgumentException("Reservations cannot be set on user create");
        }
        if (entity.getRole() != null && !entity.getRole().isEmpty()) {
            entity.setRole(resolveRoles(entity.getRole()));
        }
        final User saved = userRepository.save(entity);
        if (entity.getFavouriteShopIdsForUpdate() != null && !entity.getFavouriteShopIdsForUpdate().isEmpty()) {
            userShopService.setFavouriteShops(saved, resolveShopsByIds(entity.getFavouriteShopIdsForUpdate()));
        }
        return saved;
    }

    @Override
    public User update(final UUID id, final User entity) {
        final User existing = getById(id);
        if (entity.getName() != null) {
            existing.setName(entity.getName());
        }
        if (entity.getEmail() != null) {
            existing.setEmail(entity.getEmail());
        }
        if (entity.getPassword() != null) {
            existing.setPassword(entity.getPassword());
        }
        if (entity.getUserType() != null) {
            existing.setUserType(entity.getUserType());
        }
        if (entity.getRole() != null) {
            if (entity.getRole().isEmpty()) {
                existing.setRole(entity.getRole());
            } else {
                existing.setRole(resolveRoles(entity.getRole()));
            }
        }
        if (entity.getFavouriteShopIdsForUpdate() != null) {
            userShopService.setFavouriteShops(
                    existing,
                    entity.getFavouriteShopIdsForUpdate().isEmpty()
                            ? List.of()
                            : resolveShopsByIds(entity.getFavouriteShopIdsForUpdate()));
        }
        return userRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }

    private List<Role> resolveRoles(final List<Role> roles) {
        final List<Role> resolved = new ArrayList<>();
        for (final Role role : roles) {
            if (role == null || role.getId() == null) {
                throw new IllegalArgumentException("Each role must have an ID");
            }
            resolved.add(roleRepository.findById(role.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + role.getId())));
        }
        return resolved;
    }

    private List<Shop> resolveShopsByIds(final List<UUID> shopIds) {
        final List<Shop> resolved = new ArrayList<>();
        for (final UUID shopId : shopIds) {
            if (shopId == null) {
                throw new IllegalArgumentException("Each shop must have an ID");
            }
            resolved.add(shopRepository.findById(shopId)
                    .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + shopId)));
        }
        return resolved;
    }
}
