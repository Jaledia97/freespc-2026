import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'raffle_ticket_model.freezed.dart';
part 'raffle_ticket_model.g.dart';

@freezed
abstract class RaffleTicketModel with _$RaffleTicketModel {
  const factory RaffleTicketModel({
    required String id,
    required String raffleId,
    required String title,
    required String hallName,
    required int quantity,
    required DateTime purchaseDate,
    String? imageUrl,
  }) = _RaffleTicketModel;

  factory RaffleTicketModel.fromJson(Map<String, Object?> json) => _$RaffleTicketModelFromJson(json);
}
