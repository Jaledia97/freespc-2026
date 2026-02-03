import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import '../../../../models/special_model.dart';
import '../../repositories/hall_repository.dart';
import '../hall_profile_screen.dart';

class SpecialCard extends ConsumerStatefulWidget {
  final SpecialModel special;
  final bool isFeatured;

  const SpecialCard({super.key, required this.special, this.isFeatured = false});

  @override
  ConsumerState<SpecialCard> createState() => _SpecialCardState();
}

class _SpecialCardState extends ConsumerState<SpecialCard> with SingleTickerProviderStateMixin {
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
                                  _formattedDate(widget.special),
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
                          Container(
                            width: double.infinity,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                _ActionButton(
                                  icon: Icons.store, 
                                  label: "Visit Hall", 
                                  onTap: () async {
                                    // Fetch Hall Data & Navigate
                                    final hall = await ref.read(hallRepositoryProvider).getHallStream(widget.special.hallId).first;
                                    if (hall != null && context.mounted) {
                                       Navigator.push(context, MaterialPageRoute(builder: (_) => HallProfileScreen(hall: hall)));
                                    } else if (context.mounted) {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not load hall details.")));
                                    }
                                  }
                                ),
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
                            ),
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
  String _formattedDate(SpecialModel special) {
    if (special.startTime == null) return "Check Hall for Time";
    
    final dt = special.startTime!;
    final timeStr = "${dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour)}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}";
    
    if (special.recurrence == 'daily') {
      return "Every Day at $timeStr";
    } else if (special.recurrence == 'weekly') {
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      final weekday = days[dt.weekday - 1]; // dt.weekday is 1-7 (Mon-Sun)
      return "Every $weekday at $timeStr";
    } else if (special.recurrence == 'monthly') {
      return "Monthly on the ${dt.day}${_ordinal(dt.day)} at $timeStr";
    } else {
      // One time event
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final dateStr = "${months[dt.month - 1]} ${dt.day}";
      return "$dateStr at $timeStr";
    }
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
