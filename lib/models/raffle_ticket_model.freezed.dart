// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'raffle_ticket_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RaffleTicketModel {

 String get id; String get raffleId; String get hallId; String get title; String get hallName; int get quantity; DateTime get purchaseDate; String? get imageUrl;
/// Create a copy of RaffleTicketModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RaffleTicketModelCopyWith<RaffleTicketModel> get copyWith => _$RaffleTicketModelCopyWithImpl<RaffleTicketModel>(this as RaffleTicketModel, _$identity);

  /// Serializes this RaffleTicketModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RaffleTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.raffleId, raffleId) || other.raffleId == raffleId)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.title, title) || other.title == title)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,raffleId,hallId,title,hallName,quantity,purchaseDate,imageUrl);

@override
String toString() {
  return 'RaffleTicketModel(id: $id, raffleId: $raffleId, hallId: $hallId, title: $title, hallName: $hallName, quantity: $quantity, purchaseDate: $purchaseDate, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $RaffleTicketModelCopyWith<$Res>  {
  factory $RaffleTicketModelCopyWith(RaffleTicketModel value, $Res Function(RaffleTicketModel) _then) = _$RaffleTicketModelCopyWithImpl;
@useResult
$Res call({
 String id, String raffleId, String hallId, String title, String hallName, int quantity, DateTime purchaseDate, String? imageUrl
});




}
/// @nodoc
class _$RaffleTicketModelCopyWithImpl<$Res>
    implements $RaffleTicketModelCopyWith<$Res> {
  _$RaffleTicketModelCopyWithImpl(this._self, this._then);

  final RaffleTicketModel _self;
  final $Res Function(RaffleTicketModel) _then;

/// Create a copy of RaffleTicketModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? raffleId = null,Object? hallId = null,Object? title = null,Object? hallName = null,Object? quantity = null,Object? purchaseDate = null,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,raffleId: null == raffleId ? _self.raffleId : raffleId // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RaffleTicketModel].
extension RaffleTicketModelPatterns on RaffleTicketModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RaffleTicketModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RaffleTicketModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RaffleTicketModel value)  $default,){
final _that = this;
switch (_that) {
case _RaffleTicketModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RaffleTicketModel value)?  $default,){
final _that = this;
switch (_that) {
case _RaffleTicketModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String raffleId,  String hallId,  String title,  String hallName,  int quantity,  DateTime purchaseDate,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RaffleTicketModel() when $default != null:
return $default(_that.id,_that.raffleId,_that.hallId,_that.title,_that.hallName,_that.quantity,_that.purchaseDate,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String raffleId,  String hallId,  String title,  String hallName,  int quantity,  DateTime purchaseDate,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _RaffleTicketModel():
return $default(_that.id,_that.raffleId,_that.hallId,_that.title,_that.hallName,_that.quantity,_that.purchaseDate,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String raffleId,  String hallId,  String title,  String hallName,  int quantity,  DateTime purchaseDate,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _RaffleTicketModel() when $default != null:
return $default(_that.id,_that.raffleId,_that.hallId,_that.title,_that.hallName,_that.quantity,_that.purchaseDate,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RaffleTicketModel implements RaffleTicketModel {
  const _RaffleTicketModel({required this.id, required this.raffleId, required this.hallId, required this.title, required this.hallName, required this.quantity, required this.purchaseDate, this.imageUrl});
  factory _RaffleTicketModel.fromJson(Map<String, dynamic> json) => _$RaffleTicketModelFromJson(json);

@override final  String id;
@override final  String raffleId;
@override final  String hallId;
@override final  String title;
@override final  String hallName;
@override final  int quantity;
@override final  DateTime purchaseDate;
@override final  String? imageUrl;

/// Create a copy of RaffleTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RaffleTicketModelCopyWith<_RaffleTicketModel> get copyWith => __$RaffleTicketModelCopyWithImpl<_RaffleTicketModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RaffleTicketModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RaffleTicketModel&&(identical(other.id, id) || other.id == id)&&(identical(other.raffleId, raffleId) || other.raffleId == raffleId)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.title, title) || other.title == title)&&(identical(other.hallName, hallName) || other.hallName == hallName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,raffleId,hallId,title,hallName,quantity,purchaseDate,imageUrl);

@override
String toString() {
  return 'RaffleTicketModel(id: $id, raffleId: $raffleId, hallId: $hallId, title: $title, hallName: $hallName, quantity: $quantity, purchaseDate: $purchaseDate, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$RaffleTicketModelCopyWith<$Res> implements $RaffleTicketModelCopyWith<$Res> {
  factory _$RaffleTicketModelCopyWith(_RaffleTicketModel value, $Res Function(_RaffleTicketModel) _then) = __$RaffleTicketModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String raffleId, String hallId, String title, String hallName, int quantity, DateTime purchaseDate, String? imageUrl
});




}
/// @nodoc
class __$RaffleTicketModelCopyWithImpl<$Res>
    implements _$RaffleTicketModelCopyWith<$Res> {
  __$RaffleTicketModelCopyWithImpl(this._self, this._then);

  final _RaffleTicketModel _self;
  final $Res Function(_RaffleTicketModel) _then;

/// Create a copy of RaffleTicketModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? raffleId = null,Object? hallId = null,Object? title = null,Object? hallName = null,Object? quantity = null,Object? purchaseDate = null,Object? imageUrl = freezed,}) {
  return _then(_RaffleTicketModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,raffleId: null == raffleId ? _self.raffleId : raffleId // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,hallName: null == hallName ? _self.hallName : hallName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,purchaseDate: null == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
