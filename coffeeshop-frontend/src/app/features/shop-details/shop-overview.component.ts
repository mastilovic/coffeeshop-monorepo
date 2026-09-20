import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  output,
} from '@angular/core';
import { StarRatingComponent } from '../../shared/star-rating/star-rating.component';
import { ShopResponseDto } from '../../models/shop.model';
import { EventResponseDto } from '../../models/event.model';
import { MenuItemResponseDto } from '../../models/menu.model';
import { ReviewResponseDto } from '../../models/review.model';
import { formatUserDisplayName } from '../../utils/user-display-name';

export type OverviewSeeAllTarget = 'menu' | 'events' | 'reviews';

@Component({
  selector: 'app-shop-overview',
  standalone: true,
  imports: [StarRatingComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="shop-overview">
      <div class="stats-row mb-3">
        <div class="stat-card form-card">
          <span class="stat-label">Rating</span>
          <span class="stat-value">{{ ratingLabel() }}</span>
        </div>
        <div class="stat-card form-card">
          <span class="stat-label">Members</span>
          <span class="stat-value">{{ shop().memberCount ?? 0 }}</span>
        </div>
        <div class="stat-card form-card">
          <span class="stat-label">Events</span>
          <span class="stat-value">{{ upcomingEventCount() }}</span>
        </div>
      </div>

      @if (shop().phoneNumber || shop().email) {
        <div class="form-card mb-3 contact-card">
          <h3 class="section-title">Contact</h3>
          @if (shop().phoneNumber) {
            <p class="contact-row">{{ shop().phoneNumber }}</p>
          }
          @if (shop().email) {
            <p class="contact-row">{{ shop().email }}</p>
          }
        </div>
      }

      <div class="form-card mb-3">
        <div class="section-header">
          <h3 class="section-title">Upcoming events</h3>
          <button type="button" class="btn btn-secondary btn-sm" (click)="seeAll.emit('events')">
            See all
          </button>
        </div>
        @if (upcomingEvents().length === 0) {
          <p class="text-muted empty-copy">No upcoming events.</p>
        } @else {
          <ul class="preview-list">
            @for (event of upcomingEvents(); track event.eventId) {
              <li class="preview-item preview-item--stack">
                <span>{{ event.eventName }}</span>
                <span class="text-muted">{{ formatEventDate(event.eventDate) }}</span>
              </li>
            }
          </ul>
        }
      </div>

      <div class="form-card mb-3">
        <div class="section-header">
          <h3 class="section-title">Recent reviews</h3>
          <button type="button" class="btn btn-secondary btn-sm" (click)="seeAll.emit('reviews')">
            See all
          </button>
        </div>
        @if (recentReviews().length === 0) {
          <p class="text-muted empty-copy">No reviews yet.</p>
        } @else {
          <ul class="preview-list">
            @for (review of recentReviews(); track review.id) {
              <li class="preview-item preview-item--stack">
                <div class="review-meta">
                  <app-star-rating [rating]="review.rating" [readonly]="true" />
                  <span class="text-muted">{{ reviewAuthor(review) }}</span>
                </div>
                @if (review.description) {
                  <p class="review-snippet">{{ review.description }}</p>
                }
              </li>
            }
          </ul>
        }
      </div>

      <div class="form-card mb-3">
        <div class="section-header">
          <h3 class="section-title">Menu</h3>
          <button type="button" class="btn btn-secondary btn-sm" (click)="seeAll.emit('menu')">
            See all
          </button>
        </div>
        @if (menuItems().length === 0) {
          <p class="text-muted empty-copy">No menu yet.</p>
        } @else {
          <ul class="preview-list">
            @for (item of menuItems(); track item.id) {
              <li class="preview-item">
                <span>{{ item.name }}</span>
                <span class="text-muted">{{ item.price }} {{ item.priceCurrency }}</span>
              </li>
            }
          </ul>
        }
      </div>
    </div>
  `,
  styles: `
    .stats-row {
      display: grid;
      grid-template-columns: repeat(3, minmax(0, 1fr));
      gap: 0.75rem;
    }

    .stat-card {
      display: flex;
      flex-direction: column;
      gap: 0.25rem;
      margin-bottom: 0;
      text-align: center;
    }

    .stat-label {
      font-size: 0.75rem;
      color: var(--text-muted, #888);
      text-transform: uppercase;
      letter-spacing: 0.02em;
    }

    .stat-value {
      font-weight: 600;
      font-size: 1rem;
    }

    .section-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.75rem;
      margin-bottom: 0.75rem;
    }

    .section-title {
      margin: 0;
      font-size: 1rem;
    }

    .contact-card .section-title {
      margin-bottom: 0.5rem;
    }

    .contact-row {
      margin: 0.25rem 0 0;
    }

    .empty-copy {
      margin: 0;
    }

    .preview-list {
      list-style: none;
      margin: 0;
      padding: 0;
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }

    .preview-item {
      display: flex;
      justify-content: space-between;
      gap: 1rem;
      align-items: baseline;
    }

    .preview-item--stack {
      flex-direction: column;
      align-items: stretch;
      gap: 0.25rem;
    }

    .review-meta {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      flex-wrap: wrap;
    }

    .review-snippet {
      margin: 0;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .btn-sm {
      padding: 0.25rem 0.75rem;
      font-size: 0.8125rem;
    }

    @media (max-width: 640px) {
      .stats-row {
        grid-template-columns: 1fr;
      }
    }
  `,
})
export class ShopOverviewComponent {
  readonly shop = input.required<ShopResponseDto>();
  readonly seeAll = output<OverviewSeeAllTarget>();

  readonly menuItems = computed<MenuItemResponseDto[]>(() => {
    const items = this.shop().currentMenu?.items ?? [];
    return items.slice(0, 3);
  });

  readonly upcomingEvents = computed<EventResponseDto[]>(() => {
    const now = Date.now();
    return [...this.shop().events]
      .filter(event => {
        const time = Date.parse(event.eventDate);
        return Number.isNaN(time) || time >= now;
      })
      .sort((a, b) => a.eventDate.localeCompare(b.eventDate))
      .slice(0, 3);
  });

  readonly upcomingEventCount = computed(() => {
    const now = Date.now();
    return this.shop().events.filter(event => {
      const time = Date.parse(event.eventDate);
      return Number.isNaN(time) || time >= now;
    }).length;
  });

  readonly recentReviews = computed<ReviewResponseDto[]>(() => {
    return [...this.shop().reviews]
      .sort((a, b) => (b.reviewDate ?? '').localeCompare(a.reviewDate ?? ''))
      .slice(0, 2);
  });

  readonly ratingLabel = computed(() => {
    const shop = this.shop();
    const rating = shop.averageRating;
    const count = shop.reviewCount ?? 0;
    if (rating == null || rating <= 0 || count <= 0) {
      return 'No rating yet';
    }
    return `${rating.toFixed(1)} (${count})`;
  });

  formatEventDate(raw: string): string {
    const date = new Date(raw);
    if (Number.isNaN(date.getTime())) return raw;
    return date.toLocaleString();
  }

  reviewAuthor(review: ReviewResponseDto): string {
    return formatUserDisplayName(review.user) || 'Anonymous';
  }
}
