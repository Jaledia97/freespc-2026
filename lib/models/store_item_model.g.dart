// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoreItemModel _$StoreItemModelFromJson(Map<String, dynamic> json) =>
    _StoreItemModel(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cost: (json['cost'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String? ?? "General",
      isActive: json['isActive'] as bool? ?? true,
      perCustomerLimit: (json['perCustomerLimit'] as num?)?.toInt(),
      dailyLimit: (json['dailyLimit'] as num?)?.toInt(),
      createdAt: const TimestampConverter().fromJson(
        json['createdAt'] as Object,
      ),
    );

Map<String, dynamic> _$StoreItemModelToJson(_StoreItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'venueId': instance.venueId,
      'title': instance.title,
      'description': instance.description,
      'cost': instance.cost,
      'imageUrl': instance.imageUrl,
      'category': instance.category,
      'isActive': instance.isActive,
      'perCustomerLimit': instance.perCustomerLimit,
      'dailyLimit': instance.dailyLimit,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
