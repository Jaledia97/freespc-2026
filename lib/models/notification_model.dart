import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

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
    required DateTime createdAt,
    @Default(false) bool isRead,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, Object?> json) => _$NotificationModelFromJson(json);
}
