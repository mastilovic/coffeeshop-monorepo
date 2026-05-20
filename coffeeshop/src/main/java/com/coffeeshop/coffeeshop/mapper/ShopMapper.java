package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.model.LoyaltyPlan;
import com.coffeeshop.coffeeshop.model.Menu;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.dto.request.ShopCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ShopUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.MenuResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.ShopResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.ShopSummaryDto;
import com.coffeeshop.coffeeshop.model.enums.UserShopRelationshipType;
import com.coffeeshop.coffeeshop.repository.MenuRepository;
import com.coffeeshop.coffeeshop.repository.UserShopRepository;
import com.coffeeshop.coffeeshop.service.UserShopService;
import com.coffeeshop.coffeeshop.util.RatingAggregationUtils;
import com.coffeeshop.coffeeshop.util.RatingAggregationUtils.RatingSummary;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class ShopMapper {

    private final MenuMapper menuMapper;
    private final MenuRepository menuRepository;
    private final LoyaltyPlanMapper loyaltyPlanMapper;
    private final EventMapper eventMapper;
    private final ContactMapper contactMapper;
    private final UserMapper userMapper;
    private final ReviewMapper reviewMapper;
    private final TableMapper tableMapper;
    private final UserShopService userShopService;
    private final UserShopRepository userShopRepository;
    private final CurrentUserService currentUserService;

    public ShopMapper(
            final MenuMapper menuMapper,
            final MenuRepository menuRepository,
            final LoyaltyPlanMapper loyaltyPlanMapper,
            final EventMapper eventMapper,
            final ContactMapper contactMapper,
            @Lazy final UserMapper userMapper,
            @Lazy final ReviewMapper reviewMapper,
            @Lazy final TableMapper tableMapper,
            final UserShopService userShopService,
            final UserShopRepository userShopRepository,
            final CurrentUserService currentUserService) {
        this.menuMapper = menuMapper;
        this.menuRepository = menuRepository;
        this.loyaltyPlanMapper = loyaltyPlanMapper;
        this.eventMapper = eventMapper;
        this.contactMapper = contactMapper;
        this.userMapper = userMapper;
        this.reviewMapper = reviewMapper;
        this.tableMapper = tableMapper;
        this.userShopService = userShopService;
        this.userShopRepository = userShopRepository;
        this.currentUserService = currentUserService;
    }

    public ShopSummaryDto toShopSummary(final Shop shop) {
        if (shop == null) {
            return null;
        }
        final ShopSummaryDto dto = new ShopSummaryDto();
        dto.setId(shop.getId());
        dto.setName(shop.getName());
        dto.setAddress(shop.getAddress());
        dto.setCity(shop.getCity());
        dto.setPhoneNumber(shop.getPhoneNumber());
        dto.setEmail(shop.getEmail());
        return dto;
    }

    public ShopResponseDto toShopResponse(final Shop shop) {
        if (shop == null) {
            return null;
        }
        final ShopResponseDto dto = new ShopResponseDto();
        dto.setId(shop.getId());
        dto.setName(shop.getName());
        dto.setAddress(shop.getAddress());
        dto.setCity(shop.getCity());
        dto.setPhoneNumber(shop.getPhoneNumber());
        dto.setEmail(shop.getEmail());
        dto.setCreatedBy(userMapper.toUserSummary(userShopService.resolveOwner(shop)));
        dto.setUsers(MappingUtils.mapList(userShopService.findFavouriteUsers(shop), userMapper::toUserSummary));
        dto.setCurrentMenu(menuMapper.toMenuResponse(shop.getCurrentMenu(), shop));
        dto.setMenuHistory(buildMenuHistory(shop));
        dto.setLoyaltyPlan(loyaltyPlanMapper.toLoyaltyPlanResponse(shop.getLoyaltyPlan()));
        dto.setEvents(MappingUtils.mapList(shop.getEvents(), eventMapper::toEventResponse));
        dto.setTables(MappingUtils.mapList(shop.getTables(), tableMapper::toTableResponse));
        dto.setReviews(MappingUtils.mapList(shop.getReviews(), reviewMapper::toReviewResponse));
        final RatingSummary ratingSummary = RatingAggregationUtils.fromReviews(shop.getReviews());
        dto.setReviewCount(ratingSummary.reviewCount());
        dto.setAverageRating(ratingSummary.averageRating());
        dto.setContacts(MappingUtils.mapList(shop.getContacts(), contactMapper::toContactResponse));
        if (shop.getId() != null) {
            dto.setMemberCount(userShopRepository.countByShop_IdAndRelationshipType(
                    shop.getId(), UserShopRelationshipType.FAVOURITE));
        }
        currentUserService.getCurrentUser()
                .ifPresent(user -> dto.setFavouriteByCurrentUser(userShopService.isFavourite(user, shop)));
        return dto;
    }

    private List<MenuResponseDto> buildMenuHistory(final Shop shop) {
        if (shop.getId() == null) {
            return List.of();
        }
        final UUID currentId = shop.getCurrentMenu() != null ? shop.getCurrentMenu().getId() : null;
        final List<MenuResponseDto> history = new ArrayList<>();
        for (final Menu menu : menuRepository.findByShop_IdOrderByCreatedAtDesc(shop.getId())) {
            if (currentId != null && currentId.equals(menu.getId())) {
                continue;
            }
            final MenuResponseDto menuDto = menuMapper.toMenuResponse(menu, shop);
            menuDto.setCurrent(false);
            history.add(menuDto);
        }
        return history;
    }

    public Shop toShop(final ShopCreateRequest request) {
        final Shop shop = new Shop();
        shop.setName(request.getName());
        shop.setAddress(request.getAddress());
        shop.setCity(request.getCity());
        shop.setPhoneNumber(request.getPhoneNumber());
        shop.setOwnerUserIdForCreate(request.getCreatedByUserId());
        if (request.getLoyaltyPlanId() != null) {
            final LoyaltyPlan plan = new LoyaltyPlan();
            plan.setId(request.getLoyaltyPlanId());
            shop.setLoyaltyPlan(plan);
        }
        return shop;
    }

    public Shop toShop(final ShopUpdateRequest request) {
        final Shop shop = new Shop();
        shop.setName(request.getName());
        shop.setAddress(request.getAddress());
        shop.setCity(request.getCity());
        shop.setPhoneNumber(request.getPhoneNumber());
        shop.setEmail(request.getEmail());
        shop.setNewOwnerUserIdForUpdate(request.getCreatedByUserId());
        if (request.getLoyaltyPlanId() != null) {
            final LoyaltyPlan plan = new LoyaltyPlan();
            plan.setId(request.getLoyaltyPlanId());
            shop.setLoyaltyPlan(plan);
        }
        return shop;
    }
}
