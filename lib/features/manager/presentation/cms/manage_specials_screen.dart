import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/special_model.dart';
import 'edit_special_screen.dart';

class ManageSpecialsScreen extends ConsumerWidget {
  const ManageSpecialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Manage Specials'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           // Create Mode
           final user = userAsync.value;
           if (user != null && user.homeBaseId != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditSpecialScreen(hallId: user.homeBaseId!)));
           } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: No Home Base Hall ID found for manager.")));
           }
        },
        backgroundColor: Colors.green,
        label: const Text("New Special"),
        icon: const Icon(Icons.add),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null || user.homeBaseId == null) {
            return const Center(child: Text("No Hall Assigned to User"));
          }
          final hallId = user.homeBaseId!;
          
          return Consumer(
            builder: (context, ref, _) {
              final specialsAsync = ref.watch(hallSpecialsProvider(hallId));
              return specialsAsync.when(
                data: (specials) {
                  if (specials.isEmpty) {
                    return const Center(child: Text("No specials found. Create one!", style: TextStyle(color: Colors.white54)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: specials.length,
                    itemBuilder: (context, index) {
                      final special = specials[index];
                      return Dismissible(
                        key: Key(special.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Delete Special?"),
                              content: Text("Are you sure you want to delete '${special.title}'?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          ref.read(hallRepositoryProvider).deleteSpecial(special.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("'${special.title}' deleted")));
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: const Color(0xFF1E1E1E),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(special.imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (_, __) => const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            title: Text(special.title, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              "${special.description}\nStart: ${special.startTime != null ? _formatDate(special.startTime!) : 'TBD'}",
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                              maxLines: 2,
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => EditSpecialScreen(hallId: hallId, special: special)));
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text("Error: $e")),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Auth Error: $e")),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
