import 'package:freezed_annotation/freezed_annotation.dart';

part 'special_model.freezed.dart';
part 'special_model.g.dart';

@freezed
abstract class SpecialModel with _$SpecialModel {
  const factory SpecialModel({
    required String id,
    required String hallId,
    required String hallName,
    required String title,
    required String description,
    required String imageUrl,
    required DateTime postedAt,
    DateTime? startTime,
    double? latitude,
    double? longitude,
  }) = _SpecialModel;

  factory SpecialModel.fromJson(Map<String, Object?> json) => _$SpecialModelFromJson(json);
}
