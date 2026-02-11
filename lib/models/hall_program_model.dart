import 'package:freezed_annotation/freezed_annotation.dart';

part 'hall_program_model.freezed.dart';
part 'hall_program_model.g.dart';

@freezed
abstract class HallProgramModel with _$HallProgramModel {
  const factory HallProgramModel({
    required String title,
    @Default('') String pricing,
    @Default('') String details,
    @Default([]) List<int> selectedDays, // 1=Mon, 7=Sun. Empty = Every Day.
    String? startTime, // e.g., "6:00 PM"
    String? endTime,   // e.g., "9:00 PM"
    DateTime? overrideEndTime, // If set and in future, program is forced ACTIVE.
  }) = _HallProgramModel;

  factory HallProgramModel.fromJson(Map<String, dynamic> json) => _$HallProgramModelFromJson(json);
}
