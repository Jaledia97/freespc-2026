import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Timestamp

part 'bingo_hall_model.freezed.dart';
part 'bingo_hall_model.g.dart';

@freezed
abstract class BingoHallModel with _$BingoHallModel {
  const BingoHallModel._();

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
    String? phone,
    String? websiteUrl,
    String? description,
    // Geohashing for scalable search
    String? geoHash,
    // Bonus Logic
    @Default(0.0) double followBonus,
  }) = _BingoHallModel;

  factory BingoHallModel.fromJson(Map<String, dynamic> json) =>
      _$BingoHallModelFromJson(json);

  // Helper for GeoFlutterFire Plus
  Map<String, dynamic> get geoFirePoint => {
    'geohash': geoHash,
    'geopoint': GeoPoint(latitude, longitude), 
  };
}
