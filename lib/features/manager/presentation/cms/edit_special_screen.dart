import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../models/special_model.dart';
import '../../../../services/storage_service.dart';
import 'package:freespc/core/constants/default_tags.dart';
import 'package:freespc/core/utils/tag_utils.dart';
import '../../../../core/widgets/glass_container.dart';

class EditSpecialScreen extends ConsumerStatefulWidget {
  final String hallId;
  final SpecialModel? special; // If null, create mode
  final bool createTemplateMode; // Default false

  const EditSpecialScreen({
    super.key,
    required this.hallId,
    this.special,
    this.createTemplateMode = false,
  });

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

  bool _isTemplate = false;
  RecurrenceRule _recurrenceRule = const RecurrenceRule(frequency: 'weekly');

  // Custom Recurrence State (for UI display)
  String get _recurrenceText {
    if (_recurrenceRule.frequency == 'none') return "Does not repeat";
    if (_recurrenceRule.frequency == 'daily') return "Daily";
    if (_recurrenceRule.frequency == 'weekly' &&
        _recurrenceRule.interval == 1 &&
        _recurrenceRule.daysOfWeek.isEmpty)
      return "Weekly";
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
      _isTemplate = widget.special!.isTemplate;
      if (widget.special?.recurrenceRule != null) {
        _recurrenceRule = widget.special!.recurrenceRule!;
      } else {
        // Legacy migration for edit
        final old = widget.special?.recurrence ?? 'none';
        if (old != 'none') {
          _recurrenceRule = RecurrenceRule(
            frequency: old == 'weekly'
                ? 'weekly'
                : (old == 'monthly' ? 'monthly' : 'daily'),
          );
        }
      }
    } else {
      // New Creation
      _isTemplate = widget.createTemplateMode;
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
              leading: const Icon(
                Icons.photo_library,
                color: Colors.blueAccent,
              ),
              title: const Text(
                'Open Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _uploadFromSource(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
              title: const Text(
                'Take Photo',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _uploadFromSource(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.amber),
              title: const Text(
                'Asset Library',
                style: TextStyle(color: Colors.white),
              ),
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
      final file = await ref
          .read(storageServiceProvider)
          .pickImage(source: source);
      if (file == null) return;

      setState(() => _isUploading = true);

      // Upload (Using 'special' type)
      final url = await ref
          .read(storageServiceProvider)
          .uploadHallImage(File(file.path), widget.hallId, 'special');

      // Save to Asset Library for reuse
      await ref
          .read(hallRepositoryProvider)
          .addToAssetLibrary(widget.hallId, url, 'special');

      setState(() {
        _imageUrl = url;
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Upload Error: $e")));
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
                child: Text(
                  "Select from Library",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (_, ref, child) {
                    // Use historic images instead of empty asset library
                    final assetsStream = ref
                        .watch(hallRepositoryProvider)
                        .getRecentSpecialImages(widget.hallId);
                    return StreamBuilder<List<String>>(
                      stream: assetsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        final images = snapshot.data ?? [];
                        if (images.isEmpty)
                          return const Center(
                            child: Text(
                              "No stored images found.",
                              style: TextStyle(color: Colors.white54),
                            ),
                          );

                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: images.length,
                          itemBuilder: (ctx, i) {
                            return GestureDetector(
                              onTap: () {
                                setState(() => _imageUrl = images[i]);
                                Navigator.pop(ctx);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  images[i],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  void _showAddCustomTagDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF222222),
              title: const Text(
                "Create Custom Tag",
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Consumer(
                  builder: (context, ref, child) {
                    final allTagsAsync = ref.watch(allCustomTagsProvider);

                    return allTagsAsync.when(
                      data: (tagsMap) {
                        return Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<String>.empty();
                            }
                            // Filter non-default tags matching input
                            return tagsMap.keys.where(
                              (tag) =>
                                  !DefaultTags.categories.contains(tag) &&
                                  tag.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                            );
                          },
                          onSelected: (String selection) {
                            _tagCtrl.text = selection;
                            _addTag();
                            Navigator.pop(ctx);
                          },
                          fieldViewBuilder:
                              (
                                context,
                                textEditingController,
                                focusNode,
                                onFieldSubmitted,
                              ) {
                                // Assign the external controller to our local one so ADD button still works
                                textEditingController.addListener(() {
                                  _tagCtrl.text = textEditingController.text;
                                });

                                return TextField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "e.g. Halloween",
                                    hintStyle: const TextStyle(
                                      color: Colors.white54,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF1E1E1E),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  autofocus: true,
                                  onSubmitted: (_) {
                                    _addTag();
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                color: const Color(0xFF333333),
                                borderRadius: BorderRadius.circular(8),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: 300,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                          final String option = options
                                              .elementAt(index);
                                          final int count =
                                              tagsMap[option] ?? 0;
                                          final trafficLabel =
                                              TagUtils.getTrafficLabel(count);

                                          return ListTile(
                                            title: Text(
                                              option,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Text(
                                              trafficLabel,
                                              style: const TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 12,
                                              ),
                                            ),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          );
                                        },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => TextField(
                        controller: _tagCtrl,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g. Halloween",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF1E1E1E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        autofocus: true,
                        onSubmitted: (_) {
                          _addTag();
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _tagCtrl.clear();
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    "CANCEL",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_tagCtrl.text.isNotEmpty) {
                      _addTag();
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text(
                    "ADD",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
              Text(
                "Notification Warning",
                style: TextStyle(color: Colors.white),
              ),
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
              child: const Text(
                "I UNDERSTAND",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      // Midnight Rule: If no end time, default to 11:59:59 PM of the start date
      final DateTime endTime = _hasEndTime
          ? _endTime!
          : DateTime(
              _startTime.year,
              _startTime.month,
              _startTime.day,
              23,
              59,
              59,
            );

      final baseSpecial = SpecialModel(
        id: widget.special?.id ?? '',
        hallId: widget.hallId,
        hallName: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        imageUrl: _imageUrl!,
        postedAt: DateTime.now(), // Always fresh post time if new/copy
        startTime: _startTime,
        endTime: endTime,
        tags: _selectedTags,
        recurrence: _isTemplate
            ? _recurrenceRule.frequency
            : 'none', // Legacy support
        recurrenceRule: _isTemplate
            ? _recurrenceRule
            : const RecurrenceRule(frequency: 'none'),
        isTemplate: _isTemplate,
      );

      // 1. Main Action
      if (baseSpecial.id.isEmpty) {
        // Create
        await ref
            .read(hallRepositoryProvider)
            .addSpecial(
              baseSpecial,
              sendNotification: _sendNotification && !_isTemplate,
            );
      } else {
        // Update
        // Preserve postedAt if updating
        final updated = baseSpecial.copyWith(
          postedAt: widget.special?.postedAt ?? DateTime.now(),
        );
        await ref
            .read(hallRepositoryProvider)
            .updateSpecial(updated, sendNotification: false);
      }

      // Dual Creation logic removed; handled by single toggle & cloud triggers.

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- New Date/Time Helpers ---
  Widget _dateTimeField(
    String label,
    DateTime dt, {
    required bool isDate,
    bool isEnd = false,
  }) {
    return InkWell(
      onTap: () => isDate ? _pickDate(isEnd: isEnd) : _pickTime(isEnd: isEnd),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: _inputDec(label, null),
        child: Text(
          isDate
              ? "${dt.month}/${dt.day}/${dt.year}"
              : TimeOfDay.fromDateTime(dt).format(context),
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
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    setState(() {
      final old = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
      final newDt = DateTime(
        date.year,
        date.month,
        date.day,
        old.hour,
        old.minute,
      );
      if (isEnd) {
        _endTime = newDt;
      } else {
        _startTime = newDt;
      }
    });
  }

  Future<void> _pickTime({bool isEnd = false}) async {
    final initial = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    setState(() {
      final old = isEnd ? (_endTime ?? DateTime.now()) : _startTime;
      final newDt = DateTime(
        old.year,
        old.month,
        old.day,
        time.hour,
        time.minute,
      );
      if (isEnd) {
        _endTime = newDt;
      } else {
        _startTime = newDt;
      }
    });
  }

  String _getHumanReadableRecurrence() {
    if (_recurrenceRule.frequency == 'none') return "Does not repeat";
    final sf = _recurrenceRule.frequency == 'daily'
        ? 'day'
        : _recurrenceRule.frequency.replaceAll('ly', '');
    final freqStr = _recurrenceRule.interval > 1
        ? "every ${_recurrenceRule.interval} ${sf}s"
        : "every $sf";
    String daysStr = "";
    if (_recurrenceRule.frequency == 'weekly' &&
        _recurrenceRule.daysOfWeek.isNotEmpty) {
      final map = {
        1: 'Mon',
        2: 'Tue',
        3: 'Wed',
        4: 'Thu',
        5: 'Fri',
        6: 'Sat',
        7: 'Sun',
      };
      daysStr =
          " on ${_recurrenceRule.daysOfWeek.map((e) => map[e]).join(', ')}";
    }
    String endStr = " forever";
    if (_recurrenceRule.endCondition == 'date' &&
        _recurrenceRule.endDate != null) {
      endStr =
          " until ${_recurrenceRule.endDate!.month}/${_recurrenceRule.endDate!.day}/${_recurrenceRule.endDate!.year}";
    } else if (_recurrenceRule.endCondition == 'count' &&
        _recurrenceRule.occurrenceCount != null) {
      endStr = " for ${_recurrenceRule.occurrenceCount} occurrences";
    }
    return "Auto-publishes $freqStr$daysStr$endStr.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        title: Text(
          widget.special == null || widget.special!.id.isEmpty
              ? 'New Special'
              : 'Edit Special',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving || _isUploading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                if (_imageUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select an image.')),
                  );
                  return;
                }
                _save();
              },
              child: const Text(
                "PUBLISH",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                        ? DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: _imageUrl == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                color: Colors.white54,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Upload Photo",
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
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
                  final assetsStream = ref
                      .watch(hallRepositoryProvider)
                      .getRecentSpecialImages(widget.hallId);
                  return StreamBuilder<List<String>>(
                    stream: assetsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final images = snapshot.data ?? [];
                      if (images.isEmpty) return const SizedBox.shrink();

                      // Take top 4
                      final recent = images.take(4).toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Quick Select (Recent): ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: recent
                                .map(
                                  (url) => GestureDetector(
                                    onTap: () =>
                                        setState(() => _imageUrl = url),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 12),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _imageUrl == url
                                              ? Colors.green
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(url),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Title
              _input("Title", _titleCtrl, hint: 'e.g. \$5 Burger Basket'),
              const SizedBox(height: 16),

              // Description
              _input(
                "Description",
                _descCtrl,
                maxLines: 3,
                hint: 'e.g. Served with fries...',
              ),
              const SizedBox(height: 24),

              // Schedule Section (Collapsible)
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: const Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.blueAccent),
                      SizedBox(width: 12),
                      Text(
                        "Schedule & Recurrence",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.all(16),
                  initiallyExpanded: false,
                  collapsedIconColor: Colors.white54,
                  iconColor: Colors.blueAccent,
                  children: [
                    // Start Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: _dateTimeField(
                            "Start Date",
                            _startTime,
                            isDate: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateTimeField(
                            "Start Time",
                            _startTime,
                            isDate: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // End Date & Time (Optional)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Add Event End Time?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        "Use this if the event crosses midnight or spans multiple days. To stop a weekly special on a certain date, use Custom Recurrence instead.",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
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
                          Expanded(
                            child: _dateTimeField(
                              "End Date",
                              _endTime!,
                              isDate: true,
                              isEnd: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _dateTimeField(
                              "End Time",
                              _endTime!,
                              isDate: false,
                              isEnd: true,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),

                    // Recurrence Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: Colors.blueAccent,
                      title: const Text(
                        "Set as Recurring Template",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "Auto-generates events instead of publishing directly.",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: _isTemplate,
                      onChanged: (val) {
                        setState(() => _isTemplate = val);
                      },
                    ),
                    if (_isTemplate) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Frequency",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value:
                                        [
                                          'daily',
                                          'weekly',
                                          'monthly',
                                          'yearly',
                                        ].contains(_recurrenceRule.frequency)
                                        ? _recurrenceRule.frequency
                                        : 'weekly',
                                    dropdownColor: const Color(0xFF222222),
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'daily',
                                        child: Text("Daily"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'weekly',
                                        child: Text("Weekly"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'monthly',
                                        child: Text("Monthly"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'yearly',
                                        child: Text("Yearly"),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null)
                                        setState(
                                          () =>
                                              _recurrenceRule = _recurrenceRule
                                                  .copyWith(frequency: v),
                                        );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    "Repeat every ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: TextFormField(
                                      initialValue: _recurrenceRule.interval
                                          .toString(),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(8),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) {
                                        final i = int.tryParse(val);
                                        if (i != null && i > 0) {
                                          setState(
                                            () => _recurrenceRule =
                                                _recurrenceRule.copyWith(
                                                  interval: i,
                                                ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      "${_recurrenceRule.frequency.replaceAll('ly', 'ie')}s",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_recurrenceRule.frequency == 'weekly') ...[
                                const SizedBox(height: 16),
                                const Text(
                                  "Repeat on:",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(7, (idx) {
                                    final orderToLabel = [
                                      'S',
                                      'M',
                                      'T',
                                      'W',
                                      'T',
                                      'F',
                                      'S',
                                    ];
                                    final orderToNum = [7, 1, 2, 3, 4, 5, 6];
                                    final dNum = orderToNum[idx];
                                    final isSelected = _recurrenceRule
                                        .daysOfWeek
                                        .contains(dNum);
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          final list = List<int>.from(
                                            _recurrenceRule.daysOfWeek,
                                          );
                                          if (isSelected)
                                            list.remove(dNum);
                                          else
                                            list.add(dNum);
                                          _recurrenceRule = _recurrenceRule
                                              .copyWith(daysOfWeek: list);
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: isSelected
                                            ? Colors.blueAccent
                                            : Colors.white10,
                                        child: Text(
                                          orderToLabel[idx],
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Ends",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: _recurrenceRule.endCondition,
                                    dropdownColor: const Color(0xFF222222),
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                    underline: const SizedBox(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'never',
                                        child: Text("Never"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'date',
                                        child: Text("On Date"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'count',
                                        child: Text("After Occurrences"),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null)
                                        setState(
                                          () =>
                                              _recurrenceRule = _recurrenceRule
                                                  .copyWith(endCondition: v),
                                        );
                                    },
                                  ),
                                ],
                              ),
                              if (_recurrenceRule.endCondition == 'date') ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _recurrenceRule.endDate ??
                                            DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2030),
                                      );
                                      if (d != null)
                                        setState(
                                          () =>
                                              _recurrenceRule = _recurrenceRule
                                                  .copyWith(endDate: d),
                                        );
                                    },
                                    child: Text(
                                      _recurrenceRule.endDate != null
                                          ? "${_recurrenceRule.endDate!.month}/${_recurrenceRule.endDate!.day}/${_recurrenceRule.endDate!.year}"
                                          : "Select Date",
                                    ),
                                  ),
                                ),
                              ],
                              if (_recurrenceRule.endCondition == 'count') ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: TextFormField(
                                        initialValue:
                                            (_recurrenceRule.occurrenceCount ??
                                                    1)
                                                .toString(),
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 8,
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (val) {
                                          final i = int.tryParse(val);
                                          if (i != null && i > 0)
                                            setState(
                                              () => _recurrenceRule =
                                                  _recurrenceRule.copyWith(
                                                    occurrenceCount: i,
                                                  ),
                                            );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "times",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                              ],
                              const Divider(color: Colors.white24, height: 32),
                              Text(
                                "Summary: ${_getHumanReadableRecurrence()}",
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Push Notification Checkbox
              Container(
                decoration: BoxDecoration(
                  color: _sendNotification
                      ? Colors.amber.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: _sendNotification
                      ? Border.all(color: Colors.amber.withValues(alpha: 0.5))
                      : null,
                ),
                child: CheckboxListTile(
                  title: const Text(
                    "Send Push Notification?",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: _sendNotification
                      ? const Text(
                          "Warning: Only use for major events.",
                          style: TextStyle(color: Colors.amber, fontSize: 12),
                        )
                      : const Text(
                          "Notify nearby users about this special.",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                  value: _sendNotification,
                  checkColor: Colors.black,
                  activeColor: Colors.amber,
                  onChanged: _handleNotificationToggle,
                  secondary: Icon(
                    Icons.notifications_active,
                    color: _sendNotification ? Colors.amber : Colors.white54,
                  ),
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
              _label("Categories & Tags"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ...DefaultTags.categories.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: DefaultTags.getColorForTag(tag),
                      backgroundColor: Colors.grey[900],
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                    );
                  }),
                  // Custom Tags currently selected
                  ..._selectedTags
                      .where((t) => !DefaultTags.categories.contains(t))
                      .map((tag) {
                        return FilterChip(
                          label: Text(
                            tag,
                            style: const TextStyle(color: Colors.white),
                          ),
                          selected: true,
                          selectedColor: DefaultTags.getColorForTag(tag),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                          onSelected: (selected) {
                            if (!selected) _removeTag(tag);
                          },
                        );
                      }),
                  // Add Custom ActionChip
                  ActionChip(
                    label: const Icon(
                      Icons.add,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.blueAccent),
                    ),
                    onPressed: _showAddCustomTagDialog,
                  ),
                ],
              ),
              if (widget.special != null &&
                  !widget.special!.isTemplate &&
                  widget.special!.templateId != null) ...[
                const SizedBox(height: 40),
                if (widget.special!.isCancelled)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.greenAccent,
                        side: const BorderSide(color: Colors.greenAccent),
                      ),
                      icon: const Icon(Icons.restore),
                      label: const Text("Restore Occurrence"),
                      onPressed: _restoreOccurrence,
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text("Cancel this Occurrence"),
                      onPressed: _cancelOccurrence,
                    ),
                  ),
              ],
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    String? hint,
  }) {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => label == "Title" && v!.isEmpty ? "Required" : null,
      onFieldSubmitted: (v) {
        if (label == "Add Tag") _addTag();
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _cancelOccurrence() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          "Cancel Occurrence?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This specific event will be removed from the feed. The master template will remain active.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("GO BACK", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "CANCEL EVENT",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final cancelledSpecial = widget.special!.copyWith(isCancelled: true);
      await ref.read(hallRepositoryProvider).updateSpecial(cancelledSpecial);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _restoreOccurrence() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          "Restore Occurrence?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This specific event will be un-cancelled and return to the main feed.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("GO BACK", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "RESTORE EVENT",
              style: TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      final restoredSpecial = widget.special!.copyWith(isCancelled: false);
      await ref.read(hallRepositoryProvider).updateSpecial(restoredSpecial);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() => _isSaving = false);
      }
    }
  }
}
