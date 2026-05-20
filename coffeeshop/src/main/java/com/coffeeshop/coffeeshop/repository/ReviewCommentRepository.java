package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.ReviewComment;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewCommentRepository extends JpaRepository<ReviewComment, UUID> {

    List<ReviewComment> findByReview_IdOrderByCreatedAtAsc(UUID reviewId);

    @EntityGraph(attributePaths = {"user", "review"})
    List<ReviewComment> findByReview_IdInOrderByCreatedAtAsc(Collection<UUID> reviewIds);
}
