import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_post_model.freezed.dart';
part 'text_post_model.g.dart';

@freezed
abstract class TextPostModel with _$TextPostModel {
  const factory TextPostModel({
    required String id,
    required String title,
    @Default('') String description,
    required String userId,
    required String userName,
    String? userProfilePicture,
    String? hallId,
    String? hallName,
    required DateTime createdAt,
    @Default([]) List<String> reactionUserIds,
    @Default([]) List<String> interestedUserIds,
    @Default(0) int commentCount,
    String? latestComment,
  }) = _TextPostModel;

  factory TextPostModel.fromJson(Map<String, dynamic> json) =>
      _$TextPostModelFromJson(json);
}
