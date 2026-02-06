// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GalleryPhotoModel _$GalleryPhotoModelFromJson(Map<String, dynamic> json) =>
    _GalleryPhotoModel(
      id: json['id'] as String,
      uploaderId: json['uploaderId'] as String,
      imageUrl: json['imageUrl'] as String,
      timestamp: const TimestampConverter().fromJson(
        json['timestamp'] as Timestamp,
      ),
      description: json['description'] as String?,
      taggedUserIds:
          (json['taggedUserIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      taggedHallIds:
          (json['taggedHallIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      approvedHallIds:
          (json['approvedHallIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      pendingHallIds:
          (json['pendingHallIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
      isHidden: json['isHidden'] as bool? ?? false,
    );

Map<String, dynamic> _$GalleryPhotoModelToJson(_GalleryPhotoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uploaderId': instance.uploaderId,
      'imageUrl': instance.imageUrl,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'description': instance.description,
      'taggedUserIds': instance.taggedUserIds,
      'taggedHallIds': instance.taggedHallIds,
      'approvedHallIds': instance.approvedHallIds,
      'pendingHallIds': instance.pendingHallIds,
      'reportCount': instance.reportCount,
      'isHidden': instance.isHidden,
    };
