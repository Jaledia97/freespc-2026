// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedItem {

 Object get data;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedItem&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'FeedItem(data: $data)';
}


}

/// @nodoc
class $FeedItemCopyWith<$Res>  {
$FeedItemCopyWith(FeedItem _, $Res Function(FeedItem) __);
}


/// Adds pattern-matching-related methods to [FeedItem].
extension FeedItemPatterns on FeedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FeedItemTournament value)?  tournament,TResult Function( _FeedItemRaffle value)?  raffle,TResult Function( _FeedItemSpecial value)?  special,TResult Function( _FeedItemCheckIn value)?  checkIn,TResult Function( _FeedItemWinPost value)?  winPost,TResult Function( _FeedItemTextPost value)?  textPost,TResult Function( _FeedItemTrivia value)?  trivia,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedItemTournament() when tournament != null:
return tournament(_that);case _FeedItemRaffle() when raffle != null:
return raffle(_that);case _FeedItemSpecial() when special != null:
return special(_that);case _FeedItemCheckIn() when checkIn != null:
return checkIn(_that);case _FeedItemWinPost() when winPost != null:
return winPost(_that);case _FeedItemTextPost() when textPost != null:
return textPost(_that);case _FeedItemTrivia() when trivia != null:
return trivia(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FeedItemTournament value)  tournament,required TResult Function( _FeedItemRaffle value)  raffle,required TResult Function( _FeedItemSpecial value)  special,required TResult Function( _FeedItemCheckIn value)  checkIn,required TResult Function( _FeedItemWinPost value)  winPost,required TResult Function( _FeedItemTextPost value)  textPost,required TResult Function( _FeedItemTrivia value)  trivia,}){
final _that = this;
switch (_that) {
case _FeedItemTournament():
return tournament(_that);case _FeedItemRaffle():
return raffle(_that);case _FeedItemSpecial():
return special(_that);case _FeedItemCheckIn():
return checkIn(_that);case _FeedItemWinPost():
return winPost(_that);case _FeedItemTextPost():
return textPost(_that);case _FeedItemTrivia():
return trivia(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FeedItemTournament value)?  tournament,TResult? Function( _FeedItemRaffle value)?  raffle,TResult? Function( _FeedItemSpecial value)?  special,TResult? Function( _FeedItemCheckIn value)?  checkIn,TResult? Function( _FeedItemWinPost value)?  winPost,TResult? Function( _FeedItemTextPost value)?  textPost,TResult? Function( _FeedItemTrivia value)?  trivia,}){
final _that = this;
switch (_that) {
case _FeedItemTournament() when tournament != null:
return tournament(_that);case _FeedItemRaffle() when raffle != null:
return raffle(_that);case _FeedItemSpecial() when special != null:
return special(_that);case _FeedItemCheckIn() when checkIn != null:
return checkIn(_that);case _FeedItemWinPost() when winPost != null:
return winPost(_that);case _FeedItemTextPost() when textPost != null:
return textPost(_that);case _FeedItemTrivia() when trivia != null:
return trivia(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( TournamentModel data)?  tournament,TResult Function( RaffleModel data)?  raffle,TResult Function( SpecialModel data)?  special,TResult Function( CheckInModel data)?  checkIn,TResult Function( WinPostModel data)?  winPost,TResult Function( TextPostModel data)?  textPost,TResult Function( TriviaModel data)?  trivia,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedItemTournament() when tournament != null:
return tournament(_that.data);case _FeedItemRaffle() when raffle != null:
return raffle(_that.data);case _FeedItemSpecial() when special != null:
return special(_that.data);case _FeedItemCheckIn() when checkIn != null:
return checkIn(_that.data);case _FeedItemWinPost() when winPost != null:
return winPost(_that.data);case _FeedItemTextPost() when textPost != null:
return textPost(_that.data);case _FeedItemTrivia() when trivia != null:
return trivia(_that.data);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( TournamentModel data)  tournament,required TResult Function( RaffleModel data)  raffle,required TResult Function( SpecialModel data)  special,required TResult Function( CheckInModel data)  checkIn,required TResult Function( WinPostModel data)  winPost,required TResult Function( TextPostModel data)  textPost,required TResult Function( TriviaModel data)  trivia,}) {final _that = this;
switch (_that) {
case _FeedItemTournament():
return tournament(_that.data);case _FeedItemRaffle():
return raffle(_that.data);case _FeedItemSpecial():
return special(_that.data);case _FeedItemCheckIn():
return checkIn(_that.data);case _FeedItemWinPost():
return winPost(_that.data);case _FeedItemTextPost():
return textPost(_that.data);case _FeedItemTrivia():
return trivia(_that.data);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( TournamentModel data)?  tournament,TResult? Function( RaffleModel data)?  raffle,TResult? Function( SpecialModel data)?  special,TResult? Function( CheckInModel data)?  checkIn,TResult? Function( WinPostModel data)?  winPost,TResult? Function( TextPostModel data)?  textPost,TResult? Function( TriviaModel data)?  trivia,}) {final _that = this;
switch (_that) {
case _FeedItemTournament() when tournament != null:
return tournament(_that.data);case _FeedItemRaffle() when raffle != null:
return raffle(_that.data);case _FeedItemSpecial() when special != null:
return special(_that.data);case _FeedItemCheckIn() when checkIn != null:
return checkIn(_that.data);case _FeedItemWinPost() when winPost != null:
return winPost(_that.data);case _FeedItemTextPost() when textPost != null:
return textPost(_that.data);case _FeedItemTrivia() when trivia != null:
return trivia(_that.data);case _:
  return null;

}
}

}

/// @nodoc


class _FeedItemTournament extends FeedItem {
  const _FeedItemTournament(this.data): super._();
  

@override final  TournamentModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemTournamentCopyWith<_FeedItemTournament> get copyWith => __$FeedItemTournamentCopyWithImpl<_FeedItemTournament>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemTournament&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.tournament(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemTournamentCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemTournamentCopyWith(_FeedItemTournament value, $Res Function(_FeedItemTournament) _then) = __$FeedItemTournamentCopyWithImpl;
@useResult
$Res call({
 TournamentModel data
});


$TournamentModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemTournamentCopyWithImpl<$Res>
    implements _$FeedItemTournamentCopyWith<$Res> {
  __$FeedItemTournamentCopyWithImpl(this._self, this._then);

  final _FeedItemTournament _self;
  final $Res Function(_FeedItemTournament) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemTournament(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TournamentModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TournamentModelCopyWith<$Res> get data {
  
  return $TournamentModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _FeedItemRaffle extends FeedItem {
  const _FeedItemRaffle(this.data): super._();
  

@override final  RaffleModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemRaffleCopyWith<_FeedItemRaffle> get copyWith => __$FeedItemRaffleCopyWithImpl<_FeedItemRaffle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemRaffle&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.raffle(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemRaffleCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemRaffleCopyWith(_FeedItemRaffle value, $Res Function(_FeedItemRaffle) _then) = __$FeedItemRaffleCopyWithImpl;
@useResult
$Res call({
 RaffleModel data
});


$RaffleModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemRaffleCopyWithImpl<$Res>
    implements _$FeedItemRaffleCopyWith<$Res> {
  __$FeedItemRaffleCopyWithImpl(this._self, this._then);

  final _FeedItemRaffle _self;
  final $Res Function(_FeedItemRaffle) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemRaffle(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as RaffleModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RaffleModelCopyWith<$Res> get data {
  
  return $RaffleModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _FeedItemSpecial extends FeedItem {
  const _FeedItemSpecial(this.data): super._();
  

@override final  SpecialModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemSpecialCopyWith<_FeedItemSpecial> get copyWith => __$FeedItemSpecialCopyWithImpl<_FeedItemSpecial>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemSpecial&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.special(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemSpecialCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemSpecialCopyWith(_FeedItemSpecial value, $Res Function(_FeedItemSpecial) _then) = __$FeedItemSpecialCopyWithImpl;
@useResult
$Res call({
 SpecialModel data
});


$SpecialModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemSpecialCopyWithImpl<$Res>
    implements _$FeedItemSpecialCopyWith<$Res> {
  __$FeedItemSpecialCopyWithImpl(this._self, this._then);

  final _FeedItemSpecial _self;
  final $Res Function(_FeedItemSpecial) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemSpecial(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as SpecialModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SpecialModelCopyWith<$Res> get data {
  
  return $SpecialModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _FeedItemCheckIn extends FeedItem {
  const _FeedItemCheckIn(this.data): super._();
  

@override final  CheckInModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemCheckInCopyWith<_FeedItemCheckIn> get copyWith => __$FeedItemCheckInCopyWithImpl<_FeedItemCheckIn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemCheckIn&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.checkIn(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemCheckInCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemCheckInCopyWith(_FeedItemCheckIn value, $Res Function(_FeedItemCheckIn) _then) = __$FeedItemCheckInCopyWithImpl;
@useResult
$Res call({
 CheckInModel data
});


$CheckInModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemCheckInCopyWithImpl<$Res>
    implements _$FeedItemCheckInCopyWith<$Res> {
  __$FeedItemCheckInCopyWithImpl(this._self, this._then);

  final _FeedItemCheckIn _self;
  final $Res Function(_FeedItemCheckIn) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemCheckIn(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as CheckInModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CheckInModelCopyWith<$Res> get data {
  
  return $CheckInModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _FeedItemWinPost extends FeedItem {
  const _FeedItemWinPost(this.data): super._();
  

@override final  WinPostModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemWinPostCopyWith<_FeedItemWinPost> get copyWith => __$FeedItemWinPostCopyWithImpl<_FeedItemWinPost>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemWinPost&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.winPost(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemWinPostCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemWinPostCopyWith(_FeedItemWinPost value, $Res Function(_FeedItemWinPost) _then) = __$FeedItemWinPostCopyWithImpl;
@useResult
$Res call({
 WinPostModel data
});


$WinPostModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemWinPostCopyWithImpl<$Res>
    implements _$FeedItemWinPostCopyWith<$Res> {
  __$FeedItemWinPostCopyWithImpl(this._self, this._then);

  final _FeedItemWinPost _self;
  final $Res Function(_FeedItemWinPost) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemWinPost(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as WinPostModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WinPostModelCopyWith<$Res> get data {
  
  return $WinPostModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _FeedItemTextPost extends FeedItem {
  const _FeedItemTextPost(this.data): super._();
  

@override final  TextPostModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemTextPostCopyWith<_FeedItemTextPost> get copyWith => __$FeedItemTextPostCopyWithImpl<_FeedItemTextPost>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemTextPost&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.textPost(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemTextPostCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemTextPostCopyWith(_FeedItemTextPost value, $Res Function(_FeedItemTextPost) _then) = __$FeedItemTextPostCopyWithImpl;
@useResult
$Res call({
 TextPostModel data
});


$TextPostModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemTextPostCopyWithImpl<$Res>
    implements _$FeedItemTextPostCopyWith<$Res> {
  __$FeedItemTextPostCopyWithImpl(this._self, this._then);

  final _FeedItemTextPost _self;
  final $Res Function(_FeedItemTextPost) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemTextPost(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TextPostModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextPostModelCopyWith<$Res> get data {
  
  return $TextPostModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

/// @nodoc


class _FeedItemTrivia extends FeedItem {
  const _FeedItemTrivia(this.data): super._();
  

@override final  TriviaModel data;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedItemTriviaCopyWith<_FeedItemTrivia> get copyWith => __$FeedItemTriviaCopyWithImpl<_FeedItemTrivia>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedItemTrivia&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'FeedItem.trivia(data: $data)';
}


}

/// @nodoc
abstract mixin class _$FeedItemTriviaCopyWith<$Res> implements $FeedItemCopyWith<$Res> {
  factory _$FeedItemTriviaCopyWith(_FeedItemTrivia value, $Res Function(_FeedItemTrivia) _then) = __$FeedItemTriviaCopyWithImpl;
@useResult
$Res call({
 TriviaModel data
});


$TriviaModelCopyWith<$Res> get data;

}
/// @nodoc
class __$FeedItemTriviaCopyWithImpl<$Res>
    implements _$FeedItemTriviaCopyWith<$Res> {
  __$FeedItemTriviaCopyWithImpl(this._self, this._then);

  final _FeedItemTrivia _self;
  final $Res Function(_FeedItemTrivia) _then;

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_FeedItemTrivia(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as TriviaModel,
  ));
}

/// Create a copy of FeedItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TriviaModelCopyWith<$Res> get data {
  
  return $TriviaModelCopyWith<$Res>(_self.data, (value) {
    return _then(_self.copyWith(data: value));
  });
}
}

// dart format on
