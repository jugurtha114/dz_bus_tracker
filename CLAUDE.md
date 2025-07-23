# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DZ Bus Tracker is a Flutter app for real-time bus tracking in Algeria, serving passengers, drivers, and administrators. The app uses Provider for state management and follows clean architecture principles with feature-based organization.

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific device
flutter run -d chrome        # Web
flutter run -d linux         # Desktop Linux
flutter run -d android       # Android (if configured)

# Build for production
flutter build apk            # Android APK
flutter build web            # Web build
flutter build linux          # Linux desktop

# Code analysis and formatting
flutter analyze              # Static analysis using flutter_lints
dart format lib/             # Format all Dart files
dart format --set-exit-if-changed lib/  # Format with exit code

# Testing
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run specific test

# Clean build artifacts
flutter clean
flutter pub get              # Re-fetch dependencies after clean

# Generate app icons and splash screens
flutter pub run flutter_launcher_icons:main
flutter pub run flutter_native_splash:create
```

### Asset Management
```bash
# After adding new assets to pubspec.yaml
flutter pub get
flutter clean && flutter pub get  # If assets not loading
```

## Architecture Overview

### State Management Pattern
The app uses **Provider pattern** with hierarchical dependency injection:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LocalizationProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
    // Feature-specific providers depend on core providers
  ],
)
```

### Key Architectural Layers

1. **Providers** (`lib/providers/`): State management with ChangeNotifier
   - `AuthProvider`: Authentication and user session (core dependency)
   - `LocationProvider`: GPS tracking and location services
   - Feature providers: `PassengerProvider`, `DriverProvider`, `BusProvider`, etc.

2. **Services** (`lib/services/`): Business logic and API communication
   - Each service is injected into its corresponding provider
   - Services use `ApiClient` for HTTP operations with interceptors

3. **Network Layer** (`lib/core/network/`):
   - `ApiClient`: HTTP client with interceptors (auth, logging)
   - `ApiResponse`: Standardized response wrapper
   - `Interceptors`: Auth token management and request/response logging

4. **Configuration** (`lib/config/`):
   - `ApiConfig`: Environment-specific endpoints and API settings
   - `ThemeConfig`: Design system with glass morphism utilities
   - `RouteConfig`: Centralized navigation with named routes

### Screen Organization
```
screens/
├── auth/           # Login, registration (including driver registration)
├── admin/          # Admin dashboard and approval screens
├── driver/         # Driver-specific functionality
├── passenger/      # Passenger-specific functionality  
└── common/         # Shared screens (profile, settings, etc.)
```

### Widget Architecture
- **Common widgets** (`widgets/common/`): Reusable UI components
- **Feature widgets**: Role-specific components organized by user type
- **Design system**: `CustomButton`, `CustomTextField`, `GlassyContainer` with consistent theming

## User Types and Flows

### Three User Roles:
1. **Passengers**: Search buses, track routes, rate drivers
2. **Drivers**: Manage buses, track routes, count passengers
3. **Admins**: Approve drivers/buses, manage system

### Authentication Flow:
- Standard login/registration for passengers
- Enhanced driver registration with document uploads
- Role-based navigation and feature access

## Localization

The app supports **French (default)**, **Arabic (RTL)**, and **English**:
- Translation files: `assets/translations/[lang].json`
- Access via: `context.translate('key')` extension method
- Language switching handled by `LocalizationProvider`

## Real-time Features

### Location Services:
- **Background GPS tracking** for drivers
- **Battery optimization** with distance filtering
- **Permission handling** with user-friendly prompts

### WebSocket Integration:
- **Real-time bus positions** for passenger tracking
- **Live notifications** for status updates
- **Connection management** with auto-reconnection

## Data Storage

### Storage Strategy:
- **SharedPreferences** wrapped in `StorageUtils` for type safety
- **Secure storage** for authentication tokens
- **Image caching** via `cached_network_image`
- **Offline support** with local data persistence

## Error Handling

### Exception Hierarchy:
```dart
AppException (abstract)
├── ApiException (HTTP errors)
├── AuthException (authentication)
├── NetworkException (connectivity)
├── ValidationException (form validation)
├── LocationException (GPS/location)
└── CacheException (storage)
```

### Error Management:
- **Centralized error handling** via `ErrorHandler`
- **User-friendly messages** with localization
- **Retry mechanisms** with exponential backoff
- **Offline state management** with graceful degradation

## Key Development Guidelines

### Provider Pattern:
- Each provider follows consistent structure with `_isLoading`, `_error` state
- Services injected via constructor for testability
- Always call `notifyListeners()` after state changes

### API Integration:
- All HTTP calls go through `ApiClient` with proper error transformation
- Use environment-specific endpoints from `ApiConfig`
- Handle authentication tokens automatically via interceptors

### Navigation:
- Use named routes defined in `RouteConfig`
- Implement proper parameter validation with error screens
- Support role-based navigation guards

### Code Organization:
- Feature-based organization for scalability
- Consistent naming conventions across layers  
- Proper null safety throughout codebase
- Memory leak prevention with disposal patterns

## Configuration Files

### Environment Setup:
The app supports multiple environments configured in `ApiConfig`:
- Local development servers
- Staging environment
- Production endpoints

### Theme System:
- Material Design 3 with custom color palette
- Glass morphism effects for modern UI
- Consistent typography scale with Roboto font family
- Component themes for unified styling

## Common Development Tasks

### Adding New Features:
1. Create service class in `lib/services/`
2. Create provider in `lib/providers/` with service injection
3. Add provider to `MultiProvider` in `main.dart`
4. Create screens in appropriate feature folder
5. Add routes to `RouteConfig`
6. Create reusable widgets if needed

### API Integration:
1. Add endpoints to `ApiConfig`
2. Implement methods in appropriate service
3. Handle responses in provider with proper error handling
4. Update UI to reflect loading/error states

### Adding Translations:
1. Add keys to all language files in `assets/translations/`
2. Use `context.translate('key')` in widgets
3. Test with different languages and RTL support

### Performance Optimization:
- Use `const` constructors where possible
- Implement proper `dispose()` methods
- Optimize images and use caching
- Use lazy loading for screens and data