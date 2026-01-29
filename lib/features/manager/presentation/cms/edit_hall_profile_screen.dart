import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../models/bingo_hall_model.dart';

class EditHallProfileScreen extends ConsumerStatefulWidget {
  final String hallId;
  const EditHallProfileScreen({super.key, required this.hallId});

  @override
  ConsumerState<EditHallProfileScreen> createState() => _EditHallProfileScreenState();
}

class _EditHallProfileScreenState extends ConsumerState<EditHallProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl; // We don't have 'description' in model? 
  // Checking Model... we have 'name', 'street', 'city', ...
  // Wait, BingoHallModel might usually have a description. If not, I'll allow editing 'street/city' etc.
  // Assuming basic fields for now.
  late TextEditingController _phoneCtrl;
  late TextEditingController _webCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _zipCtrl;

  bool _isInit = false;
  bool _isSaving = false;
  BingoHallModel? _currentHall;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController(); // Maybe 'about'?
    _phoneCtrl = TextEditingController();
    _webCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _zipCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final hallAsync = ref.watch(hallStreamProvider(widget.hallId));
      hallAsync.whenData((hall) {
        if (hall != null && _currentHall == null) {
          _currentHall = hall;
          _nameCtrl.text = hall.name;
          _phoneCtrl.text = hall.phone ?? '';
          _webCtrl.text = hall.websiteUrl ?? '';
          _streetCtrl.text = hall.street ?? '';
          _cityCtrl.text = hall.city ?? '';
          _zipCtrl.text = hall.zipCode ?? '';
          _descCtrl.text = hall.description ?? ''; 
        }
      });
      _isInit = true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentHall == null) return;
    
    setState(() => _isSaving = true);
    
    try {
      final updatedHall = _currentHall!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        websiteUrl: _webCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        zipCode: _zipCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );

      await ref.read(hallRepositoryProvider).updateHall(updatedHall);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hallAsync = ref.watch(hallStreamProvider(widget.hallId));

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Edit Hall Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton(onPressed: _save, child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
        ],
      ),
      body: hallAsync.when(
        data: (hall) {
          if (hall == null) return const Center(child: Text("Hall not found"));
          // Rely on init state population or force update if drift? 
          // For simple forms, initState population is easier to avoid overwriting user input while typing if stream updates.
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Identity"),
                  _input("Hall Name", _nameCtrl),
                  const SizedBox(height: 16),
                  
                  _sectionHeader("Contact"),
                  _input("Bio / Description", _descCtrl, maxLines: 3),
                  const SizedBox(height: 12),
                  _input("Phone Number", _phoneCtrl),
                  const SizedBox(height: 12),
                  _input("Website", _webCtrl),
                  const SizedBox(height: 16),
                  
                  _sectionHeader("Location"),
                  _input("Street Address", _streetCtrl),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _input("City", _cityCtrl)),
                      const SizedBox(width: 12),
                      SizedBox(width: 100, child: _input("Zip", _zipCtrl)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,__) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (v) => label == "Hall Name" && v!.isEmpty ? "Required" : null,
    );
  }
}
