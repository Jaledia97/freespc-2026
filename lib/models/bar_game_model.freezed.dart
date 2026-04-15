// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bar_game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BarGameModel {

 String get id; String get venueId; String get gameType;// e.g., 'Darts', 'Billiards', 'Beer Pong'
 String get status;// 'Registration', 'Active', 'Completed'
 int get participantCount; int? get maxParticipants; DateTime? get createdAt;
/// Create a copy of BarGameModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarGameModelCopyWith<BarGameModel> get copyWith => _$BarGameModelCopyWithImpl<BarGameModel>(this as BarGameModel, _$identity);

  /// Serializes this BarGameModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BarGameModel&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.status, status) || other.status == status)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,venueId,gameType,status,participantCount,maxParticipants,createdAt);

@override
String toString() {
  return 'BarGameModel(id: $id, venueId: $venueId, gameType: $gameType, status: $status, participantCount: $participantCount, maxParticipants: $maxParticipants, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BarGameModelCopyWith<$Res>  {
  factory $BarGameModelCopyWith(BarGameModel value, $Res Function(BarGameModel) _then) = _$BarGameModelCopyWithImpl;
@useResult
$Res call({
 String id, String venueId, String gameType, String status, int participantCount, int? maxParticipants, DateTime? createdAt
});




}
/// @nodoc
class _$BarGameModelCopyWithImpl<$Res>
    implements $BarGameModelCopyWith<$Res> {
  _$BarGameModelCopyWithImpl(this._self, this._then);

  final BarGameModel _self;
  final $Res Function(BarGameModel) _then;

/// Create a copy of BarGameModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? venueId = null,Object? gameType = null,Object? status = null,Object? participantCount = null,Object? maxParticipants = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BarGameModel].
extension BarGameModelPatterns on BarGameModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BarGameModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BarGameModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BarGameModel value)  $default,){
final _that = this;
switch (_that) {
case _BarGameModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BarGameModel value)?  $default,){
final _that = this;
switch (_that) {
case _BarGameModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String venueId,  String gameType,  String status,  int participantCount,  int? maxParticipants,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BarGameModel() when $default != null:
return $default(_that.id,_that.venueId,_that.gameType,_that.status,_that.participantCount,_that.maxParticipants,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String venueId,  String gameType,  String status,  int participantCount,  int? maxParticipants,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _BarGameModel():
return $default(_that.id,_that.venueId,_that.gameType,_that.status,_that.participantCount,_that.maxParticipants,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String venueId,  String gameType,  String status,  int participantCount,  int? maxParticipants,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BarGameModel() when $default != null:
return $default(_that.id,_that.venueId,_that.gameType,_that.status,_that.participantCount,_that.maxParticipants,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _BarGameModel extends BarGameModel {
  const _BarGameModel({required this.id, required this.venueId, required this.gameType, this.status = 'Registration', this.participantCount = 0, this.maxParticipants, this.createdAt}): super._();
  factory _BarGameModel.fromJson(Map<String, dynamic> json) => _$BarGameModelFromJson(json);

@override final  String id;
@override final  String venueId;
@override final  String gameType;
// e.g., 'Darts', 'Billiards', 'Beer Pong'
@override@JsonKey() final  String status;
// 'Registration', 'Active', 'Completed'
@override@JsonKey() final  int participantCount;
@override final  int? maxParticipants;
@override final  DateTime? createdAt;

/// Create a copy of BarGameModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BarGameModelCopyWith<_BarGameModel> get copyWith => __$BarGameModelCopyWithImpl<_BarGameModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BarGameModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BarGameModel&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.gameType, gameType) || other.gameType == gameType)&&(identical(other.status, status) || other.status == status)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,venueId,gameType,status,participantCount,maxParticipants,createdAt);

@override
String toString() {
  return 'BarGameModel(id: $id, venueId: $venueId, gameType: $gameType, status: $status, participantCount: $participantCount, maxParticipants: $maxParticipants, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BarGameModelCopyWith<$Res> implements $BarGameModelCopyWith<$Res> {
  factory _$BarGameModelCopyWith(_BarGameModel value, $Res Function(_BarGameModel) _then) = __$BarGameModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String venueId, String gameType, String status, int participantCount, int? maxParticipants, DateTime? createdAt
});




}
/// @nodoc
class __$BarGameModelCopyWithImpl<$Res>
    implements _$BarGameModelCopyWith<$Res> {
  __$BarGameModelCopyWithImpl(this._self, this._then);

  final _BarGameModel _self;
  final $Res Function(_BarGameModel) _then;

/// Create a copy of BarGameModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? venueId = null,Object? gameType = null,Object? status = null,Object? participantCount = null,Object? maxParticipants = freezed,Object? createdAt = freezed,}) {
  return _then(_BarGameModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,gameType: null == gameType ? _self.gameType : gameType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
