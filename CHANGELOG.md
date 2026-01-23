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

## NEXT STEPS
- Verify Onboarding flow on a fresh install.
- Implement "My Halls" subscription logic.
- Add Error Handling for invalid QR codes.
