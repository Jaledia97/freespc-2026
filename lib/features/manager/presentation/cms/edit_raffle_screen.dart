import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../models/raffle_model.dart';
import '../../../../models/special_model.dart'; // For RecurrenceRule
import '../../../../core/utils/time_utils.dart';
import '../../../home/repositories/hall_repository.dart';

class EditRaffleScreen extends ConsumerStatefulWidget {
  final String hallId;
  final RaffleModel? raffle;
  final bool isCreatingFromTemplate;
  final bool isTemplate;
  final bool isEditingTemplate;

  const EditRaffleScreen({
    super.key, 
    required this.hallId, 
    this.raffle,
    this.isCreatingFromTemplate = false,
    this.isTemplate = false,
    this.isEditingTemplate = false,
  });

  @override
  ConsumerState<EditRaffleScreen> createState() => _EditRaffleScreenState();
}

class _EditRaffleScreenState extends ConsumerState<EditRaffleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imgUrlCtrl;
  late DateTime _endsAt;
  
  bool _isTemplate = false;
  RecurrenceRule? _recurrenceRule;
  
  bool _isSaving = false;
  bool _isUploading = false;

  final List<String> _presets = [
    'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80', // Cash
    'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80', // Spa
    'https://images.unsplash.com/photo-1593784991095-a205069470b6?auto=format&fit=crop&w=800&q=80', // TV
    'https://images.unsplash.com/photo-1546552356-3fae876a61ca?auto=format&fit=crop&w=200&q=80', // Ticket
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.raffle?.name ?? '');
    _descCtrl = TextEditingController(text: widget.raffle?.description ?? '');
    _imgUrlCtrl = TextEditingController(text: widget.raffle?.imageUrl ?? _presets[0]);
    
    if (widget.isCreatingFromTemplate) {
      final now = DateTime.now();
      final base = widget.raffle?.endsAt ?? now;
      // Default to tomorrow same time
      _endsAt = DateTime(now.year, now.month, now.day + 1, base.hour, base.minute);
      _isTemplate = false;
      _recurrenceRule = null;
    } else {
      _endsAt = widget.raffle?.endsAt ?? DateTime.now().add(const Duration(days: 1));
      _isTemplate = widget.isTemplate || (widget.raffle?.isTemplate ?? false) || widget.isEditingTemplate;
      _recurrenceRule = widget.raffle?.recurrenceRule;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      setState(() => _isUploading = true);

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('raffles/${widget.hallId}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        _imgUrlCtrl.text = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image Uploaded!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Failed: $e")));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String id = widget.raffle?.id ?? '';
      // Create new ID if:
      // 1. Explicitly creating from template
      // 2. Creating scratch (raffle is null) AND NOT explicitly editing a template
      if (widget.isCreatingFromTemplate || (widget.raffle == null && !widget.isEditingTemplate)) {
        id = ''; // New
      }

      final raffle = RaffleModel(
        id: id,
        hallId: widget.hallId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imgUrlCtrl.text.trim(),
        endsAt: _endsAt,
        maxTickets: widget.raffle?.maxTickets ?? 100,
        soldTickets: widget.isCreatingFromTemplate ? 0 : (widget.raffle?.soldTickets ?? 0),
        isTemplate: _isTemplate,
        recurrenceRule: _isTemplate ? _recurrenceRule : null,
      );

      final repo = ref.read(hallRepositoryProvider);
      if (id.isEmpty) {
        await repo.addRaffle(raffle);
      } else {
        await repo.updateRaffle(raffle);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endsAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endsAt),
    );
    if (time == null) return;

    setState(() {
      _endsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _openRecurrencePicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        String freq = _recurrenceRule?.frequency ?? 'weekly';
        int interval = _recurrenceRule?.interval ?? 1;
        List<int> days = List.from(_recurrenceRule?.daysOfWeek ?? []);
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text("Recurrence (Auto-Schedule)", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: freq,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text("Daily")),
                      DropdownMenuItem(value: 'weekly', child: Text("Weekly")),
                      DropdownMenuItem(value: 'monthly', child: Text("Monthly")),
                    ],
                    onChanged: (val) => setState(() => freq = val!),
                  ),
                  if (freq == 'weekly') ...[
                    const SizedBox(height: 16),
                    const Text("Repeat On:", style: TextStyle(color: Colors.white70)),
                    Wrap(
                      spacing: 4,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final isSelected = days.contains(day);
                        return FilterChip(
                          label: Text(['M','T','W','T','F','S','S'][index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) days.add(day); else days.remove(day);
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx), 
                  child: const Text("Cancel")
                ),
                ElevatedButton(
                  onPressed: () {
                    this.setState(() {
                      _recurrenceRule = RecurrenceRule(
                        frequency: freq,
                        interval: interval,
                        daysOfWeek: days,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCreatingFromTemplate 
        ? "Create from Template" 
        : (_isTemplate ? "Edit Template" : (widget.raffle == null ? "Create Raffle" : "Edit Raffle"));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check, color: Colors.green)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Raffle Name", filled: true, fillColor: Color(0xFF1E1E1E)),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Description", filled: true, fillColor: Color(0xFF1E1E1E)),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              
              if (widget.isCreatingFromTemplate)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: const Row(
                    children: [
                       Icon(Icons.info, color: Colors.blue),
                       SizedBox(width: 8),
                       Expanded(child: Text("Creating a new Active Raffle from this template. Adjust the Draw Date below.", style: TextStyle(color: Colors.blue))),
                    ],
                  ),
                ),

              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white54),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_isTemplate ? "Default Draw Time (Anchor)" : "Draw Date & Time", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          Text(TimeUtils.formatDateTime(_endsAt, ref), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (!widget.isCreatingFromTemplate && !widget.isEditingTemplate) 
                CheckboxListTile(
                  title: const Text("Save as Template", style: TextStyle(color: Colors.white)),
                  value: _isTemplate,
                  onChanged: (v) => setState(() => _isTemplate = v ?? false),
                  activeColor: Colors.amber,
                  contentPadding: EdgeInsets.zero,
                ),

              if (_isTemplate)
                InkWell(
                  onTap: _openRecurrencePicker,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), 
                      border: Border.all(color: Colors.amber.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.loop, color: Colors.amber),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Recurrence (Auto-Schedule)", style: TextStyle(color: Colors.white54, fontSize: 12)),
                            Text(
                              _recurrenceRule == null ? "None" : "${_recurrenceRule!.frequency} - ${_recurrenceRule!.daysOfWeek.isNotEmpty ? 'Days: ${_recurrenceRule!.daysOfWeek}' : ''}",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text("Cover Image", style: TextStyle(color: Colors.white54)),
                   TextButton.icon(
                     onPressed: _pickAndUploadImage,
                     icon: _isUploading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Icon(Icons.photo_library),
                     label: const Text("Pick from Gallery"),
                   ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _presets.length,
                  separatorBuilder: (_,__) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final url = _presets[index];
                    final isSelected = _imgUrlCtrl.text == url;
                    return GestureDetector(
                      onTap: () => setState(() => _imgUrlCtrl.text = url),
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imgUrlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: "Image URL", filled: true, fillColor: Color(0xFF1E1E1E)),
              ),
              
              if (_isSaving) const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
    );
  }
}
