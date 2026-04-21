import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Timestamp
import 'venue_program_model.dart';
import 'venue_charity_model.dart';

part 'venue_model.freezed.dart';
part 'venue_model.g.dart';

@freezed
abstract class VenueModel with _$VenueModel {
  const VenueModel._();

  @JsonSerializable(explicitToJson: true)
  const factory VenueModel({
    required String id,
    required String name,
    required String beaconUuid,
    String? beaconPin,
    @Default(0.0) double txPower,
    @Default(1000.0) double advInterval,
    @Default(true) bool isBroadcasting,
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
    @Default([]) List<VenueProgramModel> programs,
    // Charities
    @Default([]) List<VenueCharityModel> charities,
    // Loyalty Configuration
    @Default(LoyaltySettings()) LoyaltySettings loyaltySettings,
    // Store Categories
    @Default([
      'Merchandise',
      'Food & Beverage',
      'Sessions',
      'Pull Tabs',
      'Electronics',
      'Other',
    ])
    List<String> storeCategories,
    @Default('bingo') String venueType,
    @Default(SquadBonusConfig()) SquadBonusConfig squadBonusConfig,
  }) = _VenueModel;

  factory VenueModel.fromJson(Map<String, dynamic> json) =>
      _$VenueModelFromJson(json);

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

@freezed
abstract class SquadBonusConfig with _$SquadBonusConfig {
  @JsonSerializable(explicitToJson: true)
  const factory SquadBonusConfig({
    @Default(false) bool isSquadBonusActive,
    @Default(1.5) double squadBonusMultiplier,
    @Default(3) int gracePeriodMinutes,
    @Default(15) int assemblyDurationMinutes,
    @Default(100) int assemblyDropAmount,
    DateTime? startTime,
    DateTime? endTime,
  }) = _SquadBonusConfig;

  factory SquadBonusConfig.fromJson(Map<String, dynamic> json) =>
      _$SquadBonusConfigFromJson(json);
}
