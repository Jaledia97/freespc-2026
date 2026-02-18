import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/raffle_model.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../profile/presentation/widgets/profile_header.dart';
import 'edit_raffle_screen.dart';
import '../raffle_tool/raffle_tool_screen.dart';

class ManageRafflesScreen extends ConsumerStatefulWidget {
  final String hallId;
  const ManageRafflesScreen({super.key, required this.hallId});

  @override
  ConsumerState<ManageRafflesScreen> createState() => _ManageRafflesScreenState();
}

class _ManageRafflesScreenState extends ConsumerState<ManageRafflesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild FAB on tab change
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rafflesAsync = ref.watch(hallRafflesProvider(widget.hallId));
    final isTemplateTab = _tabController.index == 2;

    return Scaffold(
        backgroundColor: const Color(0xFF141414),
        appBar: AppBar(
          title: const Text('Manage Raffles'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Expired"),
              Tab(text: "Templates"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditRaffleScreen(
                hallId: widget.hallId,
                isTemplate: isTemplateTab, // Auto-check template box if on tab
              )),
            );
          },
          backgroundColor: Colors.amber,
          label: Text(isTemplateTab ? "Create Template" : "Create Raffle", style: const TextStyle(color: Colors.black)),
          icon: Icon(isTemplateTab ? Icons.save_as : Icons.add, color: Colors.black),
        ),
        body: rafflesAsync.when(
          data: (raffles) {
            final now = DateTime.now();

            // Filter lists
            final templates = raffles.where((r) => r.isTemplate).toList();
            // Active: Not a template, and ends in future OR is today
            final active = raffles.where((r) => !r.isTemplate && (r.endsAt.isAfter(now) || isSameDay(r.endsAt, now))).toList();
            // Expired: Not a template, ends in past, and NOT today
            final expired = raffles.where((r) => !r.isTemplate && r.endsAt.isBefore(now) && !isSameDay(r.endsAt, now)).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildRaffleList(context, ref, active, emptyMsg: "No Active Raffles"),
                _buildRaffleList(context, ref, expired, emptyMsg: "No Expired Raffles"),
                _buildRaffleList(context, ref, templates, emptyMsg: "No Templates", isTemplateTab: true),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        ),
    );
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  Widget _buildRaffleList(BuildContext context, WidgetRef ref, List<RaffleModel> raffles, {required String emptyMsg, bool isTemplateTab = false}) {
    if (raffles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
             Text(emptyMsg, style: const TextStyle(color: Colors.white54)),
             if (isTemplateTab) // Only suggest seeding on template tab maybe? or just generic
               Padding(
                 padding: const EdgeInsets.only(top: 8.0),
                 child: TextButton(
                   onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: widget.hallId, isTemplate: true))),
                   child: const Text("Create Template"),
                 ),
               ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: raffles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final raffle = raffles[index];
        final now = DateTime.now();
        final isToday = isSameDay(raffle.endsAt, now);
        final isPast = raffle.endsAt.isBefore(now) && !isToday;

        return Card(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(raffle.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(raffle.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(raffle.description, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1),
                const SizedBox(height: 4),
                if (isTemplateTab)
                  Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                     child: const Text("TEMPLATE", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                else
                  Row(
                    children: [
                       Icon(Icons.calendar_today, size: 12, color: isPast ? Colors.red : (isToday ? Colors.green : Colors.blue)),
                       const SizedBox(width: 4),
                       Text(
                         TimeUtils.formatDateTime(raffle.endsAt, ref),
                         style: TextStyle(color: isPast ? Colors.red : (isToday ? Colors.green : Colors.blue), fontSize: 12, fontWeight: FontWeight.bold)
                       ),
                       if (isToday)
                         Container(
                           margin: const EdgeInsets.only(left: 8),
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                           child: const Text("TODAY", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                         ),
                    ],
                  ),
              ],
            ),
            onTap: () {
              if (isTemplateTab) {
                // Instantiation flow
                _showTemplateDialog(context, ref, raffle);
              } else {
                if (isPast) {
                   _showEditDialog(context, ref, raffle); // Expired -> Edit/Delete/Archive
                } else if (isToday) {
                   // Active Today -> Show Options
                   _showActiveOptions(context, ref, raffle);
                } else {
                   // Future -> Edit
                   _showEditDialog(context, ref, raffle);
                }
              }
            },
          ),
        );
      },
    );
  }

  void _showTemplateDialog(BuildContext context, WidgetRef ref, RaffleModel raffle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(raffle.name, style: const TextStyle(color: Colors.white)),
        content: const Text(
          "Use this template to create a new raffle?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: widget.hallId, raffle: raffle, isCreatingFromTemplate: true)));
            },
            child: const Text("Use Template", style: TextStyle(color: Colors.black)),
          ),
          // Option to edit template itself
          TextButton(
            onPressed: () {
               Navigator.pop(ctx);
               Navigator.push(context, MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: widget.hallId, raffle: raffle, isEditingTemplate: true)));
            },
            child: const Text("Edit Template", style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, RaffleModel raffle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(raffle.name, style: const TextStyle(color: Colors.white)),
        content: Text(
          "This raffle is scheduled for ${TimeUtils.formatDateTime(raffle.endsAt, ref)}.\n\nYou can edit details or delete it.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text("Delete Raffle?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(hallRepositoryProvider).deleteRaffle(raffle.id);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("DELETE", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: widget.hallId, raffle: raffle)));
            },
            child: const Text("EDIT"),
          ),
        ],
      ),
    );
  }
  void _showActiveOptions(BuildContext context, WidgetRef ref, RaffleModel raffle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(raffle.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("This raffle is active today. What would you like to do?", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                icon: const Icon(Icons.play_arrow),
                label: const Text("LAUNCH RAFFLE TOOL"),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RaffleToolScreen(hallId: widget.hallId, raffle: raffle)));
                },
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.blueAccent, side: const BorderSide(color: Colors.blueAccent)),
                icon: const Icon(Icons.edit),
                label: const Text("EDIT DETAILS"),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditRaffleScreen(hallId: widget.hallId, raffle: raffle)));
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
