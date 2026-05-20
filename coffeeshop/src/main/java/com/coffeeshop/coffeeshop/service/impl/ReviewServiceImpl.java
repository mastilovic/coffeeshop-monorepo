package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Review;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewUpdateRequest;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.repository.ReviewRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.service.ReviewCommentLoader;
import com.coffeeshop.coffeeshop.service.ReviewService;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final ShopRepository shopRepository;
    private final CurrentUserService currentUserService;
    private final ReviewCommentLoader reviewCommentLoader;
    private final UserShopService userShopService;

    public ReviewServiceImpl(
            final ReviewRepository reviewRepository,
            final ShopRepository shopRepository,
            final CurrentUserService currentUserService,
            final ReviewCommentLoader reviewCommentLoader,
            final UserShopService userShopService) {
        this.reviewRepository = reviewRepository;
        this.shopRepository = shopRepository;
        this.currentUserService = currentUserService;
        this.reviewCommentLoader = reviewCommentLoader;
        this.userShopService = userShopService;
    }

    @Override
    public List<Review> findAll() {
        return reviewRepository.findAll();
    }

    @Override
    public Review getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Review ID cannot be null");
        }
        final Review review = reviewRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found with id: " + id));
        reviewCommentLoader.loadCommentsForReviews(List.of(review));
        return review;
    }

    @Override
    public Review create(final Review entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Review ID must be null on create");
        }
        final User currentUser = currentUserService.requireCurrentUser();
        assertCustomerCanCreateReview(currentUser);

        final Shop shop = resolveShop(entity.getShop());
        assertNotOwnShop(shop, currentUser);
        assertRatingInRange(entity.getRating());

        if (reviewRepository.findByUser_IdAndShop_Id(currentUser.getId(), shop.getId()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "You have already reviewed this shop");
        }

        entity.setUser(currentUser);
        entity.setShop(shop);
        entity.setReviewDate(Instant.now());
        return reviewRepository.save(entity);
    }

    @Override
    public Review update(final UUID id, final Review entity) {
        return update(id, entity, null);
    }

    @Override
    public Review update(final UUID id, final Review entity, final ReviewUpdateRequest request) {
        final Review existing = getById(id);
        final User currentUser = currentUserService.requireCurrentUser();
        assertAuthorOrAdmin(existing, currentUser);

        if (entity.getTitle() != null) {
            existing.setTitle(entity.getTitle());
        }
        if (entity.getDescription() != null) {
            existing.setDescription(entity.getDescription());
        }
        if (entity.getRating() != null) {
            assertRatingInRange(entity.getRating());
            existing.setRating(entity.getRating());
        }
        if (request != null && request.getCommentsEnabled() != null) {
            existing.setCommentsEnabled(request.getCommentsEnabled());
        }
        return reviewRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Review ID cannot be null");
        }
        final Review existing = getById(id);
        final User currentUser = currentUserService.requireCurrentUser();
        assertAuthorOrAdmin(existing, currentUser);
        reviewRepository.deleteById(id);
    }

    private Shop resolveShop(final Shop ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("Shop is required with an ID");
        }
        return shopRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + ref.getId()));
    }

    private void assertCustomerCanCreateReview(final User currentUser) {
        if (isAdmin(currentUser)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only customers can create shop reviews");
        }
        if (currentUser.getUserType() != UserType.CUSTOMER) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only customers can create shop reviews");
        }
    }

    private void assertNotOwnShop(final Shop shop, final User currentUser) {
        if (userShopService.isOwner(currentUser, shop)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You cannot review your own shop");
        }
    }

    private void assertAuthorOrAdmin(final Review review, final User currentUser) {
        if (isAdmin(currentUser)) {
            return;
        }
        if (review.getUser() == null || !review.getUser().getId().equals(currentUser.getId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You can only modify your own reviews");
        }
    }

    private void assertRatingInRange(final Integer rating) {
        if (rating == null || rating < 1 || rating > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }
    }

    private boolean isAdmin(final User user) {
        if (user.getUserType() == UserType.ADMIN) {
            return true;
        }
        return SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch("ROLE_ADMIN"::equals);
    }
}
