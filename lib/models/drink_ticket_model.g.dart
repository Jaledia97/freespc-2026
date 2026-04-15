// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drink_ticket_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DrinkTicketModel _$DrinkTicketModelFromJson(Map<String, dynamic> json) =>
    _DrinkTicketModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      hallId: json['hallId'] as String,
      hallName: json['hallName'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      issuedAt: DateTime.parse(json['issuedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isValid: json['isValid'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$DrinkTicketModelToJson(_DrinkTicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'hallId': instance.hallId,
      'hallName': instance.hallName,
      'title': instance.title,
      'description': instance.description,
      'issuedAt': instance.issuedAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isValid': instance.isValid,
      'imageUrl': instance.imageUrl,
    };
