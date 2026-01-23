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
- **Efficiency**: Downgraded GPS to `Balanced` mode (100m filter) to significantly improve battery life.

## NEXT STEPS
- Verify Onboarding flow on a fresh install.
- Implement "My Halls" subscription logic.
- Add Error Handling for invalid QR codes.
