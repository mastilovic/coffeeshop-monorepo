package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Role;

import java.util.List;
import java.util.UUID;

public interface RoleService {

    List<Role> findAll();

    Role getById(UUID id);

    Role create(Role entity);

    Role update(UUID id, Role entity);

    void deleteById(UUID id);
}
