import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/venue_repository.dart';
import '../../../../services/session_context_controller.dart';
import '../../../../models/bar_game_model.dart';
import 'package:uuid/uuid.dart';

class ManageBarGamesScreen extends ConsumerStatefulWidget {
  final String venueId;
  const ManageBarGamesScreen({super.key, required this.venueId});

  @override
  ConsumerState<ManageBarGamesScreen> createState() => _ManageBarGamesScreenState();
}

class _ManageBarGamesScreenState extends ConsumerState<ManageBarGamesScreen> {
  Future<void> _showCreateDialog() async {
    String selectedGameType = 'Darts';
    final countCtrl = TextEditingController(text: '8');

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              backgroundColor: const Color(0xFF222222),
              title: const Text("Launch Bar Game", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGameType,
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    items: ['Darts', 'Billiards', 'Beer Pong', 'Cornhole']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setStateBuilder(() => selectedGameType = val);
                    },
                    decoration: const InputDecoration(labelText: "Game Protocol", labelStyle: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: countCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Max Entrants (Bracket Size)", labelStyle: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () async {
                    final max = int.tryParse(countCtrl.text.trim()) ?? 8;
                    final game = BarGameModel(
                      id: const Uuid().v4(),
                      venueId: widget.venueId,
                      gameType: selectedGameType,
                      maxParticipants: max,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(venueRepositoryProvider).addBarGame(game);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text("INITIALIZE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(hallBarGamesProvider(widget.venueId));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text("Bar Games"),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.sports_kabaddi, color: Colors.white),
        label: const Text("Launch Match", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(child: Text("No physical bar games actively hosted right now.", style: TextStyle(color: Colors.white54)));
          }

          final sorted = List<BarGameModel>.from(games)..sort((a,b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final game = sorted[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text("${game.gameType} Tournament", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Status: ${game.status}\nEntrants: ${game.participantCount} / ${game.maxParticipants}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_circle_up, color: Colors.amber),
                        onPressed: () {
                          // Simple state advancement
                          String next = game.status == 'Registration' ? 'Active' : 'Completed';
                          ref.read(venueRepositoryProvider).updateBarGame(game.copyWith(status: next));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(venueRepositoryProvider).deleteBarGame(game.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
