import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../../services/storage_service.dart';

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
  late TextEditingController _descCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _webCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _zipCtrl;

  bool _isInit = false;
  bool _isSaving = false;
  BingoHallModel? _currentHall;
  
  // Image State
  String? _bannerUrl;
  String? _logoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
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
          _bannerUrl = hall.bannerUrl;
          _logoUrl = hall.logoUrl;
        }
      });
      _isInit = true;
    }
  }

  // --- Image Handling ---
  Future<void> _pickImage(String type) async {
    // Show Modal Sheet: Camera, Gallery, Asset Library
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
              title: const Text('Open Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _uploadFromSource(type, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _uploadFromSource(type, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.amber),
              title: const Text('Asset Library (Past Uploads)', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAssetLibrary(type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFromSource(String type, ImageSource source) async {
     try {
       final file = await ref.read(storageServiceProvider).pickImage(source: source);
       if (file == null) return;
       
       setState(() => _isUploading = true);
       
       // Upload
       final url = await ref.read(storageServiceProvider).uploadHallImage(File(file.path), widget.hallId, type);
       
       // Save to Asset Library
       await ref.read(hallRepositoryProvider).addToAssetLibrary(widget.hallId, url, type);
       
       // Update UI temporarily (until full save)
       setState(() {
         if (type == 'banner') _bannerUrl = url;
         if (type == 'logo') _logoUrl = url;
         _isUploading = false;
       });
       
     } catch (e) {
       setState(() => _isUploading = false);
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
     }
  }

  void _showAssetLibrary(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Select ${type == 'banner' ? 'Banner' : 'Logo'}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Consumer(
                  builder: (_, ref, __) {
                    final assetsAsync = ref.watch(hallRepositoryProvider).getAssetLibrary(widget.hallId, type);
                    return StreamBuilder<List<String>>(
                      stream: assetsAsync, 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                        
                        final images = snapshot.data ?? [];
                        if (images.isEmpty) return const Center(child: Text("No stored images found.", style: TextStyle(color: Colors.white54)));
                        
                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
                          itemCount: images.length,
                          itemBuilder: (ctx, i) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (type == 'banner') _bannerUrl = images[i];
                                  if (type == 'logo') _logoUrl = images[i];
                                });
                                Navigator.pop(ctx);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(images[i], fit: BoxFit.cover),
                              ),
                            );
                          },
                        );
                      }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        logoUrl: _logoUrl,
        bannerUrl: _bannerUrl,
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
    // Force rebuild of UI if async hall loads to populate controllers (in didChangeDep)
    // But we use _currentHall once loaded.
    
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: const Text('Edit Hall Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving || _isUploading)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton(
              onPressed: _save, 
              child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16))
            ),
        ],
      ),
      body: _currentHall == null 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderImageSection(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                ),
              ],
            ),
          ),
    );
  }
  
  Widget _buildHeaderImageSection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomLeft,
      children: [
        // Banner
        GestureDetector(
          onTap: () => _pickImage('banner'),
          child: Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[900],
            child: _bannerUrl != null 
              ? Image.network(_bannerUrl!, fit: BoxFit.cover)
              : const Center(child: Icon(Icons.add_a_photo, color: Colors.white54, size: 40)),
          ),
        ),
        // Logo
        Positioned(
          bottom: -40,
          left: 20,
          child: GestureDetector(
            onTap: () => _pickImage('logo'),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF141414), width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)], // Fixed deprecated
              ),
              child: ClipOval(
                child: _logoUrl != null
                  ? Image.network(_logoUrl!, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.add_a_photo, color: Colors.white54, size: 30)),
              ),
            ),
          ),
        ),
        // Edit Badge (Banner)
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.edit, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text("Edit Banner", style: TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          ),
        )
      ],
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
