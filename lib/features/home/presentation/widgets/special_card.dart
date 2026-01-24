import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../models/special_model.dart';

class SpecialCard extends StatelessWidget {
  final SpecialModel special;
  final bool isFeatured; // true for Home Feed (Big Image), false for Directory (Thumbnail)

  const SpecialCard({super.key, required this.special, this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Needed for full-width banner
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          children: [
            // Featured Banner Image
            if (isFeatured)
              Image.network(
                special.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(height: 200, color: Colors.grey, child: const Icon(Icons.broken_image)),
              ),

            ExpansionTile(
              collapsedIconColor: Theme.of(context).primaryColor,
              iconColor: Theme.of(context).primaryColor,
              textColor: Theme.of(context).colorScheme.onSurface,
              // Compact Mode: Show thumbnail. Featured Mode: No leading.
              leading: isFeatured 
                  ? null 
                  : Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: NetworkImage(special.imageUrl), fit: BoxFit.cover),
                      ),
                    ),
              title: Text(special.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(special.hallName),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            special.startTime != null ? "Starts: ${special.startTime.toString().substring(0, 16)}" : "Check Hall for Time",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(special.description),
                      if (special.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: special.tags.map((tag) => Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 10)),
                            backgroundColor: Colors.grey[100],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey[300]!)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionButton(
                            icon: Icons.phone, 
                            label: "Call", 
                            onTap: () async {
                               final Uri launchUri = Uri(scheme: 'tel', path: '555-555-5555'); 
                               if (await canLaunchUrl(launchUri)) {
                                 await launchUrl(launchUri);
                               }
                            }
                          ),
                          _ActionButton(
                            icon: Icons.calendar_month, 
                            label: "Add to Cal", 
                            onTap: () {
                              if (special.startTime == null) return;
                              final event = Event(
                                title: special.title,
                                description: special.description,
                                location: special.hallName,
                                startDate: special.startTime!,
                                endDate: special.startTime!.add(const Duration(hours: 2)),
                              );
                              Add2Calendar.addEvent2Cal(event);
                            }
                          ),
                          _ActionButton(
                            icon: Icons.directions, 
                            label: "Navigate", 
                            onTap: () async {
                               if (special.latitude == null || special.longitude == null) return;
                               final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${special.latitude},${special.longitude}");
                               if (await canLaunchUrl(googleMapsUrl)) {
                                   await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                               }
                            }
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Ensuring High Contrast for Accessibility
    final color = Theme.of(context).primaryColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Larger touch target
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
