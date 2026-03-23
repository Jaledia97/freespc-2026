// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'squad_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SquadModel {

 String get id; String get name; List<String> get memberIds; String get captainId;
/// Create a copy of SquadModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SquadModelCopyWith<SquadModel> get copyWith => _$SquadModelCopyWithImpl<SquadModel>(this as SquadModel, _$identity);

  /// Serializes this SquadModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SquadModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.captainId, captainId) || other.captainId == captainId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(memberIds),captainId);

@override
String toString() {
  return 'SquadModel(id: $id, name: $name, memberIds: $memberIds, captainId: $captainId)';
}


}

/// @nodoc
abstract mixin class $SquadModelCopyWith<$Res>  {
  factory $SquadModelCopyWith(SquadModel value, $Res Function(SquadModel) _then) = _$SquadModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<String> memberIds, String captainId
});




}
/// @nodoc
class _$SquadModelCopyWithImpl<$Res>
    implements $SquadModelCopyWith<$Res> {
  _$SquadModelCopyWithImpl(this._self, this._then);

  final SquadModel _self;
  final $Res Function(SquadModel) _then;

/// Create a copy of SquadModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? memberIds = null,Object? captainId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,captainId: null == captainId ? _self.captainId : captainId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SquadModel].
extension SquadModelPatterns on SquadModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SquadModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SquadModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SquadModel value)  $default,){
final _that = this;
switch (_that) {
case _SquadModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SquadModel value)?  $default,){
final _that = this;
switch (_that) {
case _SquadModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<String> memberIds,  String captainId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SquadModel() when $default != null:
return $default(_that.id,_that.name,_that.memberIds,_that.captainId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<String> memberIds,  String captainId)  $default,) {final _that = this;
switch (_that) {
case _SquadModel():
return $default(_that.id,_that.name,_that.memberIds,_that.captainId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<String> memberIds,  String captainId)?  $default,) {final _that = this;
switch (_that) {
case _SquadModel() when $default != null:
return $default(_that.id,_that.name,_that.memberIds,_that.captainId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SquadModel extends SquadModel {
  const _SquadModel({required this.id, required this.name, final  List<String> memberIds = const [], required this.captainId}): _memberIds = memberIds,super._();
  factory _SquadModel.fromJson(Map<String, dynamic> json) => _$SquadModelFromJson(json);

@override final  String id;
@override final  String name;
 final  List<String> _memberIds;
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override final  String captainId;

/// Create a copy of SquadModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SquadModelCopyWith<_SquadModel> get copyWith => __$SquadModelCopyWithImpl<_SquadModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SquadModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SquadModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.captainId, captainId) || other.captainId == captainId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_memberIds),captainId);

@override
String toString() {
  return 'SquadModel(id: $id, name: $name, memberIds: $memberIds, captainId: $captainId)';
}


}

/// @nodoc
abstract mixin class _$SquadModelCopyWith<$Res> implements $SquadModelCopyWith<$Res> {
  factory _$SquadModelCopyWith(_SquadModel value, $Res Function(_SquadModel) _then) = __$SquadModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<String> memberIds, String captainId
});




}
/// @nodoc
class __$SquadModelCopyWithImpl<$Res>
    implements _$SquadModelCopyWith<$Res> {
  __$SquadModelCopyWithImpl(this._self, this._then);

  final _SquadModel _self;
  final $Res Function(_SquadModel) _then;

/// Create a copy of SquadModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? memberIds = null,Object? captainId = null,}) {
  return _then(_SquadModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,captainId: null == captainId ? _self.captainId : captainId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
