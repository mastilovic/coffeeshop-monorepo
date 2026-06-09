export interface DashboardActivityItem {
  type: 'review' | 'event' | 'community_post';
  timestamp: string;
  shopId: string;
  shopName: string;
  title: string;
  body: string;
  actorName?: string;
  rating?: number;
}

export interface DashboardAggregate {
  shopCount: number;
  reviewCount: number;
  averageRating: number | null;
  eventCount: number;
  memberCount: number;
}

export interface TopShopItem {
  shopId: string;
  shopName: string;
  city: string;
  averageRating: number | null;
  reviewCount: number;
}

export interface UpcomingEventItem {
  eventId: string;
  eventName: string;
  eventDate: string;
  shopId: string;
  shopName: string;
}

export interface DashboardPersonalSummary {
  favouriteShops: number;
  reservations: number;
  reviewsWritten: number;
}

export interface DashboardNotification {
  type: 'pending_requests' | 'new_reviews' | string;
  message: string;
  count: number;
  link: string;
}

export interface DashboardActivityResponse {
  aggregate: DashboardAggregate;
  activities: DashboardActivityItem[];
  topShops: TopShopItem[];
  upcomingEvents: UpcomingEventItem[];
  personalSummary: DashboardPersonalSummary;
  notifications: DashboardNotification[];
}
