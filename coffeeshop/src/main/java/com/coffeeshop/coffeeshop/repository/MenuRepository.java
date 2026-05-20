package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Menu;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MenuRepository extends JpaRepository<Menu, UUID> {

    List<Menu> findByShop_IdOrderByCreatedAtDesc(UUID shopId);

    Optional<Menu> findByIdAndShop_Id(UUID menuId, UUID shopId);
}
