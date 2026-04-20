// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HallMembershipModel _$HallMembershipModelFromJson(Map<String, dynamic> json) =>
    _HallMembershipModel(
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      balance: (json['balance'] as num).toDouble(),
      currencyName: json['currencyName'] as String? ?? 'Points',
      tier: json['tier'] as String? ?? 'Bronze',
      bannerUrl: json['bannerUrl'] as String?,
    );

Map<String, dynamic> _$HallMembershipModelToJson(
  _HallMembershipModel instance,
) => <String, dynamic>{
  'venueId': instance.venueId,
  'venueName': instance.venueName,
  'balance': instance.balance,
  'currencyName': instance.currencyName,
  'tier': instance.tier,
  'bannerUrl': instance.bannerUrl,
};
