// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raffle_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RaffleModel {

 String get id; String get hallId; String get name;// Was title
 String get description; String get imageUrl; int get maxTickets; int get soldTickets; DateTime get endsAt;
/// Create a copy of RaffleModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaffleModelCopyWith<RaffleModel> get copyWith => _$RaffleModelCopyWithImpl<RaffleModel>(this as RaffleModel, _$identity);

  /// Serializes this RaffleModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaffleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.maxTickets, maxTickets) || other.maxTickets == maxTickets)&&(identical(other.soldTickets, soldTickets) || other.soldTickets == soldTickets)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,name,description,imageUrl,maxTickets,soldTickets,endsAt);

@override
String toString() {
  return 'RaffleModel(id: $id, hallId: $hallId, name: $name, description: $description, imageUrl: $imageUrl, maxTickets: $maxTickets, soldTickets: $soldTickets, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $RaffleModelCopyWith<$Res>  {
  factory $RaffleModelCopyWith(RaffleModel value, $Res Function(RaffleModel) _then) = _$RaffleModelCopyWithImpl;
@useResult
$Res call({
 String id, String hallId, String name, String description, String imageUrl, int maxTickets, int soldTickets, DateTime endsAt
});




}
/// @nodoc
class _$RaffleModelCopyWithImpl<$Res>
    implements $RaffleModelCopyWith<$Res> {
  _$RaffleModelCopyWithImpl(this._self, this._then);

  final RaffleModel _self;
  final $Res Function(RaffleModel) _then;

/// Create a copy of RaffleModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hallId = null,Object? name = null,Object? description = null,Object? imageUrl = null,Object? maxTickets = null,Object? soldTickets = null,Object? endsAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,maxTickets: null == maxTickets ? _self.maxTickets : maxTickets // ignore: cast_nullable_to_non_nullable
as int,soldTickets: null == soldTickets ? _self.soldTickets : soldTickets // ignore: cast_nullable_to_non_nullable
as int,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RaffleModel].
extension RaffleModelPatterns on RaffleModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaffleModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaffleModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaffleModel value)  $default,){
final _that = this;
switch (_that) {
case _RaffleModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaffleModel value)?  $default,){
final _that = this;
switch (_that) {
case _RaffleModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String hallId,  String name,  String description,  String imageUrl,  int maxTickets,  int soldTickets,  DateTime endsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaffleModel() when $default != null:
return $default(_that.id,_that.hallId,_that.name,_that.description,_that.imageUrl,_that.maxTickets,_that.soldTickets,_that.endsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String hallId,  String name,  String description,  String imageUrl,  int maxTickets,  int soldTickets,  DateTime endsAt)  $default,) {final _that = this;
switch (_that) {
case _RaffleModel():
return $default(_that.id,_that.hallId,_that.name,_that.description,_that.imageUrl,_that.maxTickets,_that.soldTickets,_that.endsAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String hallId,  String name,  String description,  String imageUrl,  int maxTickets,  int soldTickets,  DateTime endsAt)?  $default,) {final _that = this;
switch (_that) {
case _RaffleModel() when $default != null:
return $default(_that.id,_that.hallId,_that.name,_that.description,_that.imageUrl,_that.maxTickets,_that.soldTickets,_that.endsAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RaffleModel implements RaffleModel {
  const _RaffleModel({required this.id, required this.hallId, required this.name, required this.description, required this.imageUrl, this.maxTickets = 100, this.soldTickets = 0, required this.endsAt});
  factory _RaffleModel.fromJson(Map<String, dynamic> json) => _$RaffleModelFromJson(json);

@override final  String id;
@override final  String hallId;
@override final  String name;
// Was title
@override final  String description;
@override final  String imageUrl;
@override@JsonKey() final  int maxTickets;
@override@JsonKey() final  int soldTickets;
@override final  DateTime endsAt;

/// Create a copy of RaffleModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaffleModelCopyWith<_RaffleModel> get copyWith => __$RaffleModelCopyWithImpl<_RaffleModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RaffleModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaffleModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.maxTickets, maxTickets) || other.maxTickets == maxTickets)&&(identical(other.soldTickets, soldTickets) || other.soldTickets == soldTickets)&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,name,description,imageUrl,maxTickets,soldTickets,endsAt);

@override
String toString() {
  return 'RaffleModel(id: $id, hallId: $hallId, name: $name, description: $description, imageUrl: $imageUrl, maxTickets: $maxTickets, soldTickets: $soldTickets, endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class _$RaffleModelCopyWith<$Res> implements $RaffleModelCopyWith<$Res> {
  factory _$RaffleModelCopyWith(_RaffleModel value, $Res Function(_RaffleModel) _then) = __$RaffleModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String hallId, String name, String description, String imageUrl, int maxTickets, int soldTickets, DateTime endsAt
});




}
/// @nodoc
class __$RaffleModelCopyWithImpl<$Res>
    implements _$RaffleModelCopyWith<$Res> {
  __$RaffleModelCopyWithImpl(this._self, this._then);

  final _RaffleModel _self;
  final $Res Function(_RaffleModel) _then;

/// Create a copy of RaffleModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hallId = null,Object? name = null,Object? description = null,Object? imageUrl = null,Object? maxTickets = null,Object? soldTickets = null,Object? endsAt = null,}) {
  return _then(_RaffleModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,maxTickets: null == maxTickets ? _self.maxTickets : maxTickets // ignore: cast_nullable_to_non_nullable
as int,soldTickets: null == soldTickets ? _self.soldTickets : soldTickets // ignore: cast_nullable_to_non_nullable
as int,endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
