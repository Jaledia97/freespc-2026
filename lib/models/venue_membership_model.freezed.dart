// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
VenueMembershipModel _$VenueMembershipModelFromJson(
  Map<String, dynamic> json
) {
    return _HallMembershipModel.fromJson(
      json
    );
}

/// @nodoc
mixin _$VenueMembershipModel {

 String get venueId; String get venueName; double get balance; String get currencyName;// e.g. "Points", "Tokens", "Credits"
 String get tier;// e.g. "Gold", "VIP"
 String? get bannerUrl;
/// Create a copy of VenueMembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueMembershipModelCopyWith<VenueMembershipModel> get copyWith => _$VenueMembershipModelCopyWithImpl<VenueMembershipModel>(this as VenueMembershipModel, _$identity);

  /// Serializes this VenueMembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueMembershipModel&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,venueId,venueName,balance,currencyName,tier,bannerUrl);

@override
String toString() {
  return 'VenueMembershipModel(venueId: $venueId, venueName: $venueName, balance: $balance, currencyName: $currencyName, tier: $tier, bannerUrl: $bannerUrl)';
}


}

/// @nodoc
abstract mixin class $VenueMembershipModelCopyWith<$Res>  {
  factory $VenueMembershipModelCopyWith(VenueMembershipModel value, $Res Function(VenueMembershipModel) _then) = _$VenueMembershipModelCopyWithImpl;
@useResult
$Res call({
 String venueId, String venueName, double balance, String currencyName, String tier, String? bannerUrl
});




}
/// @nodoc
class _$VenueMembershipModelCopyWithImpl<$Res>
    implements $VenueMembershipModelCopyWith<$Res> {
  _$VenueMembershipModelCopyWithImpl(this._self, this._then);

  final VenueMembershipModel _self;
  final $Res Function(VenueMembershipModel) _then;

/// Create a copy of VenueMembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? venueId = null,Object? venueName = null,Object? balance = null,Object? currencyName = null,Object? tier = null,Object? bannerUrl = freezed,}) {
  return _then(_self.copyWith(
venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueMembershipModel].
extension VenueMembershipModelPatterns on VenueMembershipModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HallMembershipModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HallMembershipModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HallMembershipModel value)  $default,){
final _that = this;
switch (_that) {
case _HallMembershipModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HallMembershipModel value)?  $default,){
final _that = this;
switch (_that) {
case _HallMembershipModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String venueId,  String venueName,  double balance,  String currencyName,  String tier,  String? bannerUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HallMembershipModel() when $default != null:
return $default(_that.venueId,_that.venueName,_that.balance,_that.currencyName,_that.tier,_that.bannerUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String venueId,  String venueName,  double balance,  String currencyName,  String tier,  String? bannerUrl)  $default,) {final _that = this;
switch (_that) {
case _HallMembershipModel():
return $default(_that.venueId,_that.venueName,_that.balance,_that.currencyName,_that.tier,_that.bannerUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String venueId,  String venueName,  double balance,  String currencyName,  String tier,  String? bannerUrl)?  $default,) {final _that = this;
switch (_that) {
case _HallMembershipModel() when $default != null:
return $default(_that.venueId,_that.venueName,_that.balance,_that.currencyName,_that.tier,_that.bannerUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HallMembershipModel implements VenueMembershipModel {
  const _HallMembershipModel({required this.venueId, required this.venueName, required this.balance, this.currencyName = 'Points', this.tier = 'Bronze', this.bannerUrl});
  factory _HallMembershipModel.fromJson(Map<String, dynamic> json) => _$HallMembershipModelFromJson(json);

@override final  String venueId;
@override final  String venueName;
@override final  double balance;
@override@JsonKey() final  String currencyName;
// e.g. "Points", "Tokens", "Credits"
@override@JsonKey() final  String tier;
// e.g. "Gold", "VIP"
@override final  String? bannerUrl;

/// Create a copy of VenueMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HallMembershipModelCopyWith<_HallMembershipModel> get copyWith => __$HallMembershipModelCopyWithImpl<_HallMembershipModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HallMembershipModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HallMembershipModel&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,venueId,venueName,balance,currencyName,tier,bannerUrl);

@override
String toString() {
  return 'VenueMembershipModel(venueId: $venueId, venueName: $venueName, balance: $balance, currencyName: $currencyName, tier: $tier, bannerUrl: $bannerUrl)';
}


}

/// @nodoc
abstract mixin class _$HallMembershipModelCopyWith<$Res> implements $VenueMembershipModelCopyWith<$Res> {
  factory _$HallMembershipModelCopyWith(_HallMembershipModel value, $Res Function(_HallMembershipModel) _then) = __$HallMembershipModelCopyWithImpl;
@override @useResult
$Res call({
 String venueId, String venueName, double balance, String currencyName, String tier, String? bannerUrl
});




}
/// @nodoc
class __$HallMembershipModelCopyWithImpl<$Res>
    implements _$HallMembershipModelCopyWith<$Res> {
  __$HallMembershipModelCopyWithImpl(this._self, this._then);

  final _HallMembershipModel _self;
  final $Res Function(_HallMembershipModel) _then;

/// Create a copy of VenueMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? venueId = null,Object? venueName = null,Object? balance = null,Object? currencyName = null,Object? tier = null,Object? bannerUrl = freezed,}) {
  return _then(_HallMembershipModel(
venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
