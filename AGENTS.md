# AGENTS.md – Mobile (Flutter)

## Project Overview
This is the Flutter mobile app for "Saved Content Graveyard".

Core user flow:
1. User takes a screenshot or shares from Instagram / TikTok / Facebook
2. App sends the image to the backend
3. Shows a beautiful Result Card with:
   - Short description
   - Primary action buttons (Buy / Watch)
4. User can save the result to their personal library

## Tech Stack (Do not change without discussion)
- Flutter (latest stable)
- Riverpod (preferred state management)
- Dio for HTTP
- go_router or auto_route for navigation
- Clean architecture (features folder structure)

## Critical Rules
- The **Result Card** is the most important screen in the entire app. Make it delightful.
- Support iOS Share Sheet first (highest priority).
- Handle loading, error, and empty states gracefully.
- Never keep the original screenshot longer than needed.
- Design should feel modern, clean, and trustworthy (privacy-focused).
- Prefer composition over huge widgets.
- Keep business logic out of UI widgets.

## Preferred Folder Structure
lib/
├── core/
├── features/
│   ├── analyze/
│   ├── library/
│   ├── auth/
│   └── home/
├── services/
└── shared/

## UI Guidelines
- Clean typography
- Generous spacing
- Clear primary action buttons on the Result Card
- Subtle animations (but not excessive)
- Dark mode support from the beginning is preferred

## Current Priority Order
1. Project setup + clean architecture
2. Share sheet / image picker integration
3. API client that talks to the backend
4. Beautiful Result Card (even with mock data first)
5. Loading & error states
6. Personal library (save results)

## Coding Standards
- Use const constructors wherever possible
- Prefer Riverpod providers
- Keep widgets small and focused
- Write meaningful widget and unit tests for critical flows