// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drink_ticket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DrinkTicketModel {

 String get id; String get userId; String get venueId; String get venueName; String get title; String get description; DateTime get issuedAt; DateTime? get expiresAt; bool get isValid; String? get imageUrl;
/// Create a copy of DrinkTicketModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DrinkTicketModelCopyWith<DrinkTicketModel> get copyWith => _$DrinkTicketModelCopyWithImpl<DrinkTicketModel>(this as DrinkTicketModel, _$identity);

  /// Serializes this DrinkTicketModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DrinkTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,venueId,venueName,title,description,issuedAt,expiresAt,isValid,imageUrl);

@override
String toString() {
  return 'DrinkTicketModel(id: $id, userId: $userId, venueId: $venueId, venueName: $venueName, title: $title, description: $description, issuedAt: $issuedAt, expiresAt: $expiresAt, isValid: $isValid, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $DrinkTicketModelCopyWith<$Res>  {
  factory $DrinkTicketModelCopyWith(DrinkTicketModel value, $Res Function(DrinkTicketModel) _then) = _$DrinkTicketModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String venueId, String venueName, String title, String description, DateTime issuedAt, DateTime? expiresAt, bool isValid, String? imageUrl
});




}
/// @nodoc
class _$DrinkTicketModelCopyWithImpl<$Res>
    implements $DrinkTicketModelCopyWith<$Res> {
  _$DrinkTicketModelCopyWithImpl(this._self, this._then);

  final DrinkTicketModel _self;
  final $Res Function(DrinkTicketModel) _then;

/// Create a copy of DrinkTicketModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? venueId = null,Object? venueName = null,Object? title = null,Object? description = null,Object? issuedAt = null,Object? expiresAt = freezed,Object? isValid = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DrinkTicketModel].
extension DrinkTicketModelPatterns on DrinkTicketModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DrinkTicketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DrinkTicketModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DrinkTicketModel value)  $default,){
final _that = this;
switch (_that) {
case _DrinkTicketModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DrinkTicketModel value)?  $default,){
final _that = this;
switch (_that) {
case _DrinkTicketModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String venueId,  String venueName,  String title,  String description,  DateTime issuedAt,  DateTime? expiresAt,  bool isValid,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DrinkTicketModel() when $default != null:
return $default(_that.id,_that.userId,_that.venueId,_that.venueName,_that.title,_that.description,_that.issuedAt,_that.expiresAt,_that.isValid,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String venueId,  String venueName,  String title,  String description,  DateTime issuedAt,  DateTime? expiresAt,  bool isValid,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _DrinkTicketModel():
return $default(_that.id,_that.userId,_that.venueId,_that.venueName,_that.title,_that.description,_that.issuedAt,_that.expiresAt,_that.isValid,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String venueId,  String venueName,  String title,  String description,  DateTime issuedAt,  DateTime? expiresAt,  bool isValid,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _DrinkTicketModel() when $default != null:
return $default(_that.id,_that.userId,_that.venueId,_that.venueName,_that.title,_that.description,_that.issuedAt,_that.expiresAt,_that.isValid,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _DrinkTicketModel extends DrinkTicketModel {
  const _DrinkTicketModel({required this.id, required this.userId, required this.venueId, required this.venueName, required this.title, required this.description, required this.issuedAt, this.expiresAt, this.isValid = true, this.imageUrl}): super._();
  factory _DrinkTicketModel.fromJson(Map<String, dynamic> json) => _$DrinkTicketModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String venueId;
@override final  String venueName;
@override final  String title;
@override final  String description;
@override final  DateTime issuedAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  bool isValid;
@override final  String? imageUrl;

/// Create a copy of DrinkTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DrinkTicketModelCopyWith<_DrinkTicketModel> get copyWith => __$DrinkTicketModelCopyWithImpl<_DrinkTicketModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DrinkTicketModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DrinkTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.venueName, venueName) || other.venueName == venueName)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,venueId,venueName,title,description,issuedAt,expiresAt,isValid,imageUrl);

@override
String toString() {
  return 'DrinkTicketModel(id: $id, userId: $userId, venueId: $venueId, venueName: $venueName, title: $title, description: $description, issuedAt: $issuedAt, expiresAt: $expiresAt, isValid: $isValid, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$DrinkTicketModelCopyWith<$Res> implements $DrinkTicketModelCopyWith<$Res> {
  factory _$DrinkTicketModelCopyWith(_DrinkTicketModel value, $Res Function(_DrinkTicketModel) _then) = __$DrinkTicketModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String venueId, String venueName, String title, String description, DateTime issuedAt, DateTime? expiresAt, bool isValid, String? imageUrl
});




}
/// @nodoc
class __$DrinkTicketModelCopyWithImpl<$Res>
    implements _$DrinkTicketModelCopyWith<$Res> {
  __$DrinkTicketModelCopyWithImpl(this._self, this._then);

  final _DrinkTicketModel _self;
  final $Res Function(_DrinkTicketModel) _then;

/// Create a copy of DrinkTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? venueId = null,Object? venueName = null,Object? title = null,Object? description = null,Object? issuedAt = null,Object? expiresAt = freezed,Object? isValid = null,Object? imageUrl = freezed,}) {
  return _then(_DrinkTicketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,venueName: null == venueName ? _self.venueName : venueName // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,issuedAt: null == issuedAt ? _self.issuedAt : issuedAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
