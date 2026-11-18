// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_relations.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FriendRelations {
  /// 내가 친구로 추가한 사용자 (채팅방 초대 대상)
  List<String> get friends;

  /// 나를 팔로우하는 사용자
  List<String> get followers;

  /// 내가 팔로우하는 사용자
  List<String> get following;

  /// Create a copy of FriendRelations
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $FriendRelationsCopyWith<FriendRelations> get copyWith =>
      _$FriendRelationsCopyWithImpl<FriendRelations>(
          this as FriendRelations, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is FriendRelations &&
            const DeepCollectionEquality().equals(other.friends, friends) &&
            const DeepCollectionEquality().equals(other.followers, followers) &&
            const DeepCollectionEquality().equals(other.following, following));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(friends),
      const DeepCollectionEquality().hash(followers),
      const DeepCollectionEquality().hash(following));

  @override
  String toString() {
    return 'FriendRelations(friends: $friends, followers: $followers, following: $following)';
  }
}

/// @nodoc
abstract mixin class $FriendRelationsCopyWith<$Res> {
  factory $FriendRelationsCopyWith(
          FriendRelations value, $Res Function(FriendRelations) _then) =
      _$FriendRelationsCopyWithImpl;
  @useResult
  $Res call(
      {List<String> friends, List<String> followers, List<String> following});
}

/// @nodoc
class _$FriendRelationsCopyWithImpl<$Res>
    implements $FriendRelationsCopyWith<$Res> {
  _$FriendRelationsCopyWithImpl(this._self, this._then);

  final FriendRelations _self;
  final $Res Function(FriendRelations) _then;

  /// Create a copy of FriendRelations
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
    Object? followers = null,
    Object? following = null,
  }) {
    return _then(_self.copyWith(
      friends: null == friends
          ? _self.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      following: null == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [FriendRelations].
extension FriendRelationsPatterns on FriendRelations {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_FriendRelations value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FriendRelations() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_FriendRelations value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FriendRelations():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_FriendRelations value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FriendRelations() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<String> friends, List<String> followers,
            List<String> following)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _FriendRelations() when $default != null:
        return $default(_that.friends, _that.followers, _that.following);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<String> friends, List<String> followers,
            List<String> following)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FriendRelations():
        return $default(_that.friends, _that.followers, _that.following);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<String> friends, List<String> followers,
            List<String> following)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _FriendRelations() when $default != null:
        return $default(_that.friends, _that.followers, _that.following);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _FriendRelations extends FriendRelations {
  const _FriendRelations(
      {final List<String> friends = const <String>[],
      final List<String> followers = const <String>[],
      final List<String> following = const <String>[]})
      : _friends = friends,
        _followers = followers,
        _following = following,
        super._();

  /// 내가 친구로 추가한 사용자 (채팅방 초대 대상)
  final List<String> _friends;

  /// 내가 친구로 추가한 사용자 (채팅방 초대 대상)
  @override
  @JsonKey()
  List<String> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  /// 나를 팔로우하는 사용자
  final List<String> _followers;

  /// 나를 팔로우하는 사용자
  @override
  @JsonKey()
  List<String> get followers {
    if (_followers is EqualUnmodifiableListView) return _followers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followers);
  }

  /// 내가 팔로우하는 사용자
  final List<String> _following;

  /// 내가 팔로우하는 사용자
  @override
  @JsonKey()
  List<String> get following {
    if (_following is EqualUnmodifiableListView) return _following;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_following);
  }

  /// Create a copy of FriendRelations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$FriendRelationsCopyWith<_FriendRelations> get copyWith =>
      __$FriendRelationsCopyWithImpl<_FriendRelations>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _FriendRelations &&
            const DeepCollectionEquality().equals(other._friends, _friends) &&
            const DeepCollectionEquality()
                .equals(other._followers, _followers) &&
            const DeepCollectionEquality()
                .equals(other._following, _following));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_friends),
      const DeepCollectionEquality().hash(_followers),
      const DeepCollectionEquality().hash(_following));

  @override
  String toString() {
    return 'FriendRelations(friends: $friends, followers: $followers, following: $following)';
  }
}

/// @nodoc
abstract mixin class _$FriendRelationsCopyWith<$Res>
    implements $FriendRelationsCopyWith<$Res> {
  factory _$FriendRelationsCopyWith(
          _FriendRelations value, $Res Function(_FriendRelations) _then) =
      __$FriendRelationsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<String> friends, List<String> followers, List<String> following});
}

/// @nodoc
class __$FriendRelationsCopyWithImpl<$Res>
    implements _$FriendRelationsCopyWith<$Res> {
  __$FriendRelationsCopyWithImpl(this._self, this._then);

  final _FriendRelations _self;
  final $Res Function(_FriendRelations) _then;

  /// Create a copy of FriendRelations
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? friends = null,
    Object? followers = null,
    Object? following = null,
  }) {
    return _then(_FriendRelations(
      friends: null == friends
          ? _self._friends
          : friends // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followers: null == followers
          ? _self._followers
          : followers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      following: null == following
          ? _self._following
          : following // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
