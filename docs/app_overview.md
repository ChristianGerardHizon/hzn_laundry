# HZN Laundry - Application Overview

A comprehensive Flutter multi-platform laundry management system supporting Android, iOS, macOS, Linux, Windows, and Web.

---

## Table of Contents

1. [Features](#features)
2. [Core Functionality](#core-functionality)
3. [Domain Models](#domain-models)
4. [Key Screens](#key-screens)
5. [Integrations](#integrations)
6. [Navigation Structure](#navigation-structure)
7. [Architecture Patterns](#architecture-patterns)
8. [Project Structure](#project-structure)
9. [Technology Stack](#technology-stack)

---

## Features

### Primary Features (Main Navigation)

#### Employees (`/employees`)
Staff records, attendance, and payroll deductions.

- **Sub-features**:
  - Employees list & detail
  - Attendance tracking (clock in/out records)
  - Deductions (fixed or percentage-based, per employee)
- **Key Models**: `Employee`, `EmployeeAttendance`, `EmployeeDeduction`

#### Reports (`/reports`)
Sales and payroll reporting.

- Sales summaries by period (daily/weekly/monthly, via `ReportPeriod`)
- Salary/payroll reports by pay period (via `SalaryPeriod`), incorporating employee deductions
- Backed by PocketBase SQL view collections (e.g. `vw_sales_daily_summary`, `vw_sales_by_customer`) for aggregate queries

#### Products (`/products`)
Inventory and product management with lot tracking.

- **Sub-features**:
  - Products list with categories
  - Stock lots with FEFO (First-Expire-First-Out) tracking
  - Stock adjustments with audit trail
  - Hierarchical category organization
- **Key Models**: `Product`, `ProductCategory`, `ProductLot`, `ProductAdjustment`
- **Branch scope**: Product list, POS grid, cashier search, POS group picker, and order add-ons are limited to the current working branch

#### Services (`/services`)
Service management and POS integration for laundry services.

- **Sub-features**:
  - Services list with category filtering and search
  - Service categories management
  - Variable price, weight-based, and **minimum charge** support (e.g. ₱20/kg with a ₱120 floor)
  - Estimated duration tracking
  - Per-service **price tiers** (flat totals for a kg range, used by Hi-Zone Full Service)
- **Key Models**: `Service`, `ServiceCategory`, `ServicePriceTier`, `CartServiceItem`, `SaleServiceItem`
- **POS Integration**: Services appear in a separate tab in the cashier alongside products; both the services list and POS/cashier pickers are limited to the current working branch

#### Customers (`/customers`)
Customer (member) management with sales history tracking. Customers are scoped to the branch they were created on.

- **Sub-features**:
  - Customers list with search by name or phone (current branch only)
  - Customer detail with info, branch, and full sales history
  - Transfer a customer to another branch from the detail menu
  - Create/edit customer via dialog form (stamped with the current branch)
  - Inline customer creation from POS checkout
- **Key Models**: `Customer`
- **POS Integration**: Customer selection is required at checkout with search/autocomplete and quick "New Customer" creation, both limited to the current branch
- **Master-Detail Layout**: Tablet shows list + detail side-by-side; mobile navigates between pages
- **All Branches**: Admins can view customers across branches; creating a customer requires a specific branch

#### Dashboard (`/`)
Home screen with today's sales KPIs, kanban board, and operational alerts.

- Responsive layout (single column mobile, two-pane tablet)
- Sales summary KPI cards (including Needs Attention for incomplete order details); collapsing Today's Summary hides it for the rest of the local day on this device. A labeled Refresh control reloads all dashboard data (1s minimum) and shows a brief "Pulled new data complete" toast
- Kanban board for order status; Ready-for-pickup requires machines and pack count. Order cards show machine (Processing), location + packs (Ready), or machine + location + packs (Picked Up)

---

### Secondary Features

#### Point of Sale / Cashier (`/cashier`)
Complete POS system for processing sales of products and services.

- **Features**:
  - **Customizable Cashier Layout** (POS Groups): Create named groups of products/services per branch to define the cashier page layout. Groups display as scrollable sections with sticky headers. Items can belong to multiple groups. Falls back to default Products/Services tabs when no groups are configured.
  - Products/Services tab toggle (SegmentedButton) — default mode when no groups exist
  - Product grid with search and category filtering (current branch only)
  - Service grid with search (current branch only)
  - Search dropdown overlay (grouped mode) — searches products and services for the current branch, results show in a dropdown with type icons
  - Shopping cart with mixed product + service items
  - Lot selection with FEFO ordering for lot-tracked products
  - Variable price support for both products and services
  - Multiple payment methods (cash, card, check, etc.)
  - Receipt generation and printing
- **Components**:
  - `ProductGrid` - Product selection (default mode)
  - `ServiceGrid` - Service selection (default mode)
  - `GroupedCashierView` - Scrollable grouped sections with product/service cards (grouped mode)
  - `CashierSearchDropdown` - Search overlay for grouped mode
  - `CartView` - Shopping cart (products + services)
  - `CheckoutDialog` - Payment processing
  - `LotSelectionDialog` - FEFO lot selection
  - `ReceiptDialog` - Receipt display/print

#### Sales History (`/sales`)
View and manage completed transactions.

- Paginated sales history with search (current branch)
- Sale status display (pending, completed, refunded, cancelled)
- Detailed sale view with items and payment info
- Create-order add-ons picker shows only products for the current branch

#### Activities (`/activities`)
Audit log of changes made across the system (Admin-only, `system.admin` permission).

- Chronological feed of create/update/delete actions (`ChangeLogType`), who made them, and on what record
- Backed by the `activityLogs` collection, written by the `activity_logger_config.js` PocketBase hook

#### Promos (`/promos`)
Loyalty/promo campaign management (Admin-only, `system.admin` permission).

- Promos list & detail
- Customer-promo redemption tracking (`customerPromos`)

#### Customer History (`/history/:token`)
Public, tokenized read-only page a customer can open (e.g. from an SMS/receipt link) to view their own order history and status — no login required, scoped to their token.

---

### Organization/Admin Features

#### Organizations (`/organizations`)
Every signed-in user can see this tab (no permission gate) so pending invites are visible.

- List of organizations you belong to, with your role and a switch action
- Org details editable with `members.manage`
- Invite people by email + role; accept/decline pending invites
- Create a new organization (gated on global `organizations.create`) via a setup dialog: org details, first branch (required), optional team invites; the organization is created only when required setup is submitted
- Compact org switcher appears next to the branch switcher only when you belong to 2+ orgs

#### Management (`/management`)
3-panel tablet layout for org-wide people, assets, and catalog. The nav rail scrolls when needed.

**Layout** (tablet):
- Panel 1 (80px): Navigation rail with icon + text labels
- Panel 2 (320px): List panel
- Panel 3 (expanded): Detail panel or empty state

**Modes:**
- **Users** (`/management/users`) - User CRUD, role assignment, branch association
- **Roles** (`/management/roles`) - Role and permission management (Admin, Manager, Cashier, Attendant)
- **Branches** (`/management/branches`) - Multi-location support with address and contact info
- **Machines** (`/management/machines`) - Laundry machine management including size and per-machine weight→load rules; scoped to the current branch; unassigned machines remain visible
- **Storages** (`/management/storages`) - Storage location management for ready laundry items, scoped to the current branch; unassigned locations remain visible
- **Product Categories** (`/management/product-categories`) - Hierarchical product categories
- **Quantity Units** (`/management/quantity-units`) - Units of measure used by products/services (e.g. kg, pc)
- **Cashier Layout** (`/management/cashier-groups`) - POS groups management per branch (create groups, add products/services, reorder)
- **Import** (`/management/import`) - CSV product import
- **Settings** (`/management/settings`) - Organization workflow toggles (email updates, require machine/pack/storage)

Old `/system/...` URLs for the moved items redirect here.

#### System Settings (`/system`)
Device-specific settings only (this tablet/phone/desktop).

**Layout** (tablet):
- Panel 1 (80px): Navigation rail with icon + text labels
- Panel 2 (320px): Printer list (or full panel for Appearance)
- Panel 3 (expanded): Printer detail or empty state

**Modes:**
- **Printers** (`/system/printers`) - Thermal/receipt printers stored on this device; one selected printer for printing
- **Appearance** (`/system/appearance`) - Theme settings (local)

---

### Authentication (`/login`)

- Splash screen (`/splash`)
- Login page (`/login`)
- Forgot password (`/forgot-password`) — sends a PocketBase reset email; users finish at `{APP_URL}/reset-password.html?token=...`
- Auth loading (`/auth-loading`)
- Session management

---

## Core Functionality

Located in `/lib/src/core/`

### Routing (`/core/routing/`)
- GoRouter configuration with auth redirects
- Route files organized by domain
- Shell-based routing with nested subroutes

### Navigation (`/core/navigation/`)
- `desktop_nav_presentation.dart` - Shortcut/category grouping for the desktop sidebar

### PocketBase Integration (`/core/packages/pocketbase/`)
- `pocketbase_provider.dart` - Singleton instance
- `pocketbase_collections.dart` - Collection name constants
- `pb_filter.dart` - Query filter helpers
- `pb_expand.dart` - Relation expansion helpers

### Foundation (`/core/foundation/`)
- `failure.dart` - Standardized error handling
- `type_defs.dart` - Type aliases (`FutureEither<T>`, `Json`)
- `paginated_state.dart` - Pagination state management

### Shared Widgets (`/core/widgets/`)
- `mobile_bottom_nav.dart` - Bottom navigation
- `mobile_drawer.dart` - Mobile drawer
- `tablet_nav_rail.dart` - Tablet navigation rail (600–899px)
- `desktop_side_nav.dart` - Expandable desktop sidebar (≥900px)
- `breadcrumb_nav.dart` - Breadcrumb navigation
- `cached_avatar.dart` - Avatar caching

### Utilities (`/core/utils/`)
- `breakpoints.dart` - Responsive breakpoints
- `currency_format.dart` - Money formatting
- `date_utils.dart` - Date utilities

---

## Domain Models

### ~28 collections across 9 domains

See [`docs/entities.md`](entities.md) for full field-level detail; this is a summary. `docs/pb_schema.json` / `docs/updated_pb_schema.json` are the authoritative raw PocketBase schema exports.

#### Organizations Domain (3 collections)
| Collection | Description |
|------------|-------------|
| `organizations` | Multi-tenant laundry business |
| `organizationMemberships` | User membership in an organization (role + status) |
| `organizationInvites` | Email invite to join an organization |

#### Management Domain (6 collections)
| Collection | Description |
|------------|-------------|
| `users` | System users (all types) |
| `userRoles` | Role definitions with permissions |
| `branches` | Business branches/locations |
| `machines` | Laundry machines (washer, dryer, other), with size and load rules |
| `machineLoadRules` | Per-machine weight→load count rules |
| `storages` | Storage locations for ready laundry items |

Printers are stored on the device (secure storage), not in PocketBase. The leftover `printerConfigs` collection is only read once to import existing printers onto a device.

#### Product Domain (5 collections)
| Collection | Description |
|------------|-------------|
| `products` | Products/inventory items |
| `productCategories` | Hierarchical categories |
| `productStocks` | Stock lots with expiration |
| `productLots` | Batch/lot numbers (FEFO tracking) |
| `productAdjustments` | Stock change audit trail |

#### Service Domain (3 collections)
| Collection | Description |
|------------|-------------|
| `services` | Laundry services (wash, dry, fold, etc.) with optional `minimumCharge` |
| `serviceCategories` | Service categories |
| `servicePriceTiers` | Flat quantity-range totals for a service |

#### POS Domain (5 collections)
| Collection | Description |
|------------|-------------|
| `posGroups` | Named groups for cashier layout (per-branch) |
| `posGroupItems` | Many-to-many link between groups and products/services |
| `carts` / `cartItems` | Shopping cart (temporary, products) |
| `cartServiceItems` | Shopping cart (temporary, services) |

#### Sales Domain (4 collections)
| Collection | Description |
|------------|-------------|
| `customers` | Branch-scoped laundry customers (members) |
| `sales` | Transaction/order records |
| `saleItems` | Product items in a transaction |
| `saleServiceItems` | Service items in a transaction |
| `payments` | Payment records for a sale (supports multiple payments per sale) |

#### Employees Domain (3 collections)
| Collection | Description |
|------------|-------------|
| `employees` | Staff records |
| `employeeAttendances` | Clock in/out records |
| `employeeDeductions` | Payroll deductions per employee |

#### Promos & Misc (5 collections)
| Collection | Description |
|------------|-------------|
| `promos` | Loyalty/promo campaigns |
| `customerPromos` | Customer promo redemptions |
| `quantityUnits` | Units of measure (e.g. kg, pc) |
| `activityLogs` | Audit log of create/update/delete actions |
| `incentiveTiers` | Employee incentive tier definitions |

#### Workflow settings (1 collection)
| Collection | Description |
|------------|-------------|
| `featureFlags` | Organization workflow toggles (UI under Management → Settings) |

Plus a set of read-only SQL **view** collections for reporting (`vw_sales_daily_summary`, `vw_sales_by_customer`, `vw_top_selling_products`, `vw_top_selling_services`, `vw_inventory_status`, `vw_low_stock_products`, `vw_expired_lots`, `vw_near_expiration_lots`, `vw_pos_search_items`, `vw_customer_order_stats`, `vw_payments_daily_summary`, `vw_sale_service_totals`, and others).

### Enums
- `ProductStatus` - inStock, outOfStock, lowStock, noThreshold
- `ProductAdjustmentType` - product, productStock
- `OrderStatus` / `SaleStatus` - order/transaction lifecycle status
- `PaymentMethod` / `PaymentStatus` / `PaymentType` - payment handling
- `ServiceItemStatus` - per-line service item status
- `MachineType` / `MachineSize` - washer/dryer/other; small/large
- `DeductionType` / `DeductionValueType` - payroll deduction kind and fixed-vs-percentage
- `ActivityAction` - audit log action kind

---

## Key Screens

### Authentication
- Splash Screen (`/splash`)
- Login Screen (`/login`)
- Forgot Password (`/forgot-password`)

### Main Navigation
- **Dashboard**: Home with today's sales KPIs, kanban order board, alerts
- **Sales History**: Paginated transaction list and detail
- **Products List / Detail**: Catalog, stock, lot tracking, adjustments
- **Services List / Detail**: Catalog with pricing and price tiers
- **Customers List / Detail**: Member profiles with sales history
- **Employees List / Detail**: Staff records, attendance, deductions
- **Reports**: Sales and payroll reports by period
- **Activities**: Audit log feed (Admin-only)
- **Promos List / Detail**: Loyalty/promo campaigns (Admin-only)
- **Cashier/POS**: Product/service grid and checkout
- **Customer History**: Public tokenized order-history page

### Management (3-panel layout)
- Users Management (list/detail)
- Roles Management (list/detail)
- Branches Management (list/detail)
- Machines Management (list/detail, including load rules)
- Storages Management (list/detail)
- Product Categories (list/detail)
- Quantity Units (list/detail)
- Cashier Layout / POS Groups (list/detail)
- Import, Settings / feature flags (single panels)

### Organizations
- Memberships, invites, create-org setup dialog (`/organizations`)
- Header org switcher (2+ memberships) shows a full-screen, non-dismissible loader for at least 3 seconds while the new org loads

### System Settings (this device)
- Printers (list/detail; local storage, one selected printer)
- Appearance (theme)

### Responsive Behavior
| Breakpoint | Layout |
|------------|--------|
| Mobile (< 600px) | Single-column, bottom nav, drawer |
| Tablet (600-900px) | Master-detail, `TabletNavRail` |
| Tablet Large (900-1200px) | `DesktopSideNav` (expandable grouped sidebar) |
| Desktop (> 1200px) | `DesktopSideNav` + multi-panel pages |

---

## Integrations

### Backend: PocketBase
- **Type**: Open-source backend-as-a-service
- **Features**: Real-time database, authentication, file storage
- **Dev URL**: `http://127.0.0.1:8090`
- **Staging**: `https://staging.hznlaundry.hznsystems.com`
- **Production**: `https://hznlaundry.hznsystems.com`

### State Management: Hooks Riverpod
- `@riverpod` annotation for providers
- `AsyncNotifier` for async state
- `FutureEither<T>` pattern for error handling
- Family providers for parameterized state

### Serialization: dart_mappable
- `@MappableClass()` decorator
- Automatic JSON serialization
- DTOs for API↔Domain mapping

### Forms: flutter_form_builder
- `FormBuilder` widget wrapper
- Specialized fields: TextField, Dropdown, DateTimePicker, ChoiceChips
- `FormBuilderValidators` for validation

### Navigation: GoRouter
- Type-safe routing with `@TypedGoRoute`
- Generated route extensions
- Auth redirect on route change

### Error Handling: fpdart
- `Either<Failure, T>` for error handling
- `TaskEither.tryCatch()` for async operations
- Centralized `Failure` class

---

## Navigation Structure

### Route Hierarchy

```
App Root (Shell)
├── Auth (non-shell)
│   ├── /splash
│   ├── /login
│   ├── /forgot-password
│   └── /auth-loading
│
├── Public (non-shell, tokenized)
│   └── /history/:token (Customer History)
│
└── Main Shell (with navigation)
    ├── / (Dashboard)
    ├── /sales (Sales History)
    │   └── /sales/:id (Detail)
    ├── /cashier (Cashier/POS)
    ├── /products
    │   └── /products/:id (Detail)
    ├── /services
    │   └── /services/:id (Detail)
    ├── /customers
    │   └── /customers/:id (Detail)
    ├── /employees
    │   └── /employees/:id (Detail)
    ├── /reports
    ├── /activities (Admin-only)
    ├── /management (3-panel layout)
    │   ├── /management/users
    │   │   └── /management/users/:id
    │   ├── /management/roles
    │   │   └── /management/roles/:id
    │   ├── /management/branches
    │   │   └── /management/branches/:id
    │   ├── /management/machines
    │   │   └── /management/machines/:id
    │   ├── /management/storages
    │   │   └── /management/storages/:id
    │   ├── /management/product-categories
    │   │   └── /management/product-categories/:id
    │   ├── /management/quantity-units
    │   │   └── /management/quantity-units/:id
    │   ├── /management/cashier-groups
    │   │   └── /management/cashier-groups/:id
    │   ├── /management/import
    │   └── /management/settings
    ├── /organizations
    ├── /promos (Admin-only)
    │   └── /promos/:id (Detail)
    └── /system (this device)
        ├── /system/printers
        │   └── /system/printers/:id
        └── /system/appearance
```

### Navigation Components

| Platform | Component | Description |
|----------|-----------|-------------|
| Mobile | Bottom Nav | First 3 visible items + More |
| Mobile | Drawer | Full permission-filtered menu |
| Tablet (600–899px) | `TabletNavRail` | Icons + selected label |
| Tablet large / Desktop (≥900px) | `DesktopSideNav` | Expandable grouped sidebar (shortcuts + category flyouts) |

#### 3-Panel Master-Detail Layouts (Tablet)
Management and System sections use a 3-panel layout:

| Panel | Width | Content |
|-------|-------|---------|
| Panel 1 | 80px | Mode navigation rail (icon + text label) |
| Panel 2 | 320px | List panel with AppBar title and FAB |
| Panel 3 | Expanded | Detail panel or empty state |

- **Management modes**: Users, Roles, Branches, Machines, Storages, Product Categories, Quantity Units, Cashier Layout, plus single-panel Import/Settings
- **System modes**: Printers, Appearance (this device only)

### Navigation (permission-filtered, `nav_permissions.dart`)
1. 🏠 Dashboard - `/` (always visible)
2. 🧾 Sales History - `/sales`
3. 📦 Products - `/products`
4. 🧺 Services - `/services`
5. 👥 Customers - `/customers`
6. 🪪 Employees - `/employees`
7. 📊 Reports - `/reports`
8. 🕓 Activities - `/activities` (Admin-only)
9. 🏢 Management - `/management`
10. 🏬 Organizations - `/organizations` (always visible)
11. 🎁 Promos - `/promos` (Admin-only)
12. ⚙️ System - `/system`

Users with the `Admin` system role (or the `system.admin` permission) see every item; other roles see only items whose required permission they hold. Cashier/POS is reached from the Dashboard rather than as its own nav item.

---

## Architecture Patterns

### Clean Architecture Layers
1. **Data Layer**: Repositories, DTOs, data sources
2. **Domain Layer**: Entities, business models
3. **Presentation Layer**: Pages, controllers, widgets

### State Management Pattern
- **List Controllers**: `@Riverpod(keepAlive: true)` for persistent lists
- **Single Entity Providers**: `@riverpod` for detail views
- **Family Providers**: Parameterized state with `build(String id)`

### Error Handling
- All operations return `FutureEither<T>`
- `TaskEither.tryCatch()` for async error handling
- Centralized `Failure` class

### DTO Pattern
```dart
// Create from PocketBase record
factory Dto.fromRecord(RecordModel record)

// Convert to domain entity
Entity toEntity()

// Static method for create payload
static Json toCreateJson(Entity entity)
```

### Naming Conventions
- **Plural** (`PatientsController`) = manages list
- **Singular** (`patientProvider`) = manages single entity
- Pages: `*_page.dart`
- Sheets: `*_sheet.dart`
- Routes: `*.routes.dart`

---

## Project Structure

```
lib/src/
├── core/
│   ├── routing/           # GoRouter configuration
│   ├── pages/             # Shell page (app_root.dart)
│   ├── widgets/           # Shared UI components
│   ├── packages/          # External integrations
│   ├── foundation/        # Base classes (Failure, type defs)
│   ├── utils/             # Utilities
│   ├── extensions/        # Dart extensions
│   ├── hooks/             # Custom Flutter hooks
│   ├── constants/         # App constants
│   └── assets/i18n/       # Localization
│
└── features/
    ├── auth/              # Authentication
    ├── dashboard/         # Home/dashboard
    ├── products/          # Inventory
    ├── services/          # Laundry services catalog
    ├── customers/         # Customer (member) management
    ├── pos/               # Point of sale (cashier, cart, receipts)
    ├── sales/              # Sales history
    ├── employees/         # Staff, attendance, deductions
    ├── machines/          # Laundry machines
    ├── storages/          # Storage locations
    ├── promos/            # Loyalty/promo campaigns
    ├── quantity_units/    # Units of measure
    ├── reports/           # Sales/payroll reports
    ├── activities/        # Audit log
    ├── customer_history/  # Public tokenized order-history page
    ├── settings/          # Device printers, appearance; shared catalog controllers
    ├── management/        # Users/roles/branches/machines/storages (3-panel layout)
    ├── organizations/     # Multi-tenant orgs, memberships, invites
    ├── users/             # User & role management
    └── version_lock/      # Minimum-version / update enforcement
        │
        └── [feature]/
            ├── data/
            │   ├── repositories/
            │   └── dto/
            ├── domain/
            └── presentation/
                ├── controllers/
                ├── pages/
                └── widgets/
```

---

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Backend | PocketBase | BaaS, real-time database |
| Frontend | Flutter | Multi-platform UI |
| State Management | Riverpod + Hooks | Reactive state |
| Navigation | GoRouter | Type-safe routing |
| Forms | flutter_form_builder | Form handling |
| Serialization | dart_mappable | JSON mapping |
| Error Handling | fpdart | Functional Either/Task |
| Storage | flutter_secure_storage | Sensitive data |
| Localization | slang | i18n support |
| Code Gen | build_runner | Automatic generation |

---

## Recent Updates

| Sep 03 | Brand logo refresh | App icons, splash, favicon, Play high-res icon, and store feature graphic now use the circular HZN Laundry mark (charcoal + teal, FAST ★ FRESH ★ FOLDED)
| Sep 03 | Play Internal upload CI | Production Play upload is a required, retryable `upload-play-internal` job. Local `sync_github_secrets.py` pushes keystore, Play JSON, and PocketBase URLs into GitHub secrets |
| Sep 03 | Org create setup dialog | Create Organization is a stepper dialog (details, first branch, optional invites, review). The org is created only when required setup is submitted, in one server transaction with the first branch. |
| Sep 03 | Org switch loader | Full-screen overlay covers the authenticated shell (including the desktop sidebar) for at least 3 seconds when switching organizations |
| Sep 03 | Desktop side nav | Firebase-style expandable sidebar at ≥900px (`DesktopSideNav`): Dashboard, Shortcuts, hover/tap category flyouts, System/Logout, session collapse. Tablet 600–899px still uses `TabletNavRail` |
| Sep 03 | Multi-tenant organizations | Organizations, memberships, and invites; Management rename of the old admin section; org switcher for multi-org users; email+password auth with `reset-password.html` |
| Sep 03 | Docs Cleanup | Removed leftover vet-clinic template content (Patients/Appointments/Treatments/Messages) from app_overview.md, replaced with accurate feature/navigation/domain-model docs matching the current laundry app |
| Sep 02 | Google Play In-App Updates | Replaced the custom PocketBase APK-download updater with Play's native In-App Update API (flexible nudge + immediate force-update, Play Store listing fallback). Minimum-version lockout is now Android+web only; iOS/macOS/Linux/Windows skip auto-update entirely |
| Aug 30 | Dashboard order tags | Kanban cards show location when assigned: Processing = machine; Ready = location + packs; Picked Up = machine + location + packs |
| Aug 28 | App flavors | `dev`, `staging`, and `prod` flavors. Android can install all three side by side. Dev talks to local PocketBase; staging and prod use their live URLs |
| Aug 28 | Mobile dashboard and Create Order polish | Phone pull-to-refresh matches Today's Summary (1s wait + complete toast). New Customer is under More. Drawer Logout is red like desktop. Create Order service cards use an even grid |
| Aug 28 | Product Overview stock actions | Tracked products get Add/Remove Stock presets and latest adjustments with Show more (opens Adjustments). Untracked products can enable tracking from Overview. Details hides Adjust Stock when tracking is off or lot-based |
| Aug 28 | Today's Summary refresh | Dashboard section title is Today's Summary. Refresh is a labeled button with a 1s minimum wait and a "Pulled new data complete" overlay toast |
| Aug 28 | Record payment CTA + Print All | Unpaid order Record Payment is a high-contrast green button. Print menus include Print All (store then customer claim sheets) |
| Aug 28 | Magsaysay FULL SERVICE pricing | Services can set a `minimumCharge`. Mag FULL SERVICE is ₱20/kg with a ₱120 floor in Create Order and POS; Hi-Zone flat kg-bucket tiers are unchanged |
| Aug 28 | Sales summary hide for the day | Collapsing Today's Summary on the dashboard persists on-device for the local calendar day and expands again tomorrow |
| Aug 28 | Privacy policy page | Public web page at `/privacy-policy.html` for Play Console and store compliance |
| Aug 28 | Web search indexing | `robots.txt` and `noindex` meta tags discourage search indexing of the staff web app |
| Aug 28 | Remove All files access | Dropped `MANAGE_EXTERNAL_STORAGE` (Play restricted). PDF save, CSV import, and APK updates use the system picker/save dialog or app-specific storage |
| Aug 28 | Play Store Internal testing | Production deploy builds a signed Android App Bundle and publishes it to Google Play Internal testing; APK still goes to GitHub Releases |
| Aug 28 | Mobile dashboard cleanup | Phone dashboard uses a 2-column sales KPI grid, denser alert banners, full-width Order Board filters, and a More popover for Attendance / Machine & Storage |
| Aug 28 | Assign machine on completed lines | Assign Machine stays available when a service line is completed but has no machine (legacy Ready orders). Assigning does not reopen a completed line to in progress |
| Aug 28 | Ready pickup completeness | Moving an order to Ready always asks for machines and pack count. Dashboard Needs Attention KPI lists processing orders plus Ready / same-day Picked Up orders missing machines or packs |
| Aug 26 | Branch-scoped catalogs | Order add-ons, POS product/service grids, cashier search, and POS group pickers now show only the current branch's products and services. New machines and storage locations are stamped with the current branch |
| Aug 17 | Dashboard Add-ons / Loads KPIs | Add-ons Sold and Loads now aggregate from today's already-fetched sale line items instead of full-history PocketBase views (`vw_add_ons_summary`, `vw_loads_summary` removed) |
| Aug 17 | Products list across branches | Products list rule now allows any logged-in user to list products; the app still filters by the selected branch, so admins switching branches (e.g. Hi-Zone → Magsaysay) can see that branch's catalog |
| Aug 15 | Branch-scoped customers | Customers (members) belong to the branch they were created on; list/search/create follow the current branch. Existing customers were assigned from their most recent sale. Customer detail can transfer a member to another branch |
| Aug 03 | Web Thermal Print Guard | Disabled thermal printing on web (Bluetooth discovery, test print, auto-print, claim-sheet print actions); PDF preview/print remains available |
| Aug 03 | All Branches Mode | Admins can select All Branches in the branch switcher to view unfiltered data across features; Cashier/POS shows a blurred overlay warning until a specific branch is chosen |
| Aug 03 | Network Health | Polls PocketBase `/api/health` for online/poor/offline status; logo circular border is green (connected), amber (poor, ≥1s latency), or red (no connection) on nav rail, drawer, and login |
| Jun 07 | Machine Load | Added machine size (small/large) and per-machine weight→load rules (customizable, non-linear tiers) managed under System → Machines, with a "copy rules to same type/size" action. When assigning machines to an order, entering weight (kg) auto-computes the load count from the matching rule, still overridable manually; weights are stored on the sale service item |
| Jun 06 | Fix Report Date Grouping | Fixed vw_sales_daily_summary and vw_sales_by_customer to group by PHT date (UTC+8) — orders created 12:00–7:59 AM PHT were appearing in the previous day's report |
| Apr 01 | Users & Roles | Replaced old vet-clinic roles (Veterinarian, Staff, Cashier) with laundry-appropriate roles: Admin, Manager, Cashier, Attendant. Added test user accounts for each role |
| Feb 05 | Order Status History | Added orderStatusHistory collection and timeline UI on sale detail page to track every status change (sale status and order status) with auto-logging on create and update |
| Feb 05 | Machines & Storages | Added machines and storage locations management under Organization with CRUD, plus machine/storage assignment dialogs when transitioning sale order status to processing/ready |
| Feb 04 | SSH Web Deployment | Added SSH-based auto-deployment of web builds and PocketBase migrations to staging/production servers via rsync in CI/CD pipeline |
| Feb 04 | Deployment Docs | Added CI/CD and deployment documentation (`docs/deployment.md`) covering GitHub Actions workflows, secrets, version management, and branching strategy |
| Feb 02 | Customers Feature | Customer CRUD with sales history, required customer at POS checkout with search and inline creation |
| Feb 02 | Cashier Groups | Customizable cashier layout with POS groups per branch — scrollable sections, search dropdown, settings page under System, falls back to default tabs when no groups configured |
| Feb 02 | Services Feature | Full services CRUD (wash, dry, fold, iron) with categories, variable pricing, POS integration via Products/Services tab toggle, cart support, and checkout flow |
| Jan 24 | 3-Panel Layouts | Organization and System now use 3-panel tablet layouts with nav rail, list, and detail panels |
| Jan 24 | Branches Moved | Branches management moved from System to Organization section |
| Jan 24 | Nav Panel Labels | Navigation panels now show icon + text labels for better clarity |
| Jan 23 | Patient Files | Upload/view images, videos, PDFs with 10MB limit |
| Jan 21 | Lot Tracking | FEFO ordering in cashier |
| Jan 21 | Treatment Plans | Multi-visit treatment with edit |
| Jan 19 | Stock Adjustments | Audit trail for inventory |
| Jan 18 | Message Templates | Appointment message selector |
| Jan 16 | Sale Status | Improved display with icons |
