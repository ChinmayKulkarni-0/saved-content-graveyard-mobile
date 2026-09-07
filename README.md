# Saved Content Graveyard - Mobile

Flutter app that receives screenshots via the iOS share sheet, identifies the content, and shows buy/stream links.

## Features

- iOS Share Sheet integration for receiving screenshots
- AI-powered content identification
- Result Card showing description, confidence, buy links, and watch links
- Library of saved content
- Clean, modern Material 3 UI with dark mode

## Setup

```bash
flutter pub get
flutter run
```

## Project Structure

- `lib/features/analyze/` - Screenshot analysis flow + Result Card
- `lib/features/home/` - Home screen with saved library
- `lib/features/library/` - Saved content viewer
- `lib/features/auth/` - User authentication
- `lib/services/` - API client and share handler
- `lib/core/` - Theme, constants, utilities

## Backend

The app expects a running backend at `http://localhost:8000` by default.
See the backend repo for API details.