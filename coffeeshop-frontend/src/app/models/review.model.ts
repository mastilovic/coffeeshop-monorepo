import { UserSummaryDto } from './user.model';
import { ShopSummaryDto } from './shop.model';
import { ReviewCommentResponseDto } from './review-comment.model';

export interface ReviewResponseDto {
  id: string;
  title?: string;
  description: string;
  rating: number;
  reviewDate: string;
  commentsEnabled: boolean;
  comments: ReviewCommentResponseDto[];
  user: UserSummaryDto;
  shop: ShopSummaryDto;
}

export interface ReviewCreateRequest {
  title?: string;
  description: string;
  rating: number;
  shopId: string;
  commentsEnabled?: boolean;
}

export interface ReviewUpdateRequest {
  title?: string;
  description?: string;
  rating?: number;
  commentsEnabled?: boolean;
}
