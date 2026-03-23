import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in_model.freezed.dart';
part 'check_in_model.g.dart';

@freezed
abstract class CheckInModel with _$CheckInModel {
  const factory CheckInModel({
    required String id,
    required String title,
    @Default('') String description,
    required String userId,
    required String userName,
    String? userProfilePicture,
    required String hallId,
    required String hallName,
    required DateTime createdAt,
    @Default([]) List<String> reactionUserIds,
    @Default([]) List<String> interestedUserIds,
    @Default(0) int commentCount,
    String? latestComment,
  }) = _CheckInModel;

  factory CheckInModel.fromJson(Map<String, dynamic> json) => _$CheckInModelFromJson(json);
}
