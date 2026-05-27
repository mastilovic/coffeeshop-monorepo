package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Table;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface TableRepository extends JpaRepository<Table, UUID> {
    long countByShop_Id(UUID shopId);
}
