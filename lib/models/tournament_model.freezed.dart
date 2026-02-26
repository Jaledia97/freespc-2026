// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tournament_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TournamentModel {

 String get id; String get hallId; String get title; String? get imageUrl; String get description; DateTime? get startTime; DateTime? get endTime; RecurrenceRule? get recurrenceRule; bool get isTemplate; DateTime? get archivedAt; List<TournamentGame> get games;
/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentModelCopyWith<TournamentModel> get copyWith => _$TournamentModelCopyWithImpl<TournamentModel>(this as TournamentModel, _$identity);

  /// Serializes this TournamentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other.games, games));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,title,imageUrl,description,startTime,endTime,recurrenceRule,isTemplate,archivedAt,const DeepCollectionEquality().hash(games));

@override
String toString() {
  return 'TournamentModel(id: $id, hallId: $hallId, title: $title, imageUrl: $imageUrl, description: $description, startTime: $startTime, endTime: $endTime, recurrenceRule: $recurrenceRule, isTemplate: $isTemplate, archivedAt: $archivedAt, games: $games)';
}


}

/// @nodoc
abstract mixin class $TournamentModelCopyWith<$Res>  {
  factory $TournamentModelCopyWith(TournamentModel value, $Res Function(TournamentModel) _then) = _$TournamentModelCopyWithImpl;
@useResult
$Res call({
 String id, String hallId, String title, String? imageUrl, String description, DateTime? startTime, DateTime? endTime, RecurrenceRule? recurrenceRule, bool isTemplate, DateTime? archivedAt, List<TournamentGame> games
});


$RecurrenceRuleCopyWith<$Res>? get recurrenceRule;

}
/// @nodoc
class _$TournamentModelCopyWithImpl<$Res>
    implements $TournamentModelCopyWith<$Res> {
  _$TournamentModelCopyWithImpl(this._self, this._then);

  final TournamentModel _self;
  final $Res Function(TournamentModel) _then;

/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? hallId = null,Object? title = null,Object? imageUrl = freezed,Object? description = null,Object? startTime = freezed,Object? endTime = freezed,Object? recurrenceRule = freezed,Object? isTemplate = null,Object? archivedAt = freezed,Object? games = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,games: null == games ? _self.games : games // ignore: cast_nullable_to_non_nullable
as List<TournamentGame>,
  ));
}
/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res>? get recurrenceRule {
    if (_self.recurrenceRule == null) {
    return null;
  }

  return $RecurrenceRuleCopyWith<$Res>(_self.recurrenceRule!, (value) {
    return _then(_self.copyWith(recurrenceRule: value));
  });
}
}


/// Adds pattern-matching-related methods to [TournamentModel].
extension TournamentModelPatterns on TournamentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentModel value)  $default,){
final _that = this;
switch (_that) {
case _TournamentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentModel value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String hallId,  String title,  String? imageUrl,  String description,  DateTime? startTime,  DateTime? endTime,  RecurrenceRule? recurrenceRule,  bool isTemplate,  DateTime? archivedAt,  List<TournamentGame> games)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
return $default(_that.id,_that.hallId,_that.title,_that.imageUrl,_that.description,_that.startTime,_that.endTime,_that.recurrenceRule,_that.isTemplate,_that.archivedAt,_that.games);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String hallId,  String title,  String? imageUrl,  String description,  DateTime? startTime,  DateTime? endTime,  RecurrenceRule? recurrenceRule,  bool isTemplate,  DateTime? archivedAt,  List<TournamentGame> games)  $default,) {final _that = this;
switch (_that) {
case _TournamentModel():
return $default(_that.id,_that.hallId,_that.title,_that.imageUrl,_that.description,_that.startTime,_that.endTime,_that.recurrenceRule,_that.isTemplate,_that.archivedAt,_that.games);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String hallId,  String title,  String? imageUrl,  String description,  DateTime? startTime,  DateTime? endTime,  RecurrenceRule? recurrenceRule,  bool isTemplate,  DateTime? archivedAt,  List<TournamentGame> games)?  $default,) {final _that = this;
switch (_that) {
case _TournamentModel() when $default != null:
return $default(_that.id,_that.hallId,_that.title,_that.imageUrl,_that.description,_that.startTime,_that.endTime,_that.recurrenceRule,_that.isTemplate,_that.archivedAt,_that.games);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TournamentModel extends TournamentModel {
  const _TournamentModel({required this.id, required this.hallId, required this.title, this.imageUrl, this.description = '', this.startTime, this.endTime, this.recurrenceRule, this.isTemplate = false, this.archivedAt, final  List<TournamentGame> games = const []}): _games = games,super._();
  factory _TournamentModel.fromJson(Map<String, dynamic> json) => _$TournamentModelFromJson(json);

@override final  String id;
@override final  String hallId;
@override final  String title;
@override final  String? imageUrl;
@override@JsonKey() final  String description;
@override final  DateTime? startTime;
@override final  DateTime? endTime;
@override final  RecurrenceRule? recurrenceRule;
@override@JsonKey() final  bool isTemplate;
@override final  DateTime? archivedAt;
 final  List<TournamentGame> _games;
@override@JsonKey() List<TournamentGame> get games {
  if (_games is EqualUnmodifiableListView) return _games;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_games);
}


/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentModelCopyWith<_TournamentModel> get copyWith => __$TournamentModelCopyWithImpl<_TournamentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentModel&&(identical(other.id, id) || other.id == id)&&(identical(other.hallId, hallId) || other.hallId == hallId)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.isTemplate, isTemplate) || other.isTemplate == isTemplate)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&const DeepCollectionEquality().equals(other._games, _games));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,hallId,title,imageUrl,description,startTime,endTime,recurrenceRule,isTemplate,archivedAt,const DeepCollectionEquality().hash(_games));

@override
String toString() {
  return 'TournamentModel(id: $id, hallId: $hallId, title: $title, imageUrl: $imageUrl, description: $description, startTime: $startTime, endTime: $endTime, recurrenceRule: $recurrenceRule, isTemplate: $isTemplate, archivedAt: $archivedAt, games: $games)';
}


}

/// @nodoc
abstract mixin class _$TournamentModelCopyWith<$Res> implements $TournamentModelCopyWith<$Res> {
  factory _$TournamentModelCopyWith(_TournamentModel value, $Res Function(_TournamentModel) _then) = __$TournamentModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String hallId, String title, String? imageUrl, String description, DateTime? startTime, DateTime? endTime, RecurrenceRule? recurrenceRule, bool isTemplate, DateTime? archivedAt, List<TournamentGame> games
});


@override $RecurrenceRuleCopyWith<$Res>? get recurrenceRule;

}
/// @nodoc
class __$TournamentModelCopyWithImpl<$Res>
    implements _$TournamentModelCopyWith<$Res> {
  __$TournamentModelCopyWithImpl(this._self, this._then);

  final _TournamentModel _self;
  final $Res Function(_TournamentModel) _then;

/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? hallId = null,Object? title = null,Object? imageUrl = freezed,Object? description = null,Object? startTime = freezed,Object? endTime = freezed,Object? recurrenceRule = freezed,Object? isTemplate = null,Object? archivedAt = freezed,Object? games = null,}) {
  return _then(_TournamentModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,hallId: null == hallId ? _self.hallId : hallId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,recurrenceRule: freezed == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as RecurrenceRule?,isTemplate: null == isTemplate ? _self.isTemplate : isTemplate // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,games: null == games ? _self._games : games // ignore: cast_nullable_to_non_nullable
as List<TournamentGame>,
  ));
}

/// Create a copy of TournamentModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RecurrenceRuleCopyWith<$Res>? get recurrenceRule {
    if (_self.recurrenceRule == null) {
    return null;
  }

  return $RecurrenceRuleCopyWith<$Res>(_self.recurrenceRule!, (value) {
    return _then(_self.copyWith(recurrenceRule: value));
  });
}
}


/// @nodoc
mixin _$TournamentGame {

 String get id; String get title; int get value;
/// Create a copy of TournamentGame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TournamentGameCopyWith<TournamentGame> get copyWith => _$TournamentGameCopyWithImpl<TournamentGame>(this as TournamentGame, _$identity);

  /// Serializes this TournamentGame to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TournamentGame&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,value);

@override
String toString() {
  return 'TournamentGame(id: $id, title: $title, value: $value)';
}


}

/// @nodoc
abstract mixin class $TournamentGameCopyWith<$Res>  {
  factory $TournamentGameCopyWith(TournamentGame value, $Res Function(TournamentGame) _then) = _$TournamentGameCopyWithImpl;
@useResult
$Res call({
 String id, String title, int value
});




}
/// @nodoc
class _$TournamentGameCopyWithImpl<$Res>
    implements $TournamentGameCopyWith<$Res> {
  _$TournamentGameCopyWithImpl(this._self, this._then);

  final TournamentGame _self;
  final $Res Function(TournamentGame) _then;

/// Create a copy of TournamentGame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? value = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TournamentGame].
extension TournamentGamePatterns on TournamentGame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TournamentGame value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TournamentGame() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TournamentGame value)  $default,){
final _that = this;
switch (_that) {
case _TournamentGame():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TournamentGame value)?  $default,){
final _that = this;
switch (_that) {
case _TournamentGame() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TournamentGame() when $default != null:
return $default(_that.id,_that.title,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int value)  $default,) {final _that = this;
switch (_that) {
case _TournamentGame():
return $default(_that.id,_that.title,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int value)?  $default,) {final _that = this;
switch (_that) {
case _TournamentGame() when $default != null:
return $default(_that.id,_that.title,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TournamentGame implements TournamentGame {
  const _TournamentGame({required this.id, required this.title, required this.value});
  factory _TournamentGame.fromJson(Map<String, dynamic> json) => _$TournamentGameFromJson(json);

@override final  String id;
@override final  String title;
@override final  int value;

/// Create a copy of TournamentGame
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TournamentGameCopyWith<_TournamentGame> get copyWith => __$TournamentGameCopyWithImpl<_TournamentGame>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TournamentGameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TournamentGame&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,value);

@override
String toString() {
  return 'TournamentGame(id: $id, title: $title, value: $value)';
}


}

/// @nodoc
abstract mixin class _$TournamentGameCopyWith<$Res> implements $TournamentGameCopyWith<$Res> {
  factory _$TournamentGameCopyWith(_TournamentGame value, $Res Function(_TournamentGame) _then) = __$TournamentGameCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int value
});




}
/// @nodoc
class __$TournamentGameCopyWithImpl<$Res>
    implements _$TournamentGameCopyWith<$Res> {
  __$TournamentGameCopyWithImpl(this._self, this._then);

  final _TournamentGame _self;
  final $Res Function(_TournamentGame) _then;

/// Create a copy of TournamentGame
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? value = null,}) {
  return _then(_TournamentGame(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
