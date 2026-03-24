import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:convert';
import '../../home/controllers/feed_pagination_controller.dart';

class HiddenPostsScreen extends ConsumerStatefulWidget {
  const HiddenPostsScreen({super.key});

  @override
  ConsumerState<HiddenPostsScreen> createState() => _HiddenPostsScreenState();
}

class _HiddenPostsScreenState extends ConsumerState<HiddenPostsScreen> {
  List<Map<String, dynamic>> _hiddenPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHiddenPosts();
  }

  Future<void> _loadHiddenPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('hidden_posts') ?? [];
    List<Map<String, dynamic>> parsed = [];
    for (String post in raw) {
      try {
        parsed.add(jsonDecode(post) as Map<String, dynamic>);
      } catch (e) {
        parsed.add({'id': post, 'title': 'Hidden Post'});
      }
    }
    setState(() {
      _hiddenPosts = parsed;
      _isLoading = false;
    });
  }

  void _unhide(String id) async {
    ref.read(feedPaginationControllerProvider.notifier).unhidePost(id);
    Vibration.vibrate(duration: 40);
    setState(() {
      _hiddenPosts.removeWhere((p) => p['id'] == id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post restored.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Hidden Content',
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
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _hiddenPosts.isEmpty
          ? const Center(
              child: Text(
                'No hidden posts.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _hiddenPosts.length,
              itemBuilder: (context, index) {
                final post = _hiddenPosts[index];
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
                        backgroundColor: Colors.white12,
                        child: const Icon(
                          Icons.visibility_off,
                          color: Colors.white54,
                        ),
                      ),
                      title: Text(
                        post['title'] ?? 'Hidden Post',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: TextButton(
                        onPressed: () => _unhide(post['id']!),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Unhide',
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
