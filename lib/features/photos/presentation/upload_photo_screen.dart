import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/auth_service.dart';
import '../repositories/photo_repository.dart';
import '../../home/repositories/hall_repository.dart';
import 'tagging_delegates.dart';
import '../../../models/bingo_hall_model.dart';
import '../../../models/public_profile.dart';

class UploadPhotoScreen extends ConsumerStatefulWidget {
  final String? preSelectedHallId; // If coming from a specific hall

  const UploadPhotoScreen({super.key, this.preSelectedHallId});

  @override
  ConsumerState<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends ConsumerState<UploadPhotoScreen> {
  final _picker = ImagePicker();
  File? _imageFile;
  final _descriptionController = TextEditingController();
  bool _isUploading = false;

  // Tagging State
  final List<BingoHallModel> _taggedHalls = [];
  final List<PublicProfile> _taggedUsers = [];

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedHallId != null) {
      // We don't have the full model here easily without fetching.
      // But for display, we might want it.
      // For MVP, if preSelected, we just add the ID to a temporary list or fetch it?
      // Actually, let's keep the preSelected as a separate logic or fetch it.
      // To simplify: If preSelectedHallId exists, we assume it's tagged but maybe not easily displayed in the new "Chip" list unless we fetch it.
      // Or we just fetch it via ref.read(hallRepositoryProvider).getHallStream...
      // Let's just default to "Current Hall" text if model missing?
      // Better: Fetch it in initState if possible? No async in initState.
      // We can use a FutureBuilder for the initial selected hall chip?
      // OR just keep the "Current Hall" display separate (lines 163-181) and use _taggedHalls for *additional* tags?
      // User request: "tag their friends and halls".
      // If I am on a hall page, that hall is implicitly tagged.
      // If I tag *other* halls, they go into _taggedHalls.
      // Should I merge them?
      // Let's KEEP lines 163-181 for the "Main" hall, and add a section for "Additional Tags".
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _showWarningAndUpload() {
    if (_imageFile == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("⚠️ Code of Conduct Warning"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please ensure your photo contains NO inappropriate content.", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("• 1st Offense: 30-day gallery ban"),
            Text("• 2nd Offense: 1-year gallery ban"),
            Text("• 3rd Offense: Permanent Platform Ban"),
            SizedBox(height: 12),
            Text("If you tag a Hall, a manager MUST approve it before it appears on their profile."),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _upload();
            },
            child: const Text("I Understand & Upload", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _upload() async {
    setState(() => _isUploading = true);
    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null) throw Exception("Not logged in");

      // Combine preSelected + search-tagged
      final allTaggedHallIds = <String>{};
      if (widget.preSelectedHallId != null) allTaggedHallIds.add(widget.preSelectedHallId!);
      allTaggedHallIds.addAll(_taggedHalls.map((h) => h.id));

      await ref.read(photoRepositoryProvider).uploadPhoto(
        imageFile: _imageFile!,
        uploaderId: user.uid,
        description: _descriptionController.text.trim(),
        taggedHallIds: allTaggedHallIds.toList(),
        taggedUserIds: _taggedUsers.map((u) => u.uid).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload Successful! Awaiting Approval.")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Photo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Preview
            GestureDetector(
              onTap: () {
                showModalBottomSheet(context: context, builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Camera"), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
                      ListTile(leading: const Icon(Icons.photo_library), title: const Text("Gallery"), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
                    ],
                  ),
                ));
              },
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null 
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Tap to select photo", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Caption (Optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Tagging Display
            // 1. Current Hall (Immutable Tag)
            if (widget.preSelectedHallId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50], 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(child: Text("Posting to Current Hall", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                    Icon(Icons.lock, size: 16, color: Colors.blueGrey),
                  ],
                ),
              ),

            // 2. Tagged Halls List
            if (_taggedHalls.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _taggedHalls.map((hall) => Chip(
                  avatar: const Icon(Icons.location_on, size: 14),
                  label: Text(hall.name),
                  onDeleted: () => setState(() => _taggedHalls.remove(hall)),
                )).toList(),
              ),

            // 3. Tagged Users List
            if (_taggedUsers.isNotEmpty)
              Wrap(
                spacing: 8,
                children: _taggedUsers.map((u) => Chip(
                  avatar: const Icon(Icons.person, size: 14),
                  label: Text(u.firstName),
                  onDeleted: () => setState(() => _taggedUsers.remove(u)),
                )).toList(),
              ),
            
            const SizedBox(height: 16),

            // 4. Tag Buttons
            Row(
              children: [
                if (widget.preSelectedHallId == null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text("Tag Hall"),
                      onPressed: () async {
                        final hall = await showSearch(context: context, delegate: HallSearchDelegate(ref));
                        if (hall != null && !_taggedHalls.any((h) => h.id == hall.id)) {
                          setState(() => _taggedHalls.add(hall));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text("Tag User"),
                    onPressed: () async {
                      final user = await showSearch(context: context, delegate: UserSearchDelegate(ref));
                      if (user != null && !_taggedUsers.any((u) => u.uid == user.uid)) {
                          setState(() => _taggedUsers.add(user));
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                ),
                onPressed: (_imageFile != null && !_isUploading) ? _showWarningAndUpload : null,
                child: _isUploading 
                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                   : const Text("Upload Photo", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
