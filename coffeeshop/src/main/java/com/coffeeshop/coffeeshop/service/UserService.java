package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.User;

import java.util.List;
import java.util.UUID;

public interface UserService {

    List<User> findAll();

    User getById(UUID id);

    User getByEmail(String email);

    User create(User entity);

    User update(UUID id, User entity);

    void deleteById(UUID id);
}
