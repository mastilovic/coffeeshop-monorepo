import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { ReviewCommentCreateRequest, ReviewCommentResponseDto } from '../models/review-comment.model';

@Injectable({ providedIn: 'root' })
export class ReviewCommentService {
  private readonly http = inject(HttpClient);
  private readonly reviewBase = `${environment.apiUrl}/api/v1/review`;

  getByReviewId(reviewId: string): Observable<ReviewCommentResponseDto[]> {
    return this.http.get<ReviewCommentResponseDto[]>(`${this.reviewBase}/${reviewId}/comments`);
  }

  create(reviewId: string, req: ReviewCommentCreateRequest): Observable<ReviewCommentResponseDto> {
    return this.http.post<ReviewCommentResponseDto>(`${this.reviewBase}/${reviewId}/comments`, req);
  }
}
