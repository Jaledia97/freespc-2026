import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/glass_container.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  DateTime? _selectedBirthday;

  bool _isContributing = false;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (Consistent with Login)
          Image.network(
            "https://loremflickr.com/1080/1920/casino,night?lock=2",
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.black);
            },
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A1A1A)),
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.black.withOpacity(0.9)],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header / Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                          },
                        ),
                      const Spacer(),
                      Text("Step ${_currentStep + 1} of 3", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 8),
                      // Simple Progress Bar
                      SizedBox(
                        width: 40,
                        height: 4,
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / 3,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.amber),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    ],
                  ),
                ),
                
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe
                    onPageChanged: (idx) => setState(() => _currentStep = idx),
                    children: [
                      // Step 1: Identity
                      _buildStep(
                        title: "Who are you?",
                        subtitle: "Let's start with your real name for ID verification.",
                        content: Column(
                          children: [
                            _buildTextField(_firstNameController, "First Name"),
                            const SizedBox(height: 16),
                            _buildTextField(_lastNameController, "Last Name"),
                          ],
                        ),
                        onNext: () {
                          if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty) {
                            _nextPage();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your name")));
                          }
                        }
                      ),

                      // Step 2: Persona
                      _buildStep(
                        title: "Pick your Handle",
                        subtitle: "This is how you'll appear on leaderboards and to friends.",
                        content: _buildTextField(_usernameController, "Username / Handle", icon: Icons.alternate_email),
                        onNext: () {
                          if (_usernameController.text.isNotEmpty) {
                            _nextPage();
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a username")));
                          }
                        }
                      ),

                      // Step 3: Birthday
                      _buildStep(
                        title: "When's your birthday?",
                        subtitle: "You must be 18+ to play. We verify this at the hall.",
                        content: InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedBirthday == null 
                                    ? "Select Date" 
                                    : _selectedBirthday!.toLocal().toString().split(' ')[0],
                                  style: TextStyle(
                                    color: _selectedBirthday == null ? Colors.white54 : Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const Icon(Icons.calendar_today, color: Colors.amber),
                              ],
                            ),
                          ),
                        ),
                        onNext: _submit,
                        isFinal: true,
                        isLoading: _isContributing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String title, 
    required String subtitle, 
    required Widget content, 
    required VoidCallback onNext, 
    bool isFinal = false,
    bool isLoading = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 48),
          
          GlassContainer(
            child: content,
          ),
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: isLoading ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isFinal ? "Finish Setup" : "Continue", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon}) {
    return TextField(
      controller: controller, // Fixed: passing controller
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.amber, onPrimary: Colors.black, surface: Color(0xFF222222)),
            dialogBackgroundColor: const Color(0xFF222222),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedBirthday = picked);
    }
  }

  Future<void> _submit() async {
    if (_selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your birthday")));
      return;
    }

    setState(() => _isContributing = true);

    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          birthday: _selectedBirthday!,
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(newUser.toJson());
        // Navigation is handled by AuthWrapper
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isContributing = false);
    }
  }
}
