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

## NEXT STEPS
- Verify Onboarding flow on a fresh install.
- Implement "My Halls" subscription logic.
- Add Error Handling for invalid QR codes.
