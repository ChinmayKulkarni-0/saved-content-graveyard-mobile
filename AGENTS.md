# Mobile Rules

- Framework: Flutter (latest stable)
- State management: Riverpod (preferred)
- Core flow: Share screenshot → show loading → show Result Card
- Result Card is the most important screen
- Clean, modern, delightful UI
- Support iOS Share Sheet first
- Offline handling + good error states

# Code Standards

- Material 3 with a cohesive color scheme
- Feature-first folder structure
- Keep models in `data/`, UI in `presentation/`
- All API calls through `ApiClient`
- All share handling through `ShareHandler`
- Include loading, empty, and error states for every screen

# UI Guidelines

- Result Card must show: description, confidence, buy links, watch links
- Categories have distinct visual identities
- Support dark mode
- Consistent spacing (16 base unit)
- Rounded corners (16px on cards, 8px on small elements)