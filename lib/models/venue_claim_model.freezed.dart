// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_claim_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VenueClaimModel {

 String get id; String get userId; String get requestedVenueId; String? get evidenceUrl; String get status;// 'pending', 'approved', 'rejected'
@TimestampConverter() DateTime get submittedAt; String? get venueName; String? get venueAddress; String? get venueCity; String? get venueState; String? get venueWebsite; String? get emailProvided; String? get venueType; String? get logoUrl;
/// Create a copy of VenueClaimModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueClaimModelCopyWith<VenueClaimModel> get copyWith => _$VenueClaimModelCopyWithImpl<VenueClaimModel>(this as VenueClaimModel, _$identity);

  /// Serializes this VenueClaimModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueClaimModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.requestedVenueId, requestedVenueId) || other.requestedVenueId == requestedVenueId)&&(identical(other.evidenceUrl, evidenceUrl) || other.evidenceUrl == evidenceUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.venueCity, venueCity) || other.venueCity == venueCity)&&(identical(other.venueState, venueState) || other.venueState == venueState)&&(identical(other.venueWebsite, venueWebsite) || other.venueWebsite == venueWebsite)&&(identical(other.emailProvided, emailProvided) || other.emailProvided == emailProvided)&&(identical(other.venueType, venueType) || other.venueType == venueType)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,requestedVenueId,evidenceUrl,status,submittedAt,venueName,venueAddress,venueCity,venueState,venueWebsite,emailProvided,venueType,logoUrl);

@override
String toString() {
  return 'VenueClaimModel(id: $id, userId: $userId, requestedVenueId: $requestedVenueId, evidenceUrl: $evidenceUrl, status: $status, submittedAt: $submittedAt, venueName: $venueName, venueAddress: $venueAddress, venueCity: $venueCity, venueState: $venueState, venueWebsite: $venueWebsite, emailProvided: $emailProvided, venueType: $venueType, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class $VenueClaimModelCopyWith<$Res>  {
  factory $VenueClaimModelCopyWith(VenueClaimModel value, $Res Function(VenueClaimModel) _then) = _$VenueClaimModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String requestedVenueId, String? evidenceUrl, String status,@TimestampConverter() DateTime submittedAt, String? venueName, String? venueAddress, String? venueCity, String? venueState, String? venueWebsite, String? emailProvided, String? venueType, String? logoUrl
});




}
/// @nodoc
class _$VenueClaimModelCopyWithImpl<$Res>
    implements $VenueClaimModelCopyWith<$Res> {
  _$VenueClaimModelCopyWithImpl(this._self, this._then);

  final VenueClaimModel _self;
  final $Res Function(VenueClaimModel) _then;

/// Create a copy of VenueClaimModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? requestedVenueId = null,Object? evidenceUrl = freezed,Object? status = null,Object? submittedAt = null,Object? venueName = freezed,Object? venueAddress = freezed,Object? venueCity = freezed,Object? venueState = freezed,Object? venueWebsite = freezed,Object? emailProvided = freezed,Object? venueType = freezed,Object? logoUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,requestedVenueId: null == requestedVenueId ? _self.requestedVenueId : requestedVenueId // ignore: cast_nullable_to_non_nullable
as String,evidenceUrl: freezed == evidenceUrl ? _self.evidenceUrl : evidenceUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,venueAddress: freezed == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String?,venueCity: freezed == venueCity ? _self.venueCity : venueCity // ignore: cast_nullable_to_non_nullable
as String?,venueState: freezed == venueState ? _self.venueState : venueState // ignore: cast_nullable_to_non_nullable
as String?,venueWebsite: freezed == venueWebsite ? _self.venueWebsite : venueWebsite // ignore: cast_nullable_to_non_nullable
as String?,emailProvided: freezed == emailProvided ? _self.emailProvided : emailProvided // ignore: cast_nullable_to_non_nullable
as String?,venueType: freezed == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueClaimModel].
extension VenueClaimModelPatterns on VenueClaimModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueClaimModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueClaimModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueClaimModel value)  $default,){
final _that = this;
switch (_that) {
case _VenueClaimModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueClaimModel value)?  $default,){
final _that = this;
switch (_that) {
case _VenueClaimModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String requestedVenueId,  String? evidenceUrl,  String status, @TimestampConverter()  DateTime submittedAt,  String? venueName,  String? venueAddress,  String? venueCity,  String? venueState,  String? venueWebsite,  String? emailProvided,  String? venueType,  String? logoUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueClaimModel() when $default != null:
return $default(_that.id,_that.userId,_that.requestedVenueId,_that.evidenceUrl,_that.status,_that.submittedAt,_that.venueName,_that.venueAddress,_that.venueCity,_that.venueState,_that.venueWebsite,_that.emailProvided,_that.venueType,_that.logoUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String requestedVenueId,  String? evidenceUrl,  String status, @TimestampConverter()  DateTime submittedAt,  String? venueName,  String? venueAddress,  String? venueCity,  String? venueState,  String? venueWebsite,  String? emailProvided,  String? venueType,  String? logoUrl)  $default,) {final _that = this;
switch (_that) {
case _VenueClaimModel():
return $default(_that.id,_that.userId,_that.requestedVenueId,_that.evidenceUrl,_that.status,_that.submittedAt,_that.venueName,_that.venueAddress,_that.venueCity,_that.venueState,_that.venueWebsite,_that.emailProvided,_that.venueType,_that.logoUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String requestedVenueId,  String? evidenceUrl,  String status, @TimestampConverter()  DateTime submittedAt,  String? venueName,  String? venueAddress,  String? venueCity,  String? venueState,  String? venueWebsite,  String? emailProvided,  String? venueType,  String? logoUrl)?  $default,) {final _that = this;
switch (_that) {
case _VenueClaimModel() when $default != null:
return $default(_that.id,_that.userId,_that.requestedVenueId,_that.evidenceUrl,_that.status,_that.submittedAt,_that.venueName,_that.venueAddress,_that.venueCity,_that.venueState,_that.venueWebsite,_that.emailProvided,_that.venueType,_that.logoUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VenueClaimModel extends VenueClaimModel {
  const _VenueClaimModel({required this.id, required this.userId, required this.requestedVenueId, this.evidenceUrl, required this.status, @TimestampConverter() required this.submittedAt, this.venueName, this.venueAddress, this.venueCity, this.venueState, this.venueWebsite, this.emailProvided, this.venueType, this.logoUrl}): super._();
  factory _VenueClaimModel.fromJson(Map<String, dynamic> json) => _$VenueClaimModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String requestedVenueId;
@override final  String? evidenceUrl;
@override final  String status;
// 'pending', 'approved', 'rejected'
@override@TimestampConverter() final  DateTime submittedAt;
@override final  String? venueName;
@override final  String? venueAddress;
@override final  String? venueCity;
@override final  String? venueState;
@override final  String? venueWebsite;
@override final  String? emailProvided;
@override final  String? venueType;
@override final  String? logoUrl;

/// Create a copy of VenueClaimModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueClaimModelCopyWith<_VenueClaimModel> get copyWith => __$VenueClaimModelCopyWithImpl<_VenueClaimModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VenueClaimModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueClaimModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.requestedVenueId, requestedVenueId) || other.requestedVenueId == requestedVenueId)&&(identical(other.evidenceUrl, evidenceUrl) || other.evidenceUrl == evidenceUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.venueAddress, venueAddress) || other.venueAddress == venueAddress)&&(identical(other.venueCity, venueCity) || other.venueCity == venueCity)&&(identical(other.venueState, venueState) || other.venueState == venueState)&&(identical(other.venueWebsite, venueWebsite) || other.venueWebsite == venueWebsite)&&(identical(other.emailProvided, emailProvided) || other.emailProvided == emailProvided)&&(identical(other.venueType, venueType) || other.venueType == venueType)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,requestedVenueId,evidenceUrl,status,submittedAt,venueName,venueAddress,venueCity,venueState,venueWebsite,emailProvided,venueType,logoUrl);

@override
String toString() {
  return 'VenueClaimModel(id: $id, userId: $userId, requestedVenueId: $requestedVenueId, evidenceUrl: $evidenceUrl, status: $status, submittedAt: $submittedAt, venueName: $venueName, venueAddress: $venueAddress, venueCity: $venueCity, venueState: $venueState, venueWebsite: $venueWebsite, emailProvided: $emailProvided, venueType: $venueType, logoUrl: $logoUrl)';
}


}

/// @nodoc
abstract mixin class _$VenueClaimModelCopyWith<$Res> implements $VenueClaimModelCopyWith<$Res> {
  factory _$VenueClaimModelCopyWith(_VenueClaimModel value, $Res Function(_VenueClaimModel) _then) = __$VenueClaimModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String requestedVenueId, String? evidenceUrl, String status,@TimestampConverter() DateTime submittedAt, String? venueName, String? venueAddress, String? venueCity, String? venueState, String? venueWebsite, String? emailProvided, String? venueType, String? logoUrl
});




}
/// @nodoc
class __$VenueClaimModelCopyWithImpl<$Res>
    implements _$VenueClaimModelCopyWith<$Res> {
  __$VenueClaimModelCopyWithImpl(this._self, this._then);

  final _VenueClaimModel _self;
  final $Res Function(_VenueClaimModel) _then;

/// Create a copy of VenueClaimModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? requestedVenueId = null,Object? evidenceUrl = freezed,Object? status = null,Object? submittedAt = null,Object? venueName = freezed,Object? venueAddress = freezed,Object? venueCity = freezed,Object? venueState = freezed,Object? venueWebsite = freezed,Object? emailProvided = freezed,Object? venueType = freezed,Object? logoUrl = freezed,}) {
  return _then(_VenueClaimModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,requestedVenueId: null == requestedVenueId ? _self.requestedVenueId : requestedVenueId // ignore: cast_nullable_to_non_nullable
as String,evidenceUrl: freezed == evidenceUrl ? _self.evidenceUrl : evidenceUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,venueName: freezed == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String?,venueAddress: freezed == venueAddress ? _self.venueAddress : venueAddress // ignore: cast_nullable_to_non_nullable
as String?,venueCity: freezed == venueCity ? _self.venueCity : venueCity // ignore: cast_nullable_to_non_nullable
as String?,venueState: freezed == venueState ? _self.venueState : venueState // ignore: cast_nullable_to_non_nullable
as String?,venueWebsite: freezed == venueWebsite ? _self.venueWebsite : venueWebsite // ignore: cast_nullable_to_non_nullable
as String?,emailProvided: freezed == emailProvided ? _self.emailProvided : emailProvided // ignore: cast_nullable_to_non_nullable
as String?,venueType: freezed == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
