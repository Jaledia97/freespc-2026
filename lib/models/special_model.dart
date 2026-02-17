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
    DateTime? endTime,
    double? latitude,
    double? longitude,
    @Default([]) List<String> tags,
    @Default('none') String recurrence, // Deprecated, use recurrenceRule
    RecurrenceRule? recurrenceRule,
    @Default(false) bool isTemplate,
    DateTime? archivedAt,
  }) = _SpecialModel;

  factory SpecialModel.fromJson(Map<String, Object?> json) => _$SpecialModelFromJson(json);
}

@freezed
abstract class RecurrenceRule with _$RecurrenceRule {
  const factory RecurrenceRule({
    required String frequency, // daily, weekly, monthly, yearly
    @Default(1) int interval,
    @Default([]) List<int> daysOfWeek, // 1=Mon, 7=Sun
    @Default('never') String endCondition, // never, date, count
    DateTime? endDate,
    int? occurrenceCount,
  }) = _RecurrenceRule;

  factory RecurrenceRule.fromJson(Map<String, Object?> json) => _$RecurrenceRuleFromJson(json);
}


