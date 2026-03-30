import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../manager/presentation/claim_venue_screen.dart';

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
  
  // Step 4: Avatar
  File? _selectedAvatar;
  
  // Step 6: Home Base
  String? _selectedHomeBaseId;

  bool _isContributing = false;
  int _currentStep = 0;
  final int _totalSteps = 6;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => _selectedAvatar = File(picked.path));
    }
  }

  Future<void> _requestLocation() async {
    await Permission.locationWhenInUse.request();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location preference saved.")));
  }

  Future<void> _requestNotifications() async {
    await Permission.notification.request();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification preference saved.")));
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
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              onPrimary: Colors.black,
              surface: Color(0xFF222222),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF222222)),
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

    final proposedUsername = _usernameController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final proposedSearchName = proposedUsername.toLowerCase();

    if (proposedUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid username")));
      return;
    }

    setState(() => _isContributing = true);

    try {
      final user = ref.read(authStateChangesProvider).value;
      if (user != null) {
        // Uniqueness Check
        final usernameCheck = await FirebaseFirestore.instance
            .collection('public_profiles')
            .where('searchName', isEqualTo: proposedSearchName)
            .get();

        bool isTaken = false;
        for (var doc in usernameCheck.docs) {
          if (doc.id != user.uid) {
            isTaken = true;
            break;
          }
        }

        if (isTaken) throw Exception("This username is already taken. Please choose another.");

        // Avatar Upload
        String? photoUrl;
        if (_selectedAvatar != null) {
          final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
          await ref.putFile(_selectedAvatar!);
          photoUrl = await ref.getDownloadURL();
        }

        // Home Base Default Follow
        List<String> followingArray = [];
        if (_selectedHomeBaseId != null) followingArray.add(_selectedHomeBaseId!);

        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: proposedUsername,
          birthday: _selectedBirthday!,
          photoUrl: photoUrl,
          following: followingArray,
        );

        final batch = FirebaseFirestore.instance.batch();
        batch.set(
          FirebaseFirestore.instance.collection('users').doc(user.uid),
          newUser.toJson(),
        );

        batch.set(
          FirebaseFirestore.instance.collection('public_profiles').doc(user.uid),
          {
            'uid': user.uid,
            'username': proposedUsername,
            'searchName': proposedSearchName,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'photoUrl': photoUrl,
            'points': 0,
            'realNameVisibility': 'Everyone',
            'onlineStatus': 'Online',
            'lastSeen': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await batch.commit();
        // AuthWrapper handles routing
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isContributing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            "https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?q=80&w=1080&auto=format&fit=crop",
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
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: _prevPage),
                      const Spacer(),
                      Text("Step ${_currentStep + 1} of $_totalSteps", style: const TextStyle(color: Colors.white70)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40, height: 4,
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / _totalSteps,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.amber),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentStep = idx),
                    children: [
                      // Step 1: Real Name
                      _buildStep(
                        title: "Welcome to FreeSpc! 🎉",
                        subtitle: "Let's get your profile started. What's your real name?",
                        content: Column(
                          children: [
                            _buildTextField(_firstNameController, "First Name", textCapitalization: TextCapitalization.words),
                            const SizedBox(height: 16),
                            _buildTextField(_lastNameController, "Last Name", textCapitalization: TextCapitalization.words),
                          ],
                        ),
                        onNext: () {
                          if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty) _nextPage();
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your name")));
                        },
                      ),

                      // Step 2: Handle
                      _buildStep(
                        title: "Pick your Handle",
                        subtitle: "This is how your friends will find you on the leaderboards.",
                        content: _buildTextField(
                          _usernameController, "Username / Handle", icon: Icons.alternate_email,
                          textCapitalization: TextCapitalization.none, maxLength: 20,
                        ),
                        onNext: () {
                          if (_usernameController.text.isNotEmpty) _nextPage();
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a username")));
                        },
                      ),

                      // Step 3: Birthday
                      _buildStep(
                        title: "When is your birthday? 🎂",
                        subtitle: "To keep things legal and fun, we just need to make sure you are 18+.",
                        content: InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_selectedBirthday == null ? "Select Date" : _selectedBirthday!.toLocal().toString().split(' ')[0],
                                  style: TextStyle(color: _selectedBirthday == null ? Colors.white54 : Colors.white, fontSize: 18),
                                ),
                                const Icon(Icons.calendar_today, color: Colors.amber),
                              ],
                            ),
                          ),
                        ),
                        onNext: () {
                          if (_selectedBirthday != null) _nextPage();
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your birthday")));
                        },
                      ),

                      // Step 4: Avatar Flex
                      _buildStep(
                        title: "Put a face to the name",
                        subtitle: "Add a photo so your squad knows it's you when you claim the bag.",
                        content: Center(
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white10,
                              backgroundImage: _selectedAvatar != null ? FileImage(_selectedAvatar!) : null,
                              child: _selectedAvatar == null ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white54) : null,
                            ),
                          ),
                        ),
                        onNext: _nextPage,
                        showSkipButton: true,
                        skipLabel: "Skip for now",
                      ),

                      // Step 5: Permission Priming
                      _buildStep(
                        title: "Unlock the full experience",
                        subtitle: "Enable Location to magically earn free loyalty points the second you walk into a hall. Enable Notifications so you never miss a massive jackpot.",
                        content: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.location_on, color: Colors.amber, size: 32),
                              title: const Text("Location Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: const Text("Passive Loyalty Check-ins", style: TextStyle(color: Colors.white70)),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white),
                                onPressed: _requestLocation,
                                child: const Text("Enable"),
                              ),
                            ),
                            const Divider(color: Colors.white10),
                            ListTile(
                              leading: const Icon(Icons.notifications_active, color: Colors.blueAccent, size: 32),
                              title: const Text("Push Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: const Text("Daily Specials & Jackpots", style: TextStyle(color: Colors.white70)),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white10, foregroundColor: Colors.white),
                                onPressed: _requestNotifications,
                                child: const Text("Enable"),
                              ),
                            ),
                          ],
                        ),
                        onNext: _nextPage,
                        showSkipButton: true,
                        skipLabel: "Continue",
                      ),

                      // Step 6: Local Discovery
                      _buildStep(
                        title: "Where do you play? 📍",
                        subtitle: "Pick your favorite spot so we can show you the best local action right away.",
                        content: _buildHallSelector(),
                        onNext: _submit,
                        isFinal: true,
                        isLoading: _isContributing,
                        bottomWidget: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClaimVenueScreen())),
                          child: const Text("Run a hall or venue? Tap here to claim your business.",
                            style: TextStyle(color: Colors.amber, decoration: TextDecoration.underline),
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  Widget _buildHallSelector() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('bingo_halls').limit(5).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var halls = snapshot.data!.docs;
        if (halls.isEmpty) return const Text("No nearby venues found.", style: TextStyle(color: Colors.white54));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: halls.length,
          itemBuilder: (context, index) {
            final doc = halls[index];
            final data = doc.data() as Map<String, dynamic>;
            final isSelected = _selectedHomeBaseId == doc.id;
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: isSelected ? Colors.amber.withOpacity(0.2) : Colors.transparent,
              title: Text(data['name'] ?? 'Unknown', style: TextStyle(color: isSelected ? Colors.amber : Colors.white)),
              subtitle: Text(data['city'] ?? '', style: const TextStyle(color: Colors.white54)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.amber) : null,
              onTap: () => setState(() => _selectedHomeBaseId = doc.id),
            );
          },
        );
      },
    );
  }

  Widget _buildStep({
    required String title, required String subtitle, required Widget content,
    required VoidCallback onNext, bool isFinal = false, bool isLoading = false,
    bool showSkipButton = false, String skipLabel = "Skip", Widget? bottomWidget,
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
          GlassContainer(child: content),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: isLoading ? null : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isFinal ? (showSkipButton ? skipLabel : "Finish Setup") : "Continue", 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (showSkipButton && !isFinal) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: isLoading ? null : onNext,
              child: Text(skipLabel, style: const TextStyle(color: Colors.white54, fontSize: 16)),
            ),
          ],
          if (bottomWidget != null) ...[
            const SizedBox(height: 32),
            bottomWidget,
          ]
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon, TextCapitalization textCapitalization = TextCapitalization.sentences, int? maxLength}) {
    return TextField(
      controller: controller, textCapitalization: textCapitalization, maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint, labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        counterStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
