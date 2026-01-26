import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/glass_container.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Consistent with Login)
          Image.network(
            "https://loremflickr.com/1080/1920/casino,night?lock=1",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A1A1A)),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.8)],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassContainer(
                blur: 15,
                opacity: 0.1,
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Wrap content
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Join the community and start winning.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    
                    _buildTextField(_emailController, "Email", Icons.email),
                    const SizedBox(height: 16),
                    _buildTextField(_passwordController, "Password", Icons.lock, isPassword: true),
                    const SizedBox(height: 16),
                    _buildTextField(_confirmPasswordController, "Confirm Password", Icons.lock, isPassword: true),
                    
                    const SizedBox(height: 32),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.black) 
                          : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Row(children: [Expanded(child: Divider(color: Colors.white24)), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: Colors.white54))), Expanded(child: Divider(color: Colors.white24))]),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone_android, color: Colors.white),
                        label: const Text("Use Phone Number", style: TextStyle(color: Colors.white)),
                        onPressed: () => _showPhoneAuthDialog(context, ref),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhoneAuthDialog(BuildContext context, WidgetRef ref) {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Glass effect handled by container
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
           bool isCodeSent = false;
           bool isLoading = false;
           String? verificationId;

           return Padding(
             padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
             child: GlassContainer(
               blur: 20,
               opacity: 0.9,
               color: const Color(0xFF222222),
               borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
               child: Padding(
                 padding: const EdgeInsets.all(24),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Text(isCodeSent ? "Enter SMS Code" : "Enter Phone Number", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                     const SizedBox(height: 16),
                     
                     if (!isCodeSent)
                       TextField(
                         controller: phoneController,
                         keyboardType: TextInputType.phone,
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(
                           labelText: "Phone Number (e.g. +15550109999)",
                           labelStyle: TextStyle(color: Colors.white70),
                           prefixIcon: Icon(Icons.phone, color: Colors.white70),
                           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                         ),
                       )
                     else 
                       TextField(
                         controller: codeController,
                         keyboardType: TextInputType.number,
                         style: const TextStyle(color: Colors.white),
                         decoration: const InputDecoration(
                           labelText: "6-Digit Code",
                           labelStyle: TextStyle(color: Colors.white70),
                           prefixIcon: Icon(Icons.lock_clock, color: Colors.white70),
                           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                         ),
                       ),

                     const SizedBox(height: 24),
                     
                     SizedBox(
                       width: double.infinity,
                       height: 50,
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                         onPressed: isLoading ? null : () async {
                           setState(() => isLoading = true);
                           try {
                             if (!isCodeSent) {
                               await ref.read(authServiceProvider).verifyPhoneNumber(
                                 phoneController.text.trim(),
                                 (vid, token) {
                                   setState(() {
                                     verificationId = vid;
                                     isCodeSent = true;
                                     isLoading = false;
                                   });
                                 },
                                 (e) {
                                   setState(() => isLoading = false);
                                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
                                 }
                               );
                             } else {
                               // Verify Code
                               if (verificationId == null) return;
                               
                               await ref.read(authServiceProvider).verifySmsCode(verificationId!, codeController.text.trim());
                               
                               // If successful, auth state changes handle navigation
                               if (context.mounted) Navigator.pop(context);
                             }
                           } catch (e) {
                              if (context.mounted) {
                                setState(() => isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                              }
                           }
                         }, 
                         child: isLoading ? const CircularProgressIndicator() : Text(isCodeSent ? "Verify" : "Send Code"),
                       ),
                     )
                   ],
                 ),
               ),
             ),
           );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      ),
    );
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authServiceProvider).registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Auth wrapper handles navigation
       if (mounted) Navigator.pop(context); // Go back to wrapper
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
