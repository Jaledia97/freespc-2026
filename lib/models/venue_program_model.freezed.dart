// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
VenueProgramModel _$VenueProgramModelFromJson(
  Map<String, dynamic> json
) {
    return _HallProgramModel.fromJson(
      json
    );
}

/// @nodoc
mixin _$VenueProgramModel {

 String get title; String get pricing; String get details; List<int> get selectedDays;// 1=Mon, 7=Sun. Empty = Every Day.
 String? get startTime;// e.g., "6:00 PM"
 String? get endTime;// e.g., "9:00 PM"
 DateTime? get overrideEndTime;
/// Create a copy of VenueProgramModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueProgramModelCopyWith<VenueProgramModel> get copyWith => _$VenueProgramModelCopyWithImpl<VenueProgramModel>(this as VenueProgramModel, _$identity);

  /// Serializes this VenueProgramModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueProgramModel&&(identical(other.title, title) || other.title == title)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other.selectedDays, selectedDays)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.overrideEndTime, overrideEndTime) || other.overrideEndTime == overrideEndTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,pricing,details,const DeepCollectionEquality().hash(selectedDays),startTime,endTime,overrideEndTime);

@override
String toString() {
  return 'VenueProgramModel(title: $title, pricing: $pricing, details: $details, selectedDays: $selectedDays, startTime: $startTime, endTime: $endTime, overrideEndTime: $overrideEndTime)';
}


}

/// @nodoc
abstract mixin class $VenueProgramModelCopyWith<$Res>  {
  factory $VenueProgramModelCopyWith(VenueProgramModel value, $Res Function(VenueProgramModel) _then) = _$VenueProgramModelCopyWithImpl;
@useResult
$Res call({
 String title, String pricing, String details, List<int> selectedDays, String? startTime, String? endTime, DateTime? overrideEndTime
});




}
/// @nodoc
class _$VenueProgramModelCopyWithImpl<$Res>
    implements $VenueProgramModelCopyWith<$Res> {
  _$VenueProgramModelCopyWithImpl(this._self, this._then);

  final VenueProgramModel _self;
  final $Res Function(VenueProgramModel) _then;

/// Create a copy of VenueProgramModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? pricing = null,Object? details = null,Object? selectedDays = null,Object? startTime = freezed,Object? endTime = freezed,Object? overrideEndTime = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,selectedDays: null == selectedDays ? _self.selectedDays : selectedDays // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,overrideEndTime: freezed == overrideEndTime ? _self.overrideEndTime : overrideEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueProgramModel].
extension VenueProgramModelPatterns on VenueProgramModel {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String pricing,  String details,  List<int> selectedDays,  String? startTime,  String? endTime,  DateTime? overrideEndTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HallProgramModel() when $default != null:
return $default(_that.title,_that.pricing,_that.details,_that.selectedDays,_that.startTime,_that.endTime,_that.overrideEndTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String pricing,  String details,  List<int> selectedDays,  String? startTime,  String? endTime,  DateTime? overrideEndTime)  $default,) {final _that = this;
switch (_that) {
case _HallProgramModel():
return $default(_that.title,_that.pricing,_that.details,_that.selectedDays,_that.startTime,_that.endTime,_that.overrideEndTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String pricing,  String details,  List<int> selectedDays,  String? startTime,  String? endTime,  DateTime? overrideEndTime)?  $default,) {final _that = this;
switch (_that) {
case _HallProgramModel() when $default != null:
return $default(_that.title,_that.pricing,_that.details,_that.selectedDays,_that.startTime,_that.endTime,_that.overrideEndTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HallProgramModel implements VenueProgramModel {
  const _HallProgramModel({required this.title, this.pricing = '', this.details = '', final  List<int> selectedDays = const [], this.startTime, this.endTime, this.overrideEndTime}): _selectedDays = selectedDays;
  factory _HallProgramModel.fromJson(Map<String, dynamic> json) => _$HallProgramModelFromJson(json);

@override final  String title;
@override@JsonKey() final  String pricing;
@override@JsonKey() final  String details;
 final  List<int> _selectedDays;
@override@JsonKey() List<int> get selectedDays {
  if (_selectedDays is EqualUnmodifiableListView) return _selectedDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedDays);
}

// 1=Mon, 7=Sun. Empty = Every Day.
@override final  String? startTime;
// e.g., "6:00 PM"
@override final  String? endTime;
// e.g., "9:00 PM"
@override final  DateTime? overrideEndTime;

/// Create a copy of VenueProgramModel
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HallProgramModel&&(identical(other.title, title) || other.title == title)&&(identical(other.pricing, pricing) || other.pricing == pricing)&&(identical(other.details, details) || other.details == details)&&const DeepCollectionEquality().equals(other._selectedDays, _selectedDays)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.overrideEndTime, overrideEndTime) || other.overrideEndTime == overrideEndTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,pricing,details,const DeepCollectionEquality().hash(_selectedDays),startTime,endTime,overrideEndTime);

@override
String toString() {
  return 'VenueProgramModel(title: $title, pricing: $pricing, details: $details, selectedDays: $selectedDays, startTime: $startTime, endTime: $endTime, overrideEndTime: $overrideEndTime)';
}


}

/// @nodoc
abstract mixin class _$HallProgramModelCopyWith<$Res> implements $VenueProgramModelCopyWith<$Res> {
  factory _$HallProgramModelCopyWith(_HallProgramModel value, $Res Function(_HallProgramModel) _then) = __$HallProgramModelCopyWithImpl;
@override @useResult
$Res call({
 String title, String pricing, String details, List<int> selectedDays, String? startTime, String? endTime, DateTime? overrideEndTime
});




}
/// @nodoc
class __$HallProgramModelCopyWithImpl<$Res>
    implements _$HallProgramModelCopyWith<$Res> {
  __$HallProgramModelCopyWithImpl(this._self, this._then);

  final _HallProgramModel _self;
  final $Res Function(_HallProgramModel) _then;

/// Create a copy of VenueProgramModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? pricing = null,Object? details = null,Object? selectedDays = null,Object? startTime = freezed,Object? endTime = freezed,Object? overrideEndTime = freezed,}) {
  return _then(_HallProgramModel(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,pricing: null == pricing ? _self.pricing : pricing // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String,selectedDays: null == selectedDays ? _self._selectedDays : selectedDays // ignore: cast_nullable_to_non_nullable
as List<int>,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String?,overrideEndTime: freezed == overrideEndTime ? _self.overrideEndTime : overrideEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
