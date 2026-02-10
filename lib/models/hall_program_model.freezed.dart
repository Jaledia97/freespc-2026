// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hall_program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HallProgramModel {

 String get title; String get pricing; String get details; String? get specificDay;// e.g., "Monday", "Tuesday", or null for "Any Day" / "General"
 String? get startTime;// e.g., "6:00 PM"
 String? get endTime;// e.g., "9:00 PM"
 bool get isActive;
/// Create a copy of HallProgramModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HallProgramModelCopyWith<HallProgramModel> get copyWith => _$HallProgramModelCopyWithImpl<HallProgramModel>(this as HallProgramModel, _$identity);

  /// Serializes this HallProgramModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HallProgramModel&&(identical(other.title, title) || other.title == title)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.details, details) || other.details == details)&&(identical(other.specificDay, specificDay) || other.specificDay == specificDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,pricing,details,specificDay,startTime,endTime,isActive);

@override
String toString() {
  return 'HallProgramModel(title: $title, pricing: $pricing, details: $details, specificDay: $specificDay, startTime: $startTime, endTime: $endTime, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $HallProgramModelCopyWith<$Res>  {
  factory $HallProgramModelCopyWith(HallProgramModel value, $Res Function(HallProgramModel) _then) = _$HallProgramModelCopyWithImpl;
@useResult
$Res call({
 String title, String pricing, String details, String? specificDay, String? startTime, String? endTime, bool isActive
});




}
/// @nodoc
class _$HallProgramModelCopyWithImpl<$Res>
    implements $HallProgramModelCopyWith<$Res> {
  _$HallProgramModelCopyWithImpl(this._self, this._then);

  final HallProgramModel _self;
  final $Res Function(HallProgramModel) _then;

/// Create a copy of HallProgramModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? pricing = null,Object? details = null,Object? specificDay = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,specificDay: freezed == specificDay ? _self.specificDay : specificDay // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [HallProgramModel].
extension HallProgramModelPatterns on HallProgramModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HallProgramModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HallProgramModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HallProgramModel value)  $default,){
final _that = this;
switch (_that) {
case _HallProgramModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HallProgramModel value)?  $default,){
final _that = this;
switch (_that) {
case _HallProgramModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String pricing,  String details,  String? specificDay,  String? startTime,  String? endTime,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HallProgramModel() when $default != null:
return $default(_that.title,_that.pricing,_that.details,_that.specificDay,_that.startTime,_that.endTime,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String pricing,  String details,  String? specificDay,  String? startTime,  String? endTime,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _HallProgramModel():
return $default(_that.title,_that.pricing,_that.details,_that.specificDay,_that.startTime,_that.endTime,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String pricing,  String details,  String? specificDay,  String? startTime,  String? endTime,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _HallProgramModel() when $default != null:
return $default(_that.title,_that.pricing,_that.details,_that.specificDay,_that.startTime,_that.endTime,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HallProgramModel implements HallProgramModel {
  const _HallProgramModel({required this.title, this.pricing = '', this.details = '', this.specificDay, this.startTime, this.endTime, this.isActive = true});
  factory _HallProgramModel.fromJson(Map<String, dynamic> json) => _$HallProgramModelFromJson(json);

@override final  String title;
@override@JsonKey() final  String pricing;
@override@JsonKey() final  String details;
@override final  String? specificDay;
// e.g., "Monday", "Tuesday", or null for "Any Day" / "General"
@override final  String? startTime;
// e.g., "6:00 PM"
@override final  String? endTime;
// e.g., "9:00 PM"
@override@JsonKey() final  bool isActive;

/// Create a copy of HallProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HallProgramModelCopyWith<_HallProgramModel> get copyWith => __$HallProgramModelCopyWithImpl<_HallProgramModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HallProgramModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HallProgramModel&&(identical(other.title, title) || other.title == title)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.details, details) || other.details == details)&&(identical(other.specificDay, specificDay) || other.specificDay == specificDay)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,pricing,details,specificDay,startTime,endTime,isActive);

@override
String toString() {
  return 'HallProgramModel(title: $title, pricing: $pricing, details: $details, specificDay: $specificDay, startTime: $startTime, endTime: $endTime, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$HallProgramModelCopyWith<$Res> implements $HallProgramModelCopyWith<$Res> {
  factory _$HallProgramModelCopyWith(_HallProgramModel value, $Res Function(_HallProgramModel) _then) = __$HallProgramModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String pricing, String details, String? specificDay, String? startTime, String? endTime, bool isActive
});




}
/// @nodoc
class __$HallProgramModelCopyWithImpl<$Res>
    implements _$HallProgramModelCopyWith<$Res> {
  __$HallProgramModelCopyWithImpl(this._self, this._then);

  final _HallProgramModel _self;
  final $Res Function(_HallProgramModel) _then;

/// Create a copy of HallProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? pricing = null,Object? details = null,Object? specificDay = freezed,Object? startTime = freezed,Object? endTime = freezed,Object? isActive = null,}) {
  return _then(_HallProgramModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,specificDay: freezed == specificDay ? _self.specificDay : specificDay // ignore: cast_nullable_to_non_nullable
as String?,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
