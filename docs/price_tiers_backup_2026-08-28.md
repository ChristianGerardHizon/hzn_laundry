# Price tiers backup (2026-08-28)

Snapshot of PocketBase `services` + `servicePriceTiers` **before** Hi-Zone Full Service bucket changes. Use this to restore staging/prod if cashiers dislike the new prices.

**Applied 2026-08-28 (staging + prod)** on Hi-Zone Full Service `cm4ekyfxeit6pw7`: 1–5=150, 6=180, 7–8=200, 9=250, 10=300, 11=330, 12=360, 13=390, 14=400, 15–16=400, 17=450, 18=500, then ₱30/kg from 19–50, 51+=1530. Wash / Spin Dry Fold unchanged. Restore the eight original Full Service rows in the table below if this should be rolled back.

`pricePerUnit` is the **flat line total** for the quantity range (not ₱/kg), unless noted.

- Prod: `https://hznlaundry.hznsystems.com`
- Staging: `https://staging.hznlaundry.hznsystems.com`
- Collection: `servicePriceTiers`
- `maxQuantity` `0` means no upper bound (open-ended tier)

## Branches

| ID | Prod name | Staging name |
|----|-----------|----------------|
| `v270cjs7zpjqiou` | Hi-Zone Laundry | Hi-Zone Laundry |
| `e04dythmgwr0r4c` | Magsaysay Branch | Branch No.2 |

Quantity unit (kg): `ulr7qlh8r4qej8u`

---

## Hi-Zone — restore this if Full Service changes are rejected

### Full Service `cm4ekyfxeit6pw7`

Service fields:

| Field | Value |
|-------|--------|
| price | 120 |
| minimumCharge | 0 |
| weightBased | true |
| showPrompt | false |
| maxQuantity | 0 |
| isVariablePrice | false |
| isDefault | true |
| isDeleted | false |

Tiers (keep these record IDs on restore when possible):

| ID | min | max | total (₱) |
|----|-----|-----|-----------|
| `jxf0cz4kalnjpvb` | 1 | 6 | 150 |
| `sqfz6cngs6zy6b7` | 7 | 8 | 200 |
| `gpu1y8w980sdskf` | 9 | 10 | 250 |
| `7jnwdohzhkkxbse` | 11 | 12 | 300 |
| `3zwsnfiu958aj9v` | 13 | 14 | 350 |
| `qfzd1lck6ir5j55` | 15 | 16 | 400 |
| `dhsr17l4f21yeyy` | 17 | 18 | 450 |
| `lb03y1rjmigy5d7` | 19 | 0 (open) | 500 |

Same IDs exist on **staging** and **prod**.

### Wash `2jyfsgdlg94u5ji` (unchanged)

price 80, weightBased true, maxQuantity 0.

| ID | min | max | total (₱) |
|----|-----|-----|-----------|
| `bcvhuxml661695r` | 1 | 8 | 80 |
| `167ytkxdoqpqg1x` | 9 | 10 | 100 |
| `ndzyubgoatvvrd1` | 11 | 12 | 120 |

### Spin, Dry & Fold `oidnabdfmtpduie` (unchanged)

price 100, weightBased true, maxQuantity 1.

| ID | min | max | total (₱) |
|----|-----|-----|-----------|
| `0luxa3q2ajdctfg` | 1 | 6 | 120 |
| `ayfqrks6ysq6l3d` | 7 | 8 | 150 |
| `lqq7q6u0sbkum0m` | 9 | 12 | 180 |

### Drying `zwoh6x89mbgfaft`

price 20, no tiers.

### Soft-deleted Hi-Zone services (do not revive unless asked)

| ID | Name | price |
|----|------|-------|
| `fbr2cwsl3q378r2` | Wash and Dry | 20 |
| `htro013hshqa356` | Spin & Dry (Full Service) | 120 |
| `ayhl5od8rio0i6z` | Minimum Load (1-3 KG) | 125 |
| `yjhin952xbay7c1` | Regular Load (4-6 KG) | 150 |
| `8sv1dnm3bz4vpxz` | Maximum Load (7-8 KG) | 180 |
| `iilothcvm8dp6oa` | Comforter | 150 |

---

## Magsaysay (prod only — not on staging)

Staging has **no** Mag services. Restore Mag on **prod** only.

### FULL SERVICE `26c24jfsoppxeck` — **original** (before 2026-08-28)

Use this if Mag cashiers want the old Create Order / typed-total workflow back.

| Field | Original |
|-------|----------|
| price | 120 |
| minimumCharge | 0 |
| weightBased | false |
| showPrompt | false |
| maxQuantity | 1 |
| isVariablePrice | false |
| Tiers | **none** (delete all `service = 26c24jfsoppxeck`) |

### FULL SERVICE — **current live** (after 2026-08-28 API)

| Field | Value |
|-------|--------|
| price | 20 |
| minimumCharge | 0 |
| weightBased | true |
| showPrompt | true |
| maxQuantity | 0 |

Tiers encode ₱20/kg with ₱120 min (`pricePerUnit` = line total):

| min | max | total (₱) | ID |
|-----|-----|-----------|-----|
| 1 | 6 | 120 | `cltd2yx6v2gx7o1` |
| 7 | 7 | 140 | `cg34xuepr0bnct5` |
| 8 | 8 | 160 | `8wrko4dywhotrvi` |
| 9 | 9 | 180 | `5vcse7b5pa1i2s2` |
| 10 | 10 | 200 | `459brcs2mxsvuuv` |
| 11 | 11 | 220 | `tiwqbch34oe5wqc` |
| 12 | 12 | 240 | `soqmusm5ex1dbvr` |
| 13 | 13 | 260 | `wrv7rtdz0kfgoai` |
| 14 | 14 | 280 | `3g7lyo8rwa3oemf` |
| 15 | 15 | 300 | `wt9f4d1iodhaka9` |
| 16 | 16 | 320 | `x8ecf09xygfexvu` |
| 17 | 17 | 340 | `i2e4r036tc12r4g` |
| 18 | 18 | 360 | `e8fyy4ofzd095i1` |
| 19 | 19 | 380 | `h2od7k127nipp6q` |
| 20 | 20 | 400 | `mopr2gabh2anmjn` |
| 21 | 21 | 420 | `gg7rqruu3nimf0n` |
| 22 | 22 | 440 | `ro5eh9y5gpg1teq` |
| 23 | 23 | 460 | `y5smcdtsejwivf2` |
| 24 | 24 | 480 | `iksmp4u0u9g2yr2` |
| 25 | 25 | 500 | `jgf557fc0c088bt` |
| 26 | 26 | 520 | `rkrshcnq106vl59` |
| 27 | 27 | 540 | `g1hc45if4g906vf` |
| 28 | 28 | 560 | `367olf1gruq9asg` |
| 29 | 29 | 580 | `onmpd8hm0worpx2` |
| 30 | 30 | 600 | `py4tutslr3983pa` |
| 31 | 31 | 620 | `192vptrkplysedq` |
| 32 | 32 | 640 | `6a1kwfnadvk67a5` |
| 33 | 33 | 660 | `2pdykeqz1chmwhc` |
| 34 | 34 | 680 | `6g7w25rsv71cqsl` |
| 35 | 35 | 700 | `q3z3u7cd451rtzp` |
| 36 | 36 | 720 | `ddvdmjeo2jrd6cj` |
| 37 | 37 | 740 | `drwpbzcckbtxu2r` |
| 38 | 38 | 760 | `5axx6bdo5wzi3u6` |
| 39 | 39 | 780 | `a0v25i8sxy79wqw` |
| 40 | 40 | 800 | `n0womev66xhphmu` |
| 41 | 41 | 820 | `8s0h8vbo9ytct2l` |
| 42 | 42 | 840 | `ap9nqlm0pidnerw` |
| 43 | 43 | 860 | `3koc4z8b2j18j2s` |
| 44 | 44 | 880 | `4k5rrzzhq4mj2ol` |
| 45 | 45 | 900 | `o5b2h7df6bsw6iv` |
| 46 | 46 | 920 | `v6l2l2r0omal2a4` |
| 47 | 47 | 940 | `19qwvuvyqwkzx3t` |
| 48 | 48 | 960 | `vmekmu2cqrblrsp` |
| 49 | 49 | 980 | `dy8gyveair26nsf` |
| 50 | 50 | 1000 | `hkgdz1dm8zp8qbs` |
| 51 | 0 (open) | 1020 | `9c9spqcen1aipgs` |

### Mag Wash `7e4r2n8ac9mic6z`

Same buckets as Hi-Zone Wash: 1–8=80 (`o9g0aox2tt9x4a5`), 9–10=100 (`owa02hlvrpqwliz`), 11–12=120 (`b3z377bti883dby`).

### Mag Spin, Dry & Fold `oui6f5cxozydjwj`

Same as Hi-Zone SDF: 1–6=120 (`sgao1702u8fk1xu`), 7–8=150 (`3x7fyqknygl2b73`), 9–12=180 (`xyeu17ea167haig`).

### Mag Drying `adj8b4wrbyzazd9`

price 20, no tiers.

---

## Restore Hi-Zone Full Service (staging or prod)

After a failed pricing experiment, put the **eight original buckets** back.

1. List current tiers:  
   `GET /api/collections/servicePriceTiers/records?filter=service="cm4ekyfxeit6pw7"`
2. Delete any extra tiers that are not in the eight IDs above.
3. PATCH each of the eight records to the min/max/total in the Full Service table (or recreate them if they were deleted).
4. PATCH service `cm4ekyfxeit6pw7`:  
   `{ "price": 120, "minimumCharge": 0, "weightBased": true, "showPrompt": false, "maxQuantity": 0, "isVariablePrice": false, "isDefault": true }`

Example PATCH body for the 19+ cap:

```json
{
  "minQuantity": 19,
  "maxQuantity": 0,
  "pricePerUnit": 500
}
```

## Restore Mag FULL SERVICE to original (prod only)

1. Delete all `servicePriceTiers` where `service = "26c24jfsoppxeck"`.
2. PATCH `26c24jfsoppxeck`:

```json
{
  "price": 120,
  "minimumCharge": 0,
  "weightBased": false,
  "showPrompt": false,
  "maxQuantity": 1,
  "isVariablePrice": false
}
```
