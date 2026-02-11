import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../models/bingo_hall_model.dart';
import '../../../../models/hall_program_model.dart';
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
  late TextEditingController _unitCtrl;
  late TextEditingController _stateCtrl;

  // Operating Hours Logic
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final Map<String, Map<String, TextEditingController>> _hoursCtrls = {};
  
  // Programs Logic
  List<HallProgramModel> _programs = [];

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
    _unitCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    
    // Init Hours Controllers
    for (var day in _days) {
      _hoursCtrls[day] = {
        'open': TextEditingController(),
        'close': TextEditingController(),
      };
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _webCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _unitCtrl.dispose();
    _stateCtrl.dispose();
    for (var day in _days) {
      _hoursCtrls[day]?['open']?.dispose();
      _hoursCtrls[day]?['close']?.dispose();
    }
    super.dispose();
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
          _unitCtrl.text = hall.unitNumber ?? '';
          _stateCtrl.text = hall.state ?? '';
          _descCtrl.text = hall.description ?? ''; 
          _bannerUrl = hall.bannerUrl;
          _logoUrl = hall.logoUrl;
          
          // Populate Hours
          if (hall.operatingHours.isNotEmpty) {
            hall.operatingHours.forEach((day, times) {
               if (_hoursCtrls.containsKey(day)) {
                 _hoursCtrls[day]?['open']?.text = times['open'] ?? '';
                 _hoursCtrls[day]?['close']?.text = times['close'] ?? '';
               }
            });
          }
          
          // Populate Programs
          if (hall.programs.isNotEmpty) {
            _programs = List.from(hall.programs);
          }
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
      double newLat = _currentHall!.latitude;
      double newLng = _currentHall!.longitude;
      String? newState = _currentHall!.state; 
      
      // If user manually edited state, use that.
      if (_stateCtrl.text.trim() != (newState ?? '')) {
         newState = _stateCtrl.text.trim();
      }

      // Check for Address Changes
      final addressChanged = 
        _streetCtrl.text.trim() != (_currentHall!.street ?? '') ||
        _cityCtrl.text.trim() != (_currentHall!.city ?? '') ||
        _zipCtrl.text.trim() != (_currentHall!.zipCode ?? '') ||
        _unitCtrl.text.trim() != (_currentHall!.unitNumber ?? '');

      if (addressChanged) {
        // Attempt Geocoding
        try {
          final fullAddress = "${_streetCtrl.text.trim()} ${_unitCtrl.text.trim()}, ${_cityCtrl.text.trim()}, ${_stateCtrl.text.trim()} ${_zipCtrl.text.trim()}";
          // We can assume USA or append it? "fullAddress, USA"
          
          List<Location> locations = await locationFromAddress(fullAddress);
          if (locations.isNotEmpty) {
            newLat = locations.first.latitude;
            newLng = locations.first.longitude;
            
            // Only update state from Geocoding if the user DIDN'T explicit set one (or left it empty)
            if (_stateCtrl.text.isEmpty) {
              try {
                 List<Placemark> placemarks = await placemarkFromCoordinates(newLat, newLng);
                 if (placemarks.isNotEmpty) {
                   newState = placemarks.first.administrativeArea ?? newState;
                   // Update controller too so user sees it
                   _stateCtrl.text = newState ?? '';
                 }
              } catch (_) {} 
            }
          } else {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Warning: Could not locate address on map.")));
          }
        } catch (e) {
          print("Geocoding error: $e");
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Warning: Address check failed. Map pin may not update.")));
        }
      }

      final Map<String, dynamic> finalHours = {};
      for (var day in _days) {
         final open = _hoursCtrls[day]?['open']?.text.trim() ?? '';
         final close = _hoursCtrls[day]?['close']?.text.trim() ?? '';
         if (open.isNotEmpty) {
           finalHours[day] = {'open': open, 'close': close};
         }
      }

      final updatedHall = _currentHall!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        websiteUrl: _webCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: newState,
        zipCode: _zipCtrl.text.trim(),
        unitNumber: _unitCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        logoUrl: _logoUrl,
        operatingHours: finalHours,
        programs: _programs,
        bannerUrl: _bannerUrl,
        latitude: newLat,
        longitude: newLng,
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
                        // General Info (Includes Contact & Location)
                        _buildSection(
                          title: "General Information",
                          initiallyExpanded: true,
                          children: [
                            _input("Hall Name", _nameCtrl),
                            const SizedBox(height: 12),
                            _input("Bio / Description", _descCtrl, maxLines: 3),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Colors.white24),
                            ),
                            const Text("Contact Details", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 12),
                            _input("Phone Number", _phoneCtrl),
                            const SizedBox(height: 12),
                            _input("Website", _webCtrl),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Divider(color: Colors.white24),
                            ),
                            const Text("Location", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _input("Street Address", _streetCtrl)),
                                const SizedBox(width: 12),
                                SizedBox(width: 100, child: _input("Unit/Suite", _unitCtrl)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(flex: 2, child: _input("City", _cityCtrl)),
                                const SizedBox(width: 8),
                                SizedBox(width: 80, child: _input("State", _stateCtrl)),
                                const SizedBox(width: 8),
                                Expanded(child: _input("Zip", _zipCtrl)),
                              ],
                            ),
                          ],
                        ),

                        // Operating Hours
                        _buildSection(
                          title: "Operating Hours",
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                "If close time is left blank, it will display as 'to CLOSE'. e.g. '5:00 PM to CLOSE'",
                                style: TextStyle(color: Colors.white54, fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                            ),
                            ..._days.map((day) => _buildDayRow(day)).toList(),
                          ],
                        ),

                        // Program Details
                        _buildSection(
                          title: "Program Details",
                          children: [
                            if (_programs.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text("No programs added yet.", style: TextStyle(color: Colors.white54)),
                              )
                            else
                              ..._programs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final program = entry.value;
                                
                                final isOverridden = program.overrideEndTime != null && program.overrideEndTime!.isAfter(DateTime.now());
                                
                                return Card(
                                  color: const Color(0xFF2C2C2C),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: isOverridden, 
                                      activeColor: Colors.greenAccent,
                                      onChanged: (val) async {
                                        if (val == true) {
                                          // Turn ON Override: Ask for End Time
                                          final time = await showTimePicker(
                                            context: context, 
                                            initialTime: const TimeOfDay(hour: 23, minute: 59),
                                            helpText: "Select when this override ends",
                                          );
                                          
                                          if (time != null) {
                                            final now = DateTime.now();
                                            var endDt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
                                            // If time is earlier than now, assume tomorrow? Or just allow it (it will expire immediately)
                                            if (endDt.isBefore(now)) {
                                               endDt = endDt.add(const Duration(days: 1));
                                            }
                                            
                                            setState(() {
                                              _programs[index] = program.copyWith(overrideEndTime: endDt);
                                            });
                                          }
                                        } else {
                                          // Turn OFF Override
                                          setState(() {
                                            _programs[index] = program.copyWith(overrideEndTime: null);
                                          });
                                        }
                                      },
                                    ),
                                    title: Text(program.title, style: TextStyle(color: isOverridden ? Colors.greenAccent : Colors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (isOverridden)
                                          Text(
                                            "Forced Active until ${TimeOfDay.fromDateTime(program.overrideEndTime!).format(context)}",
                                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        Text(
                                          "${program.selectedDays.isEmpty ? 'Manual Only' : program.selectedDays.map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1]).join(', ')} • ${program.pricing.replaceAll('\n', ', ')}", 
                                          style: const TextStyle(color: Colors.white70),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _showAddEditProgramDialog(existing: program, index: index),
                                    ),
                                  ),
                                );
                              }).toList(),

                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showAddEditProgramDialog(),
                                icon: const Icon(Icons.add, color: Colors.blueAccent),
                                label: const Text("Add A Program", style: TextStyle(color: Colors.blueAccent)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blueAccent),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
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

  Widget _buildDayRow(String day) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
             width: 100,
             child: Text(day, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _input("Open", _hoursCtrls[day]!['open']!, isDense: true),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _input("Close", _hoursCtrls[day]!['close']!, isDense: true),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children, bool initiallyExpanded = false}) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(title, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          children: children,
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {int maxLines = 1, bool isDense = false}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        isDense: isDense,
        contentPadding: isDense ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
      validator: (v) => label == "Hall Name" && v!.isEmpty ? "Required" : null,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  void _showAddEditProgramDialog({HallProgramModel? existing, int? index}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final pricingCtrl = TextEditingController(text: existing?.pricing ?? ''); // Per request: Multiline
    final detailsCtrl = TextEditingController(text: existing?.details ?? '');
    
    // Dialog State
    Set<int> selectedDays = (existing?.selectedDays ?? []).toSet();
    // Removed specificDay logic
    // Removed isActive (moved to main list)

    // Timeframe Logic
    TimeOfDay? selectedStartTime;
    TimeOfDay? selectedEndTime;

    // Helper to parse "6:00 PM" back to TimeOfDay
    TimeOfDay? _parseTime(String? timeStr) {
      if (timeStr == null || !timeStr.contains(":")) return null;
      try {
        final parts = timeStr.split(" ");
        final timeParts = parts[0].split(":");
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (parts[1] == "PM" && hour != 12) hour += 12;
        if (parts[1] == "AM" && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      } catch (e) {
        return null;
      }
    }

    if (existing != null) {
      selectedStartTime = _parseTime(existing.startTime);
      selectedEndTime = _parseTime(existing.endTime);
    }
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(existing == null ? "Add Program" : "Edit Program", style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _input("Program Name", titleCtrl, isDense: true),
                  const SizedBox(height: 12),
                  const Text("Pricing", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  _input("Full Pricing Details", pricingCtrl, maxLines: 4, isDense: true),
                  const SizedBox(height: 12),
                  const Text("Details", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  _input("Program Description", detailsCtrl, maxLines: 4, isDense: true),
                  const SizedBox(height: 16),
                  
                  // Day Selector
                  const Text("Select Days", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Leave blank to make this program manual-only (active via override).", style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, // Increased spacing
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].asMap().entries.map((entry) {
                      final index = entry.key; // 0-6
                      final dayNum = index + 1; // 1-7
                      final isSelected = selectedDays.contains(dayNum);
                      
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            if (isSelected) {
                              selectedDays.remove(dayNum);
                            } else {
                              selectedDays.add(dayNum);
                            }
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blueAccent : const Color(0xFF2C2C2C),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blueAccent : Colors.white24,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            entry.value[0], // First letter
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Timeframe
                  const Text("Timeframe (Optional)", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Start Time
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: selectedStartTime ?? const TimeOfDay(hour: 18, minute: 0));
                            if (time != null) {
                              setDialogState(() => selectedStartTime = time);
                            }
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration("Start Time").copyWith(
                              suffixIcon: selectedStartTime != null 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                                    onPressed: () => setDialogState(() => selectedStartTime = null),
                                  )
                                : const Icon(Icons.access_time, color: Colors.white54),
                            ),
                            child: Text(
                              selectedStartTime?.format(context) ?? "Set Start",
                              style: TextStyle(color: selectedStartTime != null ? Colors.white : Colors.white38),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // End Time
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: selectedEndTime ?? const TimeOfDay(hour: 21, minute: 0));
                            if (time != null) {
                              setDialogState(() => selectedEndTime = time);
                            }
                          },
                          child: InputDecorator(
                            decoration: _inputDecoration("End Time").copyWith(
                               suffixIcon: selectedEndTime != null 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                                    onPressed: () => setDialogState(() => selectedEndTime = null),
                                  )
                                : const Icon(Icons.access_time, color: Colors.white54),
                            ),
                            child: Text(
                              selectedEndTime?.format(context) ?? "Set End",
                              style: TextStyle(color: selectedEndTime != null ? Colors.white : Colors.white38),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("CANCEL", style: TextStyle(color: Colors.grey)),
              ),
              if (existing != null)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, "DELETE"),
                  child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
                ),
              TextButton(
                onPressed: () {
                  if (titleCtrl.text.isEmpty) return;
                  
                  final newProgram = HallProgramModel(
                    title: titleCtrl.text.trim(),
                    pricing: pricingCtrl.text.trim(),
                    details: detailsCtrl.text.trim(),
                    selectedDays: selectedDays.toList(),
                    startTime: selectedStartTime?.format(context),
                    endTime: selectedEndTime?.format(context),
                    overrideEndTime: existing?.overrideEndTime, // Preserve existing override
                  );
                  
                  Navigator.pop(ctx, newProgram); // Return the new object
                },
                child: const Text("SAVE", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    ).then((result) {
      if (result != null) {
         setState(() {
           if (result == 'DELETE' && existing != null) {
             _programs.removeAt(index!);
           } else if (result is HallProgramModel) {
             if (existing != null) {
               _programs[index!] = result;
             } else {
               _programs.add(result);
             }
           }
         });
      }
    });
  }
}
