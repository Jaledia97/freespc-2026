import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/username_router.dart';

class PostHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const PostHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white12,
        backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl!) : null,
        child: avatarUrl == null ? const Icon(Icons.person, color: Colors.white54) : null,
      ),
      title: UsernameRouter(
        text: title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
      ),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(Icons.more_horiz, color: Colors.white54),
    );
  }
}
