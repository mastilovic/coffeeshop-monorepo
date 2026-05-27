package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Role;
import com.coffeeshop.coffeeshop.repository.RoleRepository;
import com.coffeeshop.coffeeshop.service.RoleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;

    public RoleServiceImpl(final RoleRepository roleRepository) {
        this.roleRepository = roleRepository;
    }

    @Override
    public List<Role> findAll() {
        return roleRepository.findAll();
    }

    @Override
    public Role getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Role ID cannot be null");
        }
        return roleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Role not found with id: " + id));
    }

    @Override
    public Role create(final Role entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Role ID must be null on create");
        }
        return roleRepository.save(entity);
    }

    @Override
    public Role update(final UUID id, final Role entity) {
        final Role existing = getById(id);
        if (entity.getName() != null) {
            existing.setName(entity.getName());
        }
        if (entity.getType() != null) {
            existing.setType(entity.getType());
        }
        return roleRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Role ID cannot be null");
        }
        if (!roleRepository.existsById(id)) {
            throw new ResourceNotFoundException("Role not found with id: " + id);
        }
        roleRepository.deleteById(id);
    }
}
