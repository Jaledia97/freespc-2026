import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../photos/models/gallery_photo_model.dart';
import '../../photos/repositories/photo_repository.dart';
import '../../../services/auth_service.dart';

class PhotoDetailScreen extends ConsumerWidget {
  final GalleryPhotoModel photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.value;

    final isOwner = user != null && user.uid == photo.uploaderId;
    // Basic check for manager (real apps would check specific hall rights, 
    // but here we just check if they are owner/manager role for simplicity 
    // or just let them delete if they are super-admin. 
    // For now, only OWNER of photo can delete, unless we pass in hall permissions context).
    // Let's stick to Uploader Only for now to be safe.
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            )
          else 
            IconButton(
              icon: const Icon(Icons.flag, color: Colors.orange),
              onPressed: () => _confirmReport(context, ref),
            ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            photo.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, loading) => loading == null ? child : const CircularProgressIndicator(),
            errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.white, size: 64),
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.black54,
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Text(
          photo.description ?? (isOwner ? "No description" : ""),
          style: const TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context, 
      builder: (c) => AlertDialog(
        title: const Text("Delete Photo?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(photoRepositoryProvider).deletePhoto(photo.id, photo.imageUrl);
        if (context.mounted) Navigator.pop(context); // Close screen
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _confirmReport(BuildContext context, WidgetRef ref) async {
     final confirm = await showDialog<bool>(
      context: context, 
      builder: (c) => AlertDialog(
        title: const Text("Report Photo"),
        content: const Text("Is this photo inappropriate due to nudity, violence, or spam?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Report")),
        ],
      )
    );

    if (confirm == true && context.mounted) {
       try {
        await ref.read(photoRepositoryProvider).reportPhoto(photo.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo reported. Thank you.")));
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
