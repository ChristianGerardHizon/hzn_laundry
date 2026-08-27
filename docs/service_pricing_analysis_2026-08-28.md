# Service pricing analysis and backup (2026-08-28)

Prod sales through 2026-08-28. `pricePerUnit` on `servicePriceTiers` is the **flat line total**.

Rollback of the **original** Hi-Zone 8-bucket Full Service menu (1–6=150 … 19+=500) is in [price_tiers_backup_2026-08-28.md](price_tiers_backup_2026-08-28.md).

This file is the snapshot **after** Mag FULL SERVICE tiers and the first Hi-Zone Full Service apply, plus the all-service analysis.

---

## Analysis (prod `saleServiceItems`)

| Branch | Service | Lines | Finding | Action |
|--------|---------|------:|---------|--------|
| Hi-Zone | Full Service | 2937 | Mix of buckets + ~₱30/kg. 1–5=150, 6=180, 7–8=200, 9=250, 10=300 hold. 11–12 mode **300** (not 330/360). 13 mode **350**. 14–16=400. 17–18 mode **500**. 19+ no longer a ₱500 cap (~₱30/kg). | Apply (refine 11–13, 17–18) |
| Hi-Zone | Wash | 21 | **₱80** for 1–8 kg (11× at 8 kg). One 10 kg also ₱80. | Keep existing 1–8=80, 9–10=100, 11–12=120 (too few 9+ sales) |
| Hi-Zone | Spin, Dry & Fold | 38 | 1 kg and 4–6 kg = **₱120**. Four 2 kg lines at ₱30 look like odd qty, not a new rate. | Keep 1–6=120, 7–8=150, 9–12=180 |
| Hi-Zone | Drying | 4 | ₱80 or ₱100, not ₱20/kg. | No tiers (too few) |
| Magsaysay | FULL SERVICE | 107 | **₱20/kg, ₱120 min** (6 kg). 8 kg often +₱10 extra (manual). | Already applied; keep |
| Magsaysay | Wash | 0 | No sales. | Keep Hi-Zone-cloned Wash buckets |
| Magsaysay | Spin, Dry & Fold | 0 | No sales. | Keep Hi-Zone-cloned SDF buckets |
| Magsaysay | Drying | 0 | No sales. | No tiers |

### Hi-Zone Full Service — most common charge (n=2937)

| kg | Mode ₱ | n at mode | Applied target |
|----|--------|-----------|----------------|
| 1–5 | 150 | strong | 150 |
| 6 | 180 | 144 / 340 | 180 |
| 7–8 | 200 | 351 / 417 and 248 / 346 | 200 |
| 9 | 250 | 153 / 262 | 250 |
| 10 | 300 | 114 / 187 | 300 |
| 11–12 | 300 | 52 / 143 and 23 / 86 | **300** (was 330 / 360) |
| 13 | 350 | 10 / 45 | **350** (was 390) |
| 14 | 400 | 43 / 69 | 400 |
| 15–16 | 400 | 22 / 57 and 20 / 39 | 400 |
| 17–18 | 500 | 10 / 29 and 19 / 34 | **500** (17 was 450) |
| 19+ | ~30/kg (20 kg → 600) | | ₱30 × kg, 51+=1530 |

---

## Live snapshot before 11–13 / 17–18 refine

### Hi-Zone Full Service `cm4ekyfxeit6pw7`

Service: price 120, weightBased true, showPrompt false, maxQuantity 0, isDefault true.

| min | max | total | Prod ID |
|-----|-----|-------|---------|
| 1 | 5 | 150 | `jxf0cz4kalnjpvb` |
| 6 | 6 | 180 | `qe7710t69xxxkqy` |
| 7 | 8 | 200 | `sqfz6cngs6zy6b7` |
| 9 | 9 | 250 | `gpu1y8w980sdskf` |
| 10 | 10 | 300 | `584fdnanx3ltnov` |
| 11 | 11 | 330 | `7jnwdohzhkkxbse` |
| 12 | 12 | 360 | `lqf1yl17ca93ul4` |
| 13 | 13 | 390 | `3zwsnfiu958aj9v` |
| 14 | 14 | 400 | `gh6wif4yznrkijb` |
| 15 | 16 | 400 | `qfzd1lck6ir5j55` |
| 17 | 17 | 450 | `dhsr17l4f21yeyy` |
| 18 | 18 | 500 | `hinuoy6pykr5eri` |
| 19 | 19 | 570 | `lb03y1rjmigy5d7` |
| 20–50 | same kg | 30×kg | see prod list |
| 51 | open | 1530 | `gfjsky4jqm5vf2t` |

Staging 6 / 10 / 12 / 14 / 18 IDs differ: `uvismjlvg14hgvu`, `242579maz2kewpf`, `7m012zo786j5pxp`, `b0qt8ffjhjpl8ko`, `f1gbt8x4s4hlkwd`. Shared original IDs match prod.

### Hi-Zone Wash `2jyfsgdlg94u5ji` — do not change

1–8=80 `bcvhuxml661695r`, 9–10=100 `167ytkxdoqpqg1x`, 11–12=120 `ndzyubgoatvvrd1`.

### Hi-Zone Spin, Dry & Fold `oidnabdfmtpduie` — do not change

1–6=120 `0luxa3q2ajdctfg`, 7–8=150 `ayfqrks6ysq6l3d`, 9–12=180 `lqq7q6u0sbkum0m`.

### Hi-Zone Drying `zwoh6x89mbgfaft` — no tiers

### Mag FULL SERVICE `26c24jfsoppxeck` — keep ₱20/kg + ₱120 min

See [price_tiers_backup_2026-08-28.md](price_tiers_backup_2026-08-28.md) for full ID list and original (no-tier) restore.

### Mag Wash / SDF — same buckets as Hi-Zone (no Mag sales)

---

## Restore

- **Hi-Zone Full Service to pre-experiment 8 buckets:** follow [price_tiers_backup_2026-08-28.md](price_tiers_backup_2026-08-28.md).
- **This round only (11–12 / 13 / 17–18):** PATCH `7jnwdohzhkkxbse` back to 11–11=330, recreate 12=360, PATCH 13=390, 17=450, recreate 18=500 (IDs above).
