import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../models/special_model.dart';

class SpecialCard extends StatefulWidget {
  final SpecialModel special;
  final bool isFeatured;

  const SpecialCard({super.key, required this.special, this.isFeatured = false});

  @override
  State<SpecialCard> createState() => _SpecialCardState();
}

class _SpecialCardState extends State<SpecialCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shared Header Content (Accessing widget.special)
    final Widget headerContent = ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Compact Mode: Show thumbnail. Featured Mode: No leading (Image is above).
      leading: widget.isFeatured 
          ? null 
          : Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(image: NetworkImage(widget.special.imageUrl), fit: BoxFit.cover),
              ),
            ),
      title: Text(widget.special.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(widget.special.hallName),
      trailing: AnimatedRotation(
        turns: _isExpanded ? 0.5 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(Icons.expand_more, color: Theme.of(context).primaryColor),
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleExpand, // Tapping anywhere toggles expansion
        child: Column(
          children: [
            // Featured Banner Image (If Featured)
            if (widget.isFeatured)
              Image.network(
                widget.special.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(height: 200, color: Colors.grey, child: const Icon(Icons.broken_image)),
              ),

            // Header Row (Title, Subtitle, Icon)
            // Use IgnorePointer to let the parent InkWell handle the tap? 
            // Or just put it in the column. logic above handles tap for whole card.
            // But ListTile has its own tap. We disable it or wrapper handles it.
            // If we use ListTile inside InkWell, ListTile's internal InkWell might capture taps.
            // Better to standard Column/Row or disable ListTile tap.
            IgnorePointer(ignoring: true, child: headerContent),

            // Expandable Body
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                widget.special.startTime != null 
                                  ? "Starts: ${widget.special.startTime.toString().substring(0, 16)}" 
                                  : "Check Hall for Time",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(widget.special.description),
                          if (widget.special.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: widget.special.tags.map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 10)),
                                backgroundColor: Colors.grey[100],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4), side: BorderSide(color: Colors.grey[300]!)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )).toList(),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          
                          // Action Buttons
                          // Note: These need to be tappable!
                          // Since they are children of the parent InkWell, we need to ensure they consume the tap event 
                          // so it doesn't just toggle expansion.
                          // InkWell inside InkWell works fine usually.
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
                                  if (widget.special.startTime == null) return;
                                  final event = Event(
                                    title: widget.special.title,
                                    description: widget.special.description,
                                    location: widget.special.hallName,
                                    startDate: widget.special.startTime!,
                                    endDate: widget.special.startTime!.add(const Duration(hours: 2)),
                                  );
                                  Add2Calendar.addEvent2Cal(event);
                                }
                              ),
                              _ActionButton(
                                icon: Icons.directions, 
                                label: "Navigate", 
                                onTap: () async {
                                   if (widget.special.latitude == null || widget.special.longitude == null) return;
                                   final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${widget.special.latitude},${widget.special.longitude}");
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
                  : const SizedBox.shrink(), // Collapsed
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
    final iconColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
