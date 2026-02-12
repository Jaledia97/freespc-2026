import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall_charity_model.freezed.dart';
part 'hall_charity_model.g.dart';

@freezed
class HallCharityModel with _$HallCharityModel {
  @JsonSerializable(explicitToJson: true)
  const factory HallCharityModel({
    required String id,
    required String name,
    required String logoUrl, // URL to uploaded image
    String? websiteUrl,
  }) = _HallCharityModel;

  factory HallCharityModel.fromJson(Map<String, dynamic> json) =>
      _$HallCharityModelFromJson(json);
}
