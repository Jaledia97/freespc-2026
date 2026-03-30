import 'package:freezed_annotation/freezed_annotation.dart';

part 'win_post_model.freezed.dart';
part 'win_post_model.g.dart';

@freezed
abstract class WinPostModel with _$WinPostModel {
  const factory WinPostModel({
    required String id,
    required String title,
    @Default('') String description,
    required String userId,
    required String userName,
    String? userProfilePicture,
    required String hallId,
    required String hallName,
    required double winAmount,
    String? imageUrl,
    required DateTime createdAt,
    @Default([]) List<String> reactionUserIds,
    @Default([]) List<String> interestedUserIds,
    @Default(0) int commentCount,
    @Default('user') String authorType,
    String? authorId,
    String? postedByUid,
    String? latestComment,
  }) = _WinPostModel;

  factory WinPostModel.fromJson(Map<String, dynamic> json) =>
      _$WinPostModelFromJson(json);
}
