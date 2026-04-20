// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'win_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WinPostModel {

 String get id; String get title; String get description; String get userId; String get userName; String? get userProfilePicture; String get venueId; String get venueName; double get winAmount; String? get imageUrl; DateTime get createdAt; List<String> get reactionUserIds; List<String> get interestedUserIds; int get commentCount; String get authorType; String? get authorId; String? get postedByUid; String? get latestComment;
/// Create a copy of WinPostModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WinPostModelCopyWith<WinPostModel> get copyWith => _$WinPostModelCopyWithImpl<WinPostModel>(this as WinPostModel, _$identity);

  /// Serializes this WinPostModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WinPostModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userProfilePicture, userProfilePicture) || other.userProfilePicture == userProfilePicture)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.winAmount, winAmount) || other.winAmount == winAmount)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.reactionUserIds, reactionUserIds)&&const DeepCollectionEquality().equals(other.interestedUserIds, interestedUserIds)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.authorType, authorType) || other.authorType == authorType)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.postedByUid, postedByUid) || other.postedByUid == postedByUid)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,userId,userName,userProfilePicture,venueId,venueName,winAmount,imageUrl,createdAt,const DeepCollectionEquality().hash(reactionUserIds),const DeepCollectionEquality().hash(interestedUserIds),commentCount,authorType,authorId,postedByUid,latestComment);

@override
String toString() {
  return 'WinPostModel(id: $id, title: $title, description: $description, userId: $userId, userName: $userName, userProfilePicture: $userProfilePicture, venueId: $venueId, venueName: $venueName, winAmount: $winAmount, imageUrl: $imageUrl, createdAt: $createdAt, reactionUserIds: $reactionUserIds, interestedUserIds: $interestedUserIds, commentCount: $commentCount, authorType: $authorType, authorId: $authorId, postedByUid: $postedByUid, latestComment: $latestComment)';
}


}

/// @nodoc
abstract mixin class $WinPostModelCopyWith<$Res>  {
  factory $WinPostModelCopyWith(WinPostModel value, $Res Function(WinPostModel) _then) = _$WinPostModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String userId, String userName, String? userProfilePicture, String venueId, String venueName, double winAmount, String? imageUrl, DateTime createdAt, List<String> reactionUserIds, List<String> interestedUserIds, int commentCount, String authorType, String? authorId, String? postedByUid, String? latestComment
});




}
/// @nodoc
class _$WinPostModelCopyWithImpl<$Res>
    implements $WinPostModelCopyWith<$Res> {
  _$WinPostModelCopyWithImpl(this._self, this._then);

  final WinPostModel _self;
  final $Res Function(WinPostModel) _then;

/// Create a copy of WinPostModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? userId = null,Object? userName = null,Object? userProfilePicture = freezed,Object? venueId = null,Object? venueName = null,Object? winAmount = null,Object? imageUrl = freezed,Object? createdAt = null,Object? reactionUserIds = null,Object? interestedUserIds = null,Object? commentCount = null,Object? authorType = null,Object? authorId = freezed,Object? postedByUid = freezed,Object? latestComment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userProfilePicture: freezed == userProfilePicture ? _self.userProfilePicture : userProfilePicture // ignore: cast_nullable_to_non_nullable
as String?,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,winAmount: null == winAmount ? _self.winAmount : winAmount // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reactionUserIds: null == reactionUserIds ? _self.reactionUserIds : reactionUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,interestedUserIds: null == interestedUserIds ? _self.interestedUserIds : interestedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,authorType: null == authorType ? _self.authorType : authorType // ignore: cast_nullable_to_non_nullable
as String,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,postedByUid: freezed == postedByUid ? _self.postedByUid : postedByUid // ignore: cast_nullable_to_non_nullable
as String?,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WinPostModel].
extension WinPostModelPatterns on WinPostModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WinPostModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WinPostModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WinPostModel value)  $default,){
final _that = this;
switch (_that) {
case _WinPostModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WinPostModel value)?  $default,){
final _that = this;
switch (_that) {
case _WinPostModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String userId,  String userName,  String? userProfilePicture,  String venueId,  String venueName,  double winAmount,  String? imageUrl,  DateTime createdAt,  List<String> reactionUserIds,  List<String> interestedUserIds,  int commentCount,  String authorType,  String? authorId,  String? postedByUid,  String? latestComment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WinPostModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.userId,_that.userName,_that.userProfilePicture,_that.venueId,_that.venueName,_that.winAmount,_that.imageUrl,_that.createdAt,_that.reactionUserIds,_that.interestedUserIds,_that.commentCount,_that.authorType,_that.authorId,_that.postedByUid,_that.latestComment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String userId,  String userName,  String? userProfilePicture,  String venueId,  String venueName,  double winAmount,  String? imageUrl,  DateTime createdAt,  List<String> reactionUserIds,  List<String> interestedUserIds,  int commentCount,  String authorType,  String? authorId,  String? postedByUid,  String? latestComment)  $default,) {final _that = this;
switch (_that) {
case _WinPostModel():
return $default(_that.id,_that.title,_that.description,_that.userId,_that.userName,_that.userProfilePicture,_that.venueId,_that.venueName,_that.winAmount,_that.imageUrl,_that.createdAt,_that.reactionUserIds,_that.interestedUserIds,_that.commentCount,_that.authorType,_that.authorId,_that.postedByUid,_that.latestComment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String userId,  String userName,  String? userProfilePicture,  String venueId,  String venueName,  double winAmount,  String? imageUrl,  DateTime createdAt,  List<String> reactionUserIds,  List<String> interestedUserIds,  int commentCount,  String authorType,  String? authorId,  String? postedByUid,  String? latestComment)?  $default,) {final _that = this;
switch (_that) {
case _WinPostModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.userId,_that.userName,_that.userProfilePicture,_that.venueId,_that.venueName,_that.winAmount,_that.imageUrl,_that.createdAt,_that.reactionUserIds,_that.interestedUserIds,_that.commentCount,_that.authorType,_that.authorId,_that.postedByUid,_that.latestComment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WinPostModel implements WinPostModel {
  const _WinPostModel({required this.id, required this.title, this.description = '', required this.userId, required this.userName, this.userProfilePicture, required this.venueId, required this.venueName, required this.winAmount, this.imageUrl, required this.createdAt, final  List<String> reactionUserIds = const [], final  List<String> interestedUserIds = const [], this.commentCount = 0, this.authorType = 'user', this.authorId, this.postedByUid, this.latestComment}): _reactionUserIds = reactionUserIds,_interestedUserIds = interestedUserIds;
  factory _WinPostModel.fromJson(Map<String, dynamic> json) => _$WinPostModelFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override final  String userId;
@override final  String userName;
@override final  String? userProfilePicture;
@override final  String venueId;
@override final  String venueName;
@override final  double winAmount;
@override final  String? imageUrl;
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
@override@JsonKey() final  String authorType;
@override final  String? authorId;
@override final  String? postedByUid;
@override final  String? latestComment;

/// Create a copy of WinPostModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WinPostModelCopyWith<_WinPostModel> get copyWith => __$WinPostModelCopyWithImpl<_WinPostModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WinPostModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WinPostModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.userName, userName) || other.userName == userName)&&(identical(other.userProfilePicture, userProfilePicture) || other.userProfilePicture == userProfilePicture)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.winAmount, winAmount) || other.winAmount == winAmount)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._reactionUserIds, _reactionUserIds)&&const DeepCollectionEquality().equals(other._interestedUserIds, _interestedUserIds)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.authorType, authorType) || other.authorType == authorType)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.postedByUid, postedByUid) || other.postedByUid == postedByUid)&&(identical(other.latestComment, latestComment) || other.latestComment == latestComment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,userId,userName,userProfilePicture,venueId,venueName,winAmount,imageUrl,createdAt,const DeepCollectionEquality().hash(_reactionUserIds),const DeepCollectionEquality().hash(_interestedUserIds),commentCount,authorType,authorId,postedByUid,latestComment);

@override
String toString() {
  return 'WinPostModel(id: $id, title: $title, description: $description, userId: $userId, userName: $userName, userProfilePicture: $userProfilePicture, venueId: $venueId, venueName: $venueName, winAmount: $winAmount, imageUrl: $imageUrl, createdAt: $createdAt, reactionUserIds: $reactionUserIds, interestedUserIds: $interestedUserIds, commentCount: $commentCount, authorType: $authorType, authorId: $authorId, postedByUid: $postedByUid, latestComment: $latestComment)';
}


}

/// @nodoc
abstract mixin class _$WinPostModelCopyWith<$Res> implements $WinPostModelCopyWith<$Res> {
  factory _$WinPostModelCopyWith(_WinPostModel value, $Res Function(_WinPostModel) _then) = __$WinPostModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String userId, String userName, String? userProfilePicture, String venueId, String venueName, double winAmount, String? imageUrl, DateTime createdAt, List<String> reactionUserIds, List<String> interestedUserIds, int commentCount, String authorType, String? authorId, String? postedByUid, String? latestComment
});




}
/// @nodoc
class __$WinPostModelCopyWithImpl<$Res>
    implements _$WinPostModelCopyWith<$Res> {
  __$WinPostModelCopyWithImpl(this._self, this._then);

  final _WinPostModel _self;
  final $Res Function(_WinPostModel) _then;

/// Create a copy of WinPostModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? userId = null,Object? userName = null,Object? userProfilePicture = freezed,Object? venueId = null,Object? venueName = null,Object? winAmount = null,Object? imageUrl = freezed,Object? createdAt = null,Object? reactionUserIds = null,Object? interestedUserIds = null,Object? commentCount = null,Object? authorType = null,Object? authorId = freezed,Object? postedByUid = freezed,Object? latestComment = freezed,}) {
  return _then(_WinPostModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,userName: null == userName ? _self.userName : userName // ignore: cast_nullable_to_non_nullable
as String,userProfilePicture: freezed == userProfilePicture ? _self.userProfilePicture : userProfilePicture // ignore: cast_nullable_to_non_nullable
as String?,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,winAmount: null == winAmount ? _self.winAmount : winAmount // ignore: cast_nullable_to_non_nullable
as double,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,reactionUserIds: null == reactionUserIds ? _self._reactionUserIds : reactionUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,interestedUserIds: null == interestedUserIds ? _self._interestedUserIds : interestedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,authorType: null == authorType ? _self.authorType : authorType // ignore: cast_nullable_to_non_nullable
as String,authorId: freezed == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String?,postedByUid: freezed == postedByUid ? _self.postedByUid : postedByUid // ignore: cast_nullable_to_non_nullable
as String?,latestComment: freezed == latestComment ? _self.latestComment : latestComment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
