import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../models/tournament_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../models/special_model.dart'; // For RecurrenceRule
import '../../repositories/tournament_repository.dart';

class EditTournamentScreen extends ConsumerStatefulWidget {
  final String hallId;
  final TournamentModel? tournament;
  final bool createTemplateMode;

  const EditTournamentScreen({
    super.key, 
    required this.hallId, 
    this.tournament, 
    this.createTemplateMode = false
  });

  @override
  ConsumerState<EditTournamentScreen> createState() => _EditTournamentScreenState();
}

class _EditTournamentScreenState extends ConsumerState<EditTournamentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Image State
  File? _imageFile;
  String? _imageUrl; // Existing URL from edit mode

  // Details State
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? _endTime;
  bool _hasEndTime = false;
  RecurrenceRule _recurrenceRule = const RecurrenceRule(frequency: 'none');

  // Games State
  List<TournamentGame> _games = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _titleCtrl = TextEditingController(text: widget.tournament?.title ?? '');
    _descCtrl = TextEditingController(text: widget.tournament?.description ?? '');
    
    if (widget.tournament != null) {
      _startTime = widget.tournament!.startTime ?? DateTime.now();
      _endTime = widget.tournament!.endTime;
      _hasEndTime = _endTime != null;
      _recurrenceRule = widget.tournament!.recurrenceRule ?? const RecurrenceRule(frequency: 'none');
      _games = List.from(widget.tournament!.games);
      _imageUrl = widget.tournament!.imageUrl;
    } else {
      // Default games?
      // _games = [const TournamentGame(id: '1', title: 'Regular Game', value: 100)];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String get _recurrenceText {
    if (_recurrenceRule.frequency == 'none') return "Does not repeat";
    if (_recurrenceRule.frequency == 'daily') return "Daily";
    if (_recurrenceRule.frequency == 'weekly') return "Weekly";
    return "Custom...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(widget.tournament == null ? 'Create Tournament' : 'Edit Tournament'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Details"),
            Tab(text: "Game Setup"),
          ],
        ),
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.greenAccent),
              onPressed: _saveTournament,
            ),
        ],
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildSetupTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Image Picker
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
              image: _imageFile != null
                  ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                  : (_imageUrl != null
                      ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                      : null),
            ),
            child: _imageFile == null && _imageUrl == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 48, color: Colors.white54),
                      SizedBox(height: 8),
                      Text("Add Cover Image", style: TextStyle(color: Colors.white54)),
                    ],
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Title
        TextFormField(
          controller: _titleCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Tournament Title',
            labelStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Color(0xFF1E1E1E),
            border: OutlineInputBorder(),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        
        // Description
        TextFormField(
          controller: _descCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Description',
            labelStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Color(0xFF1E1E1E),
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        // Schedule Section
        const Text("Schedule", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
               // Start Time
               ListTile(
                 contentPadding: EdgeInsets.zero,
                 title: const Text("Start Time", style: TextStyle(color: Colors.white)),
                 trailing: TextButton(
                   onPressed: () => _pickDateTime(isStart: true),
                   child: Text(
                     "${_startTime.month}/${_startTime.day} ${_formatTime(_startTime)}",
                     style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                   ),
                 ),
               ),
               const Divider(color: Colors.white10),
               
               // End Time Toggle
               SwitchListTile(
                 contentPadding: EdgeInsets.zero,
                 activeColor: Colors.blueAccent,
                 title: const Text("Set End Time", style: TextStyle(color: Colors.white)),
                 value: _hasEndTime,
                 onChanged: (val) {
                   setState(() {
                     _hasEndTime = val;
                     if (val && _endTime == null) {
                       _endTime = _startTime.add(const Duration(hours: 4));
                     }
                     if (!val) _endTime = null;
                   });
                 },
               ),
               if (_hasEndTime && _endTime != null)
                 ListTile(
                   contentPadding: EdgeInsets.zero,
                   title: const Text("End Time", style: TextStyle(color: Colors.white)),
                   trailing: TextButton(
                     onPressed: () => _pickDateTime(isStart: false),
                     child: Text(
                       "${_endTime!.month}/${_endTime!.day} ${_formatTime(_endTime!)}",
                       style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                     ),
                   ),
                 ),
               
               const Divider(color: Colors.white10),

               // Recurrence
               ListTile(
                 contentPadding: EdgeInsets.zero,
                 title: const Text("Recurrence", style: TextStyle(color: Colors.white)),
                 subtitle: Text(_recurrenceText, style: const TextStyle(color: Colors.white54)),
                 trailing: Icon(Icons.repeat, color: _recurrenceRule.frequency != 'none' ? Colors.green : Colors.grey),
                 onTap: _showRecurrencePicker, // Minimal implementation for now
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetupTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Games List", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 32),
              onPressed: _showAddGameDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "These games will appear on the scanner menu for workers to select when awarding points.",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 16),

        if (_games.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("No games added yet.\nTap + to add a game.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white24)),
          ))
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _games.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) newIndex -= 1;
                final item = _games.removeAt(oldIndex);
                _games.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final game = _games[index];
              return Card(
                key: ValueKey(game.id), // Key required for ReorderableListView
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.drag_handle, color: Colors.grey),
                  title: Text(game.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("${game.value} Points", style: const TextStyle(color: Colors.amber)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _games.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // --- Logic Helpers ---

  void _pickDateTime({required bool isStart}) async {
    final initial = isStart ? _startTime : (_endTime ?? DateTime.now());
    
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    
    if (date == null) return;

    if (!mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (time == null) return;

    setState(() {
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isStart) {
        _startTime = dt;
        // Adjust end if it's before start
        if (_hasEndTime && (_endTime == null || _endTime!.isBefore(dt))) {
          _endTime = dt.add(const Duration(hours: 4));
        }
      } else {
        _endTime = dt;
      }
    });
  }

  String _formatTime(DateTime dt) {
    // manually format hh:mm a
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$min $ampm";
  }

  void _showRecurrencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text("Does not repeat", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('none')),
          ListTile(title: const Text("Daily", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('daily')),
          ListTile(title: const Text("Weekly", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('weekly')),
          // Custom not implemented fully yet
        ],
      ),
    );
  }

  void _setRecurrence(String freq) {
    setState(() {
      _recurrenceRule = RecurrenceRule(frequency: freq);
    });
    Navigator.pop(context);
  }

  void _showAddGameDialog() {
    final titleCtrl = TextEditingController();
    final valCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text("Add Game", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Game Name (e.g. Early Bird)", labelStyle: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.amber),
              decoration: const InputDecoration(labelText: "Points Value", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                 final val = int.tryParse(valCtrl.text) ?? 0;
                 setState(() {
                   _games.add(TournamentGame(
                     id: const Uuid().v4(), // Use uuid package
                     title: titleCtrl.text,
                     value: val,
                   ));
                 });
                 Navigator.pop(ctx);
              }
            },
            child: const Text("ADD"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String tournamentId) async {
    if (_imageFile == null) return _imageUrl;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('halls/${widget.hallId}/tournaments/$tournamentId/cover.jpg');
      
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _saveTournament() async {
    if (!_formKey.currentState!.validate()) return;
    if (_games.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one game.")));
      _tabController.animateTo(1); // Switch to Setup tab
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tournamentId = widget.tournament?.id.isNotEmpty == true 
          ? widget.tournament!.id 
          : const Uuid().v4(); // Generate ID early for storage path

      // Upload Image
      final imageUrl = await _uploadImage(tournamentId);

      final tournament = TournamentModel(
        id: tournamentId, // Use the ID we generated/retrieved
        hallId: widget.hallId,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        imageUrl: imageUrl, // Save URL
        startTime: _startTime,
        endTime: _endTime,
        recurrenceRule: _recurrenceRule,
        isTemplate: widget.createTemplateMode || (widget.tournament?.isTemplate ?? false),
        games: _games,
      );

      await ref.read(tournamentRepositoryProvider).saveTournament(widget.hallId, tournament);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        print("ERROR SAVING TOURNAMENT: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isSaving = false);
      }
    }
  }
}
