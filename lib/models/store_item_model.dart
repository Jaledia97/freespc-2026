import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'store_item_model.freezed.dart';
part 'store_item_model.g.dart';

@freezed
abstract class StoreItemModel with _$StoreItemModel {
  const StoreItemModel._();

  @JsonSerializable(explicitToJson: true)
  const factory StoreItemModel({
    required String id,
    required String hallId,
    required String title,
    required String description,
    required int cost, // Points required
    required String imageUrl,
    @Default("General") String category, // "Merchandise", "Food & Beverage", "Sessions", "Pull Tabs", "Electronics", "Other"
    @Default(true) bool isActive,
    int? perCustomerLimit, // Max items per person
    int? dailyLimit, // Max items sold per day (overall)
    @TimestampConverter() required DateTime createdAt,
  }) = _StoreItemModel;

  factory StoreItemModel.fromJson(Map<String, dynamic> json) =>
      _$StoreItemModelFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    return DateTime.now();
  }

  @override
  Object toJson(DateTime date) => Timestamp.fromDate(date);
}
