// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bingo_hall_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BingoHallModel _$BingoHallModelFromJson(Map<String, dynamic> json) =>
    _BingoHallModel(
      id: json['id'] as String,
      name: json['name'] as String,
      beaconUuid: json['beaconUuid'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      unitNumber: json['unitNumber'] as String?,
      phone: json['phone'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      bannerUrl: json['bannerUrl'] as String?,
      geoHash: json['geoHash'] as String?,
      followBonus: (json['followBonus'] as num?)?.toDouble() ?? 0.0,
      operatingHours:
          json['operatingHours'] as Map<String, dynamic>? ?? const {},
      programs:
          (json['programs'] as List<dynamic>?)
              ?.map((e) => HallProgramModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      charities:
          (json['charities'] as List<dynamic>?)
              ?.map((e) => HallCharityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      loyaltySettings: json['loyaltySettings'] == null
          ? const LoyaltySettings()
          : LoyaltySettings.fromJson(
              json['loyaltySettings'] as Map<String, dynamic>,
            ),
      storeCategories:
          (json['storeCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [
            'Merchandise',
            'Food & Beverage',
            'Sessions',
            'Pull Tabs',
            'Electronics',
            'Other',
          ],
    );

Map<String, dynamic> _$BingoHallModelToJson(_BingoHallModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'beaconUuid': instance.beaconUuid,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isActive': instance.isActive,
      'street': instance.street,
      'city': instance.city,
      'state': instance.state,
      'zipCode': instance.zipCode,
      'unitNumber': instance.unitNumber,
      'phone': instance.phone,
      'websiteUrl': instance.websiteUrl,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'bannerUrl': instance.bannerUrl,
      'geoHash': instance.geoHash,
      'followBonus': instance.followBonus,
      'operatingHours': instance.operatingHours,
      'programs': instance.programs.map((e) => e.toJson()).toList(),
      'charities': instance.charities.map((e) => e.toJson()).toList(),
      'loyaltySettings': instance.loyaltySettings.toJson(),
      'storeCategories': instance.storeCategories,
    };

_LoyaltySettings _$LoyaltySettingsFromJson(Map<String, dynamic> json) =>
    _LoyaltySettings(
      currencyName: json['currencyName'] as String? ?? "Points",
      currencySymbol: json['currencySymbol'] as String? ?? "PTS",
      primaryColor: json['primaryColor'] as String? ?? "FFD700",
      checkInBonus: (json['checkInBonus'] as num?)?.toInt() ?? 10,
      timeDropAmount: (json['timeDropAmount'] as num?)?.toInt() ?? 5,
      timeDropInterval: (json['timeDropInterval'] as num?)?.toInt() ?? 30,
      dailyEarningCap: (json['dailyEarningCap'] as num?)?.toInt(),
      birthdayBonus: (json['birthdayBonus'] as num?)?.toInt() ?? 50,
    );

Map<String, dynamic> _$LoyaltySettingsToJson(_LoyaltySettings instance) =>
    <String, dynamic>{
      'currencyName': instance.currencyName,
      'currencySymbol': instance.currencySymbol,
      'primaryColor': instance.primaryColor,
      'checkInBonus': instance.checkInBonus,
      'timeDropAmount': instance.timeDropAmount,
      'timeDropInterval': instance.timeDropInterval,
      'dailyEarningCap': instance.dailyEarningCap,
      'birthdayBonus': instance.birthdayBonus,
    };
