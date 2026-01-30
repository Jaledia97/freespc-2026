import 'package:flutter/material.dart';
import '../../../../models/raffle_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/time_utils.dart';

class RaffleListCard extends StatefulWidget {
  final RaffleModel raffle;

  const RaffleListCard({super.key, required this.raffle});

  @override
  State<RaffleListCard> createState() => _RaffleListCardState();
}

class _RaffleListCardState extends State<RaffleListCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final raffle = widget.raffle;
    final percentage = (raffle.soldTickets / raffle.maxTickets).clamp(0.0, 1.0);
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.white,
      child: InkWell(
        onTap: _toggle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Hero Image (Always visible)
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    raffle.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_,__,___) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          raffle.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.confirmation_number, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${raffle.soldTickets} / ${raffle.maxTickets} tickets claimed",
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Text(
                        "FREE ENTRY",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Info Bar (Always visible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                   Expanded(
                     child: Text(
                       raffle.description,
                       style: TextStyle(color: Colors.grey[800], fontSize: 14),
                       maxLines: _isExpanded ? 10 : 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                   Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),

            // 3. Expanded Details
            if (_isExpanded)
              Container(
                color: Colors.grey[50],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Consumer(
                      builder: (context, ref, _) {
                        return _buildDetailRow(Icons.calendar_today, "Draw Date", TimeUtils.formatDateTime(raffle.endsAt, ref));
                      }
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.info_outline, "Details", "Physical presence required for Roll Call."),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.blueAccent,
                           padding: const EdgeInsets.symmetric(vertical: 14),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                           // Action is limited in MVP (View Only)
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Visit the Hall to enter this raffle!")));
                        },
                        child: const Text("HOW TO ENTER", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ],
    );
  }
}
