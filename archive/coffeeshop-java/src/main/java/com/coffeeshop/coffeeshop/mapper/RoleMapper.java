package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Role;
import com.coffeeshop.coffeeshop.model.dto.request.RoleCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.RoleUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.RoleResponseDto;
import org.springframework.stereotype.Service;

@Service
public class RoleMapper {

    public RoleResponseDto toRoleResponse(final Role role) {
        if (role == null) {
            return null;
        }
        final RoleResponseDto dto = new RoleResponseDto();
        dto.setId(role.getId());
        dto.setName(role.getName());
        dto.setType(role.getType());
        return dto;
    }

    public Role toRole(final RoleCreateRequest request) {
        final Role role = new Role();
        role.setName(request.getName());
        role.setType(request.getType());
        return role;
    }

    public Role toRole(final RoleUpdateRequest request) {
        final Role role = new Role();
        role.setName(request.getName());
        role.setType(request.getType());
        return role;
    }
}
