// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueModel {

 String get id; String get name; String get beaconUuid; String? get beaconPin; double get txPower; double get advInterval; bool get isBroadcasting; double get latitude; double get longitude; bool get isActive; String? get street; String? get city; String? get state; String? get zipCode; String? get unitNumber; String? get phone; String? get websiteUrl; String? get description; String? get logoUrl; String? get bannerUrl;// Geohashing for scalable search
 String? get geoHash;// Bonus Logic
 double get followBonus;// Operating Hours: Map<String, Map<String, String>> (day -> {open, close})
 Map<String, dynamic> get operatingHours;// Programs
 List<VenueProgramModel> get programs;// Charities
 List<VenueCharityModel> get charities;// Loyalty Configuration
 LoyaltySettings get loyaltySettings;// Store Categories
 List<String> get storeCategories; String get venueType; SquadBonusConfig get squadBonusConfig;
/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueModelCopyWith<VenueModel> get copyWith => _$VenueModelCopyWithImpl<VenueModel>(this as VenueModel, _$identity);

  /// Serializes this VenueModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.beaconUuid, beaconUuid) || other.beaconUuid == beaconUuid)&&(identical(other.beaconPin, beaconPin) || other.beaconPin == beaconPin)&&(identical(other.txPower, txPower) || other.txPower == txPower)&&(identical(other.advInterval, advInterval) || other.advInterval == advInterval)&&(identical(other.isBroadcasting, isBroadcasting) || other.isBroadcasting == isBroadcasting)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.unitNumber, unitNumber) || other.unitNumber == unitNumber)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.geoHash, geoHash) || other.geoHash == geoHash)&&(identical(other.followBonus, followBonus) || other.followBonus == followBonus)&&const DeepCollectionEquality().equals(other.operatingHours, operatingHours)&&const DeepCollectionEquality().equals(other.programs, programs)&&const DeepCollectionEquality().equals(other.charities, charities)&&(identical(other.loyaltySettings, loyaltySettings) || other.loyaltySettings == loyaltySettings)&&const DeepCollectionEquality().equals(other.storeCategories, storeCategories)&&(identical(other.venueType, venueType) || other.venueType == venueType)&&(identical(other.squadBonusConfig, squadBonusConfig) || other.squadBonusConfig == squadBonusConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,beaconUuid,beaconPin,txPower,advInterval,isBroadcasting,latitude,longitude,isActive,street,city,state,zipCode,unitNumber,phone,websiteUrl,description,logoUrl,bannerUrl,geoHash,followBonus,const DeepCollectionEquality().hash(operatingHours),const DeepCollectionEquality().hash(programs),const DeepCollectionEquality().hash(charities),loyaltySettings,const DeepCollectionEquality().hash(storeCategories),venueType,squadBonusConfig]);

@override
String toString() {
  return 'VenueModel(id: $id, name: $name, beaconUuid: $beaconUuid, beaconPin: $beaconPin, txPower: $txPower, advInterval: $advInterval, isBroadcasting: $isBroadcasting, latitude: $latitude, longitude: $longitude, isActive: $isActive, street: $street, city: $city, state: $state, zipCode: $zipCode, unitNumber: $unitNumber, phone: $phone, websiteUrl: $websiteUrl, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, geoHash: $geoHash, followBonus: $followBonus, operatingHours: $operatingHours, programs: $programs, charities: $charities, loyaltySettings: $loyaltySettings, storeCategories: $storeCategories, venueType: $venueType, squadBonusConfig: $squadBonusConfig)';
}


}

/// @nodoc
abstract mixin class $VenueModelCopyWith<$Res>  {
  factory $VenueModelCopyWith(VenueModel value, $Res Function(VenueModel) _then) = _$VenueModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String beaconUuid, String? beaconPin, double txPower, double advInterval, bool isBroadcasting, double latitude, double longitude, bool isActive, String? street, String? city, String? state, String? zipCode, String? unitNumber, String? phone, String? websiteUrl, String? description, String? logoUrl, String? bannerUrl, String? geoHash, double followBonus, Map<String, dynamic> operatingHours, List<VenueProgramModel> programs, List<VenueCharityModel> charities, LoyaltySettings loyaltySettings, List<String> storeCategories, String venueType, SquadBonusConfig squadBonusConfig
});


$LoyaltySettingsCopyWith<$Res> get loyaltySettings;$SquadBonusConfigCopyWith<$Res> get squadBonusConfig;

}
/// @nodoc
class _$VenueModelCopyWithImpl<$Res>
    implements $VenueModelCopyWith<$Res> {
  _$VenueModelCopyWithImpl(this._self, this._then);

  final VenueModel _self;
  final $Res Function(VenueModel) _then;

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? beaconUuid = null,Object? beaconPin = freezed,Object? txPower = null,Object? advInterval = null,Object? isBroadcasting = null,Object? latitude = null,Object? longitude = null,Object? isActive = null,Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? unitNumber = freezed,Object? phone = freezed,Object? websiteUrl = freezed,Object? description = freezed,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? geoHash = freezed,Object? followBonus = null,Object? operatingHours = null,Object? programs = null,Object? charities = null,Object? loyaltySettings = null,Object? storeCategories = null,Object? venueType = null,Object? squadBonusConfig = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,beaconUuid: null == beaconUuid ? _self.beaconUuid : beaconUuid // ignore: cast_nullable_to_non_nullable
as String,beaconPin: freezed == beaconPin ? _self.beaconPin : beaconPin // ignore: cast_nullable_to_non_nullable
as String?,txPower: null == txPower ? _self.txPower : txPower // ignore: cast_nullable_to_non_nullable
as double,advInterval: null == advInterval ? _self.advInterval : advInterval // ignore: cast_nullable_to_non_nullable
as double,isBroadcasting: null == isBroadcasting ? _self.isBroadcasting : isBroadcasting // ignore: cast_nullable_to_non_nullable
as bool,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,unitNumber: freezed == unitNumber ? _self.unitNumber : unitNumber // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,geoHash: freezed == geoHash ? _self.geoHash : geoHash // ignore: cast_nullable_to_non_nullable
as String?,followBonus: null == followBonus ? _self.followBonus : followBonus // ignore: cast_nullable_to_non_nullable
as double,operatingHours: null == operatingHours ? _self.operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,programs: null == programs ? _self.programs : programs // ignore: cast_nullable_to_non_nullable
as List<VenueProgramModel>,charities: null == charities ? _self.charities : charities // ignore: cast_nullable_to_non_nullable
as List<VenueCharityModel>,loyaltySettings: null == loyaltySettings ? _self.loyaltySettings : loyaltySettings // ignore: cast_nullable_to_non_nullable
as LoyaltySettings,storeCategories: null == storeCategories ? _self.storeCategories : storeCategories // ignore: cast_nullable_to_non_nullable
as List<String>,venueType: null == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as String,squadBonusConfig: null == squadBonusConfig ? _self.squadBonusConfig : squadBonusConfig // ignore: cast_nullable_to_non_nullable
as SquadBonusConfig,
  ));
}
/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoyaltySettingsCopyWith<$Res> get loyaltySettings {
  
  return $LoyaltySettingsCopyWith<$Res>(_self.loyaltySettings, (value) {
    return _then(_self.copyWith(loyaltySettings: value));
  });
}/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SquadBonusConfigCopyWith<$Res> get squadBonusConfig {
  
  return $SquadBonusConfigCopyWith<$Res>(_self.squadBonusConfig, (value) {
    return _then(_self.copyWith(squadBonusConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [VenueModel].
extension VenueModelPatterns on VenueModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueModel value)  $default,){
final _that = this;
switch (_that) {
case _VenueModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueModel value)?  $default,){
final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String beaconUuid,  String? beaconPin,  double txPower,  double advInterval,  bool isBroadcasting,  double latitude,  double longitude,  bool isActive,  String? street,  String? city,  String? state,  String? zipCode,  String? unitNumber,  String? phone,  String? websiteUrl,  String? description,  String? logoUrl,  String? bannerUrl,  String? geoHash,  double followBonus,  Map<String, dynamic> operatingHours,  List<VenueProgramModel> programs,  List<VenueCharityModel> charities,  LoyaltySettings loyaltySettings,  List<String> storeCategories,  String venueType,  SquadBonusConfig squadBonusConfig)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
return $default(_that.id,_that.name,_that.beaconUuid,_that.beaconPin,_that.txPower,_that.advInterval,_that.isBroadcasting,_that.latitude,_that.longitude,_that.isActive,_that.street,_that.city,_that.state,_that.zipCode,_that.unitNumber,_that.phone,_that.websiteUrl,_that.description,_that.logoUrl,_that.bannerUrl,_that.geoHash,_that.followBonus,_that.operatingHours,_that.programs,_that.charities,_that.loyaltySettings,_that.storeCategories,_that.venueType,_that.squadBonusConfig);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String beaconUuid,  String? beaconPin,  double txPower,  double advInterval,  bool isBroadcasting,  double latitude,  double longitude,  bool isActive,  String? street,  String? city,  String? state,  String? zipCode,  String? unitNumber,  String? phone,  String? websiteUrl,  String? description,  String? logoUrl,  String? bannerUrl,  String? geoHash,  double followBonus,  Map<String, dynamic> operatingHours,  List<VenueProgramModel> programs,  List<VenueCharityModel> charities,  LoyaltySettings loyaltySettings,  List<String> storeCategories,  String venueType,  SquadBonusConfig squadBonusConfig)  $default,) {final _that = this;
switch (_that) {
case _VenueModel():
return $default(_that.id,_that.name,_that.beaconUuid,_that.beaconPin,_that.txPower,_that.advInterval,_that.isBroadcasting,_that.latitude,_that.longitude,_that.isActive,_that.street,_that.city,_that.state,_that.zipCode,_that.unitNumber,_that.phone,_that.websiteUrl,_that.description,_that.logoUrl,_that.bannerUrl,_that.geoHash,_that.followBonus,_that.operatingHours,_that.programs,_that.charities,_that.loyaltySettings,_that.storeCategories,_that.venueType,_that.squadBonusConfig);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String beaconUuid,  String? beaconPin,  double txPower,  double advInterval,  bool isBroadcasting,  double latitude,  double longitude,  bool isActive,  String? street,  String? city,  String? state,  String? zipCode,  String? unitNumber,  String? phone,  String? websiteUrl,  String? description,  String? logoUrl,  String? bannerUrl,  String? geoHash,  double followBonus,  Map<String, dynamic> operatingHours,  List<VenueProgramModel> programs,  List<VenueCharityModel> charities,  LoyaltySettings loyaltySettings,  List<String> storeCategories,  String venueType,  SquadBonusConfig squadBonusConfig)?  $default,) {final _that = this;
switch (_that) {
case _VenueModel() when $default != null:
return $default(_that.id,_that.name,_that.beaconUuid,_that.beaconPin,_that.txPower,_that.advInterval,_that.isBroadcasting,_that.latitude,_that.longitude,_that.isActive,_that.street,_that.city,_that.state,_that.zipCode,_that.unitNumber,_that.phone,_that.websiteUrl,_that.description,_that.logoUrl,_that.bannerUrl,_that.geoHash,_that.followBonus,_that.operatingHours,_that.programs,_that.charities,_that.loyaltySettings,_that.storeCategories,_that.venueType,_that.squadBonusConfig);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _VenueModel extends VenueModel {
  const _VenueModel({required this.id, required this.name, required this.beaconUuid, this.beaconPin, this.txPower = 0.0, this.advInterval = 1000.0, this.isBroadcasting = true, required this.latitude, required this.longitude, required this.isActive, this.street, this.city, this.state, this.zipCode, this.unitNumber, this.phone, this.websiteUrl, this.description, this.logoUrl, this.bannerUrl, this.geoHash, this.followBonus = 0.0, final  Map<String, dynamic> operatingHours = const {}, final  List<VenueProgramModel> programs = const [], final  List<VenueCharityModel> charities = const [], this.loyaltySettings = const LoyaltySettings(), final  List<String> storeCategories = const ['Merchandise', 'Food & Beverage', 'Sessions', 'Pull Tabs', 'Electronics', 'Other'], this.venueType = 'bingo', this.squadBonusConfig = const SquadBonusConfig()}): _operatingHours = operatingHours,_programs = programs,_charities = charities,_storeCategories = storeCategories,super._();
  factory _VenueModel.fromJson(Map<String, dynamic> json) => _$VenueModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String beaconUuid;
@override final  String? beaconPin;
@override@JsonKey() final  double txPower;
@override@JsonKey() final  double advInterval;
@override@JsonKey() final  bool isBroadcasting;
@override final  double latitude;
@override final  double longitude;
@override final  bool isActive;
@override final  String? street;
@override final  String? city;
@override final  String? state;
@override final  String? zipCode;
@override final  String? unitNumber;
@override final  String? phone;
@override final  String? websiteUrl;
@override final  String? description;
@override final  String? logoUrl;
@override final  String? bannerUrl;
// Geohashing for scalable search
@override final  String? geoHash;
// Bonus Logic
@override@JsonKey() final  double followBonus;
// Operating Hours: Map<String, Map<String, String>> (day -> {open, close})
 final  Map<String, dynamic> _operatingHours;
// Operating Hours: Map<String, Map<String, String>> (day -> {open, close})
@override@JsonKey() Map<String, dynamic> get operatingHours {
  if (_operatingHours is EqualUnmodifiableMapView) return _operatingHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_operatingHours);
}

// Programs
 final  List<VenueProgramModel> _programs;
// Programs
@override@JsonKey() List<VenueProgramModel> get programs {
  if (_programs is EqualUnmodifiableListView) return _programs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_programs);
}

// Charities
 final  List<VenueCharityModel> _charities;
// Charities
@override@JsonKey() List<VenueCharityModel> get charities {
  if (_charities is EqualUnmodifiableListView) return _charities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_charities);
}

// Loyalty Configuration
@override@JsonKey() final  LoyaltySettings loyaltySettings;
// Store Categories
 final  List<String> _storeCategories;
// Store Categories
@override@JsonKey() List<String> get storeCategories {
  if (_storeCategories is EqualUnmodifiableListView) return _storeCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_storeCategories);
}

@override@JsonKey() final  String venueType;
@override@JsonKey() final  SquadBonusConfig squadBonusConfig;

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueModelCopyWith<_VenueModel> get copyWith => __$VenueModelCopyWithImpl<_VenueModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.beaconUuid, beaconUuid) || other.beaconUuid == beaconUuid)&&(identical(other.beaconPin, beaconPin) || other.beaconPin == beaconPin)&&(identical(other.txPower, txPower) || other.txPower == txPower)&&(identical(other.advInterval, advInterval) || other.advInterval == advInterval)&&(identical(other.isBroadcasting, isBroadcasting) || other.isBroadcasting == isBroadcasting)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.unitNumber, unitNumber) || other.unitNumber == unitNumber)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&(identical(other.geoHash, geoHash) || other.geoHash == geoHash)&&(identical(other.followBonus, followBonus) || other.followBonus == followBonus)&&const DeepCollectionEquality().equals(other._operatingHours, _operatingHours)&&const DeepCollectionEquality().equals(other._programs, _programs)&&const DeepCollectionEquality().equals(other._charities, _charities)&&(identical(other.loyaltySettings, loyaltySettings) || other.loyaltySettings == loyaltySettings)&&const DeepCollectionEquality().equals(other._storeCategories, _storeCategories)&&(identical(other.venueType, venueType) || other.venueType == venueType)&&(identical(other.squadBonusConfig, squadBonusConfig) || other.squadBonusConfig == squadBonusConfig));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,beaconUuid,beaconPin,txPower,advInterval,isBroadcasting,latitude,longitude,isActive,street,city,state,zipCode,unitNumber,phone,websiteUrl,description,logoUrl,bannerUrl,geoHash,followBonus,const DeepCollectionEquality().hash(_operatingHours),const DeepCollectionEquality().hash(_programs),const DeepCollectionEquality().hash(_charities),loyaltySettings,const DeepCollectionEquality().hash(_storeCategories),venueType,squadBonusConfig]);

@override
String toString() {
  return 'VenueModel(id: $id, name: $name, beaconUuid: $beaconUuid, beaconPin: $beaconPin, txPower: $txPower, advInterval: $advInterval, isBroadcasting: $isBroadcasting, latitude: $latitude, longitude: $longitude, isActive: $isActive, street: $street, city: $city, state: $state, zipCode: $zipCode, unitNumber: $unitNumber, phone: $phone, websiteUrl: $websiteUrl, description: $description, logoUrl: $logoUrl, bannerUrl: $bannerUrl, geoHash: $geoHash, followBonus: $followBonus, operatingHours: $operatingHours, programs: $programs, charities: $charities, loyaltySettings: $loyaltySettings, storeCategories: $storeCategories, venueType: $venueType, squadBonusConfig: $squadBonusConfig)';
}


}

/// @nodoc
abstract mixin class _$VenueModelCopyWith<$Res> implements $VenueModelCopyWith<$Res> {
  factory _$VenueModelCopyWith(_VenueModel value, $Res Function(_VenueModel) _then) = __$VenueModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String beaconUuid, String? beaconPin, double txPower, double advInterval, bool isBroadcasting, double latitude, double longitude, bool isActive, String? street, String? city, String? state, String? zipCode, String? unitNumber, String? phone, String? websiteUrl, String? description, String? logoUrl, String? bannerUrl, String? geoHash, double followBonus, Map<String, dynamic> operatingHours, List<VenueProgramModel> programs, List<VenueCharityModel> charities, LoyaltySettings loyaltySettings, List<String> storeCategories, String venueType, SquadBonusConfig squadBonusConfig
});


@override $LoyaltySettingsCopyWith<$Res> get loyaltySettings;@override $SquadBonusConfigCopyWith<$Res> get squadBonusConfig;

}
/// @nodoc
class __$VenueModelCopyWithImpl<$Res>
    implements _$VenueModelCopyWith<$Res> {
  __$VenueModelCopyWithImpl(this._self, this._then);

  final _VenueModel _self;
  final $Res Function(_VenueModel) _then;

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? beaconUuid = null,Object? beaconPin = freezed,Object? txPower = null,Object? advInterval = null,Object? isBroadcasting = null,Object? latitude = null,Object? longitude = null,Object? isActive = null,Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? unitNumber = freezed,Object? phone = freezed,Object? websiteUrl = freezed,Object? description = freezed,Object? logoUrl = freezed,Object? bannerUrl = freezed,Object? geoHash = freezed,Object? followBonus = null,Object? operatingHours = null,Object? programs = null,Object? charities = null,Object? loyaltySettings = null,Object? storeCategories = null,Object? venueType = null,Object? squadBonusConfig = null,}) {
  return _then(_VenueModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,beaconUuid: null == beaconUuid ? _self.beaconUuid : beaconUuid // ignore: cast_nullable_to_non_nullable
as String,beaconPin: freezed == beaconPin ? _self.beaconPin : beaconPin // ignore: cast_nullable_to_non_nullable
as String?,txPower: null == txPower ? _self.txPower : txPower // ignore: cast_nullable_to_non_nullable
as double,advInterval: null == advInterval ? _self.advInterval : advInterval // ignore: cast_nullable_to_non_nullable
as double,isBroadcasting: null == isBroadcasting ? _self.isBroadcasting : isBroadcasting // ignore: cast_nullable_to_non_nullable
as bool,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,unitNumber: freezed == unitNumber ? _self.unitNumber : unitNumber // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,geoHash: freezed == geoHash ? _self.geoHash : geoHash // ignore: cast_nullable_to_non_nullable
as String?,followBonus: null == followBonus ? _self.followBonus : followBonus // ignore: cast_nullable_to_non_nullable
as double,operatingHours: null == operatingHours ? _self._operatingHours : operatingHours // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,programs: null == programs ? _self._programs : programs // ignore: cast_nullable_to_non_nullable
as List<VenueProgramModel>,charities: null == charities ? _self._charities : charities // ignore: cast_nullable_to_non_nullable
as List<VenueCharityModel>,loyaltySettings: null == loyaltySettings ? _self.loyaltySettings : loyaltySettings // ignore: cast_nullable_to_non_nullable
as LoyaltySettings,storeCategories: null == storeCategories ? _self._storeCategories : storeCategories // ignore: cast_nullable_to_non_nullable
as List<String>,venueType: null == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as String,squadBonusConfig: null == squadBonusConfig ? _self.squadBonusConfig : squadBonusConfig // ignore: cast_nullable_to_non_nullable
as SquadBonusConfig,
  ));
}

/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoyaltySettingsCopyWith<$Res> get loyaltySettings {
  
  return $LoyaltySettingsCopyWith<$Res>(_self.loyaltySettings, (value) {
    return _then(_self.copyWith(loyaltySettings: value));
  });
}/// Create a copy of VenueModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SquadBonusConfigCopyWith<$Res> get squadBonusConfig {
  
  return $SquadBonusConfigCopyWith<$Res>(_self.squadBonusConfig, (value) {
    return _then(_self.copyWith(squadBonusConfig: value));
  });
}
}


/// @nodoc
mixin _$LoyaltySettings {

 String get currencyName; String get currencySymbol; String get primaryColor;// Hex code
 int get checkInBonus; int get timeDropAmount; int get timeDropInterval;// in minutes
 int? get dailyEarningCap; int get birthdayBonus;
/// Create a copy of LoyaltySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoyaltySettingsCopyWith<LoyaltySettings> get copyWith => _$LoyaltySettingsCopyWithImpl<LoyaltySettings>(this as LoyaltySettings, _$identity);

  /// Serializes this LoyaltySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoyaltySettings&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.checkInBonus, checkInBonus) || other.checkInBonus == checkInBonus)&&(identical(other.timeDropAmount, timeDropAmount) || other.timeDropAmount == timeDropAmount)&&(identical(other.timeDropInterval, timeDropInterval) || other.timeDropInterval == timeDropInterval)&&(identical(other.dailyEarningCap, dailyEarningCap) || other.dailyEarningCap == dailyEarningCap)&&(identical(other.birthdayBonus, birthdayBonus) || other.birthdayBonus == birthdayBonus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currencyName,currencySymbol,primaryColor,checkInBonus,timeDropAmount,timeDropInterval,dailyEarningCap,birthdayBonus);

@override
String toString() {
  return 'LoyaltySettings(currencyName: $currencyName, currencySymbol: $currencySymbol, primaryColor: $primaryColor, checkInBonus: $checkInBonus, timeDropAmount: $timeDropAmount, timeDropInterval: $timeDropInterval, dailyEarningCap: $dailyEarningCap, birthdayBonus: $birthdayBonus)';
}


}

/// @nodoc
abstract mixin class $LoyaltySettingsCopyWith<$Res>  {
  factory $LoyaltySettingsCopyWith(LoyaltySettings value, $Res Function(LoyaltySettings) _then) = _$LoyaltySettingsCopyWithImpl;
@useResult
$Res call({
 String currencyName, String currencySymbol, String primaryColor, int checkInBonus, int timeDropAmount, int timeDropInterval, int? dailyEarningCap, int birthdayBonus
});




}
/// @nodoc
class _$LoyaltySettingsCopyWithImpl<$Res>
    implements $LoyaltySettingsCopyWith<$Res> {
  _$LoyaltySettingsCopyWithImpl(this._self, this._then);

  final LoyaltySettings _self;
  final $Res Function(LoyaltySettings) _then;

/// Create a copy of LoyaltySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currencyName = null,Object? currencySymbol = null,Object? primaryColor = null,Object? checkInBonus = null,Object? timeDropAmount = null,Object? timeDropInterval = null,Object? dailyEarningCap = freezed,Object? birthdayBonus = null,}) {
  return _then(_self.copyWith(
currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,checkInBonus: null == checkInBonus ? _self.checkInBonus : checkInBonus // ignore: cast_nullable_to_non_nullable
as int,timeDropAmount: null == timeDropAmount ? _self.timeDropAmount : timeDropAmount // ignore: cast_nullable_to_non_nullable
as int,timeDropInterval: null == timeDropInterval ? _self.timeDropInterval : timeDropInterval // ignore: cast_nullable_to_non_nullable
as int,dailyEarningCap: freezed == dailyEarningCap ? _self.dailyEarningCap : dailyEarningCap // ignore: cast_nullable_to_non_nullable
as int?,birthdayBonus: null == birthdayBonus ? _self.birthdayBonus : birthdayBonus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LoyaltySettings].
extension LoyaltySettingsPatterns on LoyaltySettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoyaltySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoyaltySettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoyaltySettings value)  $default,){
final _that = this;
switch (_that) {
case _LoyaltySettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoyaltySettings value)?  $default,){
final _that = this;
switch (_that) {
case _LoyaltySettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currencyName,  String currencySymbol,  String primaryColor,  int checkInBonus,  int timeDropAmount,  int timeDropInterval,  int? dailyEarningCap,  int birthdayBonus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoyaltySettings() when $default != null:
return $default(_that.currencyName,_that.currencySymbol,_that.primaryColor,_that.checkInBonus,_that.timeDropAmount,_that.timeDropInterval,_that.dailyEarningCap,_that.birthdayBonus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currencyName,  String currencySymbol,  String primaryColor,  int checkInBonus,  int timeDropAmount,  int timeDropInterval,  int? dailyEarningCap,  int birthdayBonus)  $default,) {final _that = this;
switch (_that) {
case _LoyaltySettings():
return $default(_that.currencyName,_that.currencySymbol,_that.primaryColor,_that.checkInBonus,_that.timeDropAmount,_that.timeDropInterval,_that.dailyEarningCap,_that.birthdayBonus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currencyName,  String currencySymbol,  String primaryColor,  int checkInBonus,  int timeDropAmount,  int timeDropInterval,  int? dailyEarningCap,  int birthdayBonus)?  $default,) {final _that = this;
switch (_that) {
case _LoyaltySettings() when $default != null:
return $default(_that.currencyName,_that.currencySymbol,_that.primaryColor,_that.checkInBonus,_that.timeDropAmount,_that.timeDropInterval,_that.dailyEarningCap,_that.birthdayBonus);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _LoyaltySettings implements LoyaltySettings {
  const _LoyaltySettings({this.currencyName = "Points", this.currencySymbol = "PTS", this.primaryColor = "FFD700", this.checkInBonus = 10, this.timeDropAmount = 5, this.timeDropInterval = 30, this.dailyEarningCap, this.birthdayBonus = 50});
  factory _LoyaltySettings.fromJson(Map<String, dynamic> json) => _$LoyaltySettingsFromJson(json);

@override@JsonKey() final  String currencyName;
@override@JsonKey() final  String currencySymbol;
@override@JsonKey() final  String primaryColor;
// Hex code
@override@JsonKey() final  int checkInBonus;
@override@JsonKey() final  int timeDropAmount;
@override@JsonKey() final  int timeDropInterval;
// in minutes
@override final  int? dailyEarningCap;
@override@JsonKey() final  int birthdayBonus;

/// Create a copy of LoyaltySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoyaltySettingsCopyWith<_LoyaltySettings> get copyWith => __$LoyaltySettingsCopyWithImpl<_LoyaltySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoyaltySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoyaltySettings&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.checkInBonus, checkInBonus) || other.checkInBonus == checkInBonus)&&(identical(other.timeDropAmount, timeDropAmount) || other.timeDropAmount == timeDropAmount)&&(identical(other.timeDropInterval, timeDropInterval) || other.timeDropInterval == timeDropInterval)&&(identical(other.dailyEarningCap, dailyEarningCap) || other.dailyEarningCap == dailyEarningCap)&&(identical(other.birthdayBonus, birthdayBonus) || other.birthdayBonus == birthdayBonus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,currencyName,currencySymbol,primaryColor,checkInBonus,timeDropAmount,timeDropInterval,dailyEarningCap,birthdayBonus);

@override
String toString() {
  return 'LoyaltySettings(currencyName: $currencyName, currencySymbol: $currencySymbol, primaryColor: $primaryColor, checkInBonus: $checkInBonus, timeDropAmount: $timeDropAmount, timeDropInterval: $timeDropInterval, dailyEarningCap: $dailyEarningCap, birthdayBonus: $birthdayBonus)';
}


}

/// @nodoc
abstract mixin class _$LoyaltySettingsCopyWith<$Res> implements $LoyaltySettingsCopyWith<$Res> {
  factory _$LoyaltySettingsCopyWith(_LoyaltySettings value, $Res Function(_LoyaltySettings) _then) = __$LoyaltySettingsCopyWithImpl;
@override @useResult
$Res call({
 String currencyName, String currencySymbol, String primaryColor, int checkInBonus, int timeDropAmount, int timeDropInterval, int? dailyEarningCap, int birthdayBonus
});




}
/// @nodoc
class __$LoyaltySettingsCopyWithImpl<$Res>
    implements _$LoyaltySettingsCopyWith<$Res> {
  __$LoyaltySettingsCopyWithImpl(this._self, this._then);

  final _LoyaltySettings _self;
  final $Res Function(_LoyaltySettings) _then;

/// Create a copy of LoyaltySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currencyName = null,Object? currencySymbol = null,Object? primaryColor = null,Object? checkInBonus = null,Object? timeDropAmount = null,Object? timeDropInterval = null,Object? dailyEarningCap = freezed,Object? birthdayBonus = null,}) {
  return _then(_LoyaltySettings(
currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,primaryColor: null == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String,checkInBonus: null == checkInBonus ? _self.checkInBonus : checkInBonus // ignore: cast_nullable_to_non_nullable
as int,timeDropAmount: null == timeDropAmount ? _self.timeDropAmount : timeDropAmount // ignore: cast_nullable_to_non_nullable
as int,timeDropInterval: null == timeDropInterval ? _self.timeDropInterval : timeDropInterval // ignore: cast_nullable_to_non_nullable
as int,dailyEarningCap: freezed == dailyEarningCap ? _self.dailyEarningCap : dailyEarningCap // ignore: cast_nullable_to_non_nullable
as int?,birthdayBonus: null == birthdayBonus ? _self.birthdayBonus : birthdayBonus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$SquadBonusConfig {

 bool get isSquadBonusActive; double get squadBonusMultiplier; int get gracePeriodMinutes; int get assemblyDurationMinutes; int get assemblyDropAmount; DateTime? get startTime; DateTime? get endTime;
/// Create a copy of SquadBonusConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SquadBonusConfigCopyWith<SquadBonusConfig> get copyWith => _$SquadBonusConfigCopyWithImpl<SquadBonusConfig>(this as SquadBonusConfig, _$identity);

  /// Serializes this SquadBonusConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SquadBonusConfig&&(identical(other.isSquadBonusActive, isSquadBonusActive) || other.isSquadBonusActive == isSquadBonusActive)&&(identical(other.squadBonusMultiplier, squadBonusMultiplier) || other.squadBonusMultiplier == squadBonusMultiplier)&&(identical(other.gracePeriodMinutes, gracePeriodMinutes) || other.gracePeriodMinutes == gracePeriodMinutes)&&(identical(other.assemblyDurationMinutes, assemblyDurationMinutes) || other.assemblyDurationMinutes == assemblyDurationMinutes)&&(identical(other.assemblyDropAmount, assemblyDropAmount) || other.assemblyDropAmount == assemblyDropAmount)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSquadBonusActive,squadBonusMultiplier,gracePeriodMinutes,assemblyDurationMinutes,assemblyDropAmount,startTime,endTime);

@override
String toString() {
  return 'SquadBonusConfig(isSquadBonusActive: $isSquadBonusActive, squadBonusMultiplier: $squadBonusMultiplier, gracePeriodMinutes: $gracePeriodMinutes, assemblyDurationMinutes: $assemblyDurationMinutes, assemblyDropAmount: $assemblyDropAmount, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class $SquadBonusConfigCopyWith<$Res>  {
  factory $SquadBonusConfigCopyWith(SquadBonusConfig value, $Res Function(SquadBonusConfig) _then) = _$SquadBonusConfigCopyWithImpl;
@useResult
$Res call({
 bool isSquadBonusActive, double squadBonusMultiplier, int gracePeriodMinutes, int assemblyDurationMinutes, int assemblyDropAmount, DateTime? startTime, DateTime? endTime
});




}
/// @nodoc
class _$SquadBonusConfigCopyWithImpl<$Res>
    implements $SquadBonusConfigCopyWith<$Res> {
  _$SquadBonusConfigCopyWithImpl(this._self, this._then);

  final SquadBonusConfig _self;
  final $Res Function(SquadBonusConfig) _then;

/// Create a copy of SquadBonusConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSquadBonusActive = null,Object? squadBonusMultiplier = null,Object? gracePeriodMinutes = null,Object? assemblyDurationMinutes = null,Object? assemblyDropAmount = null,Object? startTime = freezed,Object? endTime = freezed,}) {
  return _then(_self.copyWith(
isSquadBonusActive: null == isSquadBonusActive ? _self.isSquadBonusActive : isSquadBonusActive // ignore: cast_nullable_to_non_nullable
as bool,squadBonusMultiplier: null == squadBonusMultiplier ? _self.squadBonusMultiplier : squadBonusMultiplier // ignore: cast_nullable_to_non_nullable
as double,gracePeriodMinutes: null == gracePeriodMinutes ? _self.gracePeriodMinutes : gracePeriodMinutes // ignore: cast_nullable_to_non_nullable
as int,assemblyDurationMinutes: null == assemblyDurationMinutes ? _self.assemblyDurationMinutes : assemblyDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,assemblyDropAmount: null == assemblyDropAmount ? _self.assemblyDropAmount : assemblyDropAmount // ignore: cast_nullable_to_non_nullable
as int,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SquadBonusConfig].
extension SquadBonusConfigPatterns on SquadBonusConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SquadBonusConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SquadBonusConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SquadBonusConfig value)  $default,){
final _that = this;
switch (_that) {
case _SquadBonusConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SquadBonusConfig value)?  $default,){
final _that = this;
switch (_that) {
case _SquadBonusConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSquadBonusActive,  double squadBonusMultiplier,  int gracePeriodMinutes,  int assemblyDurationMinutes,  int assemblyDropAmount,  DateTime? startTime,  DateTime? endTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SquadBonusConfig() when $default != null:
return $default(_that.isSquadBonusActive,_that.squadBonusMultiplier,_that.gracePeriodMinutes,_that.assemblyDurationMinutes,_that.assemblyDropAmount,_that.startTime,_that.endTime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSquadBonusActive,  double squadBonusMultiplier,  int gracePeriodMinutes,  int assemblyDurationMinutes,  int assemblyDropAmount,  DateTime? startTime,  DateTime? endTime)  $default,) {final _that = this;
switch (_that) {
case _SquadBonusConfig():
return $default(_that.isSquadBonusActive,_that.squadBonusMultiplier,_that.gracePeriodMinutes,_that.assemblyDurationMinutes,_that.assemblyDropAmount,_that.startTime,_that.endTime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSquadBonusActive,  double squadBonusMultiplier,  int gracePeriodMinutes,  int assemblyDurationMinutes,  int assemblyDropAmount,  DateTime? startTime,  DateTime? endTime)?  $default,) {final _that = this;
switch (_that) {
case _SquadBonusConfig() when $default != null:
return $default(_that.isSquadBonusActive,_that.squadBonusMultiplier,_that.gracePeriodMinutes,_that.assemblyDurationMinutes,_that.assemblyDropAmount,_that.startTime,_that.endTime);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _SquadBonusConfig implements SquadBonusConfig {
  const _SquadBonusConfig({this.isSquadBonusActive = false, this.squadBonusMultiplier = 1.5, this.gracePeriodMinutes = 3, this.assemblyDurationMinutes = 15, this.assemblyDropAmount = 100, this.startTime, this.endTime});
  factory _SquadBonusConfig.fromJson(Map<String, dynamic> json) => _$SquadBonusConfigFromJson(json);

@override@JsonKey() final  bool isSquadBonusActive;
@override@JsonKey() final  double squadBonusMultiplier;
@override@JsonKey() final  int gracePeriodMinutes;
@override@JsonKey() final  int assemblyDurationMinutes;
@override@JsonKey() final  int assemblyDropAmount;
@override final  DateTime? startTime;
@override final  DateTime? endTime;

/// Create a copy of SquadBonusConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SquadBonusConfigCopyWith<_SquadBonusConfig> get copyWith => __$SquadBonusConfigCopyWithImpl<_SquadBonusConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SquadBonusConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SquadBonusConfig&&(identical(other.isSquadBonusActive, isSquadBonusActive) || other.isSquadBonusActive == isSquadBonusActive)&&(identical(other.squadBonusMultiplier, squadBonusMultiplier) || other.squadBonusMultiplier == squadBonusMultiplier)&&(identical(other.gracePeriodMinutes, gracePeriodMinutes) || other.gracePeriodMinutes == gracePeriodMinutes)&&(identical(other.assemblyDurationMinutes, assemblyDurationMinutes) || other.assemblyDurationMinutes == assemblyDurationMinutes)&&(identical(other.assemblyDropAmount, assemblyDropAmount) || other.assemblyDropAmount == assemblyDropAmount)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSquadBonusActive,squadBonusMultiplier,gracePeriodMinutes,assemblyDurationMinutes,assemblyDropAmount,startTime,endTime);

@override
String toString() {
  return 'SquadBonusConfig(isSquadBonusActive: $isSquadBonusActive, squadBonusMultiplier: $squadBonusMultiplier, gracePeriodMinutes: $gracePeriodMinutes, assemblyDurationMinutes: $assemblyDurationMinutes, assemblyDropAmount: $assemblyDropAmount, startTime: $startTime, endTime: $endTime)';
}


}

/// @nodoc
abstract mixin class _$SquadBonusConfigCopyWith<$Res> implements $SquadBonusConfigCopyWith<$Res> {
  factory _$SquadBonusConfigCopyWith(_SquadBonusConfig value, $Res Function(_SquadBonusConfig) _then) = __$SquadBonusConfigCopyWithImpl;
@override @useResult
$Res call({
 bool isSquadBonusActive, double squadBonusMultiplier, int gracePeriodMinutes, int assemblyDurationMinutes, int assemblyDropAmount, DateTime? startTime, DateTime? endTime
});




}
/// @nodoc
class __$SquadBonusConfigCopyWithImpl<$Res>
    implements _$SquadBonusConfigCopyWith<$Res> {
  __$SquadBonusConfigCopyWithImpl(this._self, this._then);

  final _SquadBonusConfig _self;
  final $Res Function(_SquadBonusConfig) _then;

/// Create a copy of SquadBonusConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSquadBonusActive = null,Object? squadBonusMultiplier = null,Object? gracePeriodMinutes = null,Object? assemblyDurationMinutes = null,Object? assemblyDropAmount = null,Object? startTime = freezed,Object? endTime = freezed,}) {
  return _then(_SquadBonusConfig(
isSquadBonusActive: null == isSquadBonusActive ? _self.isSquadBonusActive : isSquadBonusActive // ignore: cast_nullable_to_non_nullable
as bool,squadBonusMultiplier: null == squadBonusMultiplier ? _self.squadBonusMultiplier : squadBonusMultiplier // ignore: cast_nullable_to_non_nullable
as double,gracePeriodMinutes: null == gracePeriodMinutes ? _self.gracePeriodMinutes : gracePeriodMinutes // ignore: cast_nullable_to_non_nullable
as int,assemblyDurationMinutes: null == assemblyDurationMinutes ? _self.assemblyDurationMinutes : assemblyDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,assemblyDropAmount: null == assemblyDropAmount ? _self.assemblyDropAmount : assemblyDropAmount // ignore: cast_nullable_to_non_nullable
as int,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
