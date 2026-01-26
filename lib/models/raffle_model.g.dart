// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raffle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RaffleModel _$RaffleModelFromJson(Map<String, dynamic> json) => RaffleModel(
  id: json['id'] as String,
  hallId: json['hallId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  prizePool: json['prizePool'] as String,
  drawTime: RaffleModel._fromJson(json['drawTime'] as Timestamp),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$RaffleModelToJson(RaffleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hallId': instance.hallId,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'prizePool': instance.prizePool,
      'drawTime': RaffleModel._toJson(instance.drawTime),
      'imageUrl': instance.imageUrl,
    };
