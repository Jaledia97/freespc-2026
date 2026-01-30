// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raffle_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RaffleTicketModel _$RaffleTicketModelFromJson(Map<String, dynamic> json) =>
    _RaffleTicketModel(
      id: json['id'] as String,
      raffleId: json['raffleId'] as String,
      hallId: json['hallId'] as String,
      title: json['title'] as String,
      hallName: json['hallName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$RaffleTicketModelToJson(_RaffleTicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'raffleId': instance.raffleId,
      'hallId': instance.hallId,
      'title': instance.title,
      'hallName': instance.hallName,
      'quantity': instance.quantity,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };
