package com.coffeeshop.coffeeshop.auth;

import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ShopOwnershipService {

    private final UserShopService userShopService;

    public ShopOwnershipService(final UserShopService userShopService) {
        this.userShopService = userShopService;
    }

    public void assertShopOwnerOrAdmin(final User user) {
        if (isAdmin(user)) {
            return;
        }
        if (user.getUserType() != UserType.SHOP_OWNER) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only shop owners can manage events");
        }
    }

    public void assertOwned(final Shop shop, final User currentUser) {
        if (isAdmin(currentUser)) {
            return;
        }
        if (!userShopService.isOwner(currentUser, shop)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not own this shop");
        }
    }

    public boolean isAdmin(final User user) {
        if (user.getUserType() == UserType.ADMIN) {
            return true;
        }
        return SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch("ROLE_ADMIN"::equals);
    }
}
