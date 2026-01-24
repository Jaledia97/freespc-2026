// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'special_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SpecialModel {

 String get id; String get hallId; String get hallName; String get title; String get description; String get imageUrl; DateTime get postedAt; DateTime? get startTime; double? get latitude; double? get longitude; List<String> get tags;
/// Create a copy of SpecialModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpecialModelCopyWith<SpecialModel> get copyWith => _$SpecialModelCopyWithImpl<SpecialModel>(this as SpecialModel, _$identity);

  /// Serializes this SpecialModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpecialModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,hallName,title,description,imageUrl,postedAt,startTime,latitude,longitude,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'SpecialModel(id: $id, hallId: $hallId, hallName: $hallName, title: $title, description: $description, imageUrl: $imageUrl, postedAt: $postedAt, startTime: $startTime, latitude: $latitude, longitude: $longitude, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $SpecialModelCopyWith<$Res>  {
  factory $SpecialModelCopyWith(SpecialModel value, $Res Function(SpecialModel) _then) = _$SpecialModelCopyWithImpl;
@useResult
$Res call({
 String id, String hallId, String hallName, String title, String description, String imageUrl, DateTime postedAt, DateTime? startTime, double? latitude, double? longitude, List<String> tags
});




}
/// @nodoc
class _$SpecialModelCopyWithImpl<$Res>
    implements $SpecialModelCopyWith<$Res> {
  _$SpecialModelCopyWithImpl(this._self, this._then);

  final SpecialModel _self;
  final $Res Function(SpecialModel) _then;

/// Create a copy of SpecialModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hallId = null,Object? hallName = null,Object? title = null,Object? description = null,Object? imageUrl = null,Object? postedAt = null,Object? startTime = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,postedAt: null == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SpecialModel].
extension SpecialModelPatterns on SpecialModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpecialModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpecialModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpecialModel value)  $default,){
final _that = this;
switch (_that) {
case _SpecialModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpecialModel value)?  $default,){
final _that = this;
switch (_that) {
case _SpecialModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String hallId,  String hallName,  String title,  String description,  String imageUrl,  DateTime postedAt,  DateTime? startTime,  double? latitude,  double? longitude,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpecialModel() when $default != null:
return $default(_that.id,_that.hallId,_that.hallName,_that.title,_that.description,_that.imageUrl,_that.postedAt,_that.startTime,_that.latitude,_that.longitude,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String hallId,  String hallName,  String title,  String description,  String imageUrl,  DateTime postedAt,  DateTime? startTime,  double? latitude,  double? longitude,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _SpecialModel():
return $default(_that.id,_that.hallId,_that.hallName,_that.title,_that.description,_that.imageUrl,_that.postedAt,_that.startTime,_that.latitude,_that.longitude,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String hallId,  String hallName,  String title,  String description,  String imageUrl,  DateTime postedAt,  DateTime? startTime,  double? latitude,  double? longitude,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _SpecialModel() when $default != null:
return $default(_that.id,_that.hallId,_that.hallName,_that.title,_that.description,_that.imageUrl,_that.postedAt,_that.startTime,_that.latitude,_that.longitude,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpecialModel implements SpecialModel {
  const _SpecialModel({required this.id, required this.hallId, required this.hallName, required this.title, required this.description, required this.imageUrl, required this.postedAt, this.startTime, this.latitude, this.longitude, final  List<String> tags = const []}): _tags = tags;
  factory _SpecialModel.fromJson(Map<String, dynamic> json) => _$SpecialModelFromJson(json);

@override final  String id;
@override final  String hallId;
@override final  String hallName;
@override final  String title;
@override final  String description;
@override final  String imageUrl;
@override final  DateTime postedAt;
@override final  DateTime? startTime;
@override final  double? latitude;
@override final  double? longitude;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of SpecialModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpecialModelCopyWith<_SpecialModel> get copyWith => __$SpecialModelCopyWithImpl<_SpecialModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpecialModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpecialModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.postedAt, postedAt) || other.postedAt == postedAt)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,hallName,title,description,imageUrl,postedAt,startTime,latitude,longitude,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'SpecialModel(id: $id, hallId: $hallId, hallName: $hallName, title: $title, description: $description, imageUrl: $imageUrl, postedAt: $postedAt, startTime: $startTime, latitude: $latitude, longitude: $longitude, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$SpecialModelCopyWith<$Res> implements $SpecialModelCopyWith<$Res> {
  factory _$SpecialModelCopyWith(_SpecialModel value, $Res Function(_SpecialModel) _then) = __$SpecialModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String hallId, String hallName, String title, String description, String imageUrl, DateTime postedAt, DateTime? startTime, double? latitude, double? longitude, List<String> tags
});




}
/// @nodoc
class __$SpecialModelCopyWithImpl<$Res>
    implements _$SpecialModelCopyWith<$Res> {
  __$SpecialModelCopyWithImpl(this._self, this._then);

  final _SpecialModel _self;
  final $Res Function(_SpecialModel) _then;

/// Create a copy of SpecialModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hallId = null,Object? hallName = null,Object? title = null,Object? description = null,Object? imageUrl = null,Object? postedAt = null,Object? startTime = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? tags = null,}) {
  return _then(_SpecialModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,postedAt: null == postedAt ? _self.postedAt : postedAt // ignore: cast_nullable_to_non_nullable
as DateTime,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
