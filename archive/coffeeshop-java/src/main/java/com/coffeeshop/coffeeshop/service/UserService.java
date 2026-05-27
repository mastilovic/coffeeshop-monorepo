package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserService {

    List<User> findAll();

    Page<User> search(Optional<String> query, Pageable pageable);

    User getById(UUID id);

    User getByEmail(String email);

    User create(User entity);

    User update(UUID id, User entity);

    void deleteById(UUID id);
}
