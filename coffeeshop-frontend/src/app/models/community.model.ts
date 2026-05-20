import { UserSummaryDto } from './user.model';
import { PageResponseDto } from './event.model';

export type CommunityPostType = 'POST' | 'ANNOUNCEMENT';

export interface CommunityPostResponseDto {
  id: string;
  body: string;
  type: CommunityPostType;
  pinned: boolean;
  createdAt: string;
  author: UserSummaryDto;
  shopId: string;
}

export type CommunityPostPage = PageResponseDto<CommunityPostResponseDto>;

export interface CommunityPostCreateRequest {
  body: string;
}
