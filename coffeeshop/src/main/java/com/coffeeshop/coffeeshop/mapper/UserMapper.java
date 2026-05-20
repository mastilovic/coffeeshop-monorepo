package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Role;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.dto.request.UserCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.UserUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.RoleResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.UserResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.UserSummaryDto;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class UserMapper {

    private final RoleMapper roleMapper;
    private final ShopMapper shopMapper;
    private final ReviewMapper reviewMapper;
    private final ReservationMapper reservationMapper;
    private final UserShopService userShopService;

    public UserMapper(
            final RoleMapper roleMapper,
            final ShopMapper shopMapper,
            @Lazy final ReviewMapper reviewMapper,
            @Lazy final ReservationMapper reservationMapper,
            final UserShopService userShopService) {
        this.roleMapper = roleMapper;
        this.shopMapper = shopMapper;
        this.reviewMapper = reviewMapper;
        this.reservationMapper = reservationMapper;
        this.userShopService = userShopService;
    }

    public UserSummaryDto toUserSummary(final User user) {
        if (user == null) {
            return null;
        }
        final UserSummaryDto dto = new UserSummaryDto();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setUserType(user.getUserType());
        dto.setRoles(mapRoles(user.getRole()));
        return dto;
    }

    public UserResponseDto toUserResponse(final User user) {
        if (user == null) {
            return null;
        }
        final UserResponseDto dto = new UserResponseDto();
        dto.setId(user.getId());
        dto.setName(user.getName());
        dto.setEmail(user.getEmail());
        dto.setUserType(user.getUserType());
        dto.setRoles(mapRoles(user.getRole()));
        dto.setFavouriteShops(MappingUtils.mapList(userShopService.findFavouriteShops(user), shopMapper::toShopSummary));
        dto.setReviews(MappingUtils.mapList(user.getReviews(), reviewMapper::toReviewResponse));
        dto.setReservations(MappingUtils.mapList(user.getReservations(), reservationMapper::toReservationResponse));
        return dto;
    }

    public User toUser(final UserCreateRequest request) {
        final User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(request.getPassword());
        user.setUserType(request.getUserType());
        if (request.getRoleIds() != null && !request.getRoleIds().isEmpty()) {
            user.setRole(stubRoles(request.getRoleIds()));
        }
        return user;
    }

    public User toUser(final UserUpdateRequest request) {
        final User user = new User();
        if (request.getName() != null) {
            user.setName(request.getName());
        }
        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }
        if (request.getPassword() != null) {
            user.setPassword(request.getPassword());
        }
        if (request.getUserType() != null) {
            user.setUserType(request.getUserType());
        }
        if (request.getRoleIds() != null) {
            user.setRole(request.getRoleIds().isEmpty() ? List.of() : stubRoles(request.getRoleIds()));
        }
        if (request.getFavouriteShopIds() != null) {
            user.setFavouriteShopIdsForUpdate(request.getFavouriteShopIds());
        }
        return user;
    }

    private List<RoleResponseDto> mapRoles(final List<Role> roles) {
        return MappingUtils.mapList(roles, roleMapper::toRoleResponse);
    }

    private List<Role> stubRoles(final List<UUID> ids) {
        final List<Role> roles = new ArrayList<>();
        for (final UUID id : ids) {
            final Role role = new Role();
            role.setId(id);
            roles.add(role);
        }
        return roles;
    }
}
