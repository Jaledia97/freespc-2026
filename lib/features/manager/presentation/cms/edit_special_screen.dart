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
  List<String> _selectedTags = ['Specials'];
  // String _recurrence = 'none'; // Deprecated
  RecurrenceRule _recurrenceRule = const RecurrenceRule(frequency: 'none');
  
  // Custom Recurrence State (for UI display)
  String get _recurrenceText {
    if (_recurrenceRule.frequency == 'none') return "Does not repeat";
    if (_recurrenceRule.frequency == 'daily') return "Daily";
    if (_recurrenceRule.frequency == 'weekly' && _recurrenceRule.interval == 1 && _recurrenceRule.daysOfWeek.isEmpty) return "Weekly";
    if (_recurrenceRule.frequency == 'monthly') return "Monthly";
    if (_recurrenceRule.frequency == 'yearly') return "Yearly";
    return "Custom...";
  }

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
      // _recurrence = widget.special?.recurrence ?? 'none';
      if (widget.special?.recurrenceRule != null) {
        _recurrenceRule = widget.special!.recurrenceRule!;
      } else {
         // Legacy migration for edit
         final old = widget.special?.recurrence ?? 'none';
         if (old != 'none') {
           _recurrenceRule = RecurrenceRule(frequency: old == 'weekly' ? 'weekly' : (old == 'monthly' ? 'monthly' : 'daily'));
         }
      }
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
        recurrence: _recurrenceRule.frequency, // Legacy support
        recurrenceRule: _recurrenceRule,
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

  // --- New Date/Time Helpers ---
  Widget _dateTimeField(String label, DateTime dt, {required bool isDate, bool isEnd = false}) {
    return InkWell(
      onTap: () => isDate ? _pickDate(isEnd: isEnd) : _pickTime(isEnd: isEnd),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: _inputDec(label, null),
        child: Text(
          isDate ? "${dt.month}/${dt.day}/${dt.year}" : TimeOfDay.fromDateTime(dt).format(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _pickDate({bool isEnd = false}) async {
    final initial = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
    final date = await showDatePicker(
      context: context, 
      initialDate: initial, 
      firstDate: DateTime(2020), 
      lastDate: DateTime(2030)
    );
    if (date == null) return;
    
    setState(() {
      final old = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
      final newDt = DateTime(date.year, date.month, date.day, old.hour, old.minute);
      if (isEnd) _endTime = newDt;
      else _startTime = newDt;
    });
  }

  Future<void> _pickTime({bool isEnd = false}) async {
    final initial = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return;

    setState(() {
      final old = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
      final newDt = DateTime(old.year, old.month, old.day, time.hour, time.minute);
      if (isEnd) _endTime = newDt;
      else _startTime = newDt;
    });
  }

  // --- Recurrence Helpers ---
  void _showRecurrenceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("Does not repeat", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('none')),
            ListTile(title: const Text("Daily", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('daily')),
            ListTile(title: const Text("Weekly", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('weekly')),
            ListTile(title: const Text("Monthly", style: TextStyle(color: Colors.white)), onTap: () => _setRecurrence('monthly')),
            const Divider(),
            ListTile(
              title: const Text("Custom...", style: TextStyle(color: Colors.white)), 
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              onTap: () {
                Navigator.pop(ctx);
                _showCustomRecurrencePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setRecurrence(String frequency) {
    setState(() {
       _recurrenceRule = RecurrenceRule(frequency: frequency, interval: 1);
    });
    Navigator.pop(context);
  }

  void _showCustomRecurrencePicker() {
    // Temp State for Modal
    String freq = _recurrenceRule.frequency == 'none' ? 'weekly' : _recurrenceRule.frequency;
    int interval = _recurrenceRule.interval;
    List<int> days = List.from(_recurrenceRule.daysOfWeek);
    String endCondition = _recurrenceRule.endCondition; // never, date, count
    DateTime? endDate = _recurrenceRule.endDate;
    int? count = _recurrenceRule.occurrenceCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Custom Recurrence", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                // Frequency Row
                Row(
                  children: [
                    const Text("Repeats every", style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        initialValue: interval.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        decoration: _inputDec('', null),
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null && n > 0) setModalState(() => interval = n);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: freq,
                      dropdownColor: const Color(0xFF222222),
                      underline: Container(),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text("day", style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'weekly', child: Text("week", style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'monthly', child: Text("month", style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'yearly', child: Text("year", style: TextStyle(color: Colors.white))),
                      ], 
                      onChanged: (v) => setModalState(() => freq = v!)
                    ),
                  ],
                ),
                
                // Weekday Selector (Only if Weekly)
                if (freq == 'weekly') ...[
                   const SizedBox(height: 24),
                   const Text("Repeats on", style: TextStyle(color: Colors.white, fontSize: 16)),
                   const SizedBox(height: 12),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((e) {
                       final idx = e.key + 1; // 1-based
                       final isSelected = days.contains(idx);
                       return GestureDetector(
                         onTap: () => setModalState(() {
                           if (isSelected) days.remove(idx); else days.add(idx);
                         }),
                         child: CircleAvatar(
                           radius: 20,
                           backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[800],
                           child: Text(e.value, style: TextStyle(color: isSelected ? Colors.white : Colors.white54)),
                         ),
                       );
                     }).toList(),
                   ),
                ],

                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 24),

                // ENDS
                const Text("Ends", style: TextStyle(color: Colors.white, fontSize: 16)),
                RadioListTile<String>(
                  title: const Text("Never", style: TextStyle(color: Colors.white)),
                  value: 'never',
                  groupValue: endCondition,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setModalState(() => endCondition = v!),
                ),
                RadioListTile<String>(
                  title: const Text("On Date", style: TextStyle(color: Colors.white)),
                  value: 'date',
                  groupValue: endCondition,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setModalState(() => endCondition = v!),
                ),
                if (endCondition == 'date')
                   Padding(
                     padding: const EdgeInsets.only(left: 32, bottom: 8),
                     child: InkWell(
                        onTap: () async {
                          final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                          if (d != null) setModalState(() => endDate = d);
                        },
                        child: Text(
                          endDate != null ? "${endDate!.month}/${endDate!.day}/${endDate!.year}" : "Select Date",
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)
                        )
                     ),
                   ),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                    onPressed: () {
                      setState(() {
                        _recurrenceRule = RecurrenceRule(
                          frequency: freq,
                          interval: interval,
                          daysOfWeek: days,
                          endCondition: endCondition,
                          endDate: endDate,
                          occurrenceCount: count,
                        );
                      });
                      Navigator.pop(context);
                    }, 
                    child: const Text("Done", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  String _getRecurrenceSummary() {
    if (_recurrenceRule.frequency == 'none') return '';
    
    final unit = _recurrenceRule.frequency; // daily -> day
    final interval = _recurrenceRule.interval;
    final intervalStr = interval > 1 ? "Every $interval ${unit}s" : "Every $unit"; // rough plural
    
    String days = "";
    if (_recurrenceRule.frequency == 'weekly' && _recurrenceRule.daysOfWeek.isNotEmpty) {
      final map = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat', 7: 'Sun'};
      days = " on ${_recurrenceRule.daysOfWeek.map((d) => map[d]).join(', ')}";
    }

    String end = "";
    if (_recurrenceRule.endCondition == 'date' && _recurrenceRule.endDate != null) {
      end = ", until ${_recurrenceRule.endDate!.month}/${_recurrenceRule.endDate!.day}";
    }

    return "$intervalStr$days$end";
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
              
              // Schedule Section (Collapsible)
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: const Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Text("Schedule & Recurrence", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  initiallyExpanded: true,
                  collapsedIconColor: Colors.white54,
                  iconColor: Colors.blueAccent,
                  children: [
                    // Start Date & Time
                    Row(
                      children: [
                        Expanded(child: _dateTimeField("Start Date", _startTime, isDate: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _dateTimeField("Start Time", _startTime, isDate: false)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // End Date & Time (Optional)
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

                    if (_hasEndTime) ...[
                       const SizedBox(height: 8),
                       Row(
                        children: [
                          Expanded(child: _dateTimeField("End Date", _endTime!, isDate: true, isEnd: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _dateTimeField("End Time", _endTime!, isDate: false, isEnd: true)),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Recurrence Picker
                    InkWell(
                      onTap: _showRecurrenceOptions,
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: _inputDec('Repeats', null).copyWith(
                          prefixIcon: const Icon(Icons.cached, color: Colors.greenAccent),
                          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                        ),
                        child: Text(_recurrenceText, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                    if (_recurrenceRule.frequency != 'none') ...[
                       const SizedBox(height: 8),
                       Text(
                         _getRecurrenceSummary(), 
                         style: const TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)
                       ),
                    ],
                  ],
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
