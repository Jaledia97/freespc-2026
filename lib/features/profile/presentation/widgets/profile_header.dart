import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/storage_service.dart';
import 'edit_profile_dialog.dart';
import '../public_profile_screen.dart';
import '../../../home/repositories/hall_repository.dart';

class ProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  ConsumerState<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<ProfileHeader> {
  bool _isLoading = false;

  void _handleImageUpload(BuildContext context) {
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
              onTap: () => _pickAndUpload(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () => _pickAndUpload(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet
    
    final storage = ref.read(storageServiceProvider);
    
    try {
      final xFile = await storage.pickImage(source: source);
      if (xFile == null) return;

      setState(() => _isLoading = true);

      final file = File(xFile.path);
      final uid = widget.user.uid;

      final downloadUrl = await storage.uploadProfileImage(file, uid);

      // Update User Profile
      await ref.read(authServiceProvider).updateUserFields(uid, {'photoUrl': downloadUrl});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload Error: $e"), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(label: 'Retry', onPressed: () => _pickAndUpload(source)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hero(
              tag: 'avatar_${user.uid}',
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white10,
                    backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (user.photoUrl == null
                            ? const Icon(Icons.person, size: 45, color: Colors.white54)
                            : null),
                  ),
                  if (!_isLoading)
                    GestureDetector(
                      onTap: () => _handleImageUpload(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF121212), width: 3),
                        ),
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer(builder: (context, ref, _) {
                    final postsAsync = ref.watch(profilePostsCountProvider(user.uid));
                    return _buildStatCol("Posts", (postsAsync.valueOrNull ?? 0).toString());
                  }),
                  Consumer(builder: (context, ref, _) {
                    final friendsAsync = ref.watch(profileFriendsCountProvider(user.uid));
                    return _buildStatCol("Friends", (friendsAsync.valueOrNull ?? 0).toString());
                  }),
                  _buildStatCol("Points", user.currentPoints.toString()),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Text(
          "${user.firstName} ${user.lastName}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          "@${user.username}",
          style: const TextStyle(fontSize: 14, color: Colors.white54),
        ),
        
        const SizedBox(height: 16),
        
        // About Me Section
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          Text(
            user.bio!,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
        ],

        // Home Hall Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Home Hall",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            if (user.homeBaseId != null)
              GestureDetector(
                onTap: () {
                  ref.read(hallRepositoryProvider).toggleHomeBase(user.uid, user.homeBaseId!, user.homeBaseId);
                },
                child: const Text("UNSET", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _HomeBaseDisplay(homeBaseId: user.homeBaseId),

        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
               showDialog(context: context, builder: (context) => EditProfileDialog(user: user));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Edit Profile Info", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        
        if (user.squadIds.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.shield, size: 14, color: Colors.amber),
              const SizedBox(width: 4),
              Text("Captain of ${user.squadIds.length} Squads", style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ]
      ],
    );
  }
}

class _HomeBaseDisplay extends ConsumerWidget {
  final String? homeBaseId;

  const _HomeBaseDisplay({required this.homeBaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (homeBaseId == null) {
      return const Text(
        "No Home Base Set",
        style: TextStyle(
          color: Colors.white38,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      );
    }

    final hallAsync = ref.watch(hallStreamProvider(homeBaseId!));

    return hallAsync.when(
      data: (hall) {
        if (hall == null) {
          return const Text(
            "Unknown Hall",
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return Text(
          hall.name,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      },
      loading: () => const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueGrey),
      ),
      error: (_, __) => const Text(
        "Error loading hall",
        style: TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
