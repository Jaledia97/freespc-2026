// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  username: json['username'] as String,
  birthday: DateTime.parse(json['birthday'] as String),
  phoneNumber: json['phoneNumber'] as String?,
  recoveryEmail: json['recoveryEmail'] as String?,
  role: json['role'] as String? ?? 'player',
  currentPoints: (json['currentPoints'] as num?)?.toInt() ?? 0,
  homeBaseId: json['homeBaseId'] as String?,
  qrToken: json['qrToken'] as String?,
  bio: json['bio'] as String?,
  photoUrl: json['photoUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  following:
      (json['following'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'birthday': instance.birthday.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
      'recoveryEmail': instance.recoveryEmail,
      'role': instance.role,
      'currentPoints': instance.currentPoints,
      'homeBaseId': instance.homeBaseId,
      'qrToken': instance.qrToken,
      'bio': instance.bio,
      'photoUrl': instance.photoUrl,
      'bannerUrl': instance.bannerUrl,
      'following': instance.following,
    };
