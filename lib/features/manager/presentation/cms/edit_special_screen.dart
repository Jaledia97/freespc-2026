import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../models/special_model.dart';

class EditSpecialScreen extends ConsumerStatefulWidget {
  final String hallId;
  final SpecialModel? special; // If null, create mode

  const EditSpecialScreen({super.key, required this.hallId, this.special});

  @override
  ConsumerState<EditSpecialScreen> createState() => _EditSpecialScreenState();
}

class _EditSpecialScreenState extends ConsumerState<EditSpecialScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _imgUrlCtrl;
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  List<String> _selectedTags = ['Specials'];
  bool _isSaving = false;

  final List<String> _presets = [
    'https://images.unsplash.com/photo-1518133910546-b6c2fb7d79e3?auto=format&fit=crop&w=800&q=80', // Cash
    'https://images.unsplash.com/photo-1563089145-599997674d42?auto=format&fit=crop&w=800&q=80', // Neon
    'https://images.unsplash.com/photo-1596838132731-3301c3fd4317?auto=format&fit=crop&w=800&q=80', // Slots
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.special?.title ?? '');
    _descCtrl = TextEditingController(text: widget.special?.description ?? '');
    _imgUrlCtrl = TextEditingController(text: widget.special?.imageUrl ?? _presets[0]);
    if (widget.special != null) {
      _startTime = widget.special!.startTime ?? DateTime.now();
      _selectedTags = List.from(widget.special!.tags);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final newSpecial = SpecialModel(
        id: widget.special?.id ?? '', // ID handled by repo if empty
        hallId: widget.hallId,
        hallName: '', // Logic in repo/server usually, but we can fetch hall name or ignore for now
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imgUrlCtrl.text.trim(),
        postedAt: widget.special?.postedAt ?? DateTime.now(),
        startTime: _startTime,
        tags: _selectedTags,
        // Lat/Lng should stick to Hall's location if not overridden
      );

      if (widget.special == null) {
        await ref.read(hallRepositoryProvider).addSpecial(newSpecial);
      } else {
        await ref.read(hallRepositoryProvider).updateSpecial(newSpecial);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context, 
      initialDate: _startTime, 
      firstDate: DateTime.now().subtract(const Duration(days: 1)), 
      lastDate: DateTime.now().add(const Duration(days: 365))
    );
    if (date == null) return;
    
    if (!mounted) return;

    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.fromDateTime(_startTime)
    );
    if (time == null) return;

    setState(() {
      _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(widget.special == null ? 'New Special' : 'Edit Special'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving) 
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton(
              onPressed: _save, 
              child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Title', 'e.g. \$5 Burger Basket'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: _inputDec('Description', 'e.g. Served with fries...'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              
              // Date Time Picker
              _label("Start Time"),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blueAccent),
                      const SizedBox(width: 12),
                      Text(
                        "${_startTime.month}/${_startTime.day}/${_startTime.year}  ${TimeOfDay.fromDateTime(_startTime).format(context)}",
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _label("Image URL"),
              TextFormField(
                controller: _imgUrlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDec('Image URL', 'https://...'),
                onChanged: (v) => setState((){}), // Preview update
              ),
              const SizedBox(height: 12),
              
              // Presets
              Row(
                children: _presets.map((url) => GestureDetector(
                  onTap: () => setState(() => _imgUrlCtrl.text = url),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40, 
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _imgUrlCtrl.text == url ? Colors.green : Colors.transparent, width: 2),
                      image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                    ),
                  ),
                )).toList(),
              ),

              const SizedBox(height: 24),
              // Live Preview
              if (_imgUrlCtrl.text.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16/9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imgUrlCtrl.text, 
                      fit: BoxFit.cover,
                      errorBuilder: (_,__,___) => Container(color: Colors.white12, child: const Icon(Icons.broken_image, color: Colors.white24)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold));
  }
}
