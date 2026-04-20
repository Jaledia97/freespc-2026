import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_program_model.freezed.dart';
part 'venue_program_model.g.dart';

@freezed
abstract class VenueProgramModel with _$VenueProgramModel {
  const factory VenueProgramModel({
    required String title,
    @Default('') String pricing,
    @Default('') String details,
    @Default([]) List<int> selectedDays, // 1=Mon, 7=Sun. Empty = Every Day.
    String? startTime, // e.g., "6:00 PM"
    String? endTime, // e.g., "9:00 PM"
    DateTime?
    overrideEndTime, // If set and in future, program is forced ACTIVE.
  }) = _HallProgramModel;

  factory VenueProgramModel.fromJson(Map<String, dynamic> json) =>
      _$HallProgramModelFromJson(json);
}
