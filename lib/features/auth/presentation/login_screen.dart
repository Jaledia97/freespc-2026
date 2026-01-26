import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/glass_container.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            "https://loremflickr.com/1080/1920/casino,night?lock=1",
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.black);
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1A1A1A),
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Branding
                  const Icon(Icons.stars, size: 100, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text(
                    'FreeSPC',
                    style: TextStyle(
                      fontSize: 48, 
                      fontWeight: FontWeight.bold, // Reduced precision
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const Text(
                    'DAUB. WIN. REDEEM.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Login Card
                  GlassContainer(
                    blur: 15,
                    opacity: 0.1,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Sign in to access your wallet and track your wins.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 32),
                        
                        // Social Login Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Apple
                            _SocialButton(
                              imageUrl: "https://upload.wikimedia.org/wikipedia/commons/3/31/Apple_logo_white.svg", 
                              onTap: () async {
                                await ref.read(authServiceProvider).signInWithApple();
                              },
                              isDark: true,
                            ),
                            
                            // Google
                            _SocialButton(
                              imageUrl: "https://cdn-icons-png.flaticon.com/512/300/300221.png",
                              onTap: () {
                                ref.read(authServiceProvider).signInWithGoogle();
                              },
                            ),

                            // Facebook
                            _SocialButton(
                              imageUrl: "https://cdn-icons-png.flaticon.com/512/5968/5968764.png",
                              onTap: () async {
                                await ref.read(authServiceProvider).signInWithFacebook();
                              },
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Create Account Button
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 16, 
                              decoration: TextDecoration.underline,
                               decorationColor: Colors.white54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final bool isDark;

  const _SocialButton({required this.imageUrl, required this.onTap, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: isDark 
          ? const Icon(Icons.apple, size: 36, color: Colors.black) // Use Icon for Apple if SVG is tricky or just standard icon
          : Image.network(imageUrl, fit: BoxFit.contain), 
      ),
    );
  }
}
