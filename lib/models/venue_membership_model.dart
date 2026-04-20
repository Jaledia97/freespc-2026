import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_membership_model.freezed.dart';
part 'venue_membership_model.g.dart';

@freezed
abstract class VenueMembershipModel with _$VenueMembershipModel {
  const factory VenueMembershipModel({
    required String venueId,
    required String venueName,
    required double balance,
    @Default('Points')
    String currencyName, // e.g. "Points", "Tokens", "Credits"
    @Default('Bronze') String tier, // e.g. "Gold", "VIP"
    String? bannerUrl, // Optional: Specific card design
  }) = _HallMembershipModel;

  factory VenueMembershipModel.fromJson(Map<String, Object?> json) =>
      _$HallMembershipModelFromJson(json);
}
