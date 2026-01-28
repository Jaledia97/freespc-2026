import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall_membership_model.freezed.dart';
part 'hall_membership_model.g.dart';

@freezed
abstract class HallMembershipModel with _$HallMembershipModel {
  const factory HallMembershipModel({
    required String hallId,
    required String hallName,
    required double balance,
    @Default('Points') String currencyName, // e.g. "Points", "Tokens", "Credits"
    @Default('Bronze') String tier, // e.g. "Gold", "VIP"
    String? bannerUrl, // Optional: Specific card design
  }) = _HallMembershipModel;

  factory HallMembershipModel.fromJson(Map<String, Object?> json) => _$HallMembershipModelFromJson(json);
}
