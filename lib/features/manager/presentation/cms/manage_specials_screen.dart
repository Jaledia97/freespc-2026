import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/repositories/hall_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../models/special_model.dart';
import 'edit_special_screen.dart';

class ManageSpecialsScreen extends ConsumerStatefulWidget {
  const ManageSpecialsScreen({super.key});

  @override
  ConsumerState<ManageSpecialsScreen> createState() => _ManageSpecialsScreenState();
}

class _ManageSpecialsScreenState extends ConsumerState<ManageSpecialsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Multi-Select State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Clear selection when changing tabs to avoid confusion
    if (_tabController.indexIsChanging) {
      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: Text("Delete $count Items?", style: const TextStyle(color: Colors.white)),
        content: const Text(
          "These specials will be permanently deleted. This action cannot be undone.", 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text("CANCEL", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("DELETE", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );

    if (confirm == true) {
      final idsToDelete = List<String>.from(_selectedIds);
      // Perform deletion
      // Ideally batch this in repo, but for now loop is sufficient for small lists
      for (var id in idsToDelete) {
        await ref.read(hallRepositoryProvider).deleteSpecial(id);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$count items deleted")));
        setState(() {
          _isSelectionMode = false;
          _selectedIds.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null || user.homeBaseId == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF141414),
            body: Center(child: Text("No Hall Assigned to User", style: TextStyle(color: Colors.white))),
          );
        }
        final hallId = user.homeBaseId!;
        final specialsAsync = ref.watch(hallSpecialsProvider(hallId));

        return Scaffold(
          backgroundColor: const Color(0xFF141414),
          appBar: _isSelectionMode 
              ? AppBar(
                  backgroundColor: const Color(0xFF2A2A2A),
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() {
                      _isSelectionMode = false;
                      _selectedIds.clear();
                    }),
                  ),
                  title: Text("${_selectedIds.length} Selected", style: const TextStyle(color: Colors.white)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: _deleteSelected,
                    ),
                  ],
                )
              : AppBar(
                  title: const Text('Manage Specials'),
                  backgroundColor: const Color(0xFF1E1E1E),
                  elevation: 0,
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.blueAccent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Active"),
                      Tab(text: "Expired"),
                      Tab(text: "Templates"),
                    ],
                  ),
                ),
          floatingActionButton: _isSelectionMode 
              ? null // Hide FAB in selection mode
              : FloatingActionButton.extended(
                  onPressed: () {
                     final isTemplateMode = _tabController.index == 2;
                     Navigator.push(context, MaterialPageRoute(builder: (_) => EditSpecialScreen(
                       hallId: hallId,
                       createTemplateMode: isTemplateMode,
                     )));
                  },
                  backgroundColor: _tabController.index == 2 ? Colors.blueAccent : Colors.green,
                  label: Text(_tabController.index == 2 ? "Create Template" : "Create Special"),
                  icon: Icon(_tabController.index == 2 ? Icons.post_add : Icons.add),
                ),
          body: specialsAsync.when(
            data: (specials) {
              // 1. Filter Logic
              final now = DateTime.now();
              
              final active = <SpecialModel>[];
              final expired = <SpecialModel>[];
              final templates = <SpecialModel>[];

              for (var s in specials) {
                if (s.isTemplate) {
                  templates.add(s);
                  continue; 
                }

                // Check Expiry
                bool isExpired = false;
                if (s.recurrence == 'none') {
                   final end = s.endTime ?? s.startTime?.add(const Duration(hours: 4));
                   if (end != null && end.isBefore(now)) {
                     isExpired = true;
                   }
                }
                
                if (isExpired) {
                  expired.add(s);
                } else {
                  active.add(s);
                }
              }

              // Sort
              active.sort((a, b) => (a.startTime ?? now).compareTo(b.startTime ?? now));
              expired.sort((a, b) => (b.startTime ?? now).compareTo(a.startTime ?? now));
              templates.sort((a, b) => a.title.compareTo(b.title));

              return TabBarView(
                controller: _tabController,
                children: [
                   _buildList(active, hallId, "No active specials.", isArchived: false),
                   _buildList(expired, hallId, "No recently expired specials.", isArchived: true),
                   _buildList(templates, hallId, "No templates saved.", isTemplate: true),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
          ),
        );
      },
      loading: () => const Scaffold(backgroundColor: Color(0xFF141414), body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(backgroundColor: const Color(0xFF141414), body: Center(child: Text("Auth Error: $e"))),
    );
  }

  Widget _buildList(List<SpecialModel> items, String hallId, String emptyMsg, {bool isArchived = false, bool isTemplate = false}) {
    if (items.isEmpty) {
      return Center(child: Text(emptyMsg, style: const TextStyle(color: Colors.white54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final special = items[index];
        final isSelected = _selectedIds.contains(special.id);

        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedIds.add(special.id);
              });
            }
          },
          onTap: () {
            if (_isSelectionMode) {
              _toggleSelection(special.id);
            } else {
              // Edit normally, or if template, USE IT
              if (isTemplate) {
                 _createCopy(hallId, special);
              } else {
                 Navigator.push(context, MaterialPageRoute(builder: (_) => EditSpecialScreen(hallId: hallId, special: special)));
              }
            }
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: _isSelectionMode && isSelected 
                ? Colors.blueAccent.withValues(alpha: 0.2) // Highlight selected
                : const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: _isSelectionMode && isSelected 
                  ? const BorderSide(color: Colors.blueAccent, width: 2) 
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Stack(
                children: [
                   Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(special.imageUrl),
                        fit: BoxFit.cover,
                        onError: (_, stackTrace) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  if (_isSelectionMode)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Center(
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.blueAccent : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(special.title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                isTemplate 
                  ? special.description 
                  : "${special.description}\nStart: ${special.startTime != null ? _formatDate(special.startTime!) : 'TBD'}",
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 2,
              ),
              isThreeLine: true,
              trailing: _isSelectionMode 
                  ? null // Hide actions in selection mode to avoid confusion
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       if (isArchived)
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.greenAccent),
                          tooltip: "Use as Copy",
                          onPressed: () {
                             _createCopy(hallId, special);
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => EditSpecialScreen(hallId: hallId, special: special)));
                        },
                      ),
                    ],
                  ),
            ),
          ),
        );
      },
    );
  }

  void _createCopy(String hallId, SpecialModel original) {
    final copy = original.copyWith(
      id: '', // Empty ID signals "New"
      title: original.isTemplate ? original.title : "Copy of ${original.title}", // No "Copy of" for templates
      isTemplate: false, // Reset template status for the copy
      startTime: DateTime.now().add(const Duration(hours: 1)), // Default to soon
      endTime: DateTime.now().add(const Duration(hours: 5)),
      recurrence: 'none',
    );
    
    Navigator.push(context, MaterialPageRoute(builder: (_) => EditSpecialScreen(hallId: hallId, special: copy)));
  }

  String _formatDate(DateTime dt) {
    return "${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
