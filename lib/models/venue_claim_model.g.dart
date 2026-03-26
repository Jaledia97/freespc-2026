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
      evidenceUrl: json['evidenceUrl'] as String,
      status: json['status'] as String,
      submittedAt: const TimestampConverter().fromJson(
        json['submittedAt'] as Timestamp,
      ),
    );

Map<String, dynamic> _$VenueClaimModelToJson(_VenueClaimModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'requestedVenueId': instance.requestedVenueId,
      'evidenceUrl': instance.evidenceUrl,
      'status': instance.status,
      'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
    };
