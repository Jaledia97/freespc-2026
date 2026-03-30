// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_team_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueTeamMemberModel {

 String get uid; String get firstName; String get lastName; String get username; String? get photoUrl; String get venueId; String get venueName; String get assignedRole;// 'owner', 'manager', 'worker'
@_TimestampConverter() DateTime get addedAt; String get addedByUid;
/// Create a copy of VenueTeamMemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueTeamMemberModelCopyWith<VenueTeamMemberModel> get copyWith => _$VenueTeamMemberModelCopyWithImpl<VenueTeamMemberModel>(this as VenueTeamMemberModel, _$identity);

  /// Serializes this VenueTeamMemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueTeamMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.assignedRole, assignedRole) || other.assignedRole == assignedRole)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.addedByUid, addedByUid) || other.addedByUid == addedByUid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,username,photoUrl,venueId,venueName,assignedRole,addedAt,addedByUid);

@override
String toString() {
  return 'VenueTeamMemberModel(uid: $uid, firstName: $firstName, lastName: $lastName, username: $username, photoUrl: $photoUrl, venueId: $venueId, venueName: $venueName, assignedRole: $assignedRole, addedAt: $addedAt, addedByUid: $addedByUid)';
}


}

/// @nodoc
abstract mixin class $VenueTeamMemberModelCopyWith<$Res>  {
  factory $VenueTeamMemberModelCopyWith(VenueTeamMemberModel value, $Res Function(VenueTeamMemberModel) _then) = _$VenueTeamMemberModelCopyWithImpl;
@useResult
$Res call({
 String uid, String firstName, String lastName, String username, String? photoUrl, String venueId, String venueName, String assignedRole,@_TimestampConverter() DateTime addedAt, String addedByUid
});




}
/// @nodoc
class _$VenueTeamMemberModelCopyWithImpl<$Res>
    implements $VenueTeamMemberModelCopyWith<$Res> {
  _$VenueTeamMemberModelCopyWithImpl(this._self, this._then);

  final VenueTeamMemberModel _self;
  final $Res Function(VenueTeamMemberModel) _then;

/// Create a copy of VenueTeamMemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? username = null,Object? photoUrl = freezed,Object? venueId = null,Object? venueName = null,Object? assignedRole = null,Object? addedAt = null,Object? addedByUid = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,assignedRole: null == assignedRole ? _self.assignedRole : assignedRole // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,addedByUid: null == addedByUid ? _self.addedByUid : addedByUid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueTeamMemberModel].
extension VenueTeamMemberModelPatterns on VenueTeamMemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueTeamMemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueTeamMemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueTeamMemberModel value)  $default,){
final _that = this;
switch (_that) {
case _VenueTeamMemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueTeamMemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _VenueTeamMemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String firstName,  String lastName,  String username,  String? photoUrl,  String venueId,  String venueName,  String assignedRole, @_TimestampConverter()  DateTime addedAt,  String addedByUid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueTeamMemberModel() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.username,_that.photoUrl,_that.venueId,_that.venueName,_that.assignedRole,_that.addedAt,_that.addedByUid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String firstName,  String lastName,  String username,  String? photoUrl,  String venueId,  String venueName,  String assignedRole, @_TimestampConverter()  DateTime addedAt,  String addedByUid)  $default,) {final _that = this;
switch (_that) {
case _VenueTeamMemberModel():
return $default(_that.uid,_that.firstName,_that.lastName,_that.username,_that.photoUrl,_that.venueId,_that.venueName,_that.assignedRole,_that.addedAt,_that.addedByUid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String firstName,  String lastName,  String username,  String? photoUrl,  String venueId,  String venueName,  String assignedRole, @_TimestampConverter()  DateTime addedAt,  String addedByUid)?  $default,) {final _that = this;
switch (_that) {
case _VenueTeamMemberModel() when $default != null:
return $default(_that.uid,_that.firstName,_that.lastName,_that.username,_that.photoUrl,_that.venueId,_that.venueName,_that.assignedRole,_that.addedAt,_that.addedByUid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VenueTeamMemberModel implements VenueTeamMemberModel {
  const _VenueTeamMemberModel({required this.uid, required this.firstName, required this.lastName, required this.username, this.photoUrl, required this.venueId, required this.venueName, required this.assignedRole, @_TimestampConverter() required this.addedAt, required this.addedByUid});
  factory _VenueTeamMemberModel.fromJson(Map<String, dynamic> json) => _$VenueTeamMemberModelFromJson(json);

@override final  String uid;
@override final  String firstName;
@override final  String lastName;
@override final  String username;
@override final  String? photoUrl;
@override final  String venueId;
@override final  String venueName;
@override final  String assignedRole;
// 'owner', 'manager', 'worker'
@override@_TimestampConverter() final  DateTime addedAt;
@override final  String addedByUid;

/// Create a copy of VenueTeamMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueTeamMemberModelCopyWith<_VenueTeamMemberModel> get copyWith => __$VenueTeamMemberModelCopyWithImpl<_VenueTeamMemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueTeamMemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueTeamMemberModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.assignedRole, assignedRole) || other.assignedRole == assignedRole)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.addedByUid, addedByUid) || other.addedByUid == addedByUid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,firstName,lastName,username,photoUrl,venueId,venueName,assignedRole,addedAt,addedByUid);

@override
String toString() {
  return 'VenueTeamMemberModel(uid: $uid, firstName: $firstName, lastName: $lastName, username: $username, photoUrl: $photoUrl, venueId: $venueId, venueName: $venueName, assignedRole: $assignedRole, addedAt: $addedAt, addedByUid: $addedByUid)';
}


}

/// @nodoc
abstract mixin class _$VenueTeamMemberModelCopyWith<$Res> implements $VenueTeamMemberModelCopyWith<$Res> {
  factory _$VenueTeamMemberModelCopyWith(_VenueTeamMemberModel value, $Res Function(_VenueTeamMemberModel) _then) = __$VenueTeamMemberModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String firstName, String lastName, String username, String? photoUrl, String venueId, String venueName, String assignedRole,@_TimestampConverter() DateTime addedAt, String addedByUid
});




}
/// @nodoc
class __$VenueTeamMemberModelCopyWithImpl<$Res>
    implements _$VenueTeamMemberModelCopyWith<$Res> {
  __$VenueTeamMemberModelCopyWithImpl(this._self, this._then);

  final _VenueTeamMemberModel _self;
  final $Res Function(_VenueTeamMemberModel) _then;

/// Create a copy of VenueTeamMemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? firstName = null,Object? lastName = null,Object? username = null,Object? photoUrl = freezed,Object? venueId = null,Object? venueName = null,Object? assignedRole = null,Object? addedAt = null,Object? addedByUid = null,}) {
  return _then(_VenueTeamMemberModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,assignedRole: null == assignedRole ? _self.assignedRole : assignedRole // ignore: cast_nullable_to_non_nullable
as String,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,addedByUid: null == addedByUid ? _self.addedByUid : addedByUid // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
