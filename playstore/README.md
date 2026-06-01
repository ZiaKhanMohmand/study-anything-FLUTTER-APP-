Play Store Upload Guide
----------------------

This folder contains metadata and instructions to publish the `study_anything` Android App Bundle to Google Play.

Quick checklist
- Ensure you have a Google Play Developer account.
- Confirm `build/app/outputs/bundle/release/app-release.aab` exists (already built).
- Host a privacy policy URL (required for many apps).

Upload steps (manual)
1. Sign in to Play Console and create a new app.
2. Select default language and app title (use metadata.md values).
3. In "Release" > "Production" (or Internal Test) create a new release.
4. Upload `app-release.aab` from `build/app/outputs/bundle/release/`.
5. Paste release notes from `release-notes_v1.0.0.txt`.
6. Fill store listing: short & full descriptions from `metadata.md`.
7. Upload required graphics and screenshots (see below for sizes).
8. Complete Content Rating, Target Countries, Pricing & Distribution.
9. Add Privacy Policy URL (see `privacy_policy_template.md` for text to host).
10. Review and roll out the release.

Required assets (recommended sizes)
- Phone screenshots: 1080 x 1920 (portrait) — provide 3-5 variants.
- 1024 x 500 feature graphic (optional but recommended).
- Hi-res app icon: 512 x 512 PNG (no alpha).
- Promo graphic & TV images only if applicable.

Notes about app signing
- Google Play will manage final signing (recommended). You upload an "upload key" signed AAB.
- You've configured an upload keystore in `android/key.properties` that points to a local JKS. Keep that secure.

Helpful commands (run locally)
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

If you want, I can:
- Prepare the Play Console store listing draft text and package it, or
- Walk through the Play Console upload interactively (I'll provide step steps), or
- Generate screenshots placeholders and a feature graphic template (requires assets).
