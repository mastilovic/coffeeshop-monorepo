package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.MenuMapper;
import com.coffeeshop.coffeeshop.mapper.ShopMapper;
import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.dto.request.MenuCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ShopCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ShopUpdateRequest;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.dto.response.MenuResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.PageResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.ShopResponseDto;
import com.coffeeshop.coffeeshop.service.MenuService;
import com.coffeeshop.coffeeshop.service.ShopService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/shop")
public class ShopController {

    private static final Set<Integer> ALLOWED_PAGE_SIZES = Set.of(10, 25, 50);

    private final ShopService shopService;
    private final ShopMapper shopMapper;
    private final MenuService menuService;
    private final MenuMapper menuMapper;

    public ShopController(
            final ShopService shopService,
            final ShopMapper shopMapper,
            final MenuService menuService,
            final MenuMapper menuMapper) {
        this.shopService = shopService;
        this.shopMapper = shopMapper;
        this.menuService = menuService;
        this.menuMapper = menuMapper;
    }

    @GetMapping
    public ResponseEntity<?> getAll(
            @RequestParam(required = false) final String q,
            @RequestParam(required = false) final Integer page,
            @RequestParam(defaultValue = "10") final int size) {
        if (page == null) {
            return new ResponseEntity<>(
                    shopService.findAll().stream().map(shopMapper::toShopResponse).collect(Collectors.toList()),
                    HttpStatus.OK);
        }

        if (!ALLOWED_PAGE_SIZES.contains(size)) {
            throw new IllegalArgumentException("size must be one of: 10, 25, 50");
        }

        final PageRequest pageable = PageRequest.of(page, size, Sort.unsorted());
        final Page<Shop> result = shopService.search(Optional.ofNullable(q), pageable);
        final PageResponseDto<ShopResponseDto> response = new PageResponseDto<>(
                result.getContent().stream().map(shopMapper::toShopResponse).collect(Collectors.toList()),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements(),
                result.getTotalPages());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @GetMapping("/mine")
    public ResponseEntity<List<ShopResponseDto>> getMine() {
        return new ResponseEntity<>(
                shopService.findByCurrentUser().stream().map(shopMapper::toShopResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShopResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(shopMapper.toShopResponse(shopService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<ShopResponseDto> create(@Valid @RequestBody final ShopCreateRequest request) {
        return new ResponseEntity<>(shopMapper.toShopResponse(shopService.create(shopMapper.toShop(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<ShopResponseDto> update(@PathVariable final UUID id, @Valid @RequestBody final ShopUpdateRequest request) {
        return new ResponseEntity<>(shopMapper.toShopResponse(shopService.update(id, shopMapper.toShop(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        shopService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping("/{shopId}/favourite")
    public ResponseEntity<ShopResponseDto> addFavourite(@PathVariable final UUID shopId) {
        return new ResponseEntity<>(shopMapper.toShopResponse(shopService.addFavourite(shopId)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{shopId}/favourite")
    public ResponseEntity<ShopResponseDto> removeFavourite(@PathVariable final UUID shopId) {
        return new ResponseEntity<>(shopMapper.toShopResponse(shopService.removeFavourite(shopId)), HttpStatus.OK);
    }

    @GetMapping("/{shopId}/menus")
    public ResponseEntity<List<MenuResponseDto>> getMenus(@PathVariable final UUID shopId) {
        final var shop = shopService.getById(shopId);
        return new ResponseEntity<>(
                menuService.findByShopId(shopId).stream()
                        .map(menu -> {
                            final MenuResponseDto dto = menuMapper.toMenuResponse(menu, shop);
                            dto.setCurrent(shop.getCurrentMenu() != null
                                    && shop.getCurrentMenu().getId().equals(menu.getId()));
                            return dto;
                        })
                        .collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping("/{shopId}/menus")
    public ResponseEntity<MenuResponseDto> createMenu(
            @PathVariable final UUID shopId,
            @RequestBody(required = false) final MenuCreateRequest request) {
        final String label = request != null ? request.getLabel() : null;
        final Menu menu = menuService.createForShop(shopId, label);
        final var shop = shopService.getById(shopId);
        final MenuResponseDto dto = menuMapper.toMenuResponse(menu, shop);
        dto.setCurrent(true);
        return new ResponseEntity<>(dto, HttpStatus.CREATED);
    }
}
