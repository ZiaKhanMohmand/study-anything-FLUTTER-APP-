Play Console Release Draft
-------------------------

App details
- App name: Study Anything — AI Summaries & Quizzes
- Package name: com.zia.study_anything
- Version: 1.0.0+1

Listings (copy into Play Console)
- Short description (max 80 chars): AI-powered flashcards, summaries, and quizzes to study anything faster.
- Full description:
  Study Anything helps you learn faster with AI-generated summaries, customizable quizzes, and flashcards. Import notes, save offline content, and track your progress with smart insights. Ideal for students, professionals, and lifelong learners.

What's new (release notes):
Initial public release.

Contact & URLs
- Email: support@example.com (replace)
- Privacy Policy URL: https://yourdomain.com/privacy-policy (replace with hosted `playstore/privacy_policy_template.md`)

Release notes (copy into release):
See `playstore/release-notes_v1.0.0.txt`

Recommended assets to upload now
- Phone screenshots: 1080x1920 (3 recommended)
- High-res icon: 512x512 PNG (no alpha)
- Feature graphic: 1024x500 PNG
- Promo video (optional): YouTube link

Internal testing recommendation
- Create an Internal Test track and upload the AAB first to verify signing and installation on devices.

Notes
- Use the `app-release.aab` at `build/app/outputs/bundle/release/app-release.aab`.
- If Play Console requests an "upload key" rather than letting Google manage signing, use the keystore at the path in `android/key.properties` to export an upload key certificate (keystore password is required).
