package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.auth.ShopOwnershipService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.Table;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.repository.TableRepository;
import com.coffeeshop.coffeeshop.service.TableService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class TableServiceImpl implements TableService {

    private final TableRepository tableRepository;
    private final ShopRepository shopRepository;
    private final ShopOwnershipService shopOwnershipService;
    private final CurrentUserService currentUserService;

    public TableServiceImpl(
            final TableRepository tableRepository,
            final ShopRepository shopRepository,
            final ShopOwnershipService shopOwnershipService,
            final CurrentUserService currentUserService) {
        this.tableRepository = tableRepository;
        this.shopRepository = shopRepository;
        this.shopOwnershipService = shopOwnershipService;
        this.currentUserService = currentUserService;
    }

    @Override
    public List<Table> findAll() {
        return tableRepository.findAll();
    }

    @Override
    public Table getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Table ID cannot be null");
        }
        return tableRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Table not found with id: " + id));
    }

    @Override
    public Table create(final Table entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Table ID must be null on create");
        }
        if (entity.getReservations() != null && !entity.getReservations().isEmpty()) {
            throw new IllegalArgumentException("Table reservations cannot be set on create");
        }
        final Shop shop = resolveShop(entity.getShop());
        shopOwnershipService.assertOwned(shop, currentUserService.requireCurrentUser());
        entity.setShop(shop);
        return tableRepository.save(entity);
    }

    @Override
    public Table update(final UUID id, final Table entity) {
        final Table existing = getById(id);
        existing.setNumber(entity.getNumber());
        existing.setCapacity(entity.getCapacity());
        if (entity.getShop() != null) {
            final Shop shop = resolveShop(entity.getShop());
            shopOwnershipService.assertOwned(shop, currentUserService.requireCurrentUser());
            existing.setShop(shop);
        } else {
            shopOwnershipService.assertOwned(existing.getShop(), currentUserService.requireCurrentUser());
        }
        return tableRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Table ID cannot be null");
        }
        final Table table = getById(id);
        shopOwnershipService.assertOwned(table.getShop(), currentUserService.requireCurrentUser());
        tableRepository.deleteById(id);
    }

    private Shop resolveShop(final Shop ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("Shop is required with an ID");
        }
        return shopRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + ref.getId()));
    }
}
