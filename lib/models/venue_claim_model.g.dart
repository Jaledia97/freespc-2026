// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_claim_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VenueClaimModel _$VenueClaimModelFromJson(Map<String, dynamic> json) =>
    _VenueClaimModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      requestedVenueId: json['requestedVenueId'] as String,
      evidenceUrl: json['evidenceUrl'] as String?,
      status: json['status'] as String,
      submittedAt: const TimestampConverter().fromJson(
        json['submittedAt'] as Timestamp,
      ),
      venueName: json['venueName'] as String?,
      venueAddress: json['venueAddress'] as String?,
      venueCity: json['venueCity'] as String?,
      venueState: json['venueState'] as String?,
      venueWebsite: json['venueWebsite'] as String?,
      emailProvided: json['emailProvided'] as String?,
      venueType: json['venueType'] as String?,
      logoUrl: json['logoUrl'] as String?,
    );

Map<String, dynamic> _$VenueClaimModelToJson(_VenueClaimModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'requestedVenueId': instance.requestedVenueId,
      'evidenceUrl': instance.evidenceUrl,
      'status': instance.status,
      'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
      'venueName': instance.venueName,
      'venueAddress': instance.venueAddress,
      'venueCity': instance.venueCity,
      'venueState': instance.venueState,
      'venueWebsite': instance.venueWebsite,
      'emailProvided': instance.emailProvided,
      'venueType': instance.venueType,
      'logoUrl': instance.logoUrl,
    };
