import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required String username,
    required DateTime birthday,
    String? phoneNumber,
    String? recoveryEmail,
    @Default('player') String role, // player, worker, admin, owner
    @Default(0) int currentPoints,
    String? homeBaseId,
    String? qrToken,
    @Default([]) List<String> following,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, Object?> json) => _$UserModelFromJson(json);
}