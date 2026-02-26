import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Timestamp
import 'hall_program_model.dart';
import 'hall_charity_model.dart';

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
    // Charities
    @Default([]) List<HallCharityModel> charities,
    // Loyalty Configuration
    @Default(LoyaltySettings()) LoyaltySettings loyaltySettings,
    // Store Categories
    @Default(['Merchandise', 'Food & Beverage', 'Sessions', 'Pull Tabs', 'Electronics', 'Other']) List<String> storeCategories,
  }) = _BingoHallModel;

  factory BingoHallModel.fromJson(Map<String, dynamic> json) =>
      _$BingoHallModelFromJson(json);

  // Helper for GeoFlutterFire Plus
  Map<String, dynamic> get geoFirePoint => {
    'geohash': geoHash,
    'geopoint': GeoPoint(latitude, longitude), 
  };
}

@freezed
abstract class LoyaltySettings with _$LoyaltySettings {
  @JsonSerializable(explicitToJson: true)
  const factory LoyaltySettings({
    @Default("Points") String currencyName,
    @Default("PTS") String currencySymbol,
    @Default("FFD700") String primaryColor, // Hex code
    @Default(10) int checkInBonus,
    @Default(5) int timeDropAmount,
    @Default(30) int timeDropInterval, // in minutes
    int? dailyEarningCap,
    @Default(50) int birthdayBonus,
  }) = _LoyaltySettings;

  factory LoyaltySettings.fromJson(Map<String, dynamic> json) =>
      _$LoyaltySettingsFromJson(json);
}
