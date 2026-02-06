// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GalleryPhotoModel {

 String get id; String get uploaderId; String get imageUrl;@TimestampConverter() DateTime get timestamp; String? get description;// Tagging & Approval Logic
 List<String> get taggedUserIds; List<String> get taggedHallIds;// All halls tagged originally
 List<String> get approvedHallIds;// Halls that approved the tag
 List<String> get pendingHallIds;// Halls that need to approve
// Moderation
 int get reportCount; bool get isHidden;
/// Create a copy of GalleryPhotoModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryPhotoModelCopyWith<GalleryPhotoModel> get copyWith => _$GalleryPhotoModelCopyWithImpl<GalleryPhotoModel>(this as GalleryPhotoModel, _$identity);

  /// Serializes this GalleryPhotoModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryPhotoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.uploaderId, uploaderId) || other.uploaderId == uploaderId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.taggedUserIds, taggedUserIds)&&const DeepCollectionEquality().equals(other.taggedHallIds, taggedHallIds)&&const DeepCollectionEquality().equals(other.approvedHallIds, approvedHallIds)&&const DeepCollectionEquality().equals(other.pendingHallIds, pendingHallIds)&&(identical(other.reportCount, reportCount) || other.reportCount == reportCount)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uploaderId,imageUrl,timestamp,description,const DeepCollectionEquality().hash(taggedUserIds),const DeepCollectionEquality().hash(taggedHallIds),const DeepCollectionEquality().hash(approvedHallIds),const DeepCollectionEquality().hash(pendingHallIds),reportCount,isHidden);

@override
String toString() {
  return 'GalleryPhotoModel(id: $id, uploaderId: $uploaderId, imageUrl: $imageUrl, timestamp: $timestamp, description: $description, taggedUserIds: $taggedUserIds, taggedHallIds: $taggedHallIds, approvedHallIds: $approvedHallIds, pendingHallIds: $pendingHallIds, reportCount: $reportCount, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class $GalleryPhotoModelCopyWith<$Res>  {
  factory $GalleryPhotoModelCopyWith(GalleryPhotoModel value, $Res Function(GalleryPhotoModel) _then) = _$GalleryPhotoModelCopyWithImpl;
@useResult
$Res call({
 String id, String uploaderId, String imageUrl,@TimestampConverter() DateTime timestamp, String? description, List<String> taggedUserIds, List<String> taggedHallIds, List<String> approvedHallIds, List<String> pendingHallIds, int reportCount, bool isHidden
});




}
/// @nodoc
class _$GalleryPhotoModelCopyWithImpl<$Res>
    implements $GalleryPhotoModelCopyWith<$Res> {
  _$GalleryPhotoModelCopyWithImpl(this._self, this._then);

  final GalleryPhotoModel _self;
  final $Res Function(GalleryPhotoModel) _then;

/// Create a copy of GalleryPhotoModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uploaderId = null,Object? imageUrl = null,Object? timestamp = null,Object? description = freezed,Object? taggedUserIds = null,Object? taggedHallIds = null,Object? approvedHallIds = null,Object? pendingHallIds = null,Object? reportCount = null,Object? isHidden = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uploaderId: null == uploaderId ? _self.uploaderId : uploaderId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,taggedUserIds: null == taggedUserIds ? _self.taggedUserIds : taggedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,taggedHallIds: null == taggedHallIds ? _self.taggedHallIds : taggedHallIds // ignore: cast_nullable_to_non_nullable
as List<String>,approvedHallIds: null == approvedHallIds ? _self.approvedHallIds : approvedHallIds // ignore: cast_nullable_to_non_nullable
as List<String>,pendingHallIds: null == pendingHallIds ? _self.pendingHallIds : pendingHallIds // ignore: cast_nullable_to_non_nullable
as List<String>,reportCount: null == reportCount ? _self.reportCount : reportCount // ignore: cast_nullable_to_non_nullable
as int,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryPhotoModel].
extension GalleryPhotoModelPatterns on GalleryPhotoModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryPhotoModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryPhotoModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryPhotoModel value)  $default,){
final _that = this;
switch (_that) {
case _GalleryPhotoModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryPhotoModel value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryPhotoModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uploaderId,  String imageUrl, @TimestampConverter()  DateTime timestamp,  String? description,  List<String> taggedUserIds,  List<String> taggedHallIds,  List<String> approvedHallIds,  List<String> pendingHallIds,  int reportCount,  bool isHidden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryPhotoModel() when $default != null:
return $default(_that.id,_that.uploaderId,_that.imageUrl,_that.timestamp,_that.description,_that.taggedUserIds,_that.taggedHallIds,_that.approvedHallIds,_that.pendingHallIds,_that.reportCount,_that.isHidden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uploaderId,  String imageUrl, @TimestampConverter()  DateTime timestamp,  String? description,  List<String> taggedUserIds,  List<String> taggedHallIds,  List<String> approvedHallIds,  List<String> pendingHallIds,  int reportCount,  bool isHidden)  $default,) {final _that = this;
switch (_that) {
case _GalleryPhotoModel():
return $default(_that.id,_that.uploaderId,_that.imageUrl,_that.timestamp,_that.description,_that.taggedUserIds,_that.taggedHallIds,_that.approvedHallIds,_that.pendingHallIds,_that.reportCount,_that.isHidden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uploaderId,  String imageUrl, @TimestampConverter()  DateTime timestamp,  String? description,  List<String> taggedUserIds,  List<String> taggedHallIds,  List<String> approvedHallIds,  List<String> pendingHallIds,  int reportCount,  bool isHidden)?  $default,) {final _that = this;
switch (_that) {
case _GalleryPhotoModel() when $default != null:
return $default(_that.id,_that.uploaderId,_that.imageUrl,_that.timestamp,_that.description,_that.taggedUserIds,_that.taggedHallIds,_that.approvedHallIds,_that.pendingHallIds,_that.reportCount,_that.isHidden);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GalleryPhotoModel implements GalleryPhotoModel {
  const _GalleryPhotoModel({required this.id, required this.uploaderId, required this.imageUrl, @TimestampConverter() required this.timestamp, this.description, final  List<String> taggedUserIds = const [], final  List<String> taggedHallIds = const [], final  List<String> approvedHallIds = const [], final  List<String> pendingHallIds = const [], this.reportCount = 0, this.isHidden = false}): _taggedUserIds = taggedUserIds,_taggedHallIds = taggedHallIds,_approvedHallIds = approvedHallIds,_pendingHallIds = pendingHallIds;
  factory _GalleryPhotoModel.fromJson(Map<String, dynamic> json) => _$GalleryPhotoModelFromJson(json);

@override final  String id;
@override final  String uploaderId;
@override final  String imageUrl;
@override@TimestampConverter() final  DateTime timestamp;
@override final  String? description;
// Tagging & Approval Logic
 final  List<String> _taggedUserIds;
// Tagging & Approval Logic
@override@JsonKey() List<String> get taggedUserIds {
  if (_taggedUserIds is EqualUnmodifiableListView) return _taggedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taggedUserIds);
}

 final  List<String> _taggedHallIds;
@override@JsonKey() List<String> get taggedHallIds {
  if (_taggedHallIds is EqualUnmodifiableListView) return _taggedHallIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taggedHallIds);
}

// All halls tagged originally
 final  List<String> _approvedHallIds;
// All halls tagged originally
@override@JsonKey() List<String> get approvedHallIds {
  if (_approvedHallIds is EqualUnmodifiableListView) return _approvedHallIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approvedHallIds);
}

// Halls that approved the tag
 final  List<String> _pendingHallIds;
// Halls that approved the tag
@override@JsonKey() List<String> get pendingHallIds {
  if (_pendingHallIds is EqualUnmodifiableListView) return _pendingHallIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingHallIds);
}

// Halls that need to approve
// Moderation
@override@JsonKey() final  int reportCount;
@override@JsonKey() final  bool isHidden;

/// Create a copy of GalleryPhotoModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryPhotoModelCopyWith<_GalleryPhotoModel> get copyWith => __$GalleryPhotoModelCopyWithImpl<_GalleryPhotoModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GalleryPhotoModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryPhotoModel&&(identical(other.id, id) || other.id == id)&&(identical(other.uploaderId, uploaderId) || other.uploaderId == uploaderId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._taggedUserIds, _taggedUserIds)&&const DeepCollectionEquality().equals(other._taggedHallIds, _taggedHallIds)&&const DeepCollectionEquality().equals(other._approvedHallIds, _approvedHallIds)&&const DeepCollectionEquality().equals(other._pendingHallIds, _pendingHallIds)&&(identical(other.reportCount, reportCount) || other.reportCount == reportCount)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uploaderId,imageUrl,timestamp,description,const DeepCollectionEquality().hash(_taggedUserIds),const DeepCollectionEquality().hash(_taggedHallIds),const DeepCollectionEquality().hash(_approvedHallIds),const DeepCollectionEquality().hash(_pendingHallIds),reportCount,isHidden);

@override
String toString() {
  return 'GalleryPhotoModel(id: $id, uploaderId: $uploaderId, imageUrl: $imageUrl, timestamp: $timestamp, description: $description, taggedUserIds: $taggedUserIds, taggedHallIds: $taggedHallIds, approvedHallIds: $approvedHallIds, pendingHallIds: $pendingHallIds, reportCount: $reportCount, isHidden: $isHidden)';
}


}

/// @nodoc
abstract mixin class _$GalleryPhotoModelCopyWith<$Res> implements $GalleryPhotoModelCopyWith<$Res> {
  factory _$GalleryPhotoModelCopyWith(_GalleryPhotoModel value, $Res Function(_GalleryPhotoModel) _then) = __$GalleryPhotoModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String uploaderId, String imageUrl,@TimestampConverter() DateTime timestamp, String? description, List<String> taggedUserIds, List<String> taggedHallIds, List<String> approvedHallIds, List<String> pendingHallIds, int reportCount, bool isHidden
});




}
/// @nodoc
class __$GalleryPhotoModelCopyWithImpl<$Res>
    implements _$GalleryPhotoModelCopyWith<$Res> {
  __$GalleryPhotoModelCopyWithImpl(this._self, this._then);

  final _GalleryPhotoModel _self;
  final $Res Function(_GalleryPhotoModel) _then;

/// Create a copy of GalleryPhotoModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uploaderId = null,Object? imageUrl = null,Object? timestamp = null,Object? description = freezed,Object? taggedUserIds = null,Object? taggedHallIds = null,Object? approvedHallIds = null,Object? pendingHallIds = null,Object? reportCount = null,Object? isHidden = null,}) {
  return _then(_GalleryPhotoModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uploaderId: null == uploaderId ? _self.uploaderId : uploaderId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,taggedUserIds: null == taggedUserIds ? _self._taggedUserIds : taggedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,taggedHallIds: null == taggedHallIds ? _self._taggedHallIds : taggedHallIds // ignore: cast_nullable_to_non_nullable
as List<String>,approvedHallIds: null == approvedHallIds ? _self._approvedHallIds : approvedHallIds // ignore: cast_nullable_to_non_nullable
as List<String>,pendingHallIds: null == pendingHallIds ? _self._pendingHallIds : pendingHallIds // ignore: cast_nullable_to_non_nullable
as List<String>,reportCount: null == reportCount ? _self.reportCount : reportCount // ignore: cast_nullable_to_non_nullable
as int,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
