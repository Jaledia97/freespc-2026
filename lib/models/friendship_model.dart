import 'package:freezed_annotation/freezed_annotation.dart';

part 'friendship_model.freezed.dart';
part 'friendship_model.g.dart';

@freezed
abstract class FriendshipModel with _$FriendshipModel {
  const factory FriendshipModel({
    required String id,
    required String user1Id,
    required String user2Id,
    @Default('pending') String status, // 'pending', 'accepted'
    required DateTime createdAt,
  }) = _FriendshipModel;

  factory FriendshipModel.fromJson(Map<String, Object?> json) => 
      _$FriendshipModelFromJson(json);
}
