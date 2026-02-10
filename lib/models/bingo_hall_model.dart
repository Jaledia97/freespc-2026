import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Timestamp
import 'hall_program_model.dart';

part 'bingo_hall_model.freezed.dart';
part 'bingo_hall_model.g.dart';

@freezed
abstract class BingoHallModel with _$BingoHallModel {
  const BingoHallModel._();

  @JsonSerializable(explicitToJson: true)
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
    String? unitNumber,
    String? phone,
    String? websiteUrl,
    String? description,
    String? logoUrl,
    String? bannerUrl,
    // Geohashing for scalable search
    String? geoHash,
    // Bonus Logic
    @Default(0.0) double followBonus,
    // Operating Hours: Map<String, Map<String, String>> (day -> {open, close})
    @Default({}) Map<String, dynamic> operatingHours,
    // Programs
    @Default([]) List<HallProgramModel> programs,
  }) = _BingoHallModel;

  factory BingoHallModel.fromJson(Map<String, dynamic> json) =>
      _$BingoHallModelFromJson(json);

  // Helper for GeoFlutterFire Plus
  Map<String, dynamic> get geoFirePoint => {
    'geohash': geoHash,
    'geopoint': GeoPoint(latitude, longitude), 
  };
}
