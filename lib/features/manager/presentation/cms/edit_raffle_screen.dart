import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../models/raffle_model.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../home/repositories/hall_repository.dart';

class EditRaffleScreen extends ConsumerStatefulWidget {
  final String hallId;
  final RaffleModel? raffle;

  const EditRaffleScreen({super.key, required this.hallId, this.raffle});

  @override
  ConsumerState<EditRaffleScreen> createState() => _EditRaffleScreenState();
}

class _EditRaffleScreenState extends ConsumerState<EditRaffleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imgUrlCtrl;
  late DateTime _endsAt;
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
    _endsAt = widget.raffle?.endsAt ?? DateTime.now().add(const Duration(days: 1));
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
      final raffle = RaffleModel(
        id: widget.raffle?.id ?? '', // ID generated in repo if empty
        hallId: widget.hallId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imgUrlCtrl.text.trim(),
        endsAt: _endsAt,
        maxTickets: 100, // Hardcoded cap for now? Or add field
        soldTickets: widget.raffle?.soldTickets ?? 0,
      );

      final repo = ref.read(hallRepositoryProvider);
      if (widget.raffle == null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(widget.raffle == null ? "Create Raffle" : "Edit Raffle"),
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
              
              // Date Picker
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
                          const Text("Draw Date & Time", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text(TimeUtils.formatDateTime(_endsAt, ref), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Preset
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
