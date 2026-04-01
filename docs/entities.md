# Project Entities

This document contains all entities (domain models) in the project with their fields, relationships, and collection names.

---

## Entity Overview

| Domain | Entity | Collection | Description |
|--------|--------|------------|-------------|
| Organization | User | `users` | System users (all types) |
| Organization | UserRole | `user_roles` | Role definitions and permissions |
| Organization | Branch | `branches` | Business branches/locations |
| Patient | Patient | `patients` | Animal patients |
| Patient | PatientSpecies | `patient_species` | Species catalog (Dog, Cat, etc.) |
| Patient | PatientBreed | `patient_breeds` | Breed catalog |
| Patient | PatientRecord | `patient_records` | Medical visit records |
| Patient | PatientFile | `patient_files` | Patient documents/images |
| Patient | PatientTreatment | `patient_treatments` | Treatment type catalog |
| Patient | PatientTreatmentRecord | `patient_treatment_records` | Treatment tracking |
| Patient | PatientPrescriptionItem | `patient_prescription_items` | Prescription medications |
| Product | Product | `products` | Products/inventory items |
| Product | ProductCategory | `product_categories` | Product categories (hierarchical) |
| Product | ProductStock | `product_stocks` | Stock lots with expiration |
| Product | ProductInventory | `product_inventories` | Inventory status view |
| Product | ProductAdjustment | `product_adjustments` | Stock adjustments |
| Service | Service | `services` | Laundry services (wash, dry, fold, iron) |
| Service | ServiceCategory | `service_categories` | Service categories |
| Service | CartServiceItem | `cart_service_items` | Service items in shopping cart |
| Service | SaleServiceItem | `sale_service_items` | Service items in completed sale |
| Sales | OrderStatusHistory | `orderStatusHistory` | Status change audit trail for sales |
| Machine | Machine | `machines` | Laundry machines (washer, dryer, etc.) |
| Storage | StorageLocation | `storages` | Storage locations for laundry items |
| Appointment | AppointmentSchedule | `appointment_schedules` | Appointment bookings |
| System | ChangeLog | `change_logs` | Audit trail |
| System | SystemVersion | `system_versions` | App version tracking |

---

## Entity Relationship Diagram

```
                          ┌────────────┐
                          │  UserRole  │
                          └─────┬──────┘
                                │
                                ▼
                          ┌────────────┐
                          │    User    │
                          └─────┬──────┘
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
        ┌───────────┐    ┌───────────┐    ┌───────────┐
        │  Branch   │    │ ChangeLog │    │  Patient  │
        └─────┬─────┘    └───────────┘    └─────┬─────┘
              │                                 │
              │         ┌───────────────────────┼───────────────────────┐
              │         │                       │                       │
              ▼         ▼                       ▼                       ▼
        ┌───────────────────┐           ┌─────────────┐         ┌───────────────────┐
        │ Patient, Product, │           │PatientRecord│         │ PatientTreatment  │
        │ AppointmentSchedule│          └──────┬──────┘         │     Record        │
        │ PatientRecord     │                  │                └─────────┬─────────┘
        └───────────────────┘                  │                          │
                                               ▼                          ▼
                                        ┌──────────────┐         ┌─────────────────┐
                                        │ Prescription │         │PatientTreatment │
                                        │    Item      │         │   (catalog)     │
                                        └──────────────┘         └─────────────────┘


        ┌──────────────────┐                  ┌─────────────────┐
        │ PatientSpecies   │◄─────────────────│  PatientBreed   │
        └────────┬─────────┘                  └─────────────────┘
                 │
                 ▼
           ┌─────────┐
           │ Patient │
           └─────────┘


        ┌─────────────────┐          ┌─────────────┐          ┌─────────────────┐
        │ ProductCategory │◄─────────│   Product   │─────────►│  ProductStock   │
        │   (hierarchy)   │          └──────┬──────┘          └────────┬────────┘
        └─────────────────┘                 │                          │
                                            │                          │
                                            ▼                          ▼
                                   ┌────────────────┐         ┌────────────────┐
                                   │ProductInventory│         │ ProductAdjust  │
                                   └────────────────┘         │    (stock)     │
                                                              └────────────────┘
```

---

## Organization Domain

### User

All system users with role-based access.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | User name |
| `username` | String | Yes | Username for authentication |
| `avatar` | String | No | Avatar filename |
| `verified` | bool | Yes | Email verification status |
| `role` | String (FK) | Yes | FK to UserRole |
| `branch` | String (FK) | No | FK to Branch |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `users`

**Relationships:**
- `role` -> UserRole
- `branch` -> Branch (optional)

**Computed Properties:**
- `hasAvatar` - Checks if avatar exists
- `avatarUri(domain)` - Builds full avatar URI

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

**Collection:** `user_roles`

**Referenced by:** User

**Default Roles:**
- `admin` - Full system access
- `manager` - Full operational access (no user/role/branch management)
- `cashier` - POS operations, customer management, view inventory
- `attendant` - Floor operations, order status updates, view-only access

**Permission Keys:**
```
customers.view, customers.create, customers.edit, customers.delete
products.view, products.create, products.edit, products.delete
services.view, services.create, services.edit, services.delete
inventory.view, inventory.adjust
sales.view, sales.create
machines.view, machines.create, machines.edit, machines.delete
storages.view, storages.create, storages.edit, storages.delete
reports.view
users.view, users.create, users.edit, users.delete
roles.view, roles.create, roles.edit, roles.delete
branches.view, branches.create, branches.edit, branches.delete
settings.view, settings.edit
system.admin
```

---

### Branch

Business branches or locations.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Branch name |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `branches`

**Referenced by:** User, Patient, Product, PatientRecord, AppointmentSchedule

---

## Patient Domain

### Patient

Animal patients/clients.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Patient name |
| `images` | List\<String> | Yes | List of image filenames |
| `avatar` | String | No | Main avatar filename |
| `species` | String (FK) | No | FK to PatientSpecies |
| `breed` | String (FK) | No | FK to PatientBreed |
| `owner` | String | No | Owner name |
| `contactNumber` | String | No | Contact phone number |
| `email` | String | No | Email address |
| `address` | String | No | Physical address |
| `color` | String | No | Animal color/markings |
| `sex` | PatientSex | No | Animal sex (male/female) |
| `branch` | String (FK) | No | FK to Branch |
| `dateOfBirth` | DateTime | No | Date of birth |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patients`

**Relationships:**
- `species` -> PatientSpecies (optional)
- `breed` -> PatientBreed (optional)
- `branch` -> Branch (optional)

**Enum:** `PatientSex { male, female }`

---

### PatientSpecies

Species catalog (Dog, Cat, Bird, etc.).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Species name |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_species`

**Referenced by:** Patient, PatientBreed

---

### PatientBreed

Breed catalog linked to species.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Breed name |
| `species` | String (FK) | Yes | FK to PatientSpecies |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_breeds`

**Relationships:**
- `species` -> PatientSpecies

---

### PatientRecord

Medical visit records for patients.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `patient` | String (FK) | Yes | FK to Patient |
| `visitDate` | DateTime | Yes | Date of visit |
| `diagnosis` | String | No | Diagnosis text |
| `treatment` | String | No | Treatment applied |
| `notes` | String | No | Additional notes |
| `branch` | String (FK) | No | FK to Branch |
| `weightInKg` | num | No | Animal weight in kg |
| `tests` | String | No | Tests performed |
| `temperature` | String | No | Temperature reading |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_records`

**Relationships:**
- `patient` -> Patient
- `branch` -> Branch (optional)

**Computed Properties:**
- `displayWeightInKg` - Formats weight with "kg" unit

---

### PatientFile

Patient documents and images.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `patient` | String (FK) | Yes | FK to Patient |
| `file` | String | Yes | Filename/path |
| `notes` | String | No | File description |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_files`

**Relationships:**
- `patient` -> Patient

**Computed Properties:**
- `isImage` - Checks if file is image format (.png, .jpg, .jpeg, .gif, .webp, .bmp, .ico, .tiff, .avif, .svg)

---

### PatientTreatment

Treatment type catalog.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Treatment name |
| `icon` | String | No | Icon filename/identifier |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_treatments`

**Referenced by:** PatientTreatmentRecord

---

### PatientTreatmentRecord

Treatment tracking for patients.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `treatment` | String (FK) | Yes | FK to PatientTreatment |
| `patient` | String (FK) | Yes | FK to Patient |
| `date` | DateTime | No | Treatment date |
| `notes` | String | No | Treatment notes |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_treatment_records`

**Relationships:**
- `treatment` -> PatientTreatment
- `patient` -> Patient

---

### PatientPrescriptionItem

Prescription medications for patient records.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | Record ID |
| `patientRecord` | String (FK) | Yes | FK to PatientRecord |
| `date` | DateTime | Yes | Prescription date |
| `medication` | String | Yes | Medication name |
| `instructions` | String | No | Usage instructions |
| `dosage` | String | No | Dosage information |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `patient_prescription_items`

**Relationships:**
- `patientRecord` -> PatientRecord

---

## Product Domain

### Product

Products and inventory items.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Product name |
| `description` | String | No | Product description |
| `category` | String (FK) | No | FK to ProductCategory |
| `image` | String | No | Product image filename |
| `branch` | String (FK) | No | FK to Branch |
| `stockThreshold` | num | No | Low stock warning threshold |
| `price` | num | Yes | Product price |
| `forSale` | bool | Yes | Whether product is for sale |
| `quantity` | num | No | Current quantity |
| `expiration` | DateTime | No | Expiration date |
| `trackByLot` | bool | Yes | Track inventory by lot numbers |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `products`

**Relationships:**
- `category` -> ProductCategory (optional)
- `branch` -> Branch (optional)

**Computed Properties:**
- `hasImage` - Checks if image exists

---

### ProductCategory

Product categories with hierarchy support.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `name` | String | Yes | Category name |
| `parent` | String (FK) | No | FK to ProductCategory (for hierarchy) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `product_categories`

**Relationships:**
- `parent` -> ProductCategory (self-referencing, optional)

---

### ProductStock

Stock lots with expiration tracking.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `product` | String (FK) | Yes | FK to Product |
| `lotNo` | String | No | Lot/batch number |
| `expiration` | DateTime | No | Expiration date |
| `notes` | String | No | Stock notes |
| `quantity` | int | No | Quantity in stock |
| `isDisposed` | bool | Yes | Whether stock has been disposed |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `product_stocks`

**Relationships:**
- `product` -> Product

---

### ProductInventory

Aggregated inventory status view.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `product` | String (FK) | Yes | FK to Product |
| `status` | ProductStatus | Yes | Inventory status |
| `totalQuantity` | num | Yes | Total quantity available |
| `totalExpired` | num | Yes | Total expired quantity |
| `forSale` | bool | Yes | Whether available for sale |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `product_inventories`

**Relationships:**
- `product` -> Product

**Enum:** `ProductStatus { inStock, outOfStock, lowStock, noThreshold }`

---

### ProductAdjustment

Stock adjustment records.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `reason` | String | No | Reason for adjustment |
| `type` | ProductAdjustmentType | Yes | Type of adjustment |
| `oldValue` | num | Yes | Previous value |
| `newValue` | num | Yes | New value |
| `product` | String (FK) | Conditional | FK to Product (if type=product) |
| `productStock` | String (FK) | Conditional | FK to ProductStock (if type=productStock) |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `product_adjustments`

**Enum:** `ProductAdjustmentType { product, productStock }`

**Subtypes:**
- `ProductAdjustmentSimple` - Adjusts Product quantity directly
- `ProductAdjustmentStock` - Adjusts ProductStock quantity

---

## Sales Domain

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

**Relationships:**
- `sale` -> Sale (cascade delete)

**Enum:** `StatusType { saleStatus, orderStatus }`

---

## Machine & Storage Domain

### Machine

Laundry machines (washers, dryers, etc.) assigned to branches.

**Collection:** `machines`
**File:** `lib/src/features/machines/domain/machine.dart`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | String | Yes | auto | PocketBase record ID |
| `name` | String | Yes | - | Machine name (e.g., "Washer #1") |
| `type` | MachineType | Yes | - | Machine type (washer, dryer, other) |
| `branchId` | String? | No | - | Relation to Branch |
| `isAvailable` | bool | No | true | Whether machine is currently available |
| `isDeleted` | bool | No | false | Soft delete flag |
| `created` | DateTime? | No | auto | Creation timestamp |
| `updated` | DateTime? | No | auto | Last update timestamp |

**Enum: MachineType** (`machine_type.dart`)
- `washer` - Washing machine
- `dryer` - Dryer machine
- `other` - Other machine type

### StorageLocation

Storage locations (shelves, racks) for laundry items.

**Collection:** `storages`
**File:** `lib/src/features/storages/domain/storage_location.dart`

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `id` | String | Yes | auto | PocketBase record ID |
| `name` | String | Yes | - | Location name (e.g., "Shelf A-1") |
| `branchId` | String? | No | - | Relation to Branch |
| `isAvailable` | bool | No | true | Whether location is available |
| `isDeleted` | bool | No | false | Soft delete flag |
| `created` | DateTime? | No | auto | Creation timestamp |
| `updated` | DateTime? | No | auto | Last update timestamp |

**SaleServiceItem Machine/Storage Fields:**
- `machineId` (String?) - Assigned machine relation
- `machineName` (String?) - Snapshot of machine name at assignment
- `storageId` (String?) - Assigned storage relation
- `storageName` (String?) - Snapshot of storage name at assignment

---

## Appointment Domain

### AppointmentSchedule

Appointment bookings.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `date` | DateTime | Yes | Appointment date/time |
| `hasTime` | bool | Yes | Whether time is included |
| `notes` | String | No | Appointment notes |
| `purpose` | String | No | Appointment purpose |
| `status` | AppointmentScheduleStatus | Yes | Appointment status |
| `patientRecord` | String (FK) | No | FK to PatientRecord |
| `patient` | String (FK) | No | FK to Patient |
| `patientName` | String | No | Cached patient name |
| `ownerName` | String | No | Cached owner name |
| `ownerContact` | String | No | Cached contact info |
| `branch` | String (FK) | No | FK to Branch |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `appointment_schedules`

**Relationships:**
- `patientRecord` -> PatientRecord (optional)
- `patient` -> Patient (optional)
- `branch` -> Branch (optional)

**Enum:** `AppointmentScheduleStatus { scheduled, completed, missed, cancelled }`

**Computed Properties:**
- `displayDate` - Formats date with/without time
- `patientDisplayName` - Returns expanded or cached patient name
- `ownerDisplayName` - Returns expanded or cached owner name

---

## System Domain

### ChangeLog

Audit trail for system changes.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `collection` | String | Yes | Name of changed collection |
| `reference` | String | Yes | ID of changed record |
| `message` | String | No | Change description |
| `user` | String (FK) | No | FK to User who made the change |
| `change` | dynamic | Yes | Actual change data/payload |
| `type` | ChangeLogType | Yes | Type of change |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `change_logs`

**Relationships:**
- `user` -> User (optional)

**Enum:** `ChangeLogType { create, update, delete }`

---

### SystemVersion

Application version tracking.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | String | Yes | PocketBase record ID |
| `buildNumber` | num | Yes | Build/version number |
| `artifacts` | List\<SystemArtifact> | Yes | List of system artifacts |
| `isDeleted` | bool | Yes | Soft delete flag |
| `created` | DateTime | No | Creation timestamp |
| `updated` | DateTime | No | Last update timestamp |

**Collection:** `system_versions`

---

### SystemArtifact

Embedded artifact information (not a separate collection).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | String | Yes | Artifact name |
| `url` | String | Yes | Download URL |
| `type` | String | Yes | Artifact type |
| `version` | String | No | Semantic version |
| `versionCode` | String | No | Build/version code |

**Computed Properties:**
- `display` - Formatted display string "name - version+versionCode"

---

## Summary

**Total Collections:** 19
**Total Enums:** 6

| Enum | Values |
|------|--------|
| PatientSex | male, female |
| ProductStatus | inStock, outOfStock, lowStock, noThreshold |
| ProductAdjustmentType | product, productStock |
| AppointmentScheduleStatus | scheduled, completed, missed, cancelled |
| ChangeLogType | create, update, delete |
| StatusType | saleStatus, orderStatus |
