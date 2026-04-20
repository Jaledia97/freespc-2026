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
  final Set<String> _selectedFavorites = {};
  Future<QuerySnapshot>? _hallsFuture;
  String _hallSearchQuery = "";

  bool _isContributing = false;
  int _currentStep = 0;
  final int _totalSteps = 5;
  
  // Real-time Username Checker
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  @override
  void initState() {
    super.initState();
    _hallsFuture = FirebaseFirestore.instance.collection('venues').get();
  }
  
  void _checkUsernameAvailability(String val) async {
    final proposed = val.trim();
    if (proposed.isEmpty) {
      setState(() { _isUsernameAvailable = null; });
      return;
    }
    setState(() => _isCheckingUsername = true);
    try {
      final user = ref.read(authStateChangesProvider).value;
      final proposedSearchName = proposed.toLowerCase();
      final usernameCheck = await FirebaseFirestore.instance
          .collection('public_profiles')
          .where('searchName', isEqualTo: proposedSearchName)
          .get();

      bool isTaken = false;
      for (var doc in usernameCheck.docs) {
        if (user != null && doc.id != user.uid) {
          isTaken = true;
          break;
        } else if (user == null) {
          isTaken = true;
          break;
        }
      }
      if (mounted) {
        setState(() {
          _isUsernameAvailable = !isTaken;
          _isCheckingUsername = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingUsername = false);
    }
  }

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

  Future<void> _requestBluetooth() async {
    await Permission.bluetooth.request();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bluetooth preference saved.")));
  }

  Future<void> _requestContacts() async {
    await Permission.contacts.request();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contacts preference saved.")));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'SELECT BIRTHDAY',
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
        // Uniqueness Check (redundant but safe)
        if (_isUsernameAvailable == false) {
           throw Exception("This username is already taken. Please choose another.");
        }

        // Avatar Upload
        String? photoUrl;
        if (_selectedAvatar != null) {
          final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
          await ref.putFile(_selectedAvatar!);
          photoUrl = await ref.getDownloadURL();
        }

        // Multi-Favorite Default Follow
        List<String> followingArray = List<String>.from(_selectedFavorites);

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
                        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: _prevPage)
                      else
                        IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () {
                           ref.read(authServiceProvider).signOut();
                        }),
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
                      // Step 1: Real Name & Birthday
                      _buildStep(
                        title: "Welcome to FreeSpc! 🎉",
                        subtitle: "Let's get your profile started. We need your real name and birthday to verify you are 18+.",
                        content: Column(
                          children: [
                            _buildTextField(_firstNameController, "First Name", textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next),
                            const SizedBox(height: 16),
                            _buildTextField(_lastNameController, "Last Name", textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.done, onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                              _pickDate();
                            }),
                            const SizedBox(height: 16),
                            InkWell(
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
                                    Text(_selectedBirthday == null ? "Select Birthday" : _selectedBirthday!.toLocal().toString().split(' ')[0],
                                      style: TextStyle(color: _selectedBirthday == null ? Colors.white54 : Colors.white, fontSize: 16),
                                    ),
                                    const Icon(Icons.calendar_today, color: Colors.amber),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        onNext: () {
                          if (_firstNameController.text.isNotEmpty && _lastNameController.text.isNotEmpty && _selectedBirthday != null) _nextPage();
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your name and verify your birthday")));
                        },
                      ),

                      // Step 2: Handle
                      _buildStep(
                        title: "Pick your Handle",
                        subtitle: "This is how your friends will find and tag you across the community. (Case Sensitive)",
                        content: Column(
                          children: [
                            TextField(
                              controller: _usernameController,
                              textCapitalization: TextCapitalization.none,
                              maxLength: 20,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (_usernameController.text.isNotEmpty && _isUsernameAvailable != false) _nextPage();
                                else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid, available username")));
                              },
                              onChanged: _checkUsernameAvailability,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Username / Handle",
                                labelStyle: const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.alternate_email, color: Colors.white70),
                                suffixIcon: _isCheckingUsername 
                                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                                  : (_isUsernameAvailable == null ? null : (_isUsernameAvailable! ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.cancel, color: Colors.red))),
                                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                              ),
                            ),
                            if (_isUsernameAvailable == false)
                              const Align(
                                alignment: Alignment.centerLeft, 
                                child: Text("Username taken", style: TextStyle(color: Colors.red, fontSize: 12))
                              ),
                          ],
                        ),
                        onNext: () {
                          if (_usernameController.text.isNotEmpty && _isUsernameAvailable != false) _nextPage();
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid, available username")));
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
                        subtitle: "Enable Location to magically earn free loyalty points the second you walk into a venue. Enable Notifications so you never miss massive events and prizes.",
                        content: Column(
                          children: [
                            const ListTile(
                              dense: true,
                              leading: Icon(Icons.location_on, color: Colors.amber, size: 28),
                              title: Text("Location Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text("Passive Loyalty Check-ins", style: TextStyle(color: Colors.white70)),
                            ),
                            const Divider(color: Colors.white10),
                            const ListTile(
                              dense: true,
                              leading: Icon(Icons.bluetooth, color: Colors.purpleAccent, size: 28),
                              title: Text("Bluetooth", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text("Local Beacon Discovery", style: TextStyle(color: Colors.white70)),
                            ),
                            const Divider(color: Colors.white10),
                            const ListTile(
                              dense: true,
                              leading: Icon(Icons.contacts, color: Colors.greenAccent, size: 28),
                              title: Text("Contacts Data", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text("Find Friends Faster", style: TextStyle(color: Colors.white70)),
                            ),
                            const Divider(color: Colors.white10),
                            const ListTile(
                              dense: true,
                              leading: Icon(Icons.notifications_active, color: Colors.blueAccent, size: 28),
                              title: Text("Push Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text("Local events and updates", style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                        onNext: () async {
                          await Permission.locationWhenInUse.request();
                          await Permission.bluetooth.request();
                          await Permission.contacts.request();
                          await Permission.notification.request();
                          _nextPage();
                        },
                        showSkipButton: true,
                        skipLabel: "Skip for now",
                      ),

                      // Step 6: Local Discovery
                      _buildStep(
                        title: "Pick your venues 📍",
                        subtitle: "Select your favorite spots so we can tailor the best local action directly to your feed.",
                        content: _buildHallSelector(),
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

  Widget _buildHallSelector() {
    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _hallSearchQuery = val.toLowerCase()),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Search for a venue",
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.search, color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<QuerySnapshot>(
          future: _hallsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            var allDocs = snapshot.data!.docs;
            
            var selectedDocs = allDocs.where((doc) => _selectedFavorites.contains(doc.id)).toList();
            var searchedDocs = allDocs.where((doc) {
               if (_selectedFavorites.contains(doc.id)) return false;
               final data = doc.data() as Map<String, dynamic>;
               final name = (data['name'] ?? '').toString().toLowerCase();
               return name.contains(_hallSearchQuery);
            }).take(10).toList();
            
            var rawHalls = [...selectedDocs, ...searchedDocs];
            
            // Deduplicate by name to prevent cloned test-venues from flooding the UI
            final uniqueNames = <String>{};
            var venues = <QueryDocumentSnapshot>[];
            for (var doc in rawHalls) {
              final data = doc.data() as Map<String, dynamic>;
              final name = (data['name'] ?? doc.id).toString().toLowerCase();
              if (uniqueNames.add(name)) {
                venues.add(doc);
              }
            }
            
            if (venues.isEmpty) return const Text("No nearby venues found.", style: TextStyle(color: Colors.white54));

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final doc = venues[index];
                final data = doc.data() as Map<String, dynamic>;
                final isSelected = _selectedFavorites.contains(doc.id);
                
                final name = data['name'] ?? 'Unknown';
                final city = data['city'] ?? '';
                final state = data['state'] ?? '';
                final location = city.isNotEmpty && state.isNotEmpty ? '$city, $state' : (city.isEmpty ? state : city);
                final type = (data['venueType'] ?? 'bingo').toString().toUpperCase();
                final logoUrl = data['logoUrl'] as String?;

                return GestureDetector(
                  onTap: () => setState(() {
                    if (isSelected) _selectedFavorites.remove(doc.id);
                    else _selectedFavorites.add(doc.id);
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.withOpacity(0.15) : Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? Colors.amber : Colors.transparent, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (logoUrl != null && logoUrl.isNotEmpty)
                                Image.network(logoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(color: Colors.white24, child: const Icon(Icons.storefront, size: 48, color: Colors.white54)))
                              else
                                Container(color: Colors.white24, child: const Icon(Icons.storefront, size: 48, color: Colors.white54)),
                              
                              if (isSelected)
                                Positioned(
                                  top: 8, right: 8,
                                  child: Container(
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.check, color: Colors.black, size: 16),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              if (location.isNotEmpty)
                                Text(location, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                                child: Text(type, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep({
    required String title, required String subtitle, required Widget content,
    required VoidCallback onNext, bool isFinal = false, bool isLoading = false,
    bool showSkipButton = false, String skipLabel = "Skip", Widget? bottomWidget,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 32),
          GlassContainer(child: content),
          const SizedBox(height: 32),
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

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon, TextCapitalization textCapitalization = TextCapitalization.sentences, int? maxLength, TextInputAction? textInputAction, void Function(String)? onSubmitted}) {
    return TextField(
      controller: controller, textCapitalization: textCapitalization, maxLength: maxLength,
      textInputAction: textInputAction, onSubmitted: onSubmitted,
      onTap: () {
        if (controller.selection.baseOffset != controller.selection.extentOffset) {
          controller.selection = TextSelection.collapsed(offset: controller.selection.extentOffset);
        }
      },
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
