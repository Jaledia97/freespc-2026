import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:convert';
import '../../home/controllers/feed_pagination_controller.dart';
import '../../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('blocked_users') ?? [];
    List<Map<String, dynamic>> parsed = [];
    for (String block in raw) {
      try {
        parsed.add(jsonDecode(block) as Map<String, dynamic>);
      } catch (e) {
        parsed.add({'id': block, 'name': 'Unknown User'});
      }
    }
    setState(() {
      _blockedUsers = parsed;
      _isLoading = false;
    });
  }

  void _showUnblockDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Unblock User?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to unblock $name?\n\nIf you unblock them, you will NOT be able to block them again for 24 hours.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _executeUnblock(id);
              },
              child: const Text(
                'Confirm Unblock',
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
  }

  void _executeUnblock(String id) async {
    // Unblock Locally
    ref.read(feedPaginationControllerProvider.notifier).unblockUser(id);

    // Attempt fallback unblock from legacy backend array if exists
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
            'blockedUsers': FieldValue.arrayRemove([id]),
          })
          .catchError((_) {});
    }

    Vibration.vibrate(duration: 40);
    setState(() {
      _blockedUsers.removeWhere((u) => u['id'] == id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Unblocked successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Blocked Accounts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : _blockedUsers.isEmpty
          ? const Center(
              child: Text(
                'No blocked accounts.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _blockedUsers.length,
              itemBuilder: (context, index) {
                final user = _blockedUsers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.redAccent.withOpacity(0.2),
                        child: const Icon(
                          Icons.person_off,
                          color: Colors.redAccent,
                        ),
                      ),
                      title: Text(
                        user['name'] ?? 'Unknown User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: TextButton(
                        onPressed: () => _showUnblockDialog(
                          user['id']!,
                          user['name'] ?? 'Unknown User',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Unblock',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
