import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, size: 80, color: Colors.blueGrey),
            const SizedBox(height: 24),
            const Text(
              'FreeSPC',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const ImageIcon(
                 NetworkImage("https://cdn-icons-png.flaticon.com/512/300/300221.png"), 
                 size: 24,
              ), // Using icon for now, usually local asset
              label: const Text('Sign in with Google'),
              onPressed: () {
                ref.read(authServiceProvider).signInWithGoogle();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
