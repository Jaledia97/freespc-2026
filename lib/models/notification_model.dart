import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();
    try {
      if (json is Timestamp) return json.toDate();
      if (json is String) return DateTime.tryParse(json) ?? DateTime.now();
      if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
      
      // Handle cases where the timestamp was serialized as a Map via cloud functions or web API
      if (json is Map) {
        final seconds = json['_seconds'] ?? json['seconds'];
        final nanoseconds = json['_nanoseconds'] ?? json['nanoseconds'] ?? 0;
        if (seconds != null) {
          // If seconds is a string, parse it. Otherwise cast to int.
          final sLength = seconds.toString();
          if (sLength.length > 10) {
              // It might actually be milliseconds secretly passed as seconds
              return DateTime.fromMillisecondsSinceEpoch(int.parse(sLength));
          }
          return Timestamp(
              int.tryParse(seconds.toString()) ?? 0, 
              int.tryParse(nanoseconds.toString()) ?? 0
            ).toDate();
        }
      }
    } catch (e) {
      print("Error parsing timestamp in NotificationModel: $e. Falling back to now(). json was $json");
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
