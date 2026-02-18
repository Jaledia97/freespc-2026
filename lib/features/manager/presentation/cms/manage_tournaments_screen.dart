import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/auth_service.dart';
import '../../repositories/tournament_repository.dart';
import '../../../../models/tournament_model.dart';
import 'edit_tournament_screen.dart';

class ManageTournamentsScreen extends ConsumerStatefulWidget {
  const ManageTournamentsScreen({super.key});

  @override
  ConsumerState<ManageTournamentsScreen> createState() => _ManageTournamentsScreenState();
}

class _ManageTournamentsScreenState extends ConsumerState<ManageTournamentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null || user.homeBaseId == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF141414),
            body: Center(child: Text("No Hall Assigned to User", style: TextStyle(color: Colors.white))),
          );
        }
        final hallId = user.homeBaseId!;
        final tournamentsAsync = ref.watch(hallTournamentsProvider(hallId));

        return Scaffold(
          backgroundColor: const Color(0xFF141414),
          appBar: AppBar(
            title: const Text('Manage Tournaments'),
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Active"),
                Tab(text: "Expired"),
                Tab(text: "Templates"),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
                final isTemplateMode = _tabController.index == 2;
                Navigator.push(context, MaterialPageRoute(builder: (_) => EditTournamentScreen(
                  hallId: hallId,
                  createTemplateMode: isTemplateMode,
                )));
            },
            backgroundColor: Colors.blueAccent,
            label: Text(_tabController.index == 2 ? "Create Template" : "Create Tournament", style: const TextStyle(color: Colors.white)),
            icon: Icon(_tabController.index == 2 ? Icons.save_as : Icons.emoji_events, color: Colors.white),
          ),
          body: tournamentsAsync.when(
            data: (tournaments) {
              final now = DateTime.now();
              
              final active = <TournamentModel>[];
              final expired = <TournamentModel>[];
              final templates = <TournamentModel>[];

              for (var t in tournaments) {
                if (t.isTemplate) {
                  templates.add(t);
                  continue; 
                }

                // Check Expiry
                bool isExpired = false;
                // If it has recurrence, let's treat it as active for now unless archived?
                // Or use minimal expiry check similar to specials
                if (t.recurrenceRule == null || t.recurrenceRule!.frequency == 'none') {
                    final end = t.endTime ?? t.startTime?.add(const Duration(hours: 4));
                    if (end != null && end.isBefore(now)) {
                      isExpired = true;
                    }
                }
                
                if (isExpired) {
                  expired.add(t);
                } else {
                  active.add(t);
                }
              }

              // Sort
              active.sort((a, b) => (a.startTime ?? now).compareTo(b.startTime ?? now));
              expired.sort((a, b) => (b.startTime ?? now).compareTo(a.startTime ?? now));
              templates.sort((a, b) => a.title.compareTo(b.title));

              return TabBarView(
                controller: _tabController,
                children: [
                    _buildList(active, hallId, "No active tournaments.", isArchived: false),
                    _buildList(expired, hallId, "No recently expired tournaments.", isArchived: true),
                    _buildList(templates, hallId, "No templates saved.", isTemplate: true),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: Color(0xFF141414), body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(backgroundColor: const Color(0xFF141414), body: Center(child: Text("Auth Error: $e"))),
    );
  }

  Widget _buildList(List<TournamentModel> items, String hallId, String emptyMsg, {bool isArchived = false, bool isTemplate = false}) {
    if (items.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tournament = items[index];

        return GestureDetector(
          onTap: () {
              if (isTemplate) {
                  // Copy Logic could be here, or just Edit
                  _createCopy(hallId, tournament);
              } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditTournamentScreen(hallId: hallId, tournament: tournament)));
              }
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.purpleAccent),
              ),
              title: Text(tournament.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                isTemplate 
                  ? tournament.description 
                  : "${tournament.description}\nGames: ${tournament.games.length}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 2,
              ),
              isThreeLine: true,
              trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        if (isArchived)
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.greenAccent),
                          tooltip: "Use as Copy",
                          onPressed: () => _createCopy(hallId, tournament),
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EditTournamentScreen(hallId: hallId, tournament: tournament)));
                        },
                      ),
                    ],
                  ),
            ),
          ),
        );
      },
    );
  }

  void _createCopy(String hallId, TournamentModel original) {
    final copy = original.copyWith(
      id: '', // Empty ID signals "New"
      title: original.isTemplate ? original.title : "Copy of ${original.title}",
      isTemplate: false,
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 5)),
      // recurrenceRule: null // Reset recurrence? Or keep it? logic suggests keeping it might be useful
    );
    
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditTournamentScreen(hallId: hallId, tournament: copy, createTemplateMode: false)));
  }
}
