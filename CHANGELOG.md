# Changelog

## [Unreleased] - 2026-01-23

### Infrastructure
- Fixed `google_sign_in` and `build_runner` dependency issues.

### Auth
- Implemented `AuthWrapper`, `LoginScreen`, and `OnboardingScreen` (User Profile creation).

### Database
- Added `UserModel` (with Freezed) and `TransactionService` (Transactional Point System).

### UI
- Created `MainLayout` (Docked FAB), `ScanActionDialog` (Animated Kiosk Flow), and `WalletScreen` (Real-time Point Display).

### Features
- Implemented the full "Scan-to-Earn" loop with optimistic UI updates.

### Security & Roles (Phase 7)
- **Roles**: Added `worker`, `owner`, and `admin` roles with `qrToken` support in `UserModel`.
- **Environment**: Added "Mary Esther" Seed Tool to `HallRepository` and `ProfileScreen` for role/env setup.
- **Scanning**: Enforced strict worker verification in `ScanActionDialog` (Fixed permissive scanner bug).
- **Audit**: Updated `TransactionService` to record `authorizedByWorkerId` for verified points.

### Geolocation (Phase 8)
- **Dependency**: Added `geolocator` for GPS tracking.
- **Service**: Implemented `LocationService` with permission handling.
- **UI**: Updated `HomeScreen` to display real-time distance to halls (in miles) and sort by proximity.

### System Audit & Refactor (Phase 8.5)
- **Security**: Split Worker Identity into `public_workers` collection. Scanner now verifies against safe, public data instead of private User Profiles.
- **Architecture**: Separated concern between Private User Data (Full PII) and Public Verification Profile (Safe PII).
- **Performance**: Optimized `AuthWrapper` to prevent whole-app rebuilds when user points change.
- **Performance**: Optimized `AuthWrapper` to prevent whole-app rebuilds when user points change.
- **Efficiency**: Downgraded GPS to `Balanced` mode (100m filter) to significantly improve battery life.

### Hall Profiles & Subscriptions (Phase 9)
- **UI**: Added `HallProfileScreen` with Follow and Home Base actions.
- **Backend**: Updated `UserModel` and `HallRepository` to track subscriptions.
- **Feature**: Implemented "My Halls" screen to filter subscribed locations.

### "Picklehead" Pivot (Phase 10)
- **Home Screen**: Completely redesigned as a Visual Specials Feed with Quick Actions.
- **My Halls**: Updated to show "Nearest to You" (GPS Top 5) alongside subscribed halls.
- **Search**: Added dedicated `HallSearchScreen` for manual discovery.
- **Data**: Implemented `SpecialModel` for the new feed.
- **UI Polish**: Refined "My Halls" with vertical lists and expandable detailed cards for followed halls.
- **Migration**: Moved "Specials" feed from client-side mock to real Firestore collection (`specials`).
- **Geo-Fencing**: Home Feed now limits "Specials" to a **75-mile radius** and sorts by "Happening Now".
- **New Feature**: Added "Upcoming Games" directory for browsing all scheduled events.
- **Android**: Fixed `SocketException` (Internet Permission) and `NetworkImage` crashes.
- **Category Browsing**: Implemented "Spotify-Style" directory with searchable category grid ("Session", "Pulltabs", etc.).
- **Smart Cards**: Created unified `SpecialCard` with expansion logic, tags, and action buttons (Call, Cal, Map).
- **Interactivity**: Added `url_launcher` and `add_2_calendar` for phone/map/calendar integration.
- **UI Standardization**: Home Feed (Featured) and Directory (Compact) now share the exact same logic.
- **Accessibility**: Improved contrast for category grid and action buttons.

## NEXT STEPS
- Verify Onboarding flow on a fresh install.
- Implement "My Halls" subscription logic.
- Add Error Handling for invalid QR codes.
