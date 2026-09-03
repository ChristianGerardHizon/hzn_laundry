# Project Entities

This document contains all entities (domain models) in the project with their fields, relationships, and collection names.

---

## Entity Overview

| Domain | Entity | Collection | Description |
|--------|--------|------------|-------------|
| Organizations | Organization | `organizations` | Multi-tenant laundry business |
| Organizations | OrganizationMembership | `organizationMemberships` | User membership in an organization |
| Organizations | OrganizationInvite | `organizationInvites` | Email invite to join an organization |
| Management | User | `users` | System users (all types) |
| Management | UserRole | `userRoles` | Role definitions and permissions |
| Management | Branch | `branches` | Business branches/locations |
| Product | Product | `products` | Products/inventory items |
| Product | ProductCategory | `productCategories` | Product categories (hierarchical) |
| Product | ProductLot | `productLots` | Lot/batch tracking for lot-tracked products |
| Product | ProductAdjustment | `productAdjustments` | Stock adjustment audit trail |
| Service | Service | `services` | Laundry services (wash, dry, fold, iron) |
| Service | ServiceCategory | `serviceCategories` | Service categories |
| Service | ServicePriceTier | `servicePriceTiers` | Quantity-based pricing tiers for a service |
| Quantity Units | QuantityUnit | `quantityUnits` | Units of measurement (kg, pcs, etc.) for products/services |
| Customer | Customer | `customers` | Branch-scoped laundry customers |
| Cart | Cart | `carts` | An in-progress POS shopping session |
| Cart | CartItem | `cartItems` | Product line item in a cart |
| Cart | CartServiceItem | `cartServiceItems` | Service line item in a cart |
| Sales | Sale | `sales` | A finalized transaction/receipt |
| Sales | SaleItem | `saleItems` | Product line item in a finalized sale |
| Sales | SaleServiceItem | `saleServiceItems` | Service line item in a finalized sale |
| Sales | OrderStatusHistory | `orderStatusHistory` | Status change audit trail for sales |
| Sales | Payment | `payments` | A payment transaction against a sale |
| Machine | Machine | `machines` | Laundry machines (washer, dryer, etc.) |
| Machine | LoadRule | `machineLoadRules` | Weight-to-load-count tiers for a machine |
| Storage | StorageLocation | `storages` | Storage locations for laundry items |
| Employee | Employee | `employees` | Laundry business staff |
| Employee | EmployeeAttendance | `employeeAttendances` | Daily attendance record |
| Employee | EmployeeDeduction | `employeeDeductions` | Recurring salary deduction |
| Promo | Promo | `promos` | Loyalty promotion (free reward after N orders) |
| Promo | CustomerPromo | `customerPromos` | A customer's progress in a loyalty promo |
| Activity | ActivityLog | `activityLogs` | CRUD audit trail across collections |
| Settings | PrinterConfig | *(device storage)* | Configured thermal printer on this device (Bluetooth/network) |
| Settings | PosGroup | `posGroups` | Named product/service group shown on the cashier page |
| Settings | PosGroupItem | `posGroupItems` | Product or service assigned to a PosGroup |
| Settings | IncentiveTier | `incentiveTiers` | Branch incentive-per-service-price tiers |
| Settings | FeatureFlag | `featureFlags` | Organization workflow toggles (Management → Settings) |
| Public | CustomerHistory | *(derived, no collection)* | Read-only customer + sales summary for the public order-status page |
| Version | AppConfig | *(external `versions` service)* | App update/minimum-version gate |

Several read-optimized **SQL view collections** back reports/dashboards without their own domain models: `vw_inventory_status`, `vw_sales_daily_summary`, `vw_top_selling_products`, `vw_top_selling_services`, `vw_todays_sales`, `vw_lot_quantity_totals`, `vw_low_stock_products`, `vw_low_stock_lot_products`, `vw_expired_lots`, `vw_near_expiration_lots`, `vw_pos_search_items`, `vw_customer_order_stats`, `vw_sales_by_customer`, `vw_payments_daily_summary`, `vw_sale_service_totals`. See `lib/src/core/packages/pocketbase/pocketbase_collections.dart` for the authoritative list of collection name constants.

---

## Entity Relationship Diagram

```
                    ┌───────────┐
                    │ UserRole  │
                    └─────┬─────┘
                          │
                          ▼
   ┌───────────┐    ┌───────────┐
   │  Branch   │◄───│   User    │
   └─────┬─────┘    └───────────┘
         │
         │  (branch-scoped; branch optional on most)
         ├─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
         ▼             ▼             ▼             ▼             ▼             ▼
   ┌──────────┐  ┌───────────┐ ┌──────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐
   │ Product  │  │  Service  │ │ Customer │ │  Machine  │ │  Storage  │ │   Promo   │
   └────┬─────┘  └─────┬─────┘ └────┬─────┘ └─────┬─────┘ │ Location  │ └─────┬─────┘
        │              │            │             │        └───────────┘       │
        ▼              ▼            │             ▼                            ▼
  ┌───────────┐  ┌─────────────┐    │       ┌───────────┐              ┌──────────────┐
  │ProductLot │  │ServicePrice │    │       │ LoadRule  │              │CustomerPromo │
  │ /Category │  │Tier/Category│    │       └───────────┘              └──────────────┘
  └───────────┘  └─────────────┘    │
                                     │
   ┌────────────────────────────────┴───────────────────────┐
   ▼                                                          ▼
┌───────┐   checkout    ┌───────┐                       ┌──────────┐
│ Cart  │──────────────►│ Sale  │◄──────────────────────│ Customer │
└───┬───┘                └───┬───┘
    │                        │
    ▼                        ▼
CartItem/            SaleItem/SaleServiceItem,
CartServiceItem      OrderStatusHistory, Payment
```

`Employee`, `ActivityLog`, `PrinterConfig`, `PosGroup`/`PosGroupItem`, `IncentiveTier`, and `FeatureFlag` are omitted from the diagram for clarity — see their sections below for relationships.

---

## Organization Domain

### User

All system users with role-based access.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | User's display name |
| `email` | String | Yes | Email for authentication |
| `avatar` | String | No | Avatar filename |
| `verified` | bool | Yes | Account verification status |
| `roleId` | String (FK) | No | FK to UserRole |
| `roleName` | String | No | Role name (expanded from FK) |
| `branchId` | String (FK) | No | FK to Branch |
| `branchName` | String | No | Branch name (expanded from FK) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `users`

**Relationships:**
- `roleId` -> UserRole (optional)
- `branchId` -> Branch (optional)

**Computed Properties:** `hasAvatar`, `displayRole`, `displayBranch`, `initials`, `verificationStatus`.

**Note:** a lighter-weight `User` model also exists at `lib/src/features/auth/domain/user.dart` for authentication state (`id`, `name`, `email`, `avatarUrl`, `verified`, `branch`) — this table describes the fuller one used by the Users management feature.

---

### UserRole

Role definitions with permissions.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Role name (e.g., "Admin", "Manager", "Cashier", "Attendant") |
| `description` | String | No | Role description |
| `permissions` | List\<String> | Yes | List of permission keys |
| `isSystem` | bool | Yes | Whether this is a system-defined role (cannot be deleted) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `userRoles`

**Referenced by:** User

**Seeded Roles:** `Admin` (full access, `system.admin`), `Manager`, `Cashier`, `Attendant` — see `server/pb_migrations/1774000001_seed_user_roles.js`.

**Permission categories** (`lib/src/features/users/domain/user_role.dart`): Customers, Products, Services, Inventory, Sales, Payments, Machines, Storages, Employees, Attendance, Reports, Users, Roles, Branches, Settings, Incentive, Dashboard, Organizations (`organizations.create`), Organization Members (`members.manage`), System — each with `.view`/`.create`/`.edit`/`.delete` keys as applicable, plus the blanket `system.admin` key.

---

### Branch

Business branches or locations.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Branch name (short internal identifier) |
| `address` | String | Yes | Branch address |
| `contactNumber` | String | Yes | Branch contact number |
| `organizationId` | String (FK) | Yes | FK to Organization |
| `operatingHours` | String | No | e.g. "Mon-Sat 8:00 AM - 5:00 PM" |
| `cutOffTime` | String | No | Cut-off time for accepting new orders |
| `incentiveAmount` | num | No | Incentive amount earned per threshold, in pesos (default 5) |
| `incentivePerServiceItems` | num | No | Service price threshold to earn the incentive (default 200) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `branches`

**Relationships:** `organizationId` -> Organization (required after backfill).

**Referenced by:** User, Product, Service, Customer, Sale, Cart, Promo, PosGroup, IncentiveTier (most of these treat `branch` as optional — unassigned records remain visible to all branches).

---

### Organization

Multi-tenant laundry business. Collection writes go through custom hooks (`POST /api/organizations`, `PATCH /api/organizations/{id}`), not raw collection REST. `POST /api/organizations` requires a first branch (and optional invites) and creates the org, Admin membership, branch, incentive tiers, and queued invites in one transaction.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Organization name |
| `contactNumber` | String | No | Contact number |
| `address` | String | No | Address |
| `onboardingCompletedAt` | DateTime | No | Set when the create-organization setup dialog finishes (org + first branch created together) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `organizations`

**Relationships:** has many Branches, OrganizationMemberships, OrganizationInvites.

---

### OrganizationMembership

Join between a user and an organization, with an org-scoped role.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `userId` | String (FK) | Yes | FK to User |
| `organizationId` | String (FK) | Yes | FK to Organization |
| `role` | UserRole | Yes | Role for this organization |
| `status` | String | Yes | `active` or `suspended` |
| `joinedAt` | DateTime | Yes | When membership started |
| `invitedBy` | String (FK) | No | FK to User |

**Collection:** `organizationMemberships`

**Relationships:** `userId` -> User; `organizationId` -> Organization; `role` -> UserRole. Unique on `(user, organization)`.

---

### OrganizationInvite

Email invite to join an organization. Token is server-hidden; clients accept/revoke by invite id.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `email` | String | Yes | Invitee email |
| `organizationId` | String (FK) | Yes | FK to Organization |
| `role` | UserRole | Yes | Role granted on accept |
| `status` | String | Yes | `pending`, `accepted`, `expired`, or `revoked` |
| `expiresAt` | DateTime | Yes | Expiry (7 days from create) |
| `invitedBy` | String (FK) | Yes | FK to User |
| `acceptedBy` | String (FK) | No | FK to User |

**Collection:** `organizationInvites`

Writes go through `POST /api/organization-invites`, `.../{id}/accept`, `.../{id}/revoke`, `.../{id}/decline`.

---

## Product Domain

### Product

Products and inventory items.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Product name |
| `description` | String | No | Product description |
| `categoryId` | String (FK) | No | FK to ProductCategory |
| `categoryName` | String | No | Category name (expanded from FK) |
| `image` | String | No | Product image URL |
| `branch` | String (FK) | No | FK to Branch |
| `stockThreshold` | num | No | Low stock warning threshold |
| `price` | num | No | Product price (default 0; `isVariablePrice` is true when `price <= 0`) |
| `unitCost` | num | No | Unit cost/acquisition cost (default 0) |
| `forSale` | bool | Yes | Whether product is for sale (default true) |
| `trackStock` | bool | Yes | Whether stock tracking is enabled (default false) |
| `requireStock` | bool | Yes | Whether stock must be available to add to cart (default false) |
| `quantity` | num | No | Current quantity (for non-lot tracking) |
| `expiration` | DateTime | No | Expiration date (for non-lot tracking) |
| `trackByLot` | bool | Yes | Whether to track inventory by lot (default false) |
| `quantityUnitId` | String (FK) | No | FK to QuantityUnit |
| `quantityUnit` | QuantityUnit | No | Quantity unit (expanded from FK) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `products`

**Relationships:** `categoryId` -> ProductCategory (optional); `branch` -> Branch (optional); `quantityUnitId` -> QuantityUnit (optional).

**Enum:** `ProductStatus { inStock, outOfStock, lowStock, noThreshold }` (computed via `stockStatus`, not a stored field).

---

### ProductCategory

Product categories with hierarchy support.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Category name |
| `parentId` | String (FK) | No | FK to ProductCategory (for hierarchy) |
| `parentName` | String | No | Parent category name (expanded from FK) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `productCategories`

**Relationships:** `parentId` -> ProductCategory (self-referencing, optional).

---

### ProductLot

Batch/lot tracking for a product with `trackByLot` enabled.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `productId` | String (FK) | Yes | FK to Product |
| `lotNumber` | String | Yes | Lot/batch identifier |
| `quantity` | num | No | Quantity in this lot (default 0) |
| `expiration` | DateTime | No | Expiration date of this lot |
| `notes` | String | No | Notes |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `productLots`

**Relationships:** `productId` -> Product.

**Computed Properties:** `isExpired`, `isNearExpiration` (within 30 days), `daysUntilExpiration`, `isOutOfStock`, `hasStock`.

---

### ProductAdjustment

Stock adjustment audit trail.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `type` | ProductAdjustmentType | Yes | `product` or `productStock` (lot) |
| `oldValue` | num | Yes | Previous quantity |
| `newValue` | num | Yes | New quantity |
| `reason` | String | No | Reason for the adjustment |
| `productId` | String (FK) | Conditional | FK to Product (when type = product) |
| `productStockId` | String (FK) | Conditional | FK to ProductStock (when type = productStock) |
| `productLotId` | String (FK) | Conditional | FK to ProductLot (for lot adjustments) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `productAdjustments`

**Enum:** `ProductAdjustmentType { product, productStock }`

**Computed Properties:** `delta`, `isIncrease`, `isDecrease`.

---

## Service Domain

### Service

Laundry services (wash, dry, fold, iron, etc.), scoped to a branch.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Service name |
| `description` | String | No | Service description |
| `categoryId` | String (FK) | No | FK to ServiceCategory |
| `categoryName` | String | No | Category name (expanded from FK) |
| `branch` | String (FK) | No | FK to Branch |
| `price` | num | No | Per-unit price (default 0) |
| `minimumCharge` | num | No | Floor for the line total (`max(minimumCharge, price × qty)` when no tiers apply); 0 = no floor |
| `isVariablePrice` | bool | Yes | Price entered at POS (default false) |
| `estimatedDuration` | num | No | Estimated duration in minutes |
| `weightBased` | bool | Yes | Quantity is typically kg (default false) |
| `showPrompt` | bool | Yes | Prompt for quantity when adding to cart (default false) |
| `maxQuantity` | int | No | Cap; null/0 means unlimited |
| `allowExcess` | bool | Yes | Split quantities exceeding `maxQuantity` into multiple cart items (default false) |
| `quantityUnitId` | String (FK) | No | FK to QuantityUnit |
| `quantityUnit` | QuantityUnit | No | Quantity unit (expanded from FK) |
| `isDefault` | bool | Yes | Auto-selected in Create Order (default false) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `services`

**Relationships:** `categoryId` -> ServiceCategory (optional); `branch` -> Branch (optional); `quantityUnitId` -> QuantityUnit (optional).

---

### ServiceCategory

Service categories (e.g., Wash, Dry, Iron).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Category name |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `serviceCategories`

---

### ServicePriceTier

Flat total or per-unit rate for a quantity range on a service (e.g. 1-3 kg at ₱90/kg, or a flat bucket total).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `serviceId` | String (FK) | Yes | FK to Service |
| `minQuantity` | num | Yes | Minimum quantity (inclusive) for this tier |
| `maxQuantity` | num | No | Maximum quantity (inclusive); null/0 = no upper limit |
| `pricePerUnit` | num | Yes | Range total when `flatPrice` unset — despite the name, this is the **range total**, not always a per-unit rate |
| `flatPrice` | num | No | When set (>0), the total is this flat amount regardless of quantity |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `servicePriceTiers`

**Relationships:** `serviceId` -> Service.

**Notes:** `resolveServiceTotal()`/`resolveServiceUnitPrice()` in `service_price_tier.dart` are the shared pricing functions used by both cart and sale line items.

---

## Quantity Units Domain

### QuantityUnit

Unit of measurement used by Products and Services (e.g., kilograms, pieces).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Full name (e.g., "kilograms") |
| `shortSingular` | String | Yes | Short singular form (e.g., "kg") |
| `shortPlural` | String | Yes | Short plural form (e.g., "kg") |
| `longSingular` | String | Yes | Long singular form (e.g., "kilogram") |
| `longPlural` | String | Yes | Long plural form (e.g., "kilograms") |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `quantityUnits`

**Referenced by:** Product, Service

---

## Customer Domain

### Customer

Laundry customers (members), scoped to the branch they were created on.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Customer name |
| `branchId` | String (FK) | No | FK to Branch (stamped on create) |
| `phone` | String | No | Phone number |
| `email` | String | No | Email (used for order history links) |
| `address` | String | No | Physical address |
| `notes` | String | No | Notes about the customer |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `customers`

**Relationships:** `branchId` -> Branch (optional in schema; always set by the app on create).

**Notes:**
- List, search, and create are filtered by the current working branch.
- Admins in All Branches mode can view all customers but cannot create until a specific branch is selected.
- A customer can be transferred to another branch from the customer detail page; historical sales stay on the branch where they were created.

---

## Cart Domain

Carts represent an in-progress POS shopping session, converted into a Sale at checkout.

### Cart

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `branchId` | String (FK) | Yes | Branch where this cart is active |
| `status` | String | Yes | Cart status (active, converted, abandoned) |
| `userId` | String (FK) | No | User owning the cart |
| `totalAmount` | num | No | Cached total amount |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `carts`

### CartItem

Product line item in a cart.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `cartId` | String (FK) | Yes | Parent Cart |
| `productId` | String (FK) | Yes | Product |
| `quantity` | num | Yes | Quantity (default 1) |
| `customPrice` | num | No | Custom price override (for variable-price products) |
| `productLotId` | String (FK) | No | FK to ProductLot (for lot-tracked products) |
| `lotNumber` | String | No | Lot number snapshot for display |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `cartItems`

### CartServiceItem

Service line item in a cart.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `cartId` | String (FK) | Yes | Parent Cart |
| `serviceId` | String (FK) | Yes | Service |
| `quantity` | num | Yes | Quantity (default 1) |
| `customPrice` | num | No | Custom price override (for variable-price services) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `cartServiceItems`

**Note:** `priceTiers` (the service's `ServicePriceTier` list) is held in memory on this model for pricing math — not a persisted field.

---

## Sales Domain

### Sale

A finalized transaction/receipt.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `receiptNumber` | String | Yes | Human-readable receipt number |
| `branchId` | String (FK) | Yes | Branch where the sale occurred |
| `cashierId` | String (FK) | Yes | User who processed the sale |
| `totalAmount` | num | Yes | Total amount charged |
| `status` | String | Yes | Transaction status (completed, refunded, voided) |
| `orderStatus` | OrderStatus | No | Fulfillment status (default `pending`) |
| `isPaid` | bool | No | Auto-calculated from payments (default false) |
| `paymentStatus` | PaymentStatus | No | `unpaid`/`partial`/`paid`, auto-calculated (default `unpaid`) |
| `packs` | int | No | Number of laundry bags/packs (default 0) |
| `pickedUpAt` | DateTime | No | Timestamp the order was picked up |
| `customerId` | String (FK) | No | FK to Customer |
| `customerName` | String | No | Customer name snapshot |
| `notes` | String | No | Internal notes |
| `postedDate` | DateTime | No | Editable business/transaction date |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `sales`

**Enums:** `OrderStatus { pending, processing, ready, pickedUp }`, `PaymentStatus { unpaid, partial, paid }`.

**Relationships:** `customerId` -> Customer (optional); `branchId` -> Branch; `cashierId` -> User.

### SaleItem

Product line item in a finalized sale.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `saleId` | String (FK) | Yes | Parent Sale |
| `productId` | String (FK) | Yes | Product |
| `productName` | String | Yes | Product name snapshot |
| `quantity` | num | Yes | Quantity sold |
| `unitPrice` | num | Yes | Price per unit at time of sale |
| `subtotal` | num | Yes | Line total |
| `productLotId` | String (FK) | No | FK to ProductLot |
| `lotNumber` | String | No | Lot number snapshot |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `saleItems`

### SaleServiceItem

Service line item in a finalized sale, including machine/storage assignment.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `saleId` | String (FK) | Yes | Parent Sale |
| `serviceId` | String (FK) | Yes | Service |
| `serviceName` | String | Yes | Service name snapshot |
| `quantity` | num | Yes | Quantity |
| `unitPrice` | num | Yes | Price per unit at time of sale |
| `subtotal` | num | Yes | Line total |
| `machineIds` | List\<String> (FK) | No | Assigned machines (multi-relation) |
| `machineLoadCounts` | Map\<String, int> | No | Load count per machine ID |
| `machineWeights` | Map\<String, double> | No | Entered weight (kg) per machine ID |
| `storageIds` | List\<String> (FK) | No | Assigned storage locations (multi-relation) |
| `storageName` | String | No | Storage name snapshot |
| `status` | ServiceItemStatus | No | Completion status |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `saleServiceItems`

**Relationships:** `machineIds` -> Machine (multi, optional); `storageIds` -> StorageLocation (multi, optional).

### OrderStatusHistory

Audit trail for status changes on sales (both sale status and order status).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `sale` | String (FK) | Yes | FK to Sale (cascade delete) |
| `statusType` | StatusType | Yes | Type of status changed |
| `fromStatus` | String | Yes | Previous status value |
| `toStatus` | String | Yes | New status value |
| `description` | String | No | Human-readable description |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `orderStatusHistory`

**Enum:** `StatusType { saleStatus, orderStatus }`

### Payment

A payment transaction against a sale.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `saleId` | String (FK) | Yes | FK to Sale |
| `amount` | num | Yes | Payment amount |
| `paymentMethod` | PaymentMethod | Yes | Cash, card, etc. |
| `type` | PaymentType | Yes | payment, deposit, or refund |
| `isVoided` | bool | No | Whether voided by an admin (default false) |
| `paymentRef` | String | No | External payment reference |
| `paymentProofUrl` | String | No | URL of payment proof image |
| `notes` | String | No | Notes |
| `postedDate` | DateTime | No | Editable business/transaction date |
| `voidedAt` | DateTime | No | Timestamp voided |
| `voidReason` | String | No | Admin note for the void |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `payments`

**Relationships:** `saleId` -> Sale.

---

## Machine & Storage Domain

### Machine

Laundry machines (washers, dryers, etc.) assigned to branches.

**Collection:** `machines` · **File:** `lib/src/features/machines/domain/machine.dart`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | String | Yes | auto | PocketBase record ID |
| `name` | String | Yes | - | Machine name (e.g., "Washer #1") |
| `type` | MachineType | Yes | - | washer, dryer, or other |
| `branchId` | String? (FK) | No | - | Relation to Branch |
| `isAvailable` | bool | No | true | Whether machine is currently available |
| `isDeleted` | bool | No | false | Soft delete flag |
| `created` | DateTime? | No | auto | Creation timestamp |
| `updated` | DateTime? | No | auto | Last update timestamp |

**Enum: MachineType** — `washer`, `dryer`, `other`. See also `MachineSize` (`machine_size.dart`) for capacity classification.

### LoadRule

Weight-to-load-count tiers for a machine (e.g. 0–8 kg = 1 load, 8.1–12 kg = 2 loads). Tiers are non-linear/customizable per machine.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `machineId` | String (FK) | Yes | FK to Machine |
| `loadCount` | int | Yes | Number of loads this tier represents |
| `minWeight` | double | No | Inclusive lower weight bound in kg (null = 0) |
| `maxWeight` | double | No | Inclusive upper weight bound in kg (null = unbounded) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `machineLoadRules`

### StorageLocation

Storage locations (shelves, racks) for laundry items.

**Collection:** `storages` · **File:** `lib/src/features/storages/domain/storage_location.dart`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | String | Yes | auto | PocketBase record ID |
| `name` | String | Yes | - | Location name (e.g., "Shelf A-1") |
| `branchId` | String? (FK) | No | - | Relation to Branch |
| `isAvailable` | bool | No | true | Whether location is available |
| `isDeleted` | bool | No | false | Soft delete flag |
| `created` | DateTime? | No | auto | Creation timestamp |
| `updated` | DateTime? | No | auto | Last update timestamp |

---

## Employee Domain

### Employee

A staff member of the laundry business (distinct from `User` — an Employee is a payroll/attendance subject, not necessarily an app login).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Employee name |
| `baseSalary` | num | No | Base salary amount (default 0) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `employees`

### EmployeeAttendance

Daily attendance record for an employee.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `employee` | String (FK) | Yes | FK to Employee |
| `date` | DateTime | Yes | Attendance date |
| `isPresent` | bool | No | Whether present (default true) |
| `notes` | String | No | Optional notes |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `employeeAttendances`

### EmployeeDeduction

A recurring deduction applied to an employee's salary — fixed amount or percentage, optionally time-bounded.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `employee` | String (FK) | Yes | FK to Employee |
| `type` | DeductionType | Yes | Deduction type |
| `valueType` | DeductionValueType | Yes | Fixed amount or percentage |
| `value` | num | Yes | Amount in pesos, or percentage |
| `name` | String | No | Custom name (used when type is "other") |
| `startMonth` | DateTime | No | Start month (inclusive); null = from the beginning |
| `endMonth` | DateTime | No | End month (inclusive); null = lifetime/ongoing |
| `isActive` | bool | No | Whether currently active (default true) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `employeeDeductions`

---

## Promo Domain

### Promo

A loyalty promotion: a free-weight reward earned after completing a set number of orders.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Promo display name |
| `description` | String | No | Description |
| `startDate` | DateTime | Yes | Start date |
| `endDate` | DateTime | Yes | Expiration date |
| `requiredOrders` | int | Yes | Orders required to earn the reward |
| `rewardFreeWeight` | num | Yes | Free weight reward amount in kg |
| `isActive` | bool | No | Whether enabled by admin (default true) |
| `branch` | String (FK) | No | FK to Branch (null = all branches) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `promos`

### CustomerPromo

Tracks one customer's progress in one loyalty promo.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `customerId` | String (FK) | Yes | FK to Customer |
| `promoId` | String (FK) | Yes | FK to Promo |
| `completedOrders` | int | No | Qualifying orders completed (default 0) |
| `isRewardEarned` | bool | No | Whether the reward threshold has been reached (default false) |
| `isRewardRedeemed` | bool | No | Whether the reward has been applied to an order (default false) |
| `redeemedOnSaleId` | String (FK) | No | Sale ID where the reward was redeemed |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `customerPromos`

**Relationships:** `customerId` -> Customer; `promoId` -> Promo; `redeemedOnSaleId` -> Sale (optional).

---

## Activity Domain

### ActivityLog

A single audit-trail entry recording a create/update/delete on any tracked collection.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `collection` | String | Yes | Name of the changed collection |
| `recordId` | String | Yes | ID of the changed record |
| `action` | ActivityAction | Yes | `create`, `update`, or `delete` |
| `description` | String | No | Human-readable description |
| `changes` | Map\<String, dynamic> | No | Change payload/diff |
| `userId` | String (FK) | No | User who made the change |
| `userName` | String | No | User name snapshot |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `activityLogs`

**Enum:** `ActivityAction { create, update, delete }`

---

## Settings Domain

### PrinterConfig

A configured thermal printer (Bluetooth or network) for receipt printing. Stored on **this device** (secure storage), not PocketBase. One printer can be selected for printing.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Local record ID |
| `name` | String | Yes | Printer name |
| `connectionType` | PrinterConnectionType | Yes | `bluetooth` or `network` |
| `address` | String | No | MAC address (Bluetooth) or IP address (network) |
| `port` | int | No | Network port (default 9100) |
| `paperWidth` | PrinterPaperWidth | No | `mm58` or `mm80` (default `mm80`) |
| `isEnabled` | bool | No | Whether enabled (default true) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

The selected printer ID is stored separately on the device (`selected_printer_id`). Existing PocketBase `printerConfigs` rows are imported once onto each device, then unused.

**Storage:** device secure storage (not a PocketBase collection)

### PosGroup

A named group of products/services shown as a section on the cashier page. Per-branch, ordered by `sortOrder`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Group display name |
| `branchId` | String (FK) | Yes | FK to Branch |
| `sortOrder` | int | No | Display order, lower first (default 0) |
| `isDeleted` | bool | No | Soft delete flag (default false) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `posGroups`

### PosGroupItem

A product or service assigned to a PosGroup — a many-to-many junction.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `groupId` | String (FK) | Yes | FK to PosGroup |
| `productId` | String (FK) | No | FK to Product (one of product/service must be set) |
| `serviceId` | String (FK) | No | FK to Service (one of product/service must be set) |
| `sortOrder` | int | No | Display order within the group (default 0) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `posGroupItems`

### IncentiveTier

Defines the incentive earned for a service price falling within a range, per branch.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `branch` | String (FK) | Yes | FK to Branch |
| `minAmount` | num | Yes | Minimum service price for this tier (inclusive) |
| `maxAmount` | num | No | Maximum service price (inclusive); null = no upper limit |
| `incentiveAmount` | num | Yes | Incentive earned when price falls in this tier |
| `sortOrder` | int | No | Display order (default 0) |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `incentiveTiers`

### FeatureFlag

Remote feature toggle for organization workflow (email updates, require machine/pack/storage). Edited under Management → Settings.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `key` | String | Yes | Flag key |
| `enabled` | bool | Yes | Whether the flag is on |
| `description` | String | No | Description |

**Collection:** `featureFlags`

---

## Public / Derived Models

### CustomerHistory

Not a PocketBase collection — a read-only aggregate assembled server-side (`server/pb_hooks/send_history_link_config.js` + related hooks) for the public customer order-status page (`docs/deployment.md` links this under the reset-password/privacy-policy static pages pattern). Composed of `CustomerHistoryCustomer`, `CustomerHistorySale` (with `OrderStatus`/`PaymentStatus`), `CustomerHistoryItem` (product lines), and `CustomerHistoryServiceItem` (service lines, including machine/storage name snapshots). See `lib/src/features/customer_history/domain/customer_history.dart`.

### AppConfig

Not a PocketBase collection in this app's own database — fetched from an external version-manager service's `versions` collection to drive the in-app update/minimum-version gate (`lib/src/features/version_lock/`). Fields: `major`/`minor`/`patch`, `minimumMajor`/`minimumMinor`/`minimumPatch`, `buildNumber`.

---

## Summary

**Total PocketBase collections (excluding SQL views):** 37 named constants in `pocketbase_collections.dart`, plus `orderStatusHistory` (referenced by literal string, not centralized as a constant) ≈ 38
**Total enums:** 15+ (one or more per feature — see each domain section above; not exhaustively cross-referenced here since several enums like `PrinterConnectionType`, `DeductionType`, `PaymentMethod` are UI/settings-only and don't warrant a dedicated table row)

| Enum | Values |
|------|--------|
| ProductStatus | inStock, outOfStock, lowStock, noThreshold |
| ProductAdjustmentType | product, productStock |
| OrderStatus | pending, processing, ready, pickedUp |
| PaymentStatus | unpaid, partial, paid |
| StatusType | saleStatus, orderStatus |
| ActivityAction | create, update, delete |
| MachineType | washer, dryer, other |

> **Note:** an earlier version of this document described a `Patient`/`AppointmentSchedule` domain family (patients, species, breeds, treatments, prescriptions) inherited from the veterinary-clinic template this project was originally forked from. None of that ever shipped for HZN Laundry — it has been removed as of the 2026-09-03 docs cleanup.
