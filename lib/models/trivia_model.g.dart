// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trivia_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TriviaModel _$TriviaModelFromJson(Map<String, dynamic> json) => _TriviaModel(
  id: json['id'] as String,
  venueId: json['venueId'] as String,
  title: json['title'] as String,
  date: DateTime.parse(json['date'] as String),
  category: json['category'] as String,
  prizeString: json['prizeString'] as String,
  imageUrl: json['imageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TriviaModelToJson(_TriviaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venueId': instance.venueId,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'category': instance.category,
      'prizeString': instance.prizeString,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
