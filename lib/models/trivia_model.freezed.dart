// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trivia_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TriviaModel {

 String get id; String get venueId; String get title; DateTime get date; String get category; String get prizeString; String? get imageUrl; bool get isActive; DateTime? get createdAt;
/// Create a copy of TriviaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TriviaModelCopyWith<TriviaModel> get copyWith => _$TriviaModelCopyWithImpl<TriviaModel>(this as TriviaModel, _$identity);

  /// Serializes this TriviaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TriviaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.category, category) || other.category == category)&&(identical(other.prizeString, prizeString) || other.prizeString == prizeString)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,venueId,title,date,category,prizeString,imageUrl,isActive,createdAt);

@override
String toString() {
  return 'TriviaModel(id: $id, venueId: $venueId, title: $title, date: $date, category: $category, prizeString: $prizeString, imageUrl: $imageUrl, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TriviaModelCopyWith<$Res>  {
  factory $TriviaModelCopyWith(TriviaModel value, $Res Function(TriviaModel) _then) = _$TriviaModelCopyWithImpl;
@useResult
$Res call({
 String id, String venueId, String title, DateTime date, String category, String prizeString, String? imageUrl, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class _$TriviaModelCopyWithImpl<$Res>
    implements $TriviaModelCopyWith<$Res> {
  _$TriviaModelCopyWithImpl(this._self, this._then);

  final TriviaModel _self;
  final $Res Function(TriviaModel) _then;

/// Create a copy of TriviaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? venueId = null,Object? title = null,Object? date = null,Object? category = null,Object? prizeString = null,Object? imageUrl = freezed,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,prizeString: null == prizeString ? _self.prizeString : prizeString // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TriviaModel].
extension TriviaModelPatterns on TriviaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TriviaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TriviaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TriviaModel value)  $default,){
final _that = this;
switch (_that) {
case _TriviaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TriviaModel value)?  $default,){
final _that = this;
switch (_that) {
case _TriviaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String venueId,  String title,  DateTime date,  String category,  String prizeString,  String? imageUrl,  bool isActive,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TriviaModel() when $default != null:
return $default(_that.id,_that.venueId,_that.title,_that.date,_that.category,_that.prizeString,_that.imageUrl,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String venueId,  String title,  DateTime date,  String category,  String prizeString,  String? imageUrl,  bool isActive,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TriviaModel():
return $default(_that.id,_that.venueId,_that.title,_that.date,_that.category,_that.prizeString,_that.imageUrl,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String venueId,  String title,  DateTime date,  String category,  String prizeString,  String? imageUrl,  bool isActive,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TriviaModel() when $default != null:
return $default(_that.id,_that.venueId,_that.title,_that.date,_that.category,_that.prizeString,_that.imageUrl,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TriviaModel extends TriviaModel {
  const _TriviaModel({required this.id, required this.venueId, required this.title, required this.date, required this.category, required this.prizeString, this.imageUrl, this.isActive = true, this.createdAt}): super._();
  factory _TriviaModel.fromJson(Map<String, dynamic> json) => _$TriviaModelFromJson(json);

@override final  String id;
@override final  String venueId;
@override final  String title;
@override final  DateTime date;
@override final  String category;
@override final  String prizeString;
@override final  String? imageUrl;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;

/// Create a copy of TriviaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TriviaModelCopyWith<_TriviaModel> get copyWith => __$TriviaModelCopyWithImpl<_TriviaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TriviaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TriviaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.venueId, venueId) || other.venueId == venueId)&&(identical(other.title, title) || other.title == title)&&(identical(other.date, date) || other.date == date)&&(identical(other.category, category) || other.category == category)&&(identical(other.prizeString, prizeString) || other.prizeString == prizeString)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,venueId,title,date,category,prizeString,imageUrl,isActive,createdAt);

@override
String toString() {
  return 'TriviaModel(id: $id, venueId: $venueId, title: $title, date: $date, category: $category, prizeString: $prizeString, imageUrl: $imageUrl, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TriviaModelCopyWith<$Res> implements $TriviaModelCopyWith<$Res> {
  factory _$TriviaModelCopyWith(_TriviaModel value, $Res Function(_TriviaModel) _then) = __$TriviaModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String venueId, String title, DateTime date, String category, String prizeString, String? imageUrl, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class __$TriviaModelCopyWithImpl<$Res>
    implements _$TriviaModelCopyWith<$Res> {
  __$TriviaModelCopyWithImpl(this._self, this._then);

  final _TriviaModel _self;
  final $Res Function(_TriviaModel) _then;

/// Create a copy of TriviaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? venueId = null,Object? title = null,Object? date = null,Object? category = null,Object? prizeString = null,Object? imageUrl = freezed,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_TriviaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,venueId: null == venueId ? _self.venueId : venueId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,prizeString: null == prizeString ? _self.prizeString : prizeString // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
