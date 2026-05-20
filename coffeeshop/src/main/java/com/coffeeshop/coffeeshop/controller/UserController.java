package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.UserMapper;
import com.coffeeshop.coffeeshop.model.dto.request.UserCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.UserUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.UserResponseDto;
import com.coffeeshop.coffeeshop.service.UserService;
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
@RequestMapping("/api/v1/user")
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;

    public UserController(final UserService userService, final UserMapper userMapper) {
        this.userService = userService;
        this.userMapper = userMapper;
    }

    @GetMapping
    public ResponseEntity<List<UserResponseDto>> getAll() {
        return new ResponseEntity<>(
                userService.findAll().stream().map(userMapper::toUserResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(userMapper.toUserResponse(userService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<UserResponseDto> create(@RequestBody final UserCreateRequest request) {
        return new ResponseEntity<>(userMapper.toUserResponse(userService.create(userMapper.toUser(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<UserResponseDto> update(@PathVariable final UUID id, @RequestBody final UserUpdateRequest request) {
        return new ResponseEntity<>(userMapper.toUserResponse(userService.update(id, userMapper.toUser(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        userService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
