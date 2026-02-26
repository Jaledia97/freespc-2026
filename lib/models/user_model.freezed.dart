// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {

 String get uid; String get email; String get firstName; String get lastName; String get username; DateTime get birthday; String? get phoneNumber; String? get recoveryEmail; String get role;// superadmin, admin, owner, manager, worker, player
 int get currentPoints; String? get homeBaseId; String? get qrToken; String? get bio; String? get photoUrl; String? get bannerUrl; List<String> get following; String get realNameVisibility;// 'Private', 'Friends Only', 'Everyone'
 String get onlineStatus; String? get currentCheckInHallId; List<String> get blockedUsers;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.username, username) || other.username == username)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.recoveryEmail, recoveryEmail) || other.recoveryEmail == recoveryEmail)&&(identical(other.role, role) || other.role == role)&&(identical(other.currentPoints, currentPoints) || other.currentPoints == currentPoints)&&(identical(other.homeBaseId, homeBaseId) || other.homeBaseId == homeBaseId)&&(identical(other.qrToken, qrToken) || other.qrToken == qrToken)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other.following, following)&&(identical(other.realNameVisibility, realNameVisibility) || other.realNameVisibility == realNameVisibility)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.currentCheckInHallId, currentCheckInHallId) || other.currentCheckInHallId == currentCheckInHallId)&&const DeepCollectionEquality().equals(other.blockedUsers, blockedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,firstName,lastName,username,birthday,phoneNumber,recoveryEmail,role,currentPoints,homeBaseId,qrToken,bio,photoUrl,bannerUrl,const DeepCollectionEquality().hash(following),realNameVisibility,onlineStatus,currentCheckInHallId,const DeepCollectionEquality().hash(blockedUsers)]);

@override
String toString() {
  return 'UserModel(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName, username: $username, birthday: $birthday, phoneNumber: $phoneNumber, recoveryEmail: $recoveryEmail, role: $role, currentPoints: $currentPoints, homeBaseId: $homeBaseId, qrToken: $qrToken, bio: $bio, photoUrl: $photoUrl, bannerUrl: $bannerUrl, following: $following, realNameVisibility: $realNameVisibility, onlineStatus: $onlineStatus, currentCheckInHallId: $currentCheckInHallId, blockedUsers: $blockedUsers)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String firstName, String lastName, String username, DateTime birthday, String? phoneNumber, String? recoveryEmail, String role, int currentPoints, String? homeBaseId, String? qrToken, String? bio, String? photoUrl, String? bannerUrl, List<String> following, String realNameVisibility, String onlineStatus, String? currentCheckInHallId, List<String> blockedUsers
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? username = null,Object? birthday = null,Object? phoneNumber = freezed,Object? recoveryEmail = freezed,Object? role = null,Object? currentPoints = null,Object? homeBaseId = freezed,Object? qrToken = freezed,Object? bio = freezed,Object? photoUrl = freezed,Object? bannerUrl = freezed,Object? following = null,Object? realNameVisibility = null,Object? onlineStatus = null,Object? currentCheckInHallId = freezed,Object? blockedUsers = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,birthday: null == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,recoveryEmail: freezed == recoveryEmail ? _self.recoveryEmail : recoveryEmail // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,currentPoints: null == currentPoints ? _self.currentPoints : currentPoints // ignore: cast_nullable_to_non_nullable
as int,homeBaseId: freezed == homeBaseId ? _self.homeBaseId : homeBaseId // ignore: cast_nullable_to_non_nullable
as String?,qrToken: freezed == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as List<String>,realNameVisibility: null == realNameVisibility ? _self.realNameVisibility : realNameVisibility // ignore: cast_nullable_to_non_nullable
as String,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as String,currentCheckInHallId: freezed == currentCheckInHallId ? _self.currentCheckInHallId : currentCheckInHallId // ignore: cast_nullable_to_non_nullable
as String?,blockedUsers: null == blockedUsers ? _self.blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserModel value)  $default,){
final _that = this;
switch (_that) {
case _UserModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String firstName,  String lastName,  String username,  DateTime birthday,  String? phoneNumber,  String? recoveryEmail,  String role,  int currentPoints,  String? homeBaseId,  String? qrToken,  String? bio,  String? photoUrl,  String? bannerUrl,  List<String> following,  String realNameVisibility,  String onlineStatus,  String? currentCheckInHallId,  List<String> blockedUsers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.email,_that.firstName,_that.lastName,_that.username,_that.birthday,_that.phoneNumber,_that.recoveryEmail,_that.role,_that.currentPoints,_that.homeBaseId,_that.qrToken,_that.bio,_that.photoUrl,_that.bannerUrl,_that.following,_that.realNameVisibility,_that.onlineStatus,_that.currentCheckInHallId,_that.blockedUsers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String firstName,  String lastName,  String username,  DateTime birthday,  String? phoneNumber,  String? recoveryEmail,  String role,  int currentPoints,  String? homeBaseId,  String? qrToken,  String? bio,  String? photoUrl,  String? bannerUrl,  List<String> following,  String realNameVisibility,  String onlineStatus,  String? currentCheckInHallId,  List<String> blockedUsers)  $default,) {final _that = this;
switch (_that) {
case _UserModel():
return $default(_that.uid,_that.email,_that.firstName,_that.lastName,_that.username,_that.birthday,_that.phoneNumber,_that.recoveryEmail,_that.role,_that.currentPoints,_that.homeBaseId,_that.qrToken,_that.bio,_that.photoUrl,_that.bannerUrl,_that.following,_that.realNameVisibility,_that.onlineStatus,_that.currentCheckInHallId,_that.blockedUsers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String firstName,  String lastName,  String username,  DateTime birthday,  String? phoneNumber,  String? recoveryEmail,  String role,  int currentPoints,  String? homeBaseId,  String? qrToken,  String? bio,  String? photoUrl,  String? bannerUrl,  List<String> following,  String realNameVisibility,  String onlineStatus,  String? currentCheckInHallId,  List<String> blockedUsers)?  $default,) {final _that = this;
switch (_that) {
case _UserModel() when $default != null:
return $default(_that.uid,_that.email,_that.firstName,_that.lastName,_that.username,_that.birthday,_that.phoneNumber,_that.recoveryEmail,_that.role,_that.currentPoints,_that.homeBaseId,_that.qrToken,_that.bio,_that.photoUrl,_that.bannerUrl,_that.following,_that.realNameVisibility,_that.onlineStatus,_that.currentCheckInHallId,_that.blockedUsers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserModel implements UserModel {
  const _UserModel({required this.uid, required this.email, required this.firstName, required this.lastName, required this.username, required this.birthday, this.phoneNumber, this.recoveryEmail, this.role = 'player', this.currentPoints = 0, this.homeBaseId, this.qrToken, this.bio, this.photoUrl, this.bannerUrl, final  List<String> following = const [], this.realNameVisibility = 'Private', this.onlineStatus = 'Online', this.currentCheckInHallId, final  List<String> blockedUsers = const []}): _following = following,_blockedUsers = blockedUsers;
  factory _UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String firstName;
@override final  String lastName;
@override final  String username;
@override final  DateTime birthday;
@override final  String? phoneNumber;
@override final  String? recoveryEmail;
@override@JsonKey() final  String role;
// superadmin, admin, owner, manager, worker, player
@override@JsonKey() final  int currentPoints;
@override final  String? homeBaseId;
@override final  String? qrToken;
@override final  String? bio;
@override final  String? photoUrl;
@override final  String? bannerUrl;
 final  List<String> _following;
@override@JsonKey() List<String> get following {
  if (_following is EqualUnmodifiableListView) return _following;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_following);
}

@override@JsonKey() final  String realNameVisibility;
// 'Private', 'Friends Only', 'Everyone'
@override@JsonKey() final  String onlineStatus;
@override final  String? currentCheckInHallId;
 final  List<String> _blockedUsers;
@override@JsonKey() List<String> get blockedUsers {
  if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedUsers);
}


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserModelCopyWith<_UserModel> get copyWith => __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.username, username) || other.username == username)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.recoveryEmail, recoveryEmail) || other.recoveryEmail == recoveryEmail)&&(identical(other.role, role) || other.role == role)&&(identical(other.currentPoints, currentPoints) || other.currentPoints == currentPoints)&&(identical(other.homeBaseId, homeBaseId) || other.homeBaseId == homeBaseId)&&(identical(other.qrToken, qrToken) || other.qrToken == qrToken)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.bannerUrl, bannerUrl) || other.bannerUrl == bannerUrl)&&const DeepCollectionEquality().equals(other._following, _following)&&(identical(other.realNameVisibility, realNameVisibility) || other.realNameVisibility == realNameVisibility)&&(identical(other.onlineStatus, onlineStatus) || other.onlineStatus == onlineStatus)&&(identical(other.currentCheckInHallId, currentCheckInHallId) || other.currentCheckInHallId == currentCheckInHallId)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,firstName,lastName,username,birthday,phoneNumber,recoveryEmail,role,currentPoints,homeBaseId,qrToken,bio,photoUrl,bannerUrl,const DeepCollectionEquality().hash(_following),realNameVisibility,onlineStatus,currentCheckInHallId,const DeepCollectionEquality().hash(_blockedUsers)]);

@override
String toString() {
  return 'UserModel(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName, username: $username, birthday: $birthday, phoneNumber: $phoneNumber, recoveryEmail: $recoveryEmail, role: $role, currentPoints: $currentPoints, homeBaseId: $homeBaseId, qrToken: $qrToken, bio: $bio, photoUrl: $photoUrl, bannerUrl: $bannerUrl, following: $following, realNameVisibility: $realNameVisibility, onlineStatus: $onlineStatus, currentCheckInHallId: $currentCheckInHallId, blockedUsers: $blockedUsers)';
}


}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(_UserModel value, $Res Function(_UserModel) _then) = __$UserModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String firstName, String lastName, String username, DateTime birthday, String? phoneNumber, String? recoveryEmail, String role, int currentPoints, String? homeBaseId, String? qrToken, String? bio, String? photoUrl, String? bannerUrl, List<String> following, String realNameVisibility, String onlineStatus, String? currentCheckInHallId, List<String> blockedUsers
});




}
/// @nodoc
class __$UserModelCopyWithImpl<$Res>
    implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? firstName = null,Object? lastName = null,Object? username = null,Object? birthday = null,Object? phoneNumber = freezed,Object? recoveryEmail = freezed,Object? role = null,Object? currentPoints = null,Object? homeBaseId = freezed,Object? qrToken = freezed,Object? bio = freezed,Object? photoUrl = freezed,Object? bannerUrl = freezed,Object? following = null,Object? realNameVisibility = null,Object? onlineStatus = null,Object? currentCheckInHallId = freezed,Object? blockedUsers = null,}) {
  return _then(_UserModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,birthday: null == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,recoveryEmail: freezed == recoveryEmail ? _self.recoveryEmail : recoveryEmail // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,currentPoints: null == currentPoints ? _self.currentPoints : currentPoints // ignore: cast_nullable_to_non_nullable
as int,homeBaseId: freezed == homeBaseId ? _self.homeBaseId : homeBaseId // ignore: cast_nullable_to_non_nullable
as String?,qrToken: freezed == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,bannerUrl: freezed == bannerUrl ? _self.bannerUrl : bannerUrl // ignore: cast_nullable_to_non_nullable
as String?,following: null == following ? _self._following : following // ignore: cast_nullable_to_non_nullable
as List<String>,realNameVisibility: null == realNameVisibility ? _self.realNameVisibility : realNameVisibility // ignore: cast_nullable_to_non_nullable
as String,onlineStatus: null == onlineStatus ? _self.onlineStatus : onlineStatus // ignore: cast_nullable_to_non_nullable
as String,currentCheckInHallId: freezed == currentCheckInHallId ? _self.currentCheckInHallId : currentCheckInHallId // ignore: cast_nullable_to_non_nullable
as String?,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
