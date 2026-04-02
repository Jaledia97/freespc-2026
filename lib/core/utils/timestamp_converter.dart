import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String();
  }
}
