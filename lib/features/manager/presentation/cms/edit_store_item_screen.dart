import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../../../models/store_item_model.dart';
import '../../../store/repositories/store_repository.dart';
import '../../../home/repositories/hall_repository.dart';
import '../widgets/cms_asset_library_modal.dart'; // Reusing Asset Library
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStoreItemScreen extends ConsumerStatefulWidget {
  final String hallId;
  final StoreItemModel? existingItem; // Null = Create Mode

  const EditStoreItemScreen({super.key, required this.hallId, this.existingItem});

  @override
  ConsumerState<EditStoreItemScreen> createState() => _EditStoreItemScreenState();
}

class _EditStoreItemScreenState extends ConsumerState<EditStoreItemScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _costController;
  late TextEditingController _perCustomerLimitController;
  late TextEditingController _dailyLimitController;
  
  String? _imageUrl;
  String _category = 'Merchandise'; // Default
  bool _isActive = true;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingItem?.title ?? '');
    _descController = TextEditingController(text: widget.existingItem?.description ?? '');
    _costController = TextEditingController(text: widget.existingItem?.cost.toString() ?? '');
    _perCustomerLimitController = TextEditingController(text: widget.existingItem?.perCustomerLimit?.toString() ?? '');
    _dailyLimitController = TextEditingController(text: widget.existingItem?.dailyLimit?.toString() ?? '');
    _imageUrl = widget.existingItem?.imageUrl;
    _category = widget.existingItem?.category ?? 'Merchandise';
    _isActive = widget.existingItem?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _costController.dispose();
    _perCustomerLimitController.dispose();
    _dailyLimitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (image != null) {
      setState(() => _isSaving = true); // Show loading
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('halls/${widget.hallId}/store/${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}');
            
        await ref.putFile(File(image.path));
        final url = await ref.getDownloadURL();
        
        setState(() {
          _imageUrl = url;
          _isSaving = false;
        });
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blueAccent),
              title: const Text("Choose from Gallery", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purpleAccent),
              title: const Text("Take Photo", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
             ListTile(
              leading: const Icon(Icons.folder_shared, color: Colors.amberAccent),
              title: const Text("Asset Library", style: TextStyle(color: Colors.white)),
              onTap: () {
                 Navigator.pop(context);
                 showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CmsAssetLibraryModal(
                      hallId: widget.hallId,
                      onAssetSelected: (url) {
                         setState(() => _imageUrl = url);
                         Navigator.pop(context);
                      },
                    ),
                 );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add an image")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final item = StoreItemModel(
        id: widget.existingItem?.id ?? const Uuid().v4(),
        hallId: widget.hallId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        cost: int.parse(_costController.text.trim()),
        imageUrl: _imageUrl!,
        category: _category,
        isActive: _isActive,
        perCustomerLimit: int.tryParse(_perCustomerLimitController.text.trim()),
        dailyLimit: int.tryParse(_dailyLimitController.text.trim()),
        createdAt: widget.existingItem?.createdAt ?? DateTime.now(),
      );

      final repo = ref.read(storeRepositoryProvider);
      if (widget.existingItem == null) {
        await repo.createStoreItem(item);
      } else {
        await repo.updateStoreItem(item);
      }

      if (mounted) Navigator.pop(context);
      
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      setState(() => _isSaving = false);
    }
  }

  void _showNewCategoryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("New Category", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter category name",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final newCat = controller.text.trim();
              if (newCat.isNotEmpty) {
                 // Atomic update
                 await FirebaseFirestore.instance.collection('bingo_halls').doc(widget.hallId).update({
                   'storeCategories': FieldValue.arrayUnion([newCat])
                 });
                 setState(() => _category = newCat);
                 if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hallAsync = ref.watch(hallStreamProvider(widget.hallId));
    final categoriesList = hallAsync.value?.storeCategories ?? ['Merchandise', 'Food & Beverage', 'Sessions', 'Pull Tabs', 'Electronics', 'Other'];
    
    if (!categoriesList.contains(_category)) {
       // Ensure current _category is valid if it was deleted or changed
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) setState(() => _category = categoriesList.first);
       });
    }
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(widget.existingItem == null ? "New Store Item" : "Edit Item"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator())),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 48),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(16),
                    image: _imageUrl != null
                        ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                        : null,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _imageUrl == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.white54, size: 48),
                            SizedBox(height: 8),
                            Text("Add Item Photo", style: TextStyle(color: Colors.white54)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Item Name",
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Cost
              TextFormField(
                controller: _costController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Point Cost",
                  suffixText: "PTS",
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty || int.tryParse(v) == null ? "Enter a valid number" : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description / Details",
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),

              // Category Dropdown with Add Custom Button
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Category",
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: categoriesList.contains(_category) ? _category : null,
                          dropdownColor: const Color(0xFF1E1E1E),
                          style: const TextStyle(color: Colors.white),
                          isExpanded: true,
                          isDense: true,
                          items: categoriesList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.blueAccent),
                      tooltip: "Create Custom Category",
                      onPressed: _showNewCategoryDialog,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Limits Section
              Row(
                children: [
                   Expanded(
                     child: TextFormField(
                        controller: _perCustomerLimitController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Person Limit",
                          hintText: "No Limit",
                          labelStyle: const TextStyle(color: Colors.white54),
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: TextFormField(
                        controller: _dailyLimitController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Daily Total",
                          hintText: "No Limit",
                          labelStyle: const TextStyle(color: Colors.white54),
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                     ),
                   ),
                ],
              ),

              const SizedBox(height: 24),

              // Active Toggle
              SwitchListTile(
                title: const Text("Active / Published", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Item will be visible in the store", style: TextStyle(color: Colors.white54, fontSize: 12)),
                value: _isActive,
                activeThumbColor: Colors.greenAccent,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("SAVE ITEM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              
              if (widget.existingItem != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                     final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: const Color(0xFF2C2C2C),
                          title: const Text("Delete Item?", style: TextStyle(color: Colors.white)),
                          content: const Text("This cannot be undone.", style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                          ],
                        ),
                     );
                     
                     if (confirm == true) {
                        await ref.read(storeRepositoryProvider).deleteStoreItem(widget.hallId, widget.existingItem!.id);
                        if (context.mounted) Navigator.pop(context);
                     }
                  }, 
                  icon: const Icon(Icons.delete, color: Colors.red), 
                  label: const Text("Delete Item", style: TextStyle(color: Colors.red))
                ),
              ],
              const SizedBox(height: 48), // Prevent bottom clipping
            ],
          ),
        ),
      ),
      ),
    );
  }
}
