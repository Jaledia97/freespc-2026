// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hall_charity_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HallCharityModel {

 String get id; String get name; String get logoUrl;// URL to uploaded image
 String? get websiteUrl;
/// Create a copy of HallCharityModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HallCharityModelCopyWith<HallCharityModel> get copyWith => _$HallCharityModelCopyWithImpl<HallCharityModel>(this as HallCharityModel, _$identity);

  /// Serializes this HallCharityModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HallCharityModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,websiteUrl);

@override
String toString() {
  return 'HallCharityModel(id: $id, name: $name, logoUrl: $logoUrl, websiteUrl: $websiteUrl)';
}


}

/// @nodoc
abstract mixin class $HallCharityModelCopyWith<$Res>  {
  factory $HallCharityModelCopyWith(HallCharityModel value, $Res Function(HallCharityModel) _then) = _$HallCharityModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String logoUrl, String? websiteUrl
});




}
/// @nodoc
class _$HallCharityModelCopyWithImpl<$Res>
    implements $HallCharityModelCopyWith<$Res> {
  _$HallCharityModelCopyWithImpl(this._self, this._then);

  final HallCharityModel _self;
  final $Res Function(HallCharityModel) _then;

/// Create a copy of HallCharityModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logoUrl = null,Object? websiteUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HallCharityModel].
extension HallCharityModelPatterns on HallCharityModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HallCharityModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HallCharityModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HallCharityModel value)  $default,){
final _that = this;
switch (_that) {
case _HallCharityModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HallCharityModel value)?  $default,){
final _that = this;
switch (_that) {
case _HallCharityModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String logoUrl,  String? websiteUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HallCharityModel() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.websiteUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String logoUrl,  String? websiteUrl)  $default,) {final _that = this;
switch (_that) {
case _HallCharityModel():
return $default(_that.id,_that.name,_that.logoUrl,_that.websiteUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String logoUrl,  String? websiteUrl)?  $default,) {final _that = this;
switch (_that) {
case _HallCharityModel() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.websiteUrl);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _HallCharityModel implements HallCharityModel {
  const _HallCharityModel({required this.id, required this.name, required this.logoUrl, this.websiteUrl});
  factory _HallCharityModel.fromJson(Map<String, dynamic> json) => _$HallCharityModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String logoUrl;
// URL to uploaded image
@override final  String? websiteUrl;

/// Create a copy of HallCharityModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HallCharityModelCopyWith<_HallCharityModel> get copyWith => __$HallCharityModelCopyWithImpl<_HallCharityModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HallCharityModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HallCharityModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,websiteUrl);

@override
String toString() {
  return 'HallCharityModel(id: $id, name: $name, logoUrl: $logoUrl, websiteUrl: $websiteUrl)';
}


}

/// @nodoc
abstract mixin class _$HallCharityModelCopyWith<$Res> implements $HallCharityModelCopyWith<$Res> {
  factory _$HallCharityModelCopyWith(_HallCharityModel value, $Res Function(_HallCharityModel) _then) = __$HallCharityModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String logoUrl, String? websiteUrl
});




}
/// @nodoc
class __$HallCharityModelCopyWithImpl<$Res>
    implements _$HallCharityModelCopyWith<$Res> {
  __$HallCharityModelCopyWithImpl(this._self, this._then);

  final _HallCharityModel _self;
  final $Res Function(_HallCharityModel) _then;

/// Create a copy of HallCharityModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logoUrl = null,Object? websiteUrl = freezed,}) {
  return _then(_HallCharityModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
