import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'venue_claim_model.freezed.dart';
part 'venue_claim_model.g.dart';

@freezed
abstract class VenueClaimModel with _$VenueClaimModel {
  const VenueClaimModel._();

  const factory VenueClaimModel({
    required String id,
    required String userId,
    required String requestedVenueId,
    String? evidenceUrl,
    required String status, // 'pending', 'approved', 'rejected'
    @TimestampConverter() required DateTime submittedAt,
    String? venueName,
    String? venueAddress,
    String? venueCity,
    String? venueState,
    String? venueWebsite,
    String? emailProvided,
    String? venueType,
    String? logoUrl,
  }) = _VenueClaimModel;

  factory VenueClaimModel.fromJson(Map<String, dynamic> json) => _$VenueClaimModelFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
