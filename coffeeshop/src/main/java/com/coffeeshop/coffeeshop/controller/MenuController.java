package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.MenuMapper;
import com.coffeeshop.coffeeshop.model.dto.request.MenuCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.MenuUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.MenuResponseDto;
import com.coffeeshop.coffeeshop.service.MenuService;
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
@RequestMapping("/api/v1/menu")
public class MenuController {

    private final MenuService menuService;
    private final MenuMapper menuMapper;

    public MenuController(final MenuService menuService, final MenuMapper menuMapper) {
        this.menuService = menuService;
        this.menuMapper = menuMapper;
    }

    @GetMapping
    public ResponseEntity<List<MenuResponseDto>> getAll() {
        return new ResponseEntity<>(
                menuService.findAll().stream().map(menuMapper::toMenuResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<MenuResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(menuMapper.toMenuResponse(menuService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<MenuResponseDto> create(@RequestBody(required = false) final MenuCreateRequest ignored) {
        return new ResponseEntity<>(menuMapper.toMenuResponse(menuService.create(menuMapper.newMenu())), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<MenuResponseDto> update(@PathVariable final UUID id, @RequestBody(required = false) final MenuUpdateRequest ignored) {
        return new ResponseEntity<>(menuMapper.toMenuResponse(menuService.update(id, menuMapper.newMenu())), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        menuService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
