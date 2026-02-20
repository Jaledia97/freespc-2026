// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatModel {

 String get id; String? get name;// Null for 1-on-1, string for groups
 bool get isGroup; List<String> get participantIds; Map<String, String> get participantNames;// Denormalized for 0-read UI
 String get lastMessage; DateTime get lastMessageAt; String get lastMessageSenderId; Map<String, int> get unreadCounts;
/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatModelCopyWith<ChatModel> get copyWith => _$ChatModelCopyWithImpl<ChatModel>(this as ChatModel, _$identity);

  /// Serializes this ChatModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&const DeepCollectionEquality().equals(other.participantNames, participantNames)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&const DeepCollectionEquality().equals(other.unreadCounts, unreadCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isGroup,const DeepCollectionEquality().hash(participantIds),const DeepCollectionEquality().hash(participantNames),lastMessage,lastMessageAt,lastMessageSenderId,const DeepCollectionEquality().hash(unreadCounts));

@override
String toString() {
  return 'ChatModel(id: $id, name: $name, isGroup: $isGroup, participantIds: $participantIds, participantNames: $participantNames, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, lastMessageSenderId: $lastMessageSenderId, unreadCounts: $unreadCounts)';
}


}

/// @nodoc
abstract mixin class $ChatModelCopyWith<$Res>  {
  factory $ChatModelCopyWith(ChatModel value, $Res Function(ChatModel) _then) = _$ChatModelCopyWithImpl;
@useResult
$Res call({
 String id, String? name, bool isGroup, List<String> participantIds, Map<String, String> participantNames, String lastMessage, DateTime lastMessageAt, String lastMessageSenderId, Map<String, int> unreadCounts
});




}
/// @nodoc
class _$ChatModelCopyWithImpl<$Res>
    implements $ChatModelCopyWith<$Res> {
  _$ChatModelCopyWithImpl(this._self, this._then);

  final ChatModel _self;
  final $Res Function(ChatModel) _then;

/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? isGroup = null,Object? participantIds = null,Object? participantNames = null,Object? lastMessage = null,Object? lastMessageAt = null,Object? lastMessageSenderId = null,Object? unreadCounts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,participantNames: null == participantNames ? _self.participantNames : participantNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageSenderId: null == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String,unreadCounts: null == unreadCounts ? _self.unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatModel].
extension ChatModelPatterns on ChatModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  bool isGroup,  List<String> participantIds,  Map<String, String> participantNames,  String lastMessage,  DateTime lastMessageAt,  String lastMessageSenderId,  Map<String, int> unreadCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
return $default(_that.id,_that.name,_that.isGroup,_that.participantIds,_that.participantNames,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderId,_that.unreadCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  bool isGroup,  List<String> participantIds,  Map<String, String> participantNames,  String lastMessage,  DateTime lastMessageAt,  String lastMessageSenderId,  Map<String, int> unreadCounts)  $default,) {final _that = this;
switch (_that) {
case _ChatModel():
return $default(_that.id,_that.name,_that.isGroup,_that.participantIds,_that.participantNames,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderId,_that.unreadCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  bool isGroup,  List<String> participantIds,  Map<String, String> participantNames,  String lastMessage,  DateTime lastMessageAt,  String lastMessageSenderId,  Map<String, int> unreadCounts)?  $default,) {final _that = this;
switch (_that) {
case _ChatModel() when $default != null:
return $default(_that.id,_that.name,_that.isGroup,_that.participantIds,_that.participantNames,_that.lastMessage,_that.lastMessageAt,_that.lastMessageSenderId,_that.unreadCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatModel extends ChatModel {
  const _ChatModel({required this.id, this.name, required this.isGroup, required final  List<String> participantIds, final  Map<String, String> participantNames = const {}, this.lastMessage = '', required this.lastMessageAt, this.lastMessageSenderId = '', final  Map<String, int> unreadCounts = const {}}): _participantIds = participantIds,_participantNames = participantNames,_unreadCounts = unreadCounts,super._();
  factory _ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);

@override final  String id;
@override final  String? name;
// Null for 1-on-1, string for groups
@override final  bool isGroup;
 final  List<String> _participantIds;
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

 final  Map<String, String> _participantNames;
@override@JsonKey() Map<String, String> get participantNames {
  if (_participantNames is EqualUnmodifiableMapView) return _participantNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_participantNames);
}

// Denormalized for 0-read UI
@override@JsonKey() final  String lastMessage;
@override final  DateTime lastMessageAt;
@override@JsonKey() final  String lastMessageSenderId;
 final  Map<String, int> _unreadCounts;
@override@JsonKey() Map<String, int> get unreadCounts {
  if (_unreadCounts is EqualUnmodifiableMapView) return _unreadCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unreadCounts);
}


/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatModelCopyWith<_ChatModel> get copyWith => __$ChatModelCopyWithImpl<_ChatModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.isGroup, isGroup) || other.isGroup == isGroup)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&const DeepCollectionEquality().equals(other._participantNames, _participantNames)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&const DeepCollectionEquality().equals(other._unreadCounts, _unreadCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,isGroup,const DeepCollectionEquality().hash(_participantIds),const DeepCollectionEquality().hash(_participantNames),lastMessage,lastMessageAt,lastMessageSenderId,const DeepCollectionEquality().hash(_unreadCounts));

@override
String toString() {
  return 'ChatModel(id: $id, name: $name, isGroup: $isGroup, participantIds: $participantIds, participantNames: $participantNames, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, lastMessageSenderId: $lastMessageSenderId, unreadCounts: $unreadCounts)';
}


}

/// @nodoc
abstract mixin class _$ChatModelCopyWith<$Res> implements $ChatModelCopyWith<$Res> {
  factory _$ChatModelCopyWith(_ChatModel value, $Res Function(_ChatModel) _then) = __$ChatModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, bool isGroup, List<String> participantIds, Map<String, String> participantNames, String lastMessage, DateTime lastMessageAt, String lastMessageSenderId, Map<String, int> unreadCounts
});




}
/// @nodoc
class __$ChatModelCopyWithImpl<$Res>
    implements _$ChatModelCopyWith<$Res> {
  __$ChatModelCopyWithImpl(this._self, this._then);

  final _ChatModel _self;
  final $Res Function(_ChatModel) _then;

/// Create a copy of ChatModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? isGroup = null,Object? participantIds = null,Object? participantNames = null,Object? lastMessage = null,Object? lastMessageAt = null,Object? lastMessageSenderId = null,Object? unreadCounts = null,}) {
  return _then(_ChatModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,isGroup: null == isGroup ? _self.isGroup : isGroup // ignore: cast_nullable_to_non_nullable
as bool,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,participantNames: null == participantNames ? _self._participantNames : participantNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,lastMessage: null == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String,lastMessageAt: null == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageSenderId: null == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String,unreadCounts: null == unreadCounts ? _self._unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
