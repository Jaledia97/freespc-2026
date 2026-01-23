import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../main_layout.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    
    // PERFORMANCE OPTIMIZATION: 
    // We only care if the profile *exists* to decide routing.
    // We do NOT want to rebuild the entire AuthWrapper (and thus the App)
    // every time the user gets 10 points. 
    // So we select only the 'hasValue' state essentially.
    final hasProfileAsync = ref.watch(userProfileProvider.select((value) => value.whenData((profile) => profile != null)));

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        // Authenticated, check profile existence
        return hasProfileAsync.when(
          data: (hasProfile) {
            if (!hasProfile) {
              return const OnboardingScreen();
            }
            // Once we have a profile, we mount the MainLayout.
            // MainLayout can then listen to the specific user streams it needs deeper down.
            return const MainLayout();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            body: Center(child: Text('Error: $err')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
    );
  }
}

