package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.UserShop;
import com.coffeeshop.coffeeshop.model.enums.UserShopRelationshipType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserShopRepository extends JpaRepository<UserShop, UUID>, JpaSpecificationExecutor<UserShop> {

    boolean existsByUser_IdAndRelationshipType(UUID userId, UserShopRelationshipType relationshipType);

    boolean existsByUser_IdAndShop_IdAndRelationshipType(
            UUID userId, UUID shopId, UserShopRelationshipType relationshipType);

    long countByShop_IdAndRelationshipType(UUID shopId, UserShopRelationshipType relationshipType);

    void deleteByUser_IdAndRelationshipType(UUID userId, UserShopRelationshipType relationshipType);

    void deleteByShop_IdAndRelationshipType(UUID shopId, UserShopRelationshipType relationshipType);

    void deleteByUser_IdAndShop_IdAndRelationshipType(
            UUID userId, UUID shopId, UserShopRelationshipType relationshipType);

    Optional<UserShop> findByShop_IdAndRelationshipType(UUID shopId, UserShopRelationshipType relationshipType);

    Optional<UserShop> findByUser_IdAndShop_Id(UUID userId, UUID shopId);

    @Query("SELECT us.shop FROM UserShop us WHERE us.user.id = :userId AND us.relationshipType = :type")
    List<Shop> findShopsByUserIdAndRelationshipType(
            @Param("userId") UUID userId, @Param("type") UserShopRelationshipType type);

    @Query("SELECT us.user FROM UserShop us WHERE us.shop.id = :shopId AND us.relationshipType = :type")
    List<User> findUsersByShopIdAndRelationshipType(
            @Param("shopId") UUID shopId, @Param("type") UserShopRelationshipType type);

    @Query("""
            SELECT rr FROM ReservationRequest rr
            WHERE rr.shop.id IN (
                SELECT us.shop.id FROM UserShop us
                WHERE us.user.id = :ownerId AND us.relationshipType = :relationshipType
            )
            """)
    List<com.coffeeshop.coffeeshop.model.ReservationRequest> findReservationRequestsByOwnerId(
            @Param("ownerId") UUID ownerId,
            @Param("relationshipType") UserShopRelationshipType relationshipType);
}
