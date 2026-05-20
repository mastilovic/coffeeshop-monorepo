import { UserSummaryDto } from './user.model';

export interface ReviewCommentResponseDto {
  id: string;
  body: string;
  createdAt: string;
  user: UserSummaryDto;
}

export interface ReviewCommentCreateRequest {
  body: string;
}
