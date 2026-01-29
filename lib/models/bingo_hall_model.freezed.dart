// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bingo_hall_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BingoHallModel {

 String get id; String get name; String get beaconUuid; double get latitude; double get longitude; bool get isActive; String? get street; String? get city; String? get state; String? get zipCode; String? get phone; String? get websiteUrl; String? get description;// Geohashing for scalable search
 String? get geoHash;// Bonus Logic
 double get followBonus;
/// Create a copy of BingoHallModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BingoHallModelCopyWith<BingoHallModel> get copyWith => _$BingoHallModelCopyWithImpl<BingoHallModel>(this as BingoHallModel, _$identity);

  /// Serializes this BingoHallModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BingoHallModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.beaconUuid, beaconUuid) || other.beaconUuid == beaconUuid)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.geoHash, geoHash) || other.geoHash == geoHash)&&(identical(other.followBonus, followBonus) || other.followBonus == followBonus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,beaconUuid,latitude,longitude,isActive,street,city,state,zipCode,phone,websiteUrl,description,geoHash,followBonus);

@override
String toString() {
  return 'BingoHallModel(id: $id, name: $name, beaconUuid: $beaconUuid, latitude: $latitude, longitude: $longitude, isActive: $isActive, street: $street, city: $city, state: $state, zipCode: $zipCode, phone: $phone, websiteUrl: $websiteUrl, description: $description, geoHash: $geoHash, followBonus: $followBonus)';
}


}

/// @nodoc
abstract mixin class $BingoHallModelCopyWith<$Res>  {
  factory $BingoHallModelCopyWith(BingoHallModel value, $Res Function(BingoHallModel) _then) = _$BingoHallModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String beaconUuid, double latitude, double longitude, bool isActive, String? street, String? city, String? state, String? zipCode, String? phone, String? websiteUrl, String? description, String? geoHash, double followBonus
});




}
/// @nodoc
class _$BingoHallModelCopyWithImpl<$Res>
    implements $BingoHallModelCopyWith<$Res> {
  _$BingoHallModelCopyWithImpl(this._self, this._then);

  final BingoHallModel _self;
  final $Res Function(BingoHallModel) _then;

/// Create a copy of BingoHallModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? beaconUuid = null,Object? latitude = null,Object? longitude = null,Object? isActive = null,Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? phone = freezed,Object? websiteUrl = freezed,Object? description = freezed,Object? geoHash = freezed,Object? followBonus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,beaconUuid: null == beaconUuid ? _self.beaconUuid : beaconUuid // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,geoHash: freezed == geoHash ? _self.geoHash : geoHash // ignore: cast_nullable_to_non_nullable
as String?,followBonus: null == followBonus ? _self.followBonus : followBonus // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BingoHallModel].
extension BingoHallModelPatterns on BingoHallModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BingoHallModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BingoHallModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BingoHallModel value)  $default,){
final _that = this;
switch (_that) {
case _BingoHallModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BingoHallModel value)?  $default,){
final _that = this;
switch (_that) {
case _BingoHallModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String beaconUuid,  double latitude,  double longitude,  bool isActive,  String? street,  String? city,  String? state,  String? zipCode,  String? phone,  String? websiteUrl,  String? description,  String? geoHash,  double followBonus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BingoHallModel() when $default != null:
return $default(_that.id,_that.name,_that.beaconUuid,_that.latitude,_that.longitude,_that.isActive,_that.street,_that.city,_that.state,_that.zipCode,_that.phone,_that.websiteUrl,_that.description,_that.geoHash,_that.followBonus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String beaconUuid,  double latitude,  double longitude,  bool isActive,  String? street,  String? city,  String? state,  String? zipCode,  String? phone,  String? websiteUrl,  String? description,  String? geoHash,  double followBonus)  $default,) {final _that = this;
switch (_that) {
case _BingoHallModel():
return $default(_that.id,_that.name,_that.beaconUuid,_that.latitude,_that.longitude,_that.isActive,_that.street,_that.city,_that.state,_that.zipCode,_that.phone,_that.websiteUrl,_that.description,_that.geoHash,_that.followBonus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String beaconUuid,  double latitude,  double longitude,  bool isActive,  String? street,  String? city,  String? state,  String? zipCode,  String? phone,  String? websiteUrl,  String? description,  String? geoHash,  double followBonus)?  $default,) {final _that = this;
switch (_that) {
case _BingoHallModel() when $default != null:
return $default(_that.id,_that.name,_that.beaconUuid,_that.latitude,_that.longitude,_that.isActive,_that.street,_that.city,_that.state,_that.zipCode,_that.phone,_that.websiteUrl,_that.description,_that.geoHash,_that.followBonus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BingoHallModel extends BingoHallModel {
  const _BingoHallModel({required this.id, required this.name, required this.beaconUuid, required this.latitude, required this.longitude, required this.isActive, this.street, this.city, this.state, this.zipCode, this.phone, this.websiteUrl, this.description, this.geoHash, this.followBonus = 0.0}): super._();
  factory _BingoHallModel.fromJson(Map<String, dynamic> json) => _$BingoHallModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String beaconUuid;
@override final  double latitude;
@override final  double longitude;
@override final  bool isActive;
@override final  String? street;
@override final  String? city;
@override final  String? state;
@override final  String? zipCode;
@override final  String? phone;
@override final  String? websiteUrl;
@override final  String? description;
// Geohashing for scalable search
@override final  String? geoHash;
// Bonus Logic
@override@JsonKey() final  double followBonus;

/// Create a copy of BingoHallModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BingoHallModelCopyWith<_BingoHallModel> get copyWith => __$BingoHallModelCopyWithImpl<_BingoHallModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BingoHallModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BingoHallModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.beaconUuid, beaconUuid) || other.beaconUuid == beaconUuid)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.geoHash, geoHash) || other.geoHash == geoHash)&&(identical(other.followBonus, followBonus) || other.followBonus == followBonus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,beaconUuid,latitude,longitude,isActive,street,city,state,zipCode,phone,websiteUrl,description,geoHash,followBonus);

@override
String toString() {
  return 'BingoHallModel(id: $id, name: $name, beaconUuid: $beaconUuid, latitude: $latitude, longitude: $longitude, isActive: $isActive, street: $street, city: $city, state: $state, zipCode: $zipCode, phone: $phone, websiteUrl: $websiteUrl, description: $description, geoHash: $geoHash, followBonus: $followBonus)';
}


}

/// @nodoc
abstract mixin class _$BingoHallModelCopyWith<$Res> implements $BingoHallModelCopyWith<$Res> {
  factory _$BingoHallModelCopyWith(_BingoHallModel value, $Res Function(_BingoHallModel) _then) = __$BingoHallModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String beaconUuid, double latitude, double longitude, bool isActive, String? street, String? city, String? state, String? zipCode, String? phone, String? websiteUrl, String? description, String? geoHash, double followBonus
});




}
/// @nodoc
class __$BingoHallModelCopyWithImpl<$Res>
    implements _$BingoHallModelCopyWith<$Res> {
  __$BingoHallModelCopyWithImpl(this._self, this._then);

  final _BingoHallModel _self;
  final $Res Function(_BingoHallModel) _then;

/// Create a copy of BingoHallModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? beaconUuid = null,Object? latitude = null,Object? longitude = null,Object? isActive = null,Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? zipCode = freezed,Object? phone = freezed,Object? websiteUrl = freezed,Object? description = freezed,Object? geoHash = freezed,Object? followBonus = null,}) {
  return _then(_BingoHallModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,beaconUuid: null == beaconUuid ? _self.beaconUuid : beaconUuid // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,geoHash: freezed == geoHash ? _self.geoHash : geoHash // ignore: cast_nullable_to_non_nullable
as String?,followBonus: null == followBonus ? _self.followBonus : followBonus // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
