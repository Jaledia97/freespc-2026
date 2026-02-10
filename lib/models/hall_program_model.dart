import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall_program_model.freezed.dart';
part 'hall_program_model.g.dart';

@freezed
abstract class HallProgramModel with _$HallProgramModel {
  const factory HallProgramModel({
    required String title,
    @Default('') String pricing,
    @Default('') String details,
    String? specificDay, // e.g., "Monday", "Tuesday", or null for "Any Day" / "General"
  }) = _HallProgramModel;

  factory HallProgramModel.fromJson(Map<String, dynamic> json) => _$HallProgramModelFromJson(json);
}
