import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'raffle_model.g.dart';

@JsonSerializable()
class RaffleModel {
  final String id;
  final String hallId;
  final String title;
  final String description;
  final double price;
  final String prizePool; // e.g. "Est. $500" or "MacBook Pro"
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  final DateTime drawTime;
  final String? imageUrl;

  RaffleModel({
    required this.id,
    required this.hallId,
    required this.title,
    required this.description,
    required this.price,
    required this.prizePool,
    required this.drawTime,
    this.imageUrl,
  });

  factory RaffleModel.fromJson(Map<String, dynamic> json) => _$RaffleModelFromJson(json);
  Map<String, dynamic> toJson() => _$RaffleModelToJson(this);

  // Firestore Timestamp handling
  static DateTime _fromJson(Timestamp timestamp) => timestamp.toDate();
  static Timestamp _toJson(DateTime date) => Timestamp.fromDate(date);
}
