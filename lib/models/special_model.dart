import 'package:freezed_annotation/freezed_annotation.dart';

part 'special_model.freezed.dart';
part 'special_model.g.dart';

@freezed
abstract class SpecialModel with _$SpecialModel {
  const SpecialModel._();

  @JsonSerializable(explicitToJson: true)
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
    String? templateId,
    @Default(false) bool isCancelled,
    DateTime? archivedAt,
    @Default(false) bool isStarred,
    DateTime? unstarredAt,
    @Default([]) List<String> reactionUserIds,
    @Default([]) List<String> interestedUserIds,
    @Default(0) int commentCount,
    @Default('venue') String authorType,
    String? authorId,
    String? postedByUid,
    String? latestComment,
  }) = _SpecialModel;

  factory SpecialModel.fromJson(Map<String, Object?> json) =>
      _$SpecialModelFromJson(json);
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

  factory RecurrenceRule.fromJson(Map<String, Object?> json) =>
      _$RecurrenceRuleFromJson(json);
}
