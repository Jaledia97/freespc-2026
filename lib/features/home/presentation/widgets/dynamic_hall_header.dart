import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/bingo_hall_model.dart';
import '../hall_profile_screen.dart';
import 'post_header.dart';

final singleHallHeaderProvider = FutureProvider.family<BingoHallModel?, String>(
  (ref, hallId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('bingo_halls')
          .doc(hallId)
          .get();
      if (snap.exists && snap.data() != null) {
        return BingoHallModel.fromJson({'id': snap.id, ...snap.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  },
);

class DynamicHallHeader extends ConsumerWidget {
  final String hallId;
  final String fallbackName;
  final String subtitle;
  final DateTime? createdAt;
  final String postId;
  final String authorId;
  final String targetType;

  const DynamicHallHeader({
    super.key,
    required this.hallId,
    required this.fallbackName,
    required this.subtitle,
    required this.postId,
    required this.authorId,
    required this.targetType,
    this.createdAt,
  });

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallAsync = ref.watch(singleHallHeaderProvider(hallId));
    final String timeAgoStr = createdAt != null
        ? " • ${_timeAgo(createdAt!)}"
        : "";
    final String fullSubtitle = "$subtitle$timeAgoStr";

    return hallAsync.when(
      data: (hall) {
        if (hall == null) {
          return PostHeader(
            title: fallbackName,
            subtitle: fullSubtitle,
            postId: postId,
            authorId: authorId,
            targetType: targetType,
          );
        }
        return PostHeader(
          title: hall.name,
          subtitle: fullSubtitle,
          avatarUrl: hall.logoUrl ?? hall.bannerUrl,
          postId: postId,
          authorId: authorId,
          targetType: targetType,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HallProfileScreen(hall: hall),
              ),
            );
          },
        );
      },
      loading: () => PostHeader(
        title: fallbackName,
        subtitle: fullSubtitle,
        postId: postId,
        authorId: authorId,
        targetType: targetType,
      ),
      error: (e, st) => PostHeader(
        title: fallbackName,
        subtitle: fullSubtitle,
        postId: postId,
        authorId: authorId,
        targetType: targetType,
      ),
    );
  }
}
