// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'check_in_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CheckInModel {

 String get id; String get title; String get description; String get userId; String get userName; String? get userProfilePicture; String get venueId; String get venueName; DateTime get createdAt; List<String> get reactionUserIds; List<String> get interestedUserIds; int get commentCount; String? get latestComment;
/// Create a copy of CheckInModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckInModelCopyWith<CheckInModel> get copyWith => _$CheckInModelCopyWithImpl<CheckInModel>(this as CheckInModel, _$identity);

  /// Serializes this CheckInModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckInModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userProfilePicture, userProfilePicture) || other.userProfilePicture == userProfilePicture)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.reactionUserIds, reactionUserIds)&&const DeepCollectionEquality().equals(other.interestedUserIds, interestedUserIds)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,userId,userName,userProfilePicture,venueId,venueName,createdAt,const DeepCollectionEquality().hash(reactionUserIds),const DeepCollectionEquality().hash(interestedUserIds),commentCount,latestComment);

@override
String toString() {
  return 'CheckInModel(id: $id, title: $title, description: $description, userId: $userId, userName: $userName, userProfilePicture: $userProfilePicture, venueId: $venueId, venueName: $venueName, createdAt: $createdAt, reactionUserIds: $reactionUserIds, interestedUserIds: $interestedUserIds, commentCount: $commentCount, latestComment: $latestComment)';
}


}

/// @nodoc
abstract mixin class $CheckInModelCopyWith<$Res>  {
  factory $CheckInModelCopyWith(CheckInModel value, $Res Function(CheckInModel) _then) = _$CheckInModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String userId, String userName, String? userProfilePicture, String venueId, String venueName, DateTime createdAt, List<String> reactionUserIds, List<String> interestedUserIds, int commentCount, String? latestComment
});




}
/// @nodoc
class _$CheckInModelCopyWithImpl<$Res>
    implements $CheckInModelCopyWith<$Res> {
  _$CheckInModelCopyWithImpl(this._self, this._then);

  final CheckInModel _self;
  final $Res Function(CheckInModel) _then;

/// Create a copy of CheckInModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? userId = null,Object? userName = null,Object? userProfilePicture = freezed,Object? venueId = null,Object? venueName = null,Object? createdAt = null,Object? reactionUserIds = null,Object? interestedUserIds = null,Object? commentCount = null,Object? latestComment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userProfilePicture: freezed == userProfilePicture ? _self.userProfilePicture : userProfilePicture // ignore: cast_nullable_to_non_nullable
as String?,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reactionUserIds: null == reactionUserIds ? _self.reactionUserIds : reactionUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,interestedUserIds: null == interestedUserIds ? _self.interestedUserIds : interestedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckInModel].
extension CheckInModelPatterns on CheckInModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckInModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckInModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckInModel value)  $default,){
final _that = this;
switch (_that) {
case _CheckInModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckInModel value)?  $default,){
final _that = this;
switch (_that) {
case _CheckInModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String userId,  String userName,  String? userProfilePicture,  String venueId,  String venueName,  DateTime createdAt,  List<String> reactionUserIds,  List<String> interestedUserIds,  int commentCount,  String? latestComment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckInModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.userId,_that.userName,_that.userProfilePicture,_that.venueId,_that.venueName,_that.createdAt,_that.reactionUserIds,_that.interestedUserIds,_that.commentCount,_that.latestComment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String userId,  String userName,  String? userProfilePicture,  String venueId,  String venueName,  DateTime createdAt,  List<String> reactionUserIds,  List<String> interestedUserIds,  int commentCount,  String? latestComment)  $default,) {final _that = this;
switch (_that) {
case _CheckInModel():
return $default(_that.id,_that.title,_that.description,_that.userId,_that.userName,_that.userProfilePicture,_that.venueId,_that.venueName,_that.createdAt,_that.reactionUserIds,_that.interestedUserIds,_that.commentCount,_that.latestComment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String userId,  String userName,  String? userProfilePicture,  String venueId,  String venueName,  DateTime createdAt,  List<String> reactionUserIds,  List<String> interestedUserIds,  int commentCount,  String? latestComment)?  $default,) {final _that = this;
switch (_that) {
case _CheckInModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.userId,_that.userName,_that.userProfilePicture,_that.venueId,_that.venueName,_that.createdAt,_that.reactionUserIds,_that.interestedUserIds,_that.commentCount,_that.latestComment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CheckInModel implements CheckInModel {
  const _CheckInModel({required this.id, required this.title, this.description = '', required this.userId, required this.userName, this.userProfilePicture, required this.venueId, required this.venueName, required this.createdAt, final  List<String> reactionUserIds = const [], final  List<String> interestedUserIds = const [], this.commentCount = 0, this.latestComment}): _reactionUserIds = reactionUserIds,_interestedUserIds = interestedUserIds;
  factory _CheckInModel.fromJson(Map<String, dynamic> json) => _$CheckInModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override final  String userId;
@override final  String userName;
@override final  String? userProfilePicture;
@override final  String venueId;
@override final  String venueName;
@override final  DateTime createdAt;
 final  List<String> _reactionUserIds;
@override@JsonKey() List<String> get reactionUserIds {
  if (_reactionUserIds is EqualUnmodifiableListView) return _reactionUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactionUserIds);
}

 final  List<String> _interestedUserIds;
@override@JsonKey() List<String> get interestedUserIds {
  if (_interestedUserIds is EqualUnmodifiableListView) return _interestedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interestedUserIds);
}

@override@JsonKey() final  int commentCount;
@override final  String? latestComment;

/// Create a copy of CheckInModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckInModelCopyWith<_CheckInModel> get copyWith => __$CheckInModelCopyWithImpl<_CheckInModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckInModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckInModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userProfilePicture, userProfilePicture) || other.userProfilePicture == userProfilePicture)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._reactionUserIds, _reactionUserIds)&&const DeepCollectionEquality().equals(other._interestedUserIds, _interestedUserIds)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,userId,userName,userProfilePicture,venueId,venueName,createdAt,const DeepCollectionEquality().hash(_reactionUserIds),const DeepCollectionEquality().hash(_interestedUserIds),commentCount,latestComment);

@override
String toString() {
  return 'CheckInModel(id: $id, title: $title, description: $description, userId: $userId, userName: $userName, userProfilePicture: $userProfilePicture, venueId: $venueId, venueName: $venueName, createdAt: $createdAt, reactionUserIds: $reactionUserIds, interestedUserIds: $interestedUserIds, commentCount: $commentCount, latestComment: $latestComment)';
}


}

/// @nodoc
abstract mixin class _$CheckInModelCopyWith<$Res> implements $CheckInModelCopyWith<$Res> {
  factory _$CheckInModelCopyWith(_CheckInModel value, $Res Function(_CheckInModel) _then) = __$CheckInModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String userId, String userName, String? userProfilePicture, String venueId, String venueName, DateTime createdAt, List<String> reactionUserIds, List<String> interestedUserIds, int commentCount, String? latestComment
});




}
/// @nodoc
class __$CheckInModelCopyWithImpl<$Res>
    implements _$CheckInModelCopyWith<$Res> {
  __$CheckInModelCopyWithImpl(this._self, this._then);

  final _CheckInModel _self;
  final $Res Function(_CheckInModel) _then;

/// Create a copy of CheckInModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? userId = null,Object? userName = null,Object? userProfilePicture = freezed,Object? venueId = null,Object? venueName = null,Object? createdAt = null,Object? reactionUserIds = null,Object? interestedUserIds = null,Object? commentCount = null,Object? latestComment = freezed,}) {
  return _then(_CheckInModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userProfilePicture: freezed == userProfilePicture ? _self.userProfilePicture : userProfilePicture // ignore: cast_nullable_to_non_nullable
as String?,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reactionUserIds: null == reactionUserIds ? _self._reactionUserIds : reactionUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,interestedUserIds: null == interestedUserIds ? _self._interestedUserIds : interestedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
