import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_charity_model.freezed.dart';
part 'venue_charity_model.g.dart';

@freezed
abstract class VenueCharityModel with _$VenueCharityModel {
  const factory VenueCharityModel({
    required String id,
    required String name,
    required String logoUrl, // URL to uploaded image
    String? websiteUrl,
  }) = _HallCharityModel;

  factory VenueCharityModel.fromJson(Map<String, dynamic> json) =>
      _$HallCharityModelFromJson(json);
}
