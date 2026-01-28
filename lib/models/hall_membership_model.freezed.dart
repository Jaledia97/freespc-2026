// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hall_membership_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HallMembershipModel {

 String get hallId; String get hallName; double get balance; String get currencyName;// e.g. "Points", "Tokens", "Credits"
 String get tier;// e.g. "Gold", "VIP"
 String? get bannerUrl;
/// Create a copy of HallMembershipModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HallMembershipModelCopyWith<HallMembershipModel> get copyWith => _$HallMembershipModelCopyWithImpl<HallMembershipModel>(this as HallMembershipModel, _$identity);

  /// Serializes this HallMembershipModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HallMembershipModel&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hallId,hallName,balance,currencyName,tier,bannerUrl);

@override
String toString() {
  return 'HallMembershipModel(hallId: $hallId, hallName: $hallName, balance: $balance, currencyName: $currencyName, tier: $tier, bannerUrl: $bannerUrl)';
}


}

/// @nodoc
abstract mixin class $HallMembershipModelCopyWith<$Res>  {
  factory $HallMembershipModelCopyWith(HallMembershipModel value, $Res Function(HallMembershipModel) _then) = _$HallMembershipModelCopyWithImpl;
@useResult
$Res call({
 String hallId, String hallName, double balance, String currencyName, String tier, String? bannerUrl
});




}
/// @nodoc
class _$HallMembershipModelCopyWithImpl<$Res>
    implements $HallMembershipModelCopyWith<$Res> {
  _$HallMembershipModelCopyWithImpl(this._self, this._then);

  final HallMembershipModel _self;
  final $Res Function(HallMembershipModel) _then;

/// Create a copy of HallMembershipModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hallId = null,Object? hallName = null,Object? balance = null,Object? currencyName = null,Object? tier = null,Object? bannerUrl = freezed,}) {
  return _then(_self.copyWith(
hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HallMembershipModel].
extension HallMembershipModelPatterns on HallMembershipModel {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hallId,  String hallName,  double balance,  String currencyName,  String tier,  String? bannerUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HallMembershipModel() when $default != null:
return $default(_that.hallId,_that.hallName,_that.balance,_that.currencyName,_that.tier,_that.bannerUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hallId,  String hallName,  double balance,  String currencyName,  String tier,  String? bannerUrl)  $default,) {final _that = this;
switch (_that) {
case _HallMembershipModel():
return $default(_that.hallId,_that.hallName,_that.balance,_that.currencyName,_that.tier,_that.bannerUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hallId,  String hallName,  double balance,  String currencyName,  String tier,  String? bannerUrl)?  $default,) {final _that = this;
switch (_that) {
case _HallMembershipModel() when $default != null:
return $default(_that.hallId,_that.hallName,_that.balance,_that.currencyName,_that.tier,_that.bannerUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HallMembershipModel implements HallMembershipModel {
  const _HallMembershipModel({required this.hallId, required this.hallName, required this.balance, this.currencyName = 'Points', this.tier = 'Bronze', this.bannerUrl});
  factory _HallMembershipModel.fromJson(Map<String, dynamic> json) => _$HallMembershipModelFromJson(json);

@override final  String hallId;
@override final  String hallName;
@override final  double balance;
@override@JsonKey() final  String currencyName;
// e.g. "Points", "Tokens", "Credits"
@override@JsonKey() final  String tier;
// e.g. "Gold", "VIP"
@override final  String? bannerUrl;

/// Create a copy of HallMembershipModel
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HallMembershipModel&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.currencyName, currencyName) || other.currencyName == currencyName)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hallId,hallName,balance,currencyName,tier,bannerUrl);

@override
String toString() {
  return 'HallMembershipModel(hallId: $hallId, hallName: $hallName, balance: $balance, currencyName: $currencyName, tier: $tier, bannerUrl: $bannerUrl)';
}


}

/// @nodoc
abstract mixin class _$HallMembershipModelCopyWith<$Res> implements $HallMembershipModelCopyWith<$Res> {
  factory _$HallMembershipModelCopyWith(_HallMembershipModel value, $Res Function(_HallMembershipModel) _then) = __$HallMembershipModelCopyWithImpl;
@override @useResult
$Res call({
 String hallId, String hallName, double balance, String currencyName, String tier, String? bannerUrl
});




}
/// @nodoc
class __$HallMembershipModelCopyWithImpl<$Res>
    implements _$HallMembershipModelCopyWith<$Res> {
  __$HallMembershipModelCopyWithImpl(this._self, this._then);

  final _HallMembershipModel _self;
  final $Res Function(_HallMembershipModel) _then;

/// Create a copy of HallMembershipModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hallId = null,Object? hallName = null,Object? balance = null,Object? currencyName = null,Object? tier = null,Object? bannerUrl = freezed,}) {
  return _then(_HallMembershipModel(
hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,currencyName: null == currencyName ? _self.currencyName : currencyName // ignore: cast_nullable_to_non_nullable
as String,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
