# Play Console listing pack

Graphics for **HZN Laundry** Internal testing. Paste these into Play Console → Store listing. Do not commit keystores or service-account JSON here.

## App identity

| Field | Value |
|-------|--------|
| App name | HZN Laundry |
| Package name | `com.hznsystems.hznlaundry` |
| Default language | English (United States) |
| App or game | App |
| Free or paid | Free |
| Privacy policy | https://hznlaundry.hznsystems.com/privacy-policy.html (no `#`; keep `.html`) |
| Staging privacy policy | https://staging.hznlaundry.hznsystems.com/privacy-policy.html |

## Graphics

| File | Spec |
|------|------|
| [`../assets/icons/play_store_icon_512.png`](../assets/icons/play_store_icon_512.png) | High-res icon, 512×512 PNG |
| [`feature-graphic.png`](feature-graphic.png) | Feature graphic |
| [`phone/`](phone/) | Phone screenshots (`phone-01-dashboard.png` through `phone-06-checkout.png`) |

Upload at least two phone screenshots in Store listing.

## Console notes

- **Internal testing** only (not the public Production track). Testers install via the Internal testing opt-in URL.
- Grant `google-playstore-upload@hznsystems.iam.gserviceaccount.com` **Release apps to testing tracks** on this app.
- First AAB is still a one-time manual Console upload; later production deploys use the `upload-play-internal` job. See [docs/deployment.md](../docs/deployment.md#google-play-store).
