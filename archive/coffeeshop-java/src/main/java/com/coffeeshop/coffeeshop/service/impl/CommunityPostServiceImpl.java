package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.auth.ShopOwnershipService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.CommunityPost;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.enums.CommunityPostType;
import com.coffeeshop.coffeeshop.repository.CommunityPostRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.service.CommunityPostService;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.UUID;

@Service
@Transactional
public class CommunityPostServiceImpl implements CommunityPostService {

    private final CommunityPostRepository communityPostRepository;
    private final ShopRepository shopRepository;
    private final CurrentUserService currentUserService;
    private final UserShopService userShopService;
    private final ShopOwnershipService shopOwnershipService;

    public CommunityPostServiceImpl(
            final CommunityPostRepository communityPostRepository,
            final ShopRepository shopRepository,
            final CurrentUserService currentUserService,
            final UserShopService userShopService,
            final ShopOwnershipService shopOwnershipService) {
        this.communityPostRepository = communityPostRepository;
        this.shopRepository = shopRepository;
        this.currentUserService = currentUserService;
        this.userShopService = userShopService;
        this.shopOwnershipService = shopOwnershipService;
    }

    @Override
    public Page<CommunityPost> findByShop(final UUID shopId, final Pageable pageable) {
        assertShopExists(shopId);
        return communityPostRepository.findByShop_IdOrderByPinnedDescCreatedAtDesc(shopId, pageable);
    }

    @Override
    public CommunityPost createAnnouncement(final UUID shopId, final String body) {
        final Shop shop = requireShop(shopId);
        final User currentUser = currentUserService.requireCurrentUser();
        assertShopOwner(currentUser, shop);
        return savePost(shop, currentUser, body, CommunityPostType.ANNOUNCEMENT, true);
    }

    @Override
    public void delete(final UUID shopId, final UUID postId) {
        assertShopExists(shopId);
        final CommunityPost post = communityPostRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Community post not found with id: " + postId));
        if (!post.getShop().getId().equals(shopId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Community post not found for this shop");
        }
        final User currentUser = currentUserService.requireCurrentUser();
        final boolean isAuthor = post.getAuthor().getId().equals(currentUser.getId());
        final boolean isOwnerOrAdmin = shopOwnershipService.isAdmin(currentUser)
                || userShopService.isOwner(currentUser, post.getShop());
        if (!isAuthor && !isOwnerOrAdmin) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You cannot delete this post");
        }
        communityPostRepository.delete(post);
    }

    private CommunityPost savePost(
            final Shop shop,
            final User author,
            final String body,
            final CommunityPostType type,
            final boolean pinned) {
        final CommunityPost post = new CommunityPost();
        post.setBody(body.trim());
        post.setCreatedAt(Instant.now());
        post.setType(type);
        post.setPinned(pinned);
        post.setAuthor(author);
        post.setShop(shop);
        return communityPostRepository.save(post);
    }

    private Shop requireShop(final UUID shopId) {
        assertShopExists(shopId);
        return shopRepository.findById(shopId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + shopId));
    }

    private void assertShopExists(final UUID shopId) {
        if (shopId == null) {
            throw new IllegalArgumentException("Shop ID cannot be null");
        }
        if (!shopRepository.existsById(shopId)) {
            throw new ResourceNotFoundException("Shop not found with id: " + shopId);
        }
    }

    private void assertShopOwner(final User user, final Shop shop) {
        if (!userShopService.isOwner(user, shop)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN, "Only the shop owner can create community posts");
        }
    }
}
