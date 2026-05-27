package model

import "time"

type RoleType string

const (
	RoleTypeUser      RoleType = "USER"
	RoleTypeAdmin     RoleType = "ADMIN"
	RoleTypeShopOwner RoleType = "SHOP_OWNER"
)

type Role struct {
	ID   string   `gorm:"type:uuid;primaryKey" json:"id"`
	Name string   `gorm:"not null" json:"name"`
	Type RoleType `gorm:"not null" json:"type"`
}

func (Role) TableName() string { return "roles" }

type Contact struct {
	ID     string `gorm:"type:uuid;primaryKey" json:"id"`
	ShopID string `gorm:"type:uuid;not null" json:"shopId"`
}

func (Contact) TableName() string { return "contacts" }

type Table struct {
	ID       string `gorm:"type:uuid;primaryKey" json:"id"`
	Number   int    `gorm:"not null" json:"number"`
	Capacity int    `gorm:"not null" json:"capacity"`
	ShopID   string `gorm:"type:uuid;not null" json:"shopId"`
}

func (Table) TableName() string { return "tables" }

type LoyaltyPlanType string

type LoyaltyPlan struct {
	ID          string          `gorm:"type:uuid;primaryKey" json:"id"`
	Name        string          `gorm:"not null" json:"name"`
	Description string          `json:"description"`
	Type        LoyaltyPlanType `gorm:"not null" json:"type"`
}

func (LoyaltyPlan) TableName() string { return "loyalty_plan" }

type Menu struct {
	ID        string    `gorm:"type:uuid;primaryKey" json:"id"`
	Label     *string   `json:"label"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"createdAt"`
	ShopID    string    `gorm:"type:uuid;not null" json:"shopId"`
	Current   bool      `gorm:"default:false" json:"current"`
}

func (Menu) TableName() string { return "menu" }

type MenuItemType string

const (
	MenuItemTypeFood    MenuItemType = "FOOD"
	MenuItemTypeDrink   MenuItemType = "DRINK"
	MenuItemTypeDessert MenuItemType = "DESSERT"
	MenuItemTypeOther   MenuItemType = "OTHER"
)

type MenuItem struct {
	ID            string       `gorm:"type:uuid;primaryKey" json:"id"`
	Name          string       `gorm:"not null" json:"name"`
	Description   string       `json:"description"`
	Price         float64      `gorm:"not null" json:"price"`
	PriceCurrency string       `gorm:"not null" json:"priceCurrency"`
	ImageURL      string       `json:"imageUrl"`
	ItemType      MenuItemType `gorm:"not null" json:"itemType"`
	MenuID        string       `gorm:"type:uuid;not null" json:"menuId"`
}

func (MenuItem) TableName() string { return "menu_item" }

type Shop struct {
	ID            string  `gorm:"column:id;primaryKey" json:"id"`
	Name          string  `gorm:"column:name" json:"name"`
	Address       string  `gorm:"column:address" json:"address"`
	City          string  `gorm:"column:city" json:"city"`
	PhoneNumber   string  `gorm:"column:phone_number" json:"phoneNumber"`
	Email         string  `gorm:"column:email" json:"email"`
	CurrentMenuID *string `gorm:"column:current_menu_id" json:"-"`
	LoyaltyPlanID *string `gorm:"column:loyalty_plan_id" json:"-"`
}

func (Shop) TableName() string { return "shop" }

type UserShop struct {
	ID               string `gorm:"column:id;primaryKey" json:"id"`
	UserID           string `gorm:"column:user_id" json:"userId"`
	ShopID           string `gorm:"column:shop_id" json:"shopId"`
	RelationshipType string `gorm:"column:relationship_type" json:"relationshipType"`
}

func (UserShop) TableName() string { return "user_shop" }

type Review struct {
	ID              string  `gorm:"column:id;primaryKey" json:"id"`
	Title           string  `gorm:"column:title" json:"title"`
	Description     string  `gorm:"column:description" json:"description"`
	Rating          int     `gorm:"column:rating" json:"rating"`
	ReviewDate      string  `gorm:"column:review_date" json:"reviewDate"`
	CommentsEnabled bool    `gorm:"column:comments_enabled" json:"commentsEnabled"`
	UserID          *string `gorm:"column:user_id" json:"userId"`
	ShopID          *string `gorm:"column:shop_id" json:"shopId"`
}

func (Review) TableName() string { return "review" }

type ReviewComment struct {
	ID        string  `gorm:"column:id;primaryKey" json:"id"`
	Body      string  `gorm:"column:body" json:"body"`
	CreatedAt string  `gorm:"column:created_at" json:"createdAt"`
	UserID    *string `gorm:"column:user_id" json:"userId"`
	ReviewID  *string `gorm:"column:review_id" json:"reviewId"`
}

func (ReviewComment) TableName() string { return "review_comment" }

type CommunityPost struct {
	ID        string  `gorm:"column:id;primaryKey" json:"id"`
	Body      string  `gorm:"column:body" json:"body"`
	CreatedAt string  `gorm:"column:created_at" json:"createdAt"`
	Type      string  `gorm:"column:type" json:"type"`
	Pinned    bool    `gorm:"column:pinned" json:"pinned"`
	AuthorID  *string `gorm:"column:author_id" json:"authorId"`
	ShopID    *string `gorm:"column:shop_id" json:"shopId"`
}

func (CommunityPost) TableName() string { return "community_post" }

type Event struct {
	EventID     string  `gorm:"column:event_id;primaryKey" json:"eventId"`
	EventName   string  `gorm:"column:event_name" json:"eventName"`
	EventDate   string  `gorm:"column:event_date" json:"eventDate"`
	Description string  `gorm:"column:description" json:"description"`
	ShopID      *string `gorm:"column:shop_id" json:"shopId"`
}

func (Event) TableName() string { return "event" }

type Reservation struct {
	ID                   string  `gorm:"column:id;primaryKey" json:"id"`
	PartySize            int     `gorm:"column:party_size" json:"partySize"`
	UserID               *string `gorm:"column:user_id" json:"userId"`
	ShopID               *string `gorm:"column:shop_id" json:"shopId"`
	TableID              *string `gorm:"column:table_id" json:"tableId"`
	EventID              *string `gorm:"column:event_id" json:"eventId"`
	ReservationRequestID *string `gorm:"column:reservation_request_id" json:"reservationRequestId"`
}

func (Reservation) TableName() string { return "reservations" }

type ReservationRequest struct {
	ID        string  `gorm:"column:id;primaryKey" json:"id"`
	PartySize int     `gorm:"column:party_size" json:"partySize"`
	Status    string  `gorm:"column:status" json:"status"`
	UserID    *string `gorm:"column:user_id" json:"userId"`
	ShopID    *string `gorm:"column:shop_id" json:"shopId"`
	EventID   *string `gorm:"column:event_id" json:"eventId"`
}

func (ReservationRequest) TableName() string { return "reservation_request" }
