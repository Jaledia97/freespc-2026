// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoreItemModel {

 String get id; String get hallId; String get title; String get description; int get cost;// Points required
 String get imageUrl; String get category;// "Merchandise", "Food & Beverage", "Sessions", "Pull Tabs", "Electronics", "Other"
 bool get isActive; int? get perCustomerLimit;// Max items per person
 int? get dailyLimit;// Max items sold per day (overall)
@TimestampConverter() DateTime get createdAt;
/// Create a copy of StoreItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreItemModelCopyWith<StoreItemModel> get copyWith => _$StoreItemModelCopyWithImpl<StoreItemModel>(this as StoreItemModel, _$identity);

  /// Serializes this StoreItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoreItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.perCustomerLimit, perCustomerLimit) || other.perCustomerLimit == perCustomerLimit)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,title,description,cost,imageUrl,category,isActive,perCustomerLimit,dailyLimit,createdAt);

@override
String toString() {
  return 'StoreItemModel(id: $id, hallId: $hallId, title: $title, description: $description, cost: $cost, imageUrl: $imageUrl, category: $category, isActive: $isActive, perCustomerLimit: $perCustomerLimit, dailyLimit: $dailyLimit, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $StoreItemModelCopyWith<$Res>  {
  factory $StoreItemModelCopyWith(StoreItemModel value, $Res Function(StoreItemModel) _then) = _$StoreItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String hallId, String title, String description, int cost, String imageUrl, String category, bool isActive, int? perCustomerLimit, int? dailyLimit,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$StoreItemModelCopyWithImpl<$Res>
    implements $StoreItemModelCopyWith<$Res> {
  _$StoreItemModelCopyWithImpl(this._self, this._then);

  final StoreItemModel _self;
  final $Res Function(StoreItemModel) _then;

/// Create a copy of StoreItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hallId = null,Object? title = null,Object? description = null,Object? cost = null,Object? imageUrl = null,Object? category = null,Object? isActive = null,Object? perCustomerLimit = freezed,Object? dailyLimit = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,perCustomerLimit: freezed == perCustomerLimit ? _self.perCustomerLimit : perCustomerLimit // ignore: cast_nullable_to_non_nullable
as int?,dailyLimit: freezed == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StoreItemModel].
extension StoreItemModelPatterns on StoreItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoreItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoreItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoreItemModel value)  $default,){
final _that = this;
switch (_that) {
case _StoreItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoreItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _StoreItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String hallId,  String title,  String description,  int cost,  String imageUrl,  String category,  bool isActive,  int? perCustomerLimit,  int? dailyLimit, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoreItemModel() when $default != null:
return $default(_that.id,_that.hallId,_that.title,_that.description,_that.cost,_that.imageUrl,_that.category,_that.isActive,_that.perCustomerLimit,_that.dailyLimit,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String hallId,  String title,  String description,  int cost,  String imageUrl,  String category,  bool isActive,  int? perCustomerLimit,  int? dailyLimit, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _StoreItemModel():
return $default(_that.id,_that.hallId,_that.title,_that.description,_that.cost,_that.imageUrl,_that.category,_that.isActive,_that.perCustomerLimit,_that.dailyLimit,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String hallId,  String title,  String description,  int cost,  String imageUrl,  String category,  bool isActive,  int? perCustomerLimit,  int? dailyLimit, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StoreItemModel() when $default != null:
return $default(_that.id,_that.hallId,_that.title,_that.description,_that.cost,_that.imageUrl,_that.category,_that.isActive,_that.perCustomerLimit,_that.dailyLimit,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _StoreItemModel extends StoreItemModel {
  const _StoreItemModel({required this.id, required this.hallId, required this.title, required this.description, required this.cost, required this.imageUrl, this.category = "General", this.isActive = true, this.perCustomerLimit, this.dailyLimit, @TimestampConverter() required this.createdAt}): super._();
  factory _StoreItemModel.fromJson(Map<String, dynamic> json) => _$StoreItemModelFromJson(json);

@override final  String id;
@override final  String hallId;
@override final  String title;
@override final  String description;
@override final  int cost;
// Points required
@override final  String imageUrl;
@override@JsonKey() final  String category;
// "Merchandise", "Food & Beverage", "Sessions", "Pull Tabs", "Electronics", "Other"
@override@JsonKey() final  bool isActive;
@override final  int? perCustomerLimit;
// Max items per person
@override final  int? dailyLimit;
// Max items sold per day (overall)
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of StoreItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreItemModelCopyWith<_StoreItemModel> get copyWith => __$StoreItemModelCopyWithImpl<_StoreItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoreItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.cost, cost) || other.cost == cost)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.category, category) || other.category == category)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.perCustomerLimit, perCustomerLimit) || other.perCustomerLimit == perCustomerLimit)&&(identical(other.dailyLimit, dailyLimit) || other.dailyLimit == dailyLimit)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,title,description,cost,imageUrl,category,isActive,perCustomerLimit,dailyLimit,createdAt);

@override
String toString() {
  return 'StoreItemModel(id: $id, hallId: $hallId, title: $title, description: $description, cost: $cost, imageUrl: $imageUrl, category: $category, isActive: $isActive, perCustomerLimit: $perCustomerLimit, dailyLimit: $dailyLimit, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StoreItemModelCopyWith<$Res> implements $StoreItemModelCopyWith<$Res> {
  factory _$StoreItemModelCopyWith(_StoreItemModel value, $Res Function(_StoreItemModel) _then) = __$StoreItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String hallId, String title, String description, int cost, String imageUrl, String category, bool isActive, int? perCustomerLimit, int? dailyLimit,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$StoreItemModelCopyWithImpl<$Res>
    implements _$StoreItemModelCopyWith<$Res> {
  __$StoreItemModelCopyWithImpl(this._self, this._then);

  final _StoreItemModel _self;
  final $Res Function(_StoreItemModel) _then;

/// Create a copy of StoreItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hallId = null,Object? title = null,Object? description = null,Object? cost = null,Object? imageUrl = null,Object? category = null,Object? isActive = null,Object? perCustomerLimit = freezed,Object? dailyLimit = freezed,Object? createdAt = null,}) {
  return _then(_StoreItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as int,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,perCustomerLimit: freezed == perCustomerLimit ? _self.perCustomerLimit : perCustomerLimit // ignore: cast_nullable_to_non_nullable
as int?,dailyLimit: freezed == dailyLimit ? _self.dailyLimit : dailyLimit // ignore: cast_nullable_to_non_nullable
as int?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
