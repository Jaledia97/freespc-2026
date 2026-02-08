import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../../features/photos/repositories/photo_repository.dart';
import '../../../../features/photos/models/gallery_photo_model.dart';
import '../../../../features/photos/presentation/upload_photo_screen.dart';
import '../../../../features/photos/presentation/photo_detail_screen.dart';
import '../hall_full_gallery_screen.dart';

class HallAboutTab extends ConsumerWidget {
  final BingoHallModel hall;

  const HallAboutTab({super.key, required this.hall});

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null) return;
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null) return;
    final uri = Uri.parse("tel:$phone");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
  
  Future<void> _openMap() async {
    final uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=${hall.latitude},${hall.longitude}");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch map');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosStream = ref.watch(photoRepositoryProvider).getHallPhotos(hall.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio Section
          const Text("About Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            hall.description ?? "No description available.",
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
          const SizedBox(height: 32),

          // Photo Gallery Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Photo Gallery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => HallFullGalleryScreen(hallId: hall.id, hallName: hall.name)));
                }, 
                child: const Text("See All"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          StreamBuilder<List<GalleryPhotoModel>>(
            stream: photosStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              
              final allPhotos = snapshot.data ?? [];
              // Determine display count: Max 11 photos + 1 add button = 12 slots (3 columns * 4 rows)
              final displayPhotos = allPhotos.take(11).toList();
              final itemCount = displayPhotos.length + 1;
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  // Check if this is the "Add Photo" slot (Last item)
                  if (index == itemCount - 1) {
                     return InkWell(
                       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UploadPhotoScreen(preSelectedHallId: hall.id))),
                       child: Container(
                         decoration: BoxDecoration(
                           color: Colors.grey[200],
                           borderRadius: BorderRadius.circular(4),
                         ),
                         child: const Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.add_a_photo, size: 28, color: Colors.grey),
                             SizedBox(height: 4),
                             Text("Add", style: TextStyle(color: Colors.grey, fontSize: 12)),
                           ],
                         ),
                       ),
                     );
                  }
                  
                  final photo = displayPhotos[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        photo.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // Contact Actions
          const Text("Contact & Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _contactRow(
            Icons.location_on, 
            "${hall.street}${(hall.unitNumber != null && hall.unitNumber!.isNotEmpty) ? ' ${hall.unitNumber}' : ''}\n${hall.city}, ${hall.state} ${hall.zipCode}",
            onTap: _openMap,
          ),
          const Divider(height: 32),
          _contactRow(
            Icons.phone, 
            hall.phone ?? "No phone listed",
            onTap: () => _callPhone(hall.phone),
            isLink: hall.phone != null,
          ),
          const Divider(height: 32),
          _contactRow(
            Icons.language, 
            hall.websiteUrl ?? "No website listed",
            onTap: () => _launchUrl(hall.websiteUrl),
            isLink: hall.websiteUrl != null,
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text, {VoidCallback? onTap, bool isLink = true}) {
    return InkWell(
      onTap: isLink ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.blue[800], size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10), // Align with icon
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isLink ? Colors.blue[800] : Colors.grey[700],
                      fontWeight: isLink ? FontWeight.w500 : FontWeight.normal,
                      decoration: isLink ? TextDecoration.underline : null,
                      decorationColor: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
            if (isLink)
              const Padding(
                padding: EdgeInsets.only(top: 10, left: 8),
                child: Icon(Icons.arrow_outward, size: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
