import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'special_model.dart'; // For RecurrenceRule

part 'raffle_model.freezed.dart';
part 'raffle_model.g.dart';

@freezed
abstract class RaffleModel with _$RaffleModel {
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
    DateTime? archivedAt,
    RecurrenceRule? recurrenceRule, // For templates to auto-schedule
  }) = _RaffleModel;

  factory RaffleModel.fromJson(Map<String, dynamic> json) =>
      _$RaffleModelFromJson(json);
}
