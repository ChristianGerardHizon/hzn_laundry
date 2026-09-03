# UI Structure - Tablet & Mobile

This document outlines the responsive UI structure for tablet and mobile devices, including navigation patterns and routing architecture.

---

## Table of Contents
- [Responsive Breakpoints](#responsive-breakpoints)
- [Mobile Layout](#mobile-layout)
- [Tablet & Desktop Layout](#tablet--desktop-layout)
- [Navigation Hierarchy](#navigation-hierarchy)
- [Routing Structure](#routing-structure)
- [Component Architecture](#component-architecture)
- [Navigation Configuration](#navigation-configuration)
- [Tabbed Detail Pages](#tabbed-detail-pages)
- [Implementation Notes](#implementation-notes)

---

## Responsive Breakpoints

```
┌─────────────────────────────────────────────────────────────────┐
│                        BREAKPOINTS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  0px          600px         900px        1200px                 │
│  │             │             │             │                    │
│  │   MOBILE    │   TABLET    │  TABLET LARGE / DESKTOP           │
│  │             │  (icons)    │   expandable sidebar              │
│  │ Bottom Nav  │             │                                   │
│  │ + Drawer    │  TabletNavRail       DesktopSideNav             │
│  │             │                                                 │
└─────────────────────────────────────────────────────────────────┘
```

Defined in `lib/src/core/utils/breakpoints.dart` (`Breakpoints`):

| Breakpoint | Range | Layout |
|------------|-------|--------|
| Mobile     | 0-599px | Bottom nav + drawer (`MobileBottomNav` / `MobileDrawer`) |
| Tablet     | 600-899px | `TabletNavRail`, icons only (selected label) |
| Tablet large / Desktop | 900px+ | `DesktopSideNav` — expandable grouped sidebar |

`AppRoot` still has one non-mobile shell (`_buildTabletLayout`). Inside that row it switches at `Breakpoints.isTabletLargeOrLarger` (900px): `TabletNavRail` below the threshold, `DesktopSideNav` at and above it.

---

## Mobile Layout

### Main Structure (< 600px)

```
┌─────────────────────────────────────┐
│ [Branch Switcher]      [Fullscreen] │  <- Top row (BranchSwitcher + toggle)
├─────────────────────────────────────┤
│                                     │
│                                     │
│           CONTENT AREA              │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  🏠      🧾      📦      •••       │  <- NavigationBar: first 3 items + More
│ Dash   Sales   Products  More       │
└─────────────────────────────────────┘
```

`MobileBottomNav` (`lib/src/core/widgets/mobile_bottom_nav.dart`) shows only the **first 3 permission-visible nav items** plus a "More" destination that opens the drawer — not a fixed 5-item set. Which 3 items appear depends on the signed-in user's role permissions (see [Navigation Configuration](#navigation-configuration)).

### Mobile Drawer (`MobileDrawer`, accessed via hamburger or "More")

```
┌───────────────────────┐
│  ╭─────╮              │
│  │ LOGO│  HZN Laundry  │
│  ╰─────╯  Laundry Management System │
│           <pocketbase url>          │
├───────────────────────┤
│  [Branch Switcher]     │
├───────────────────────┤
│ 🏠 Dashboard           │
│ 🧾 Sales History       │
│ 📦 Products            │
│ 🩺 Services            │
│ 👤 Customers           │
│ 🪪 Employees            │
├───────────────────────┤   <- Divider after index 5
│ 📊 Reports             │
│ 🕓 Activities           │
│ 🏢 Organization        │
│ 🎟️ Promos              │
│ ⚙️ System              │
├───────────────────────┤
│ 🚪 Logout              │
└───────────────────────┘
```

Items are permission-filtered (`filterNavItems`) before this split — a role without `system.admin` only sees the items its permissions unlock, in this same relative order. `MobileDrawer` splits the *visible* list into a "primary" group (original index ≤ 5: Dashboard, Sales History, Products, Services, Customers, Employees) above a divider, and a "secondary" group (index > 5: Reports, Activities, Organization, Promos, System) below it.

---

## Tablet & Desktop Layout

Both tablet and desktop widths (≥ 600px) use `AppRoot._buildTabletLayout`: nav on the left, a vertical divider, and the page content (with the same branch-switcher/fullscreen-toggle header row as mobile) filling the rest. The left chrome changes at 900px.

### Tablet (600–899px) — `TabletNavRail`

```
┌────┬──────────────────────────────────────────┐
│    │ [Branch Switcher]           [Fullscreen] │
│ 🏠 ├──────────────────────────────────────────┤
│ 🧾 │                                          │
│ 📦 │              CONTENT AREA                │
│ …  │                                          │
│ 🚪 │  <- Logout icon button, bottom of rail    │
└────┴──────────────────────────────────────────┘
```

`TabletNavRail` renders a Material `NavigationRail` over the same permission-filtered item list used by mobile (no primary/secondary split — every visible item is a rail destination). `labelType` is `NavigationRailLabelType.selected` (icons only, except the selected item's label).

### Tablet large / Desktop (900px+) — `DesktopSideNav`

Firebase-style expandable sidebar (`lib/src/core/widgets/desktop_side_nav.dart`): 260px expanded / 72px collapsed. Grouping lives in `lib/src/core/navigation/desktop_nav_presentation.dart` and still uses the same permission-filtered `NavItem` list.

```
┌────────────────┬──────────────────────────────────┐
│ LOGO  HZN …    │ [Branch Switcher]   [Fullscreen] │
│ Dashboard      ├──────────────────────────────────┤
│ Shortcuts      │                                  │
│  Orders        │                                  │
│  Products      │          CONTENT AREA            │
│  Services      │                                  │
│  Customers     │                                  │
│  Show more     │                                  │
│ Categories     │                                  │
│  Operations ▸  │  <- hover/tap flyout             │
│  People ▸      │                                  │
│  Insights ▸    │                                  │
│  Administration▸                                  │
│ System      ▸  │                                  │
│ Logout         │                                  │
│ < collapse     │                                  │
└────────────────┴──────────────────────────────────┘
```

| Slot | Items |
|------|--------|
| Pinned top | Dashboard |
| Default shortcuts | Orders, Products, Services, Customers |
| Show more extras | Employees, Reports, Activities, Management, Organizations, Promos |
| Operations flyout | Promos (when not expanded via Show more) |
| People flyout | Employees |
| Insights flyout | Reports, Activities |
| Administration flyout | Management, Organizations |
| Pinned above footer | System |
| Footer | Logout + collapse/expand |

Shown shortcuts are excluded from category flyouts. Empty groups (after permission filtering) are omitted. Collapse is session-only. Category rows open a flyout on hover when expanded, and on tap when collapsed.

List/detail master-detail layouts (e.g. a list panel beside a detail panel) are implemented per-page where the page needs one, not by the shell itself — check individual feature pages (e.g. `lib/src/features/products/presentation/pages/`) for whether a given screen adopts that pattern at these widths.

---

## Navigation Hierarchy

```
                              ┌─────────────────┐
                              │    AppRoot      │
                              │ (mobile/tablet   │
                              │  layout switch)  │
                              └────────┬────────┘
                                       │
        ┌───────────────┬─────────────┼─────────────┬───────────────┐
        ▼               ▼             ▼             ▼               ▼
   ┌─────────┐    ┌───────────┐  ┌──────────┐  ┌──────────┐   ┌───────────┐
   │Dashboard│    │  Sales    │  │ Products │  │ Services │   │ Customers │
   └─────────┘    │  History  │  └────┬─────┘  └────┬─────┘   └─────┬─────┘
                   └─────┬─────┘      │             │               │
                         ▼            ▼             ▼               ▼
                    Sale Detail  Product Detail Service Detail Customer Detail

   ┌───────────┐   ┌─────────┐   ┌───────────────┐   ┌────────┐   ┌────────┐
   │ Employees │   │ Reports │   │  Activities   │   │ Promos │   │ System │
   └─────┬─────┘   └─────────┘   └───────────────┘   └───┬────┘   └───┬────┘
         ▼                                                ▼            ▼
   Employee Detail                                   Promo Detail  Printers,
                                                                    Appearance

                              ┌───────────────┐
                              │ Management    │
                              └───────┬───────┘
         ┌───────┬──────┬──────┼──────┬────────┬─────────┬────────┐
         ▼       ▼      ▼      ▼      ▼        ▼         ▼        ▼
       Users   Roles Branches Machines Storages Categories Units  Cashier,
                                                                  Import,
                                                                  Settings

                              ┌───────────────┐
                              │ Organizations │
                              └───────────────┘
                                Switch / invites / setup
```

Sales History (`/sales`, list + report view) and the Cashier/POS screen (`/cashier`) are distinct routes — the nav item labelled "Sales History" points at `/sales`; the point-of-sale checkout flow lives at `/cashier` and is reached from within the app rather than as its own top-level nav destination.

---

## Routing Structure

### Route Tree (per `lib/src/core/routing/routes/*.routes.dart`)

```
/                                    -> Dashboard
│
├── /sales                           -> Sales History List
│   └── /sales/:id                   -> Sale Detail
│
├── /cashier                         -> Cashier / POS
│
├── /products                        -> Products List
│   └── /products/:id                -> Product Detail
│
├── /services                        -> Services List
│   └── /services/:id                -> Service Detail
│
├── /customers                       -> Customers List
│   └── /customers/:id               -> Customer Detail
│
├── /employees                       -> Employees List
│   └── /employees/:id               -> Employee Detail
│
├── /reports                         -> Reports
│
├── /activities                      -> Activities (audit log; requires system.admin)
│
├── /management                    -> Management Landing
│   ├── /management/users          -> Users List
│   │   └── /management/users/:id  -> User Detail
│   ├── /management/roles          -> Roles List
│   │   └── /management/roles/:id  -> Role Detail
│   ├── /management/branches       -> Branches List
│   │   └── /management/branches/:id -> Branch Detail
│   ├── /management/machines       -> Machines List
│   │   └── /management/machines/:id -> Machine Detail
│   ├── /management/storages       -> Storages List
│   │   └── /management/storages/:id -> Storage Detail
│   ├── /management/product-categories -> Product Categories List
│   │   └── /management/product-categories/:id -> Category Detail
│   ├── /management/quantity-units -> Quantity Units List
│   │   └── /management/quantity-units/:id -> Quantity Unit Detail
│   ├── /management/cashier-groups -> POS Groups List
│   │   └── /management/cashier-groups/:id -> Cashier Group Detail
│   ├── /management/import         -> Data Import
│   └── /management/settings       -> Workflow Settings
│
├── /organizations                 -> Organizations
│
├── /promos                          -> Promos List
│   └── /promos/:id                  -> Promo Detail
│
├── /system                          -> System Landing (this device)
│   ├── /system/printers             -> Printer Configs List
│   │   └── /system/printers/:id     -> Printer Config Detail
│   └── /system/appearance           -> Appearance Settings
│
│   (legacy `/system/product-categories`, `/system/quantity-units`,
│    `/system/machines`, `/system/cashier-groups`, `/system/import`,
│    `/system/feature-flags` redirect to the matching `/management/...` paths)
│
├── /history/:token                  -> Customer History (shared link, outside the shell)
│
└── auth (non-shell routes)
    ├── /splash                      -> Splash
    ├── /login                       -> Login
    ├── /forgot-password             -> Forgot Password
    └── /auth-loading                -> Auth Loading
```

`/users` and `/roles` also exist as separate top-level route files (`users.routes.dart`, `roles.routes.dart`) alongside the `/management/users` and `/management/roles` nested routes above — both are present in the codebase; which one a given entry point (e.g. a dashboard quick action vs. the Management nav item) links to depends on the calling widget, not audited exhaustively here.

### Shell Branches (12 nav-visible + Cashier)

| # | Branch | Base Route | Permission gate |
|---|--------|------------|------------------|
| 0 | Dashboard | `/` | always visible |
| 1 | Sales History | `/sales` | `sales.view` |
| 2 | Products | `/products` | `products.view` |
| 3 | Services | `/services` | `services.view` |
| 4 | Customers | `/customers` | `customers.view` |
| 5 | Employees | `/employees` | `employees.view` |
| 6 | Reports | `/reports` | `reports.view` |
| 7 | Activities | `/activities` | `system.admin` |
| 8 | Management | `/management` | `branches.view` |
| 9 | Organizations | `/organizations` | always visible |
| 10 | Promos | `/promos` | `system.admin` |
| 11 | System | `/system` | `settings.view` |
| — | Cashier / POS | `/cashier` | reached in-app, not a nav-bar destination |

A role with `isAdmin` (`system.admin` permission) sees every item regardless of the individual gates above (`filterNavItems`).

---

## Component Architecture

### Shell Widget Structure (`AppRoot`)

```
AppRoot (ConsumerStatefulWidget)
├── Mobile layout (< 600px)
│   └── Scaffold
│       ├── drawer: MobileDrawer
│       ├── body: [OrganizationSwitcher + BranchSwitcher + FullscreenToggleButton] row, then page content
│       └── bottomNavigationBar: MobileBottomNav (first 3 items + More)
│
└── Tablet/Desktop layout (>= 600px)
    └── Row
        ├── TabletNavRail (600-899px) or DesktopSideNav (900px+)
        ├── VerticalDivider
        └── Expanded
            └── Scaffold
                └── body: [OrganizationSwitcher + BranchSwitcher + FullscreenToggleButton] row, then page content
```

There is no separate `AdaptiveShell`/`MobileShell`/`TabletShell`/`DesktopShell` class hierarchy — `AppRoot` itself branches on `Breakpoints.isMobile(context)` and calls `_buildMobileLayout` or `_buildTabletLayout` directly. `_buildTabletLayout` then picks `TabletNavRail` vs `DesktopSideNav` at 900px.

---

## Navigation Configuration

Source of truth: `buildAllNavItems()` in `lib/src/core/widgets/nav_permissions.dart`.

| Index | Icon | Label | Route | Required permission |
|---|---|---|---|---|
| 0 | `dashboard_outlined` | Dashboard | `/` | none (always visible) |
| 1 | `receipt_long_outlined` | Sales History | `/sales` | `sales.view` |
| 2 | `inventory_2_outlined` | Products | `/products` | `products.view` |
| 3 | `miscellaneous_services_outlined` | Services | `/services` | `services.view` |
| 4 | `people_outlined` | Customers | `/customers` | `customers.view` |
| 5 | `badge_outlined` | Employees | `/employees` | `employees.view` |
| 6 | `analytics_outlined` | Reports | `/reports` | `reports.view` |
| 7 | `history_outlined` | Activities | `/activities` | `system.admin` |
| 8 | `business_outlined` | Management | `/management` | `branches.view` |
| 9 | `apartment_outlined` | Organizations | `/organizations` | none (always visible) |
| 10 | `loyalty_outlined` | Promos | `/promos` | `system.admin` |
| 11 | `settings_outlined` | System | `/system` | `settings.view` |

Mobile bottom nav uses `visibleItems.take(3)` from this same permission-filtered list (so its contents shift per role, not a fixed "primary 4" set); the drawer shows the full filtered list split around original index 5.

---

## Tabbed Detail Pages

Several detail pages across the app use a `TabBar`/`TabBarView` pattern rather than a single scroll view — e.g. `lib/src/features/products/presentation/pages/product_detail_page.dart`, plus `sale_detail_page.dart`, `user_detail_page.dart`, and `employee_detail_page.dart`. Product Detail is representative:

```
Product Detail Page (/products/:id)
├── Tab 0: Overview     -> ProductOverviewTab
├── Tab 1: Details      -> ProductDetailsTab
├── Tab 2: Stock        -> ProductStockTab
└── Tab 3: Adjustments  -> ProductAdjustmentsTab
```

Each such page keeps its tab widgets in `presentation/widgets/tabs/` (or similar) alongside the page, named `*_tab.dart`. Check the specific feature's `presentation/pages/*_detail_page.dart` for its exact tab set — they aren't identical across features (e.g. Employee Detail's tabs differ from Product Detail's).

---

## Implementation Notes

### Key Files

| File | Purpose |
|------|---------|
| `lib/src/core/pages/app_root.dart` | Main shell widget — mobile/tablet layout switch, nav item wiring |
| `lib/src/core/widgets/mobile_bottom_nav.dart` | Mobile bottom navigation bar |
| `lib/src/core/widgets/mobile_drawer.dart` | Mobile drawer |
| `lib/src/core/widgets/tablet_nav_rail.dart` | Navigation rail for tablet widths (600–899px) |
| `lib/src/core/widgets/desktop_side_nav.dart` | Expandable grouped sidebar for tablet-large / desktop (≥900px) |
| `lib/src/core/navigation/desktop_nav_presentation.dart` | Shortcut/category grouping for `DesktopSideNav` |
| `lib/src/core/widgets/nav_permissions.dart` | `NavId` / `NavItem` list, permission filtering, `currentUserRoleProvider` |
| `lib/src/core/utils/breakpoints.dart` | Centralized breakpoint definitions |
| `lib/src/core/routing/routes/*.routes.dart` | Per-feature route definitions (`@TypedGoRoute`) |
