import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/photos/repositories/photo_repository.dart';
import '../../../../features/photos/models/gallery_photo_model.dart';
import 'package:intl/intl.dart';
import '../../../../services/auth_service.dart';

class PhotoApprovalScreen extends ConsumerStatefulWidget {
  final String hallId;
  final String hallName;

  const PhotoApprovalScreen({super.key, required this.hallId, required this.hallName});

  @override
  ConsumerState<PhotoApprovalScreen> createState() => _PhotoApprovalScreenState();
}

class _PhotoApprovalScreenState extends ConsumerState<PhotoApprovalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProfileProvider).value;
      if (user != null) {
        ref.read(authServiceProvider).updateLastViewedPhotoApprovals(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingPhotosStream = ref.watch(photoRepositoryProvider).getPendingHallPhotos(widget.hallId);

    return Scaffold(
      appBar: AppBar(title: Text("Approvals: ${widget.hallName}")),
      body: StreamBuilder<List<GalleryPhotoModel>>(
        stream: pendingPhotosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          final photos = snapshot.data ?? [];

          if (photos.isEmpty) {
             return const Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                   SizedBox(height: 16),
                   Text("All caught up!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   Text("No pending photos to review."),
                 ],
               ),
             );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        photo.imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text("Uploaded: ${_timeAgo(photo.timestamp)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                               // Potentially show user ID here
                             ],
                           ),
                           const SizedBox(height: 8),
                           if (photo.description != null && photo.description!.isNotEmpty)
                             Text(photo.description!, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                           if (photo.description == null || photo.description!.isEmpty)
                             const Text("No caption provided.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                               ref.read(photoRepositoryProvider).declinePhoto(photo.id, widget.hallId);
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo Declined & Tag Removed")));
                            },
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text("Decline", style: TextStyle(color: Colors.red)),
                            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                        Container(width: 1, height: 48, color: Colors.grey[200]),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () {
                              ref.read(photoRepositoryProvider).approvePhoto(photo.id, widget.hallId);
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo Approved!")));
                            },
                            icon: const Icon(Icons.check, color: Colors.green),
                            label: const Text("Approve", style: TextStyle(color: Colors.green)),
                             style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours < 1) {
      if (difference.inMinutes == 0) return "Just now";
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
    } else {
      return DateFormat('MMM d, yyyy').add_jm().format(createdAt);
    }
  }
}
