import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/utils/role_utils.dart';
// import 'package:image_picker/image_picker.dart'; // Add if full manual upload is configured

class ClaimVenueScreen extends ConsumerStatefulWidget {
  const ClaimVenueScreen({super.key});

  @override
  ConsumerState<ClaimVenueScreen> createState() => _ClaimVenueScreenState();
}

class _ClaimVenueScreenState extends ConsumerState<ClaimVenueScreen> {
  final PageController _pageController = PageController();
  int _currentPhase = 0;

  // State
  String? _selectedVenueId;
  String? _selectedVenueName;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _nextPhase() {
    FocusScope.of(context).unfocus();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPhase() {
    FocusScope.of(context).unfocus();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitVerification(UserModel user) async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a business email or provide proof.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Elevate User Role to Pending
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'role': RoleUtils.pendingOwner,
        'pendingVenueClaimId': _selectedVenueId ?? 'NEW_VENUE',
      });

      // Submit Document to Venue Verifications Pool
      await FirebaseFirestore.instance.collection('venue_verifications').add({
        'uid': user.uid,
        'emailProvided': _emailController.text.trim(),
        'venueId': _selectedVenueId ?? 'NEW_VENUE',
        'venueName': _selectedVenueName ?? 'Unknown / New',
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Advance to Success Phase
      _nextPhase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting claim: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Hall Portal"),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (idx) => setState(() => _currentPhase = idx),
        children: [
          _buildPhase1Search(),
          _buildPhase2Verification(user),
          _buildPhase3Success(),
        ],
      ),
    );
  }

  Widget _buildPhase1Search() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Find your venue 📍",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            "Search for your bingo hall below. If it's not listed, you can request to add it.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search by name...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (val) => setState(() {}),
          ),
          const SizedBox(height: 24),
          _buildVenueList(),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              onPressed: () {
                _selectedVenueId = 'NEW_VENUE';
                _selectedVenueName = _searchController.text.isNotEmpty 
                    ? _searchController.text 
                    : 'New Unlisted Venue';
                _nextPhase();
              },
              icon: const Icon(Icons.add_business, color: Colors.amber),
              label: const Text(
                "Can't find your hall? Create it now.",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
    final query = _searchController.text.trim().toLowerCase();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bingo_halls').limit(20).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        var halls = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          return name.contains(query);
        }).toList();

        if (halls.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                "No venues found matching your search.",
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: halls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = halls[index];
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] ?? 'Unknown Hall';
            final address = data['address'] ?? 'No Address Provided';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              tileColor: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const CircleAvatar(
                backgroundColor: Colors.white10,
                child: Icon(Icons.storefront, color: Colors.white),
              ),
              title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(address, style: const TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.chevron_right, color: Colors.amber),
              onTap: () {
                _selectedVenueId = doc.id;
                _selectedVenueName = name;
                _nextPhase();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPhase2Verification(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white54),
                onPressed: _prevPhase,
              ),
              const Expanded(
                child: Text(
                  "Proof of Ownership",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "To unlock full Manager access for $_selectedVenueName, we need to quickly verify your identity.",
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.mark_email_read, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      "Fast Path: Domain Email",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enter an official business email associated with the hall (e.g. manager@myhall.com).",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: "Business Email",
                    hintStyle: TextStyle(color: Colors.white38),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Center(child: Text("— OR —", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),

          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.upload_file, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text(
                      "Upload Documents",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  "Upload a business license, utility bill, or letterhead verifying your association with the hall.",
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Document manual upload is being expanded. Please enter an email or wait for an update.")),
                      );
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text("Select Document"),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : () => _submitVerification(user),
              child: _isSubmitting 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text("Submit Verification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhase3Success() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, size: 80, color: Colors.greenAccent),
          ),
          const SizedBox(height: 32),
          const Text(
            "You're all set!",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "Our team will quickly verify your venue.\nYour Dashboard is now in a pending state. You will be fully upgraded to an Owner once approved.",
            style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Return to Profile", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
