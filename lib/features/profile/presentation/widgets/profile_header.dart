import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import 'edit_profile_dialog.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool _isLoading = false;

  void _handleImageUpload(BuildContext context, bool isBanner) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () => _pickAndUpload(isBanner, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () => _pickAndUpload(isBanner, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(bool isBanner, ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    
    final storage = ref.read(storageServiceProvider);
    
    try {
      final xFile = await storage.pickImage(source: source);
      if (xFile == null) return;

      setState(() => _isLoading = true);

      final file = File(xFile.path);
      final uid = widget.user.uid;

      String downloadUrl;
      if (isBanner) {
        downloadUrl = await storage.uploadBannerImage(file, uid);
      } else {
        downloadUrl = await storage.uploadProfileImage(file, uid);
      }

      // Update User Profile
      await ref.read(authServiceProvider).updateUserFields(
        uid, 
        isBanner ? {'bannerUrl': downloadUrl} : {'photoUrl': downloadUrl}
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image updated successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload Error: $e"), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Retry', onPressed: () => _pickAndUpload(isBanner, source)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    
    return Column(
      children: [
        // Container wrapping Banner + Avatar to ensure size includes both
        SizedBox(
          height: 210, // 160 Banner + 50 Avatar Overflow
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 1. Banner
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  image: user.bannerUrl != null
                      ? DecorationImage(image: NetworkImage(user.bannerUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: Stack(
                  children: [
                    if (user.bannerUrl == null)
                      Center(child: Icon(Icons.image, size: 48, color: Colors.white.withOpacity(0.1))),
                    
                    // Loading Indicator Overlay
                    if (_isLoading)
                       Container(
                         decoration: BoxDecoration(
                           color: Colors.black45,
                           borderRadius: BorderRadius.circular(16),
                         ),
                         child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                       ),
                  ],
                ),
              ),
              
              // Banner Edit Button
              if (!_isLoading)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _handleImageUpload(context, true), // true = banner
                  child: Container(
                    padding: const EdgeInsets.all(8), // Larger hit target
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 18, color: Colors.white),
                  ),
                ),
              ),

              // 2. Profile Picture
              // Align to bottom center of the *SizedBox*, which is 210 high.
              // Banner is 160. Avatar radius is 50 (diameter 100).
              // We want center of avatar at y=160.
              // So bottom of avatar is at 160 + 50 = 210.
              // Layout: aligned to bottomCenter of the 210-height stack.
              Positioned(
                bottom: 0, 
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF121212), width: 4), // Match bg
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                        child: _isLoading 
                            ? const SizedBox() // Don't show text if loading banner (global loading)
                            : (user.photoUrl == null
                                ? Text(
                                    (user.firstName.isNotEmpty ? user.firstName[0] : '').toUpperCase(),
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                                  )
                                : null),
                      ),
                    ),
                    
                    // Profile Edit Button
                    if (!_isLoading)
                    GestureDetector(
                      onTap: () {
                         print("Profile Edit Tapped"); // Debug print just in case
                         _handleImageUpload(context, false);
                      },
                      behavior: HitTestBehavior.opaque, // Ensure hit test works
                      child: Container(
                        padding: const EdgeInsets.all(8), // Larger hit target
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF121212), width: 3),
                        ),
                        child: const Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 3. User Info (No Spacing needed as SizedBox covers it)
        const SizedBox(height: 10),

        Text(
          "${user.firstName} ${user.lastName}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          "@${user.username}",
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        
        const SizedBox(height: 12),
        
        // Edit Text Profile
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => EditProfileDialog(user: user),
            );
          },
          icon: const Icon(Icons.edit, size: 16),
          label: const Text("Edit Profile Info"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }
}
