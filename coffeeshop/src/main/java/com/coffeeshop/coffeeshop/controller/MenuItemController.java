package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.MenuItemMapper;
import com.coffeeshop.coffeeshop.model.dto.request.MenuItemCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.MenuItemUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.MenuItemResponseDto;
import com.coffeeshop.coffeeshop.service.MenuItemService;
import org.springframework.http.HttpStatus;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/menu-item")
public class MenuItemController {

    private final MenuItemService menuItemService;
    private final MenuItemMapper menuItemMapper;

    public MenuItemController(final MenuItemService menuItemService, final MenuItemMapper menuItemMapper) {
        this.menuItemService = menuItemService;
        this.menuItemMapper = menuItemMapper;
    }

    @GetMapping
    public ResponseEntity<List<MenuItemResponseDto>> getAll() {
        return new ResponseEntity<>(
                menuItemService.findAll().stream().map(menuItemMapper::toMenuItemResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MenuItemResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(menuItemMapper.toMenuItemResponse(menuItemService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<MenuItemResponseDto> create(@RequestBody final MenuItemCreateRequest request) {
        return new ResponseEntity<>(menuItemMapper.toMenuItemResponse(menuItemService.create(menuItemMapper.toMenuItem(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<MenuItemResponseDto> update(@PathVariable final UUID id, @RequestBody final MenuItemUpdateRequest request) {
        return new ResponseEntity<>(menuItemMapper.toMenuItemResponse(menuItemService.update(id, menuItemMapper.toMenuItem(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        menuItemService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
