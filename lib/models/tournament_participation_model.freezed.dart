// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_participation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TournamentParticipationModel {

 String get id; String get tournamentId; String get title; String get hallId;// Added field
 String get hallName;// Kept for fallback
 String get currentPlacement;// e.g. "1st", "Eliminated", "Qualifying"
 String get status;// Active, Completed, Pending
 DateTime get lastUpdated;
/// Create a copy of TournamentParticipationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentParticipationModelCopyWith<TournamentParticipationModel> get copyWith => _$TournamentParticipationModelCopyWithImpl<TournamentParticipationModel>(this as TournamentParticipationModel, _$identity);

  /// Serializes this TournamentParticipationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentParticipationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.title, title) || other.title == title)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.currentPlacement, currentPlacement) || other.currentPlacement == currentPlacement)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,title,hallId,hallName,currentPlacement,status,lastUpdated);

@override
String toString() {
  return 'TournamentParticipationModel(id: $id, tournamentId: $tournamentId, title: $title, hallId: $hallId, hallName: $hallName, currentPlacement: $currentPlacement, status: $status, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $TournamentParticipationModelCopyWith<$Res>  {
  factory $TournamentParticipationModelCopyWith(TournamentParticipationModel value, $Res Function(TournamentParticipationModel) _then) = _$TournamentParticipationModelCopyWithImpl;
@useResult
$Res call({
 String id, String tournamentId, String title, String hallId, String hallName, String currentPlacement, String status, DateTime lastUpdated
});




}
/// @nodoc
class _$TournamentParticipationModelCopyWithImpl<$Res>
    implements $TournamentParticipationModelCopyWith<$Res> {
  _$TournamentParticipationModelCopyWithImpl(this._self, this._then);

  final TournamentParticipationModel _self;
  final $Res Function(TournamentParticipationModel) _then;

/// Create a copy of TournamentParticipationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tournamentId = null,Object? title = null,Object? hallId = null,Object? hallName = null,Object? currentPlacement = null,Object? status = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,currentPlacement: null == currentPlacement ? _self.currentPlacement : currentPlacement // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentParticipationModel].
extension TournamentParticipationModelPatterns on TournamentParticipationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentParticipationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentParticipationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentParticipationModel value)  $default,){
final _that = this;
switch (_that) {
case _TournamentParticipationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentParticipationModel value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentParticipationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String title,  String hallId,  String hallName,  String currentPlacement,  String status,  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentParticipationModel() when $default != null:
return $default(_that.id,_that.tournamentId,_that.title,_that.hallId,_that.hallName,_that.currentPlacement,_that.status,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tournamentId,  String title,  String hallId,  String hallName,  String currentPlacement,  String status,  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _TournamentParticipationModel():
return $default(_that.id,_that.tournamentId,_that.title,_that.hallId,_that.hallName,_that.currentPlacement,_that.status,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tournamentId,  String title,  String hallId,  String hallName,  String currentPlacement,  String status,  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _TournamentParticipationModel() when $default != null:
return $default(_that.id,_that.tournamentId,_that.title,_that.hallId,_that.hallName,_that.currentPlacement,_that.status,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentParticipationModel implements TournamentParticipationModel {
  const _TournamentParticipationModel({required this.id, required this.tournamentId, required this.title, required this.hallId, required this.hallName, required this.currentPlacement, required this.status, required this.lastUpdated});
  factory _TournamentParticipationModel.fromJson(Map<String, dynamic> json) => _$TournamentParticipationModelFromJson(json);

@override final  String id;
@override final  String tournamentId;
@override final  String title;
@override final  String hallId;
// Added field
@override final  String hallName;
// Kept for fallback
@override final  String currentPlacement;
// e.g. "1st", "Eliminated", "Qualifying"
@override final  String status;
// Active, Completed, Pending
@override final  DateTime lastUpdated;

/// Create a copy of TournamentParticipationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentParticipationModelCopyWith<_TournamentParticipationModel> get copyWith => __$TournamentParticipationModelCopyWithImpl<_TournamentParticipationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentParticipationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentParticipationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.tournamentId, tournamentId) || other.tournamentId == tournamentId)&&(identical(other.title, title) || other.title == title)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.currentPlacement, currentPlacement) || other.currentPlacement == currentPlacement)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tournamentId,title,hallId,hallName,currentPlacement,status,lastUpdated);

@override
String toString() {
  return 'TournamentParticipationModel(id: $id, tournamentId: $tournamentId, title: $title, hallId: $hallId, hallName: $hallName, currentPlacement: $currentPlacement, status: $status, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$TournamentParticipationModelCopyWith<$Res> implements $TournamentParticipationModelCopyWith<$Res> {
  factory _$TournamentParticipationModelCopyWith(_TournamentParticipationModel value, $Res Function(_TournamentParticipationModel) _then) = __$TournamentParticipationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String tournamentId, String title, String hallId, String hallName, String currentPlacement, String status, DateTime lastUpdated
});




}
/// @nodoc
class __$TournamentParticipationModelCopyWithImpl<$Res>
    implements _$TournamentParticipationModelCopyWith<$Res> {
  __$TournamentParticipationModelCopyWithImpl(this._self, this._then);

  final _TournamentParticipationModel _self;
  final $Res Function(_TournamentParticipationModel) _then;

/// Create a copy of TournamentParticipationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tournamentId = null,Object? title = null,Object? hallId = null,Object? hallName = null,Object? currentPlacement = null,Object? status = null,Object? lastUpdated = null,}) {
  return _then(_TournamentParticipationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tournamentId: null == tournamentId ? _self.tournamentId : tournamentId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,currentPlacement: null == currentPlacement ? _self.currentPlacement : currentPlacement // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
