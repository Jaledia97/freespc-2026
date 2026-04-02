import 'package:freezed_annotation/freezed_annotation.dart';
import 'special_model.dart'; // For RecurrenceRule

part 'raffle_model.freezed.dart';
part 'raffle_model.g.dart';

@freezed
abstract class RaffleModel with _$RaffleModel {
  const RaffleModel._();

  @JsonSerializable(explicitToJson: true)
  const factory RaffleModel({
    required String id,
    required String hallId,
    required String name, // Was title
    required String description,
    required String imageUrl,
    @Default(100) int maxTickets,
    @Default(0) int soldTickets,
    required DateTime endsAt, // Draw Time
    @Default(false) bool isTemplate,
    String? templateId,
    @Default(false) bool isCancelled,
    DateTime? archivedAt,
    RecurrenceRule? recurrenceRule, // For templates to auto-schedule
    @Default(false) bool isStarred,
    DateTime? unstarredAt,
    @Default([]) List<String> reactionUserIds,
    @Default([]) List<String> interestedUserIds,
    @Default(0) int commentCount,
    DateTime? createdAt,
    String? latestComment,
  }) = _RaffleModel;

  factory RaffleModel.fromJson(Map<String, dynamic> json) =>
      _$RaffleModelFromJson(json);
}
