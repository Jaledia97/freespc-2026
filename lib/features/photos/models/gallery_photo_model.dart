import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'gallery_photo_model.freezed.dart';
part 'gallery_photo_model.g.dart';

// JSON Converter for Firestore Timestamp
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
abstract class GalleryPhotoModel with _$GalleryPhotoModel {
  const factory GalleryPhotoModel({
    required String id,
    required String uploaderId,
    required String imageUrl,
    @TimestampConverter() required DateTime timestamp,
    String? description,
    
    // Tagging & Approval Logic
    @Default([]) List<String> taggedUserIds,
    @Default([]) List<String> taggedHallIds,    // All halls tagged originally
    @Default([]) List<String> approvedHallIds,  // Halls that approved the tag
    @Default([]) List<String> pendingHallIds,   // Halls that need to approve
    
    // Moderation
    @Default(0) int reportCount,
    @Default(false) bool isHidden,
  }) = _GalleryPhotoModel;

  factory GalleryPhotoModel.fromJson(Map<String, dynamic> json) =>
      _$GalleryPhotoModelFromJson(json);
}
