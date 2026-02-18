import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../photos/repositories/photo_repository.dart';
import '../../photos/models/gallery_photo_model.dart';
import '../../photos/presentation/upload_photo_screen.dart';
import '../../photos/presentation/photo_detail_screen.dart';
import 'package:intl/intl.dart';

class HallFullGalleryScreen extends ConsumerWidget {
  final String hallId;
  final String hallName;

  const HallFullGalleryScreen({super.key, required this.hallId, required this.hallName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosStream = ref.watch(photoRepositoryProvider).getHallPhotos(hallId);

    return Scaffold(
      appBar: AppBar(
        title: Text("$hallName Gallery"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => UploadPhotoScreen(preSelectedHallId: hallId)));
            },
          )
        ],
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
             return const Center(child: Text("No photos yet. Be the first!"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)));
                },
                child: CachedNetworkImage(
                  imageUrl: photo.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[900]),
                  errorWidget: (_,__,___) => Container(color: Colors.grey[900], child: const Icon(Icons.broken_image)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
