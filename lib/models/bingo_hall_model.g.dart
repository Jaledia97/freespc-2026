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
    };
