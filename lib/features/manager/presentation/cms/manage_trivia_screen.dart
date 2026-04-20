import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/venue_repository.dart';
import '../../../../services/session_context_controller.dart';
import '../../../../models/trivia_model.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../services/storage_service.dart';
import 'package:intl/intl.dart';

class ManageTriviaScreen extends ConsumerStatefulWidget {
  final String venueId;
  const ManageTriviaScreen({super.key, required this.venueId});

  @override
  ConsumerState<ManageTriviaScreen> createState() => _ManageTriviaScreenState();
}

class _ManageTriviaScreenState extends ConsumerState<ManageTriviaScreen> {
  Future<void> _showCreateOrEditDialog([TriviaModel? existingTrivia]) async {
    final isNew = existingTrivia == null;
    final titleCtrl = TextEditingController(text: existingTrivia?.title ?? '');
    final catCtrl = TextEditingController(text: existingTrivia?.category ?? '');
    final prizeCtrl = TextEditingController(text: existingTrivia?.prizeString ?? '');
    DateTime selectedDate = existingTrivia?.date ?? DateTime.now().add(const Duration(days: 1));
    String? localImageUrl = existingTrivia?.imageUrl;
    bool isUploadingImage = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              backgroundColor: const Color(0xFF222222),
              title: Text(isNew ? "Host New Trivia" : "Edit Trivia", style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final file = await ref.read(storageServiceProvider).pickImage(source: ImageSource.gallery);
                        if (file == null) return;
                        setStateBuilder(() => isUploadingImage = true);
                        try {
                          final url = await ref.read(storageServiceProvider).uploadHallImage(File(file.path), widget.venueId, 'trivia');
                          setStateBuilder(() {
                            localImageUrl = url;
                            isUploadingImage = false;
                          });
                        } catch (e) {
                          setStateBuilder(() => isUploadingImage = false);
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                          image: localImageUrl != null ? DecorationImage(image: NetworkImage(localImageUrl!), fit: BoxFit.cover) : null,
                        ),
                        child: isUploadingImage
                            ? const Center(child: CircularProgressIndicator())
                            : localImageUrl == null
                                ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                    Icon(Icons.add_a_photo, color: Colors.white54, size: 36),
                                    SizedBox(height: 8),
                                    Text("Upload Poster", style: TextStyle(color: Colors.white54)),
                                  ]))
                                : const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.edit, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                    ),
                                  ),
                      ),
                    ),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Event Title", labelStyle: TextStyle(color: Colors.white54)),
                    ),
                    TextField(
                      controller: catCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Theme / Category", labelStyle: TextStyle(color: Colors.white54)),
                    ),
                    TextField(
                      controller: prizeCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: "Prize (e.g. \$50 Bar Tab)", labelStyle: TextStyle(color: Colors.white54)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMM dd, h:mm a').format(selectedDate), style: const TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              if (!ctx.mounted) return;
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              );
                              if (time != null) {
                                setStateBuilder(() {
                                  selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                                });
                              }
                            }
                          },
                          child: const Text("Set Time"),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) return;
                    final trivia = TriviaModel(
                      id: isNew ? const Uuid().v4() : existingTrivia.id,
                      venueId: widget.venueId,
                      title: titleCtrl.text.trim(),
                      category: catCtrl.text.trim(),
                      prizeString: prizeCtrl.text.trim(),
                      imageUrl: localImageUrl,
                      date: selectedDate,
                      isActive: existingTrivia?.isActive ?? true,
                      createdAt: existingTrivia?.createdAt ?? DateTime.now(),
                    );

                    if (isNew) {
                      await ref.read(venueRepositoryProvider).addTrivia(trivia);
                    } else {
                      await ref.read(venueRepositoryProvider).updateTrivia(trivia);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text("SAVE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
    final triviaAsync = ref.watch(hallTriviaProvider(widget.venueId));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text("Manage Trivia"),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOrEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Host Trivia"),
        backgroundColor: Colors.greenAccent,
      ),
      body: triviaAsync.when(
        data: (triviaList) {
          if (triviaList.isEmpty) {
            return const Center(child: Text("No upcoming trivia nights.", style: TextStyle(color: Colors.white54)));
          }

          final sorted = List<TriviaModel>.from(triviaList)..sort((a,b) => a.date.compareTo(b.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final trivia = sorted[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(trivia.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${trivia.category}  •  ${DateFormat('MMM d, h:mm a').format(trivia.date)}\nPrize: ${trivia.prizeString}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: trivia.isActive,
                        activeColor: Colors.greenAccent,
                        onChanged: (val) {
                          ref.read(venueRepositoryProvider).updateTrivia(trivia.copyWith(isActive: val));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showCreateOrEditDialog(trivia),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          ref.read(venueRepositoryProvider).deleteTrivia(trivia.id);
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
