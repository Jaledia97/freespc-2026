import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth_service.dart';
import '../../friends/presentation/friends_screen.dart'; // To reuse the friends list provider
import '../../../models/public_profile.dart';
import '../repositories/messaging_repository.dart';
import 'chat_screen.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final List<PublicProfile> _selectedFriends = [];
  bool _isCreating = false;

  void _toggleSelection(PublicProfile friend) {
    setState(() {
      if (_selectedFriends.contains(friend)) {
        _selectedFriends.remove(friend);
      } else {
        _selectedFriends.add(friend);
      }
    });
  }

  Future<void> _createChat() async {
    if (_selectedFriends.isEmpty) return;

    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser == null) return;

    setState(() => _isCreating = true);

    try {
      final participantIds = [currentUser.uid, ..._selectedFriends.map((f) => f.uid)];
      
      final participantNames = <String, String>{
        currentUser.uid: currentUser.username,
        for (var f in _selectedFriends) f.uid: f.username,
      };

      // Prompt for Group Name if multiple friends selected
      String? groupName;
      if (_selectedFriends.length > 1) {
         groupName = await _showGroupNameDialog();
         if (groupName == null || groupName.isEmpty) {
            // Cancelled
            setState(() => _isCreating = false);
            return;
         }
      }

      final chat = await ref.read(messagingRepositoryProvider).createChat(
        participantIds,
        participantNames,
        groupName: groupName,
      );

      if (mounted) {
        Navigator.pop(context); // Close new chat screen
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chat.id, chatName: chat.name ?? _selectedFriends.first.username)
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<String?> _showGroupNameDialog() async {
    String name = "";
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text("Name your group", style: TextStyle(color: Colors.white)),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Group Name", hintStyle: TextStyle(color: Colors.white54)),
            onChanged: (val) => name = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, name), child: const Text("Create")),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProfilesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("New Message"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedFriends.isNotEmpty)
            TextButton(
              onPressed: _isCreating ? null : _createChat,
              child: _isCreating 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text("Chat (${_selectedFriends.length})", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
             return const Center(child: Text("No friends to message yet.", style: TextStyle(color: Colors.white54)));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedFriends.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: const Color(0xFF2C2C2C),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _selectedFriends.map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(f.username),
                          onDeleted: () => _toggleSelection(f),
                          backgroundColor: Colors.blueAccent.withOpacity(0.2),
                          deleteIconColor: Colors.blueAccent,
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final isSelected = _selectedFriends.contains(friend);
                    
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(friend.username, style: const TextStyle(color: Colors.white)),
                      trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Colors.blueAccent)
                        : const Icon(Icons.circle_outlined, color: Colors.white54),
                      onTap: () => _toggleSelection(friend),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
