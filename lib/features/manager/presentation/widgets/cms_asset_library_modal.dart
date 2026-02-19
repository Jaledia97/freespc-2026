import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/hall_repository.dart';

class CmsAssetLibraryModal extends ConsumerWidget {
  final String hallId;
  final Function(String url) onAssetSelected;

  const CmsAssetLibraryModal({
    super.key, 
    required this.hallId, 
    required this.onAssetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, 
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Select from Library", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Consumer(
                builder: (_, ref, child) {
                  // Fetch recent special images. 
                  // In the future, we might want to pass a 'type' (special vs store vs hall) 
                  // but for now, reusing special images is a good start as they are likely similar promo content.
                  final assetsStream = ref.watch(hallRepositoryProvider).getRecentSpecialImages(hallId);
                  
                  return StreamBuilder<List<String>>(
                    stream: assetsStream, 
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      
                      final images = snapshot.data ?? [];
                      if (images.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported, color: Colors.white24, size: 48),
                              const SizedBox(height: 16),
                              const Text("No stored images found.", style: TextStyle(color: Colors.white54)),
                              const SizedBox(height: 8),
                              const Text("Upload images in other screens to populate this library.", style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      }
                      
                      return GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                        itemCount: images.length,
                        itemBuilder: (ctx, i) {
                          return GestureDetector(
                            onTap: () => onAssetSelected(images[i]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(images[i], fit: BoxFit.cover),
                            ),
                          );
                        },
                      );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
