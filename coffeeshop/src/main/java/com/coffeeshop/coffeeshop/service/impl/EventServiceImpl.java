package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.auth.ShopOwnershipService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.EventRepository;
import com.coffeeshop.coffeeshop.repository.EventSpecifications;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.service.EventService;
import com.coffeeshop.coffeeshop.util.EventDateValidator;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@Transactional
public class EventServiceImpl implements EventService {

    private final EventRepository eventRepository;
    private final ShopRepository shopRepository;
    private final CurrentUserService currentUserService;
    private final ShopOwnershipService shopOwnershipService;

    public EventServiceImpl(
            final EventRepository eventRepository,
            final ShopRepository shopRepository,
            final CurrentUserService currentUserService,
            final ShopOwnershipService shopOwnershipService) {
        this.eventRepository = eventRepository;
        this.shopRepository = shopRepository;
        this.currentUserService = currentUserService;
        this.shopOwnershipService = shopOwnershipService;
    }

    @Override
    public List<Event> findAll() {
        return eventRepository.findAll();
    }

    @Override
    public Page<Event> search(
            final Optional<String> query,
            final Optional<LocalDate> dateFrom,
            final Optional<LocalDate> dateTo,
            final Pageable pageable) {
        return eventRepository.findAll(EventSpecifications.search(query, dateFrom, dateTo), pageable);
    }

    @Override
    public List<Event> findByShopId(final UUID shopId) {
        if (shopId == null) {
            throw new IllegalArgumentException("Shop ID cannot be null");
        }
        if (!shopRepository.existsById(shopId)) {
            throw new ResourceNotFoundException("Shop not found with id: " + shopId);
        }
        return eventRepository.findByShop_Id(shopId);
    }

    @Override
    public Event getById(final String eventId) {
        if (eventId == null) {
            throw new IllegalArgumentException("Event ID cannot be null");
        }
        return eventRepository.findById(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Event not found with id: " + eventId));
    }

    @Override
    public Event create(final Event entity) {
        if (entity.getEventId() != null) {
            throw new IllegalArgumentException("Event ID must be null on create");
        }
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertShopOwnerOrAdmin(currentUser);
        final Shop shop = resolveShop(entity.getShop());
        shopOwnershipService.assertOwned(shop, currentUser);
        entity.setShop(shop);
        EventDateValidator.assertNotInPast(entity.getEventDate());
        return eventRepository.save(entity);
    }

    @Override
    public Event update(final String eventId, final Event entity) {
        final Event existing = getById(eventId);
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertShopOwnerOrAdmin(currentUser);
        if (entity.getEventName() != null) {
            existing.setEventName(entity.getEventName());
        }
        if (entity.getEventDate() != null) {
            existing.setEventDate(entity.getEventDate());
        }
        if (entity.getDescription() != null) {
            existing.setDescription(entity.getDescription());
        }
        if (entity.getShop() != null) {
            final Shop shop = resolveShop(entity.getShop());
            shopOwnershipService.assertOwned(shop, currentUser);
            existing.setShop(shop);
        } else {
            shopOwnershipService.assertOwned(existing.getShop(), currentUser);
        }
        return eventRepository.save(existing);
    }

    @Override
    public void deleteById(final String eventId) {
        if (eventId == null) {
            throw new IllegalArgumentException("Event ID cannot be null");
        }
        final Event event = getById(eventId);
        final User currentUser = currentUserService.requireCurrentUser();
        shopOwnershipService.assertShopOwnerOrAdmin(currentUser);
        shopOwnershipService.assertOwned(event.getShop(), currentUser);
        eventRepository.deleteById(eventId);
    }

    private Shop resolveShop(final Shop ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("Shop is required with an ID");
        }
        return shopRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + ref.getId()));
    }
}
