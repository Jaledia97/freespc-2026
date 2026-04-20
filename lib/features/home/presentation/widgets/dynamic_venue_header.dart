import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../models/venue_model.dart';
import '../venue_profile_screen.dart';
import 'post_header.dart';

final singleHallHeaderProvider = FutureProvider.family<VenueModel?, String>(
  (ref, venueId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('venues')
          .doc(venueId)
          .get();
      if (snap.exists && snap.data() != null) {
        return VenueModel.fromJson({'id': snap.id, ...snap.data()!});
      }
      return null;
    } catch (e) {
      return null;
    }
  },
);

class DynamicVenueHeader extends ConsumerWidget {
  final String venueId;
  final String fallbackName;
  final String subtitle;
  final DateTime? createdAt;
  final String postId;
  final String authorId;
  final String targetType;

  const DynamicVenueHeader({
    super.key,
    required this.venueId,
    required this.fallbackName,
    required this.subtitle,
    required this.postId,
    required this.authorId,
    required this.targetType,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hallAsync = ref.watch(singleHallHeaderProvider(venueId));
    final String timeAgoStr = createdAt != null
        ? " • ${TimeUtils.getTimeAgo(createdAt!)}"
        : "";
    final String fullSubtitle = "$subtitle$timeAgoStr";

    return hallAsync.when(
      data: (venue) {
        if (venue == null) {
          return PostHeader(
            title: fallbackName,
            subtitle: fullSubtitle,
            postId: postId,
            authorId: authorId,
            targetType: targetType,
          );
        }
        return PostHeader(
          title: venue.name,
          subtitle: fullSubtitle,
          avatarUrl: venue.logoUrl ?? venue.bannerUrl,
          postId: postId,
          authorId: authorId,
          targetType: targetType,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HallProfileScreen(venue: venue),
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
