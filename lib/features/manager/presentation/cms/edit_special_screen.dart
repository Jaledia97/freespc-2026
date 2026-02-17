import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../models/special_model.dart';
import '../../../../services/storage_service.dart';

class EditSpecialScreen extends ConsumerStatefulWidget {
  final String hallId;
  final SpecialModel? special; // If null, create mode
  final bool createTemplateMode; // Default false

  const EditSpecialScreen({super.key, required this.hallId, this.special, this.createTemplateMode = false});

  @override
  ConsumerState<EditSpecialScreen> createState() => _EditSpecialScreenState();
}

class _EditSpecialScreenState extends ConsumerState<EditSpecialScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _tagCtrl;
  
  String? _imageUrl;
  bool _isUploading = false;
  
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime? _endTime; // Optional End Time
  bool _hasEndTime = false;

  List<String> _selectedTags = ['Specials'];
  String _recurrence = 'none'; // none, daily, weekly, monthly
  // bool _isTemplate = false; // Removed unused field
  
  // Notification Logic
  bool _sendNotification = false;
  bool _isSaving = false;



  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.special?.title ?? '');
    _descCtrl = TextEditingController(text: widget.special?.description ?? '');
    _tagCtrl = TextEditingController();
    _imageUrl = widget.special?.imageUrl;
    
    // If creating new, _imageUrl starts null. We can't synchronously set default from async stream.
    // User can just pick one.

    if (widget.special != null) {
      _startTime = widget.special!.startTime ?? DateTime.now();
      _endTime = widget.special!.endTime;
      _hasEndTime = _endTime != null;
      _selectedTags = List.from(widget.special!.tags);
      _recurrence = widget.special?.recurrence ?? 'none';
      // _isTemplate = widget.special?.isTemplate ?? false; // Removed unused
    } else {
      // New Creation
      // _isTemplate = widget.createTemplateMode; // Removed unused
    }
  }

  String _formatDateTime(DateTime dt) {
     return "${dt.month}/${dt.day}/${dt.year}  ${TimeOfDay.fromDateTime(dt).format(context)}";
  }

  // --- Image Handling ---
  Future<void> _pickImage() async {
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
                _uploadFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _uploadFromSource(ImageSource.camera);
              },
            ),
             ListTile(
              leading: const Icon(Icons.history, color: Colors.amber),
              title: const Text('Asset Library', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showAssetLibrary();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFromSource(ImageSource source) async {
     try {
       final file = await ref.read(storageServiceProvider).pickImage(source: source);
       if (file == null) return;
       
       setState(() => _isUploading = true);
       
       // Upload (Using 'special' type)
       final url = await ref.read(storageServiceProvider).uploadHallImage(File(file.path), widget.hallId, 'special');
       
       // Save to Asset Library for reuse
       await ref.read(hallRepositoryProvider).addToAssetLibrary(widget.hallId, url, 'special');
       
       setState(() {
         _imageUrl = url;
         _isUploading = false;
       });
       
     } catch (e) {
       setState(() => _isUploading = false);
       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
     }
  }
  
  void _showAssetLibrary() {
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Select from Library", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Consumer(
                  builder: (_, ref, child) {
                    // Use historic images instead of empty asset library
                    final assetsStream = ref.watch(hallRepositoryProvider).getRecentSpecialImages(widget.hallId);
                    return StreamBuilder<List<String>>(
                      stream: assetsStream, 
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                        
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
                                setState(() => _imageUrl = images[i]);
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

  // --- Tag Handling ---
  void _addTag() {
    final text = _tagCtrl.text.trim();
    if (text.isNotEmpty && !_selectedTags.contains(text)) {
      setState(() {
        _selectedTags.add(text);
        _tagCtrl.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }
  
  // --- Notification Warning ---
  Future<void> _handleNotificationToggle(bool? value) async {
    if (value == true) {
      // Show Warning
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF222222),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text("Notification Warning", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "Sending push notifications too frequently leads to 'Notification Fatigue' and users turning off specific app permissions.\n\nOnly send notifications for major, time-sensitive events.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), 
              child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true), 
              child: const Text("I UNDERSTAND", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      
      setState(() {
        _sendNotification = proceed ?? false;
      });
    } else {
      setState(() {
        _sendNotification = false;
      });
    }
  }

  void _showPublishOptions() {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image.')));
       return;
    }

    // Determine Context
    final isNew = widget.special == null || widget.special!.id.isEmpty;
    final isEditingTemplate = !isNew && (widget.special?.isTemplate ?? false);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Publish Options", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            // OPTION 1: Post Live (Not available if strictly creating a template)
            if (!widget.createTemplateMode)
            ListTile(
              leading: const Icon(Icons.send, color: Colors.greenAccent),
              title: Text(isEditingTemplate ? "Post Live (Copy)" : "Post Live", style: const TextStyle(color: Colors.white)),
              subtitle: const Text("Visible to everyone immediately.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _save(isTemplate: false, createCopy: isEditingTemplate); 
              },
            ),

            // OPTION 2: Save as Template (Always available for new, or maintenance)
            if (isNew || isEditingTemplate || widget.createTemplateMode)
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.blueAccent),
              title: Text(isEditingTemplate ? "Save Changes" : "Save as Template", style: const TextStyle(color: Colors.white)),
              subtitle: const Text("Save for future use. Hidden from feed.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _save(isTemplate: true, createCopy: false);
              },
            ),

            // OPTION 3: Post AND Save Template (Only for new specials)
            if (isNew && !widget.createTemplateMode)
            ListTile(
              leading: const Icon(Icons.library_add_check, color: Colors.amber),
              title: const Text("Post to Feed & Save Logic", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Goes live AND saves a template copy.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _save(isTemplate: false, createCopy: false, alsoSaveTemplate: true);
              },
            ),
             
            // Editing Live Special
            if (!isNew && !isEditingTemplate)
             ListTile(
              leading: const Icon(Icons.save, color: Colors.blueAccent),
              title: const Text("Save Changes", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _save(isTemplate: false, createCopy: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save({required bool isTemplate, required bool createCopy, bool alsoSaveTemplate = false}) async {
    setState(() => _isSaving = true);

    try {
      // Midnight Rule: If no end time, default to 11:59:59 PM of the start date
      final DateTime endTime = _hasEndTime 
          ? _endTime! 
          : DateTime(_startTime.year, _startTime.month, _startTime.day, 23, 59, 59);

      final baseSpecial = SpecialModel(
        id: createCopy ? '' : (widget.special?.id ?? ''), 
        hallId: widget.hallId,
        hallName: '', 
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imageUrl!,
        postedAt: DateTime.now(), // Always fresh post time if new/copy
        startTime: _startTime,
        endTime: endTime,
        tags: _selectedTags,
        recurrence: _recurrence,
        isTemplate: isTemplate,
      );

      // 1. Main Action
      if (baseSpecial.id.isEmpty) {
        // Create
        await ref.read(hallRepositoryProvider).addSpecial(baseSpecial, sendNotification: _sendNotification && !isTemplate);
      } else {
        // Update
        // Preserve postedAt if updating
        final updated = baseSpecial.copyWith(postedAt: widget.special?.postedAt ?? DateTime.now());
        await ref.read(hallRepositoryProvider).updateSpecial(updated, sendNotification: false);
      }

      // 2. Dual Creation (Post & Save Template)
      if (alsoSaveTemplate) {
        final templateCopy = baseSpecial.copyWith(id: '', isTemplate: true);
        await ref.read(hallRepositoryProvider).addSpecial(templateCopy, sendNotification: false);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDateTime({bool isEnd = false}) async {
    final initial = isEnd ? (_endTime ?? DateTime.now().add(const Duration(hours: 3))) : _startTime;
    
    final date = await showDatePicker(
      context: context, 
      initialDate: initial, 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030), // Allow planning far ahead
    );
    if (date == null) return;
    
    if (!mounted) return;

    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.fromDateTime(initial)
    );
    if (time == null) return;

    setState(() {
      final newDt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (isEnd) {
        _endTime = newDt;
      } else {
        _startTime = newDt;
        // Auto-adjust end time if it's before start time
        if (_hasEndTime && _endTime != null && _endTime!.isBefore(_startTime)) {
            _endTime = _startTime.add(const Duration(hours: 2));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(widget.special == null || widget.special!.id.isEmpty ? 'New Special' : 'Edit Special'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving || _isUploading) 
            const Center(child: Padding(padding: EdgeInsets.only(right: 16), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
          else
            TextButton(
              onPressed: _showPublishOptions, 
              child: const Text("PUBLISH", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
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
               // Image Section
              _label("Event Image"),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    image: _imageUrl != null 
                        ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                        : null,
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: _imageUrl == null 
                      ? const Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.white54, size: 40),
                            SizedBox(height: 8),
                            Text("Upload Photo", style: TextStyle(color: Colors.white54)),
                          ],
                        ))
                      : Container(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              // Presets
              // Dynamic Quick Select (Most Recent)
              Consumer(
                builder: (context, ref, child) {
                  // Use historic images for quick select
                  final assetsStream = ref.watch(hallRepositoryProvider).getRecentSpecialImages(widget.hallId);
                  return StreamBuilder<List<String>>(
                    stream: assetsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
                      }
                      
                      final images = snapshot.data ?? [];
                      if (images.isEmpty) return const SizedBox.shrink();

                      // Take top 4
                      final recent = images.take(4).toList();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Quick Select (Recent): ", style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: recent.map((url) => GestureDetector(
                              onTap: () => setState(() => _imageUrl = url),
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 50, 
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _imageUrl == url ? Colors.green : Colors.transparent, width: 2),
                                  image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
              const SizedBox(height: 24),

              // Title
              _input("Title", _titleCtrl, hint: 'e.g. \$5 Burger Basket'),
              const SizedBox(height: 16),
              
              // Description
              _input("Description", _descCtrl, maxLines: 3, hint: 'e.g. Served with fries...'),
              const SizedBox(height: 24),
              
              // Date Time Picker
              _label("Date & Time"),
              const SizedBox(height: 8),
              
              // Start Time Field (Button behavior, TextField look)
              InkWell(
                onTap: () => _pickDateTime(isEnd: false),
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: _inputDec('Start Time', null).copyWith(
                    suffixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  ),
                  child: Text(
                    _formatDateTime(_startTime),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // End Time Checkbox
              CheckboxListTile(
                 contentPadding: EdgeInsets.zero,
                 title: const Text("Add End Time?", style: TextStyle(color: Colors.white)),
                 value: _hasEndTime,
                 checkColor: Colors.black,
                 activeColor: Colors.blueAccent,
                 onChanged: (val) {
                   setState(() {
                     _hasEndTime = val ?? false;
                     if (_hasEndTime && _endTime == null) {
                       _endTime = _startTime.add(const Duration(hours: 2));
                     }
                   });
                 },
              ),

              if (_hasEndTime)
                 Padding(
                   padding: const EdgeInsets.only(top: 8),
                   child: InkWell(
                    onTap: () => _pickDateTime(isEnd: true),
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: _inputDec('End Time', null).copyWith(
                        suffixIcon: const Icon(Icons.access_time, color: Colors.amber),
                      ),
                      child: Text(
                        _endTime != null ? _formatDateTime(_endTime!) : '',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                   ),
                 ),
              
              const SizedBox(height: 24),

              // Recurrence Dropdown
              _label("Recurrence"),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_recurrence), // Ensure updates when state changes
                  initialValue: _recurrence,
                  decoration: const InputDecoration(border: InputBorder.none),
                  dropdownColor: const Color(0xFF1E1E1E),
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.blueAccent,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text("Don't Repeat")),
                    DropdownMenuItem(value: 'daily', child: Text("Every Day")),
                    DropdownMenuItem(value: 'weekly', child: Text("Every Week")),
                    DropdownMenuItem(value: 'monthly', child: Text("Every Month")),
                  ], 
                  onChanged: (val) {
                    if (val != null) setState(() => _recurrence = val);
                  }
                ),
              ),

              const SizedBox(height: 24),
              
              // Push Notification Checkbox
              Container(
                 decoration: BoxDecoration(
                   color: _sendNotification ? Colors.amber.withValues(alpha: 0.1) : Colors.transparent,
                   borderRadius: BorderRadius.circular(8),
                   border: _sendNotification ? Border.all(color: Colors.amber.withValues(alpha: 0.5)) : null,
                 ),
                 child: CheckboxListTile(
                    title: const Text("Send Push Notification?", style: TextStyle(color: Colors.white)),
                    subtitle: _sendNotification 
                       ? const Text("Warning: Only use for major events.", style: TextStyle(color: Colors.amber, fontSize: 12))
                       : const Text("Notify nearby users about this special.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    value: _sendNotification,
                    checkColor: Colors.black,
                    activeColor: Colors.amber, 
                    onChanged: _handleNotificationToggle,
                    secondary: Icon(Icons.notifications_active, color: _sendNotification ? Colors.amber : Colors.white54),
                 ),
              ),

              const SizedBox(height: 24),
              
              // Template Checkbox REMOVED (Handled by Publish Dialog)
              /*
              Container(
                 decoration: BoxDecoration(
                   color: _isTemplate ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                   borderRadius: BorderRadius.circular(8),
                   border: _isTemplate ? Border.all(color: Colors.blue.withValues(alpha: 0.5)) : null,
                 ),
                 child: CheckboxListTile(
                    title: const Text("Save as Template?", style: TextStyle(color: Colors.white)),
                    subtitle: const Text("Templates are saved for future use.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                    value: _isTemplate,
                    checkColor: Colors.black,
                    activeColor: Colors.blueAccent,
                    onChanged: (val) {
                      setState(() => _isTemplate = val ?? false);
                    },
                    secondary: Icon(Icons.copy, color: _isTemplate ? Colors.blueAccent : Colors.white54),
                 ),
              ),
              const SizedBox(height: 24),
              */

              // Tags
              _label("Tags"),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _input("Add Tag", _tagCtrl, hint: "e.g. Bingo, Food"),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _addTag, 
                    icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 32)
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedTags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                  deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white54),
                  onDeleted: () => _removeTag(tag),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, String? hint) {
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

  Widget _input(String label, TextEditingController ctrl, {int maxLines = 1, String? hint}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (v) => label == "Title" && v!.isEmpty ? "Required" : null,
      onFieldSubmitted: (v) {
        if (label == "Add Tag") _addTag();
      },
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold));
  }
}
