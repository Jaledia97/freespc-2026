import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../services/auth_service.dart';
import '../../../squads/repositories/squad_repository.dart';
import '../friends_screen.dart';
import '../../../../models/public_profile.dart';
import 'package:share_plus/share_plus.dart';

class CreateSquadSheet extends ConsumerStatefulWidget {
  const CreateSquadSheet({super.key});

  @override
  ConsumerState<CreateSquadSheet> createState() => _CreateSquadSheetState();
}

class _CreateSquadSheetState extends ConsumerState<CreateSquadSheet> {
  final _nameController = TextEditingController();
  final Set<String> _selectedFriendIds = {};
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleFriend(String uid) {
    setState(() {
      if (_selectedFriendIds.contains(uid)) {
        _selectedFriendIds.remove(uid);
      } else {
        _selectedFriendIds.add(uid);
      }
    });
  }

  Future<void> _formSquad() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Squad requires a name!')),
      );
      return;
    }

    if (_selectedFriendIds.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 4 friends to meet the 5-member minimum.')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      await ref.read(squadRepositoryProvider).createSquad(
        name: name,
        captainId: user.uid,
        memberIds: _selectedFriendIds.toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Squad Formed! Assembly Ready.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProfilesProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Form a Squad",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Squads require 5 members (You + 4 friends) to participate in Assembly Drops.",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Name Input
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Squad Name",
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: "e.g., The Night Owls",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Friends Multi-Select & Recruitment
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Members",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.group_add, size: 16),
                    label: const Text(
                      "Recruit",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () {
                      final u = ref.read(authStateChangesProvider).value;
                      if (u != null) {
                        Share.share("Join my FreeSpc Squad! Download the app: freespc://add_friend?uid=\${u.uid}");
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: friendsAsync.when(
                  data: (friends) {
                    if (friends.isEmpty) {
                      return const Center(
                        child: Text(
                          "You need friends to form a Squad!",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final isSelected = _selectedFriendIds.contains(friend.uid);
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: friend.photoUrl != null
                                ? CachedNetworkImageProvider(friend.photoUrl!)
                                : null,
                            child: friend.photoUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            friend.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${friend.firstName} ${friend.lastName}",
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          trailing: Checkbox(
                            value: isSelected,
                            activeColor: Colors.blueAccent,
                            checkColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            onChanged: (_) => _toggleFriend(friend.uid),
                          ),
                          onTap: () => _toggleFriend(friend.uid),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
                ),
              ),

              const SizedBox(height: 16),
              
              // Validation Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Selected: ${_selectedFriendIds.length} / 4+ Required",
                    style: TextStyle(
                      color: _selectedFriendIds.length >= 4 ? Colors.greenAccent : Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Form Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: (_selectedFriendIds.length >= 4 && !_isCreating) 
                    ? _formSquad 
                    : null,
                  child: _isCreating
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "FORM SQUAD",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
