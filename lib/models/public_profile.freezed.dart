// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicProfile {

 String get uid; String get username; String get firstName; String get lastName; String? get photoUrl; String? get bio; int get points;// syncing points for potential leaderboards? kept simple for now
 String get realNameVisibility; String get onlineStatus; String? get currentCheckInHallId;
/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProfileCopyWith<PublicProfile> get copyWith => _$PublicProfileCopyWithImpl<PublicProfile>(this as PublicProfile, _$identity);

  /// Serializes this PublicProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.points, points) || other.points == points)&&(identical(other.realNameVisibility, realNameVisibility) || other.realNameVisibility == realNameVisibility)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.currentCheckInHallId, currentCheckInHallId) || other.currentCheckInHallId == currentCheckInHallId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,username,firstName,lastName,photoUrl,bio,points,realNameVisibility,onlineStatus,currentCheckInHallId);

@override
String toString() {
  return 'PublicProfile(uid: $uid, username: $username, firstName: $firstName, lastName: $lastName, photoUrl: $photoUrl, bio: $bio, points: $points, realNameVisibility: $realNameVisibility, onlineStatus: $onlineStatus, currentCheckInHallId: $currentCheckInHallId)';
}


}

/// @nodoc
abstract mixin class $PublicProfileCopyWith<$Res>  {
  factory $PublicProfileCopyWith(PublicProfile value, $Res Function(PublicProfile) _then) = _$PublicProfileCopyWithImpl;
@useResult
$Res call({
 String uid, String username, String firstName, String lastName, String? photoUrl, String? bio, int points, String realNameVisibility, String onlineStatus, String? currentCheckInHallId
});




}
/// @nodoc
class _$PublicProfileCopyWithImpl<$Res>
    implements $PublicProfileCopyWith<$Res> {
  _$PublicProfileCopyWithImpl(this._self, this._then);

  final PublicProfile _self;
  final $Res Function(PublicProfile) _then;

/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? username = null,Object? firstName = null,Object? lastName = null,Object? photoUrl = freezed,Object? bio = freezed,Object? points = null,Object? realNameVisibility = null,Object? onlineStatus = null,Object? currentCheckInHallId = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,realNameVisibility: null == realNameVisibility ? _self.realNameVisibility : realNameVisibility // ignore: cast_nullable_to_non_nullable
as String,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as String,currentCheckInHallId: freezed == currentCheckInHallId ? _self.currentCheckInHallId : currentCheckInHallId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicProfile].
extension PublicProfilePatterns on PublicProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProfile value)  $default,){
final _that = this;
switch (_that) {
case _PublicProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String username,  String firstName,  String lastName,  String? photoUrl,  String? bio,  int points,  String realNameVisibility,  String onlineStatus,  String? currentCheckInHallId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
return $default(_that.uid,_that.username,_that.firstName,_that.lastName,_that.photoUrl,_that.bio,_that.points,_that.realNameVisibility,_that.onlineStatus,_that.currentCheckInHallId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String username,  String firstName,  String lastName,  String? photoUrl,  String? bio,  int points,  String realNameVisibility,  String onlineStatus,  String? currentCheckInHallId)  $default,) {final _that = this;
switch (_that) {
case _PublicProfile():
return $default(_that.uid,_that.username,_that.firstName,_that.lastName,_that.photoUrl,_that.bio,_that.points,_that.realNameVisibility,_that.onlineStatus,_that.currentCheckInHallId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String username,  String firstName,  String lastName,  String? photoUrl,  String? bio,  int points,  String realNameVisibility,  String onlineStatus,  String? currentCheckInHallId)?  $default,) {final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
return $default(_that.uid,_that.username,_that.firstName,_that.lastName,_that.photoUrl,_that.bio,_that.points,_that.realNameVisibility,_that.onlineStatus,_that.currentCheckInHallId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicProfile implements PublicProfile {
  const _PublicProfile({required this.uid, required this.username, required this.firstName, required this.lastName, this.photoUrl, this.bio, this.points = 0, this.realNameVisibility = 'Private', this.onlineStatus = 'Online', this.currentCheckInHallId});
  factory _PublicProfile.fromJson(Map<String, dynamic> json) => _$PublicProfileFromJson(json);

@override final  String uid;
@override final  String username;
@override final  String firstName;
@override final  String lastName;
@override final  String? photoUrl;
@override final  String? bio;
@override@JsonKey() final  int points;
// syncing points for potential leaderboards? kept simple for now
@override@JsonKey() final  String realNameVisibility;
@override@JsonKey() final  String onlineStatus;
@override final  String? currentCheckInHallId;

/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProfileCopyWith<_PublicProfile> get copyWith => __$PublicProfileCopyWithImpl<_PublicProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.points, points) || other.points == points)&&(identical(other.realNameVisibility, realNameVisibility) || other.realNameVisibility == realNameVisibility)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.currentCheckInHallId, currentCheckInHallId) || other.currentCheckInHallId == currentCheckInHallId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,username,firstName,lastName,photoUrl,bio,points,realNameVisibility,onlineStatus,currentCheckInHallId);

@override
String toString() {
  return 'PublicProfile(uid: $uid, username: $username, firstName: $firstName, lastName: $lastName, photoUrl: $photoUrl, bio: $bio, points: $points, realNameVisibility: $realNameVisibility, onlineStatus: $onlineStatus, currentCheckInHallId: $currentCheckInHallId)';
}


}

/// @nodoc
abstract mixin class _$PublicProfileCopyWith<$Res> implements $PublicProfileCopyWith<$Res> {
  factory _$PublicProfileCopyWith(_PublicProfile value, $Res Function(_PublicProfile) _then) = __$PublicProfileCopyWithImpl;
@override @useResult
$Res call({
 String uid, String username, String firstName, String lastName, String? photoUrl, String? bio, int points, String realNameVisibility, String onlineStatus, String? currentCheckInHallId
});




}
/// @nodoc
class __$PublicProfileCopyWithImpl<$Res>
    implements _$PublicProfileCopyWith<$Res> {
  __$PublicProfileCopyWithImpl(this._self, this._then);

  final _PublicProfile _self;
  final $Res Function(_PublicProfile) _then;

/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? username = null,Object? firstName = null,Object? lastName = null,Object? photoUrl = freezed,Object? bio = freezed,Object? points = null,Object? realNameVisibility = null,Object? onlineStatus = null,Object? currentCheckInHallId = freezed,}) {
  return _then(_PublicProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,realNameVisibility: null == realNameVisibility ? _self.realNameVisibility : realNameVisibility // ignore: cast_nullable_to_non_nullable
as String,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as String,currentCheckInHallId: freezed == currentCheckInHallId ? _self.currentCheckInHallId : currentCheckInHallId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
