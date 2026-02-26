import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json) ?? DateTime.now();
    
    // Handle cases where the timestamp was serialized as a Map via cloud functions or web API
    if (json is Map) {
      final seconds = json['_seconds'] ?? json['seconds'];
      final nanoseconds = json['_nanoseconds'] ?? json['nanoseconds'] ?? 0;
      if (seconds != null) {
        return Timestamp(seconds as int, nanoseconds as int).toDate();
      }
    }
    
    return DateTime.now(); // Fallback
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String userId, // Target user
    required String title,
    required String body,
    required String type, // 'system', 'hall_update', 'event'
    String? hallId, // Source of notification
    Map<String, dynamic>? metadata, // Deep link payload, e.g. {'photoId': '...'}
    @TimestampConverter() required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, Object?> json) => _$NotificationModelFromJson(json);
}
