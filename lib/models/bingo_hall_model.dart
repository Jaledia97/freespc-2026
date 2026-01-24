import 'package:freezed_annotation/freezed_annotation.dart';

part 'bingo_hall_model.freezed.dart';
part 'bingo_hall_model.g.dart';

@freezed
abstract class BingoHallModel with _$BingoHallModel {
  const factory BingoHallModel({
    required String id,
    required String name,
    required String beaconUuid,
    required double latitude,
    required double longitude,
    required bool isActive,
    String? street,
    String? city,
    String? state,
    String? zipCode,
  }) = _BingoHallModel;

  factory BingoHallModel.fromJson(Map<String, dynamic> json) =>
      _$BingoHallModelFromJson(json);
}
