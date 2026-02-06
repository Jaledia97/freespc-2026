import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../photos/repositories/photo_repository.dart';
import '../../photos/models/gallery_photo_model.dart';
import '../../photos/presentation/photo_detail_screen.dart';
import '../../photos/presentation/upload_photo_screen.dart';
import '../../../services/auth_service.dart';

class MyPhotosScreen extends ConsumerWidget {
  const MyPhotosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).value;
    if (user == null) return const Scaffold(body: Center(child: Text("Please log in")));

    final photosStream = ref.watch(photoRepositoryProvider).getUserGallery(user.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("My Gallery")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadPhotoScreen())),
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add_a_photo),
      ),
      body: StreamBuilder<List<GalleryPhotoModel>>(
        stream: photosStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          final photos = snapshot.data ?? [];
          if (photos.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text("No photos uploaded yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () => Navigator.pop(context), 
                     child: const Text("Go Explore Halls")
                   )
                 ],
               ),
             );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _MyPhotoCard(photo: photo);
            },
          );
        },
      ),
    );
  }
}

class _MyPhotoCard extends StatelessWidget {
  final GalleryPhotoModel photo;

  const _MyPhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    // Status Logic
    // If pendingHallIds is not empty -> Pending
    // If approvedHallIds is not empty -> Live
    // If both empty and taggedHallIds was not empty -> Declined? 
    // Wait, decline logic removes from taggedHallIds.
    // So if taggedHallIds is empty = Orphaned (Declined by all).
    // If taggedHallIds is NOT empty:
    //    If pendingHallIds contains x -> Pending at x
    //    If approvedHallIds contains x -> Live upon x
    
    // Simplification for User View:
    // If ANY approved -> LIVE
    // Else If ANY pending -> PENDING
    // Else -> DECLINED (or no tags)

    bool isPersonal = photo.taggedHallIds.isEmpty;
    bool isLive = isPersonal || photo.approvedHallIds.isNotEmpty;
    bool isPending = !isLive && photo.pendingHallIds.isNotEmpty;
    // Declined only if it was tagged but neither approved nor pending
    
    Color statusColor = isPersonal ? Colors.blue : (isLive ? Colors.green : (isPending ? Colors.orange : Colors.red));
    String statusText = isPersonal ? "PERSONAL" : (isLive ? "LIVE" : (isPending ? "PENDING" : "DECLINED"));
    IconData statusIcon = isPersonal ? Icons.person : (isLive ? Icons.check_circle : (isPending ? Icons.hourglass_empty : Icons.cancel));

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              photo.imageUrl, 
              fit: BoxFit.cover,
              errorBuilder: (_,__,___) => const Center(child: Icon(Icons.broken_image)),
            ),
          
          // Gradient Overlay
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo.description != null && photo.description!.isNotEmpty)
                     Text(photo.description!, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(DateFormat.MMMd().format(photo.timestamp), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ),
          
          // Status Badge
          Positioned(
            top: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
        ],
      ),
      ),
    );
  }
}
