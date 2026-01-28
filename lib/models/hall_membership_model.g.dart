// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HallMembershipModel _$HallMembershipModelFromJson(Map<String, dynamic> json) =>
    _HallMembershipModel(
      hallId: json['hallId'] as String,
      hallName: json['hallName'] as String,
      balance: (json['balance'] as num).toDouble(),
      currencyName: json['currencyName'] as String? ?? 'Points',
      tier: json['tier'] as String? ?? 'Bronze',
      bannerUrl: json['bannerUrl'] as String?,
    );

Map<String, dynamic> _$HallMembershipModelToJson(
  _HallMembershipModel instance,
) => <String, dynamic>{
  'hallId': instance.hallId,
  'hallName': instance.hallName,
  'balance': instance.balance,
  'currencyName': instance.currencyName,
  'tier': instance.tier,
  'bannerUrl': instance.bannerUrl,
};
