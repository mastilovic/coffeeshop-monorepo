import { inject, Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import {
  CommunityPostCreateRequest,
  CommunityPostPage,
  CommunityPostResponseDto,
} from '../models/community.model';

@Injectable({ providedIn: 'root' })
export class CommunityService {
  private readonly http = inject(HttpClient);

  private base(shopId: string): string {
    return `${environment.apiUrl}/api/v1/shop/${shopId}/community`;
  }

  getPosts(shopId: string, page = 0, size = 20): Observable<CommunityPostPage> {
    const params = new HttpParams().set('page', page).set('size', size);
    return this.http.get<CommunityPostPage>(`${this.base(shopId)}/posts`, { params });
  }

  createAnnouncement(shopId: string, body: CommunityPostCreateRequest): Observable<CommunityPostResponseDto> {
    return this.http.post<CommunityPostResponseDto>(`${this.base(shopId)}/announcements`, body);
  }

  deletePost(shopId: string, postId: string): Observable<void> {
    return this.http.delete<void>(`${this.base(shopId)}/posts/${postId}`);
  }
}
