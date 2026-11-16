// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {
  String get uid;
  String get userName;
  String get profileImageUrl;
  String get backgroundImageUrl;
  String get introduction;

  /// 프로필 대표곡. 설정하지 않았으면 null.
  ProfileTrack? get track;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<UserProfile> get copyWith =>
      _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserProfile &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.backgroundImageUrl, backgroundImageUrl) ||
                other.backgroundImageUrl == backgroundImageUrl) &&
            (identical(other.introduction, introduction) ||
                other.introduction == introduction) &&
            (identical(other.track, track) || other.track == track));
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid, userName, profileImageUrl,
      backgroundImageUrl, introduction, track);

  @override
  String toString() {
    return 'UserProfile(uid: $uid, userName: $userName, profileImageUrl: $profileImageUrl, backgroundImageUrl: $backgroundImageUrl, introduction: $introduction, track: $track)';
  }
}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) _then) =
      _$UserProfileCopyWithImpl;
  @useResult
  $Res call(
      {String uid,
      String userName,
      String profileImageUrl,
      String backgroundImageUrl,
      String introduction,
      ProfileTrack? track});

  $ProfileTrackCopyWith<$Res>? get track;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res> implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? userName = null,
    Object? profileImageUrl = null,
    Object? backgroundImageUrl = null,
    Object? introduction = null,
    Object? track = freezed,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: null == profileImageUrl
          ? _self.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundImageUrl: null == backgroundImageUrl
          ? _self.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      introduction: null == introduction
          ? _self.introduction
          : introduction // ignore: cast_nullable_to_non_nullable
              as String,
      track: freezed == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as ProfileTrack?,
    ));
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileTrackCopyWith<$Res>? get track {
    if (_self.track == null) {
      return null;
    }

    return $ProfileTrackCopyWith<$Res>(_self.track!, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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
    TResult Function(_UserProfile value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
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
    TResult Function(_UserProfile value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile():
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
    TResult? Function(_UserProfile value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
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
    TResult Function(
            String uid,
            String userName,
            String profileImageUrl,
            String backgroundImageUrl,
            String introduction,
            ProfileTrack? track)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
        return $default(_that.uid, _that.userName, _that.profileImageUrl,
            _that.backgroundImageUrl, _that.introduction, _that.track);
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
    TResult Function(String uid, String userName, String profileImageUrl,
            String backgroundImageUrl, String introduction, ProfileTrack? track)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile():
        return $default(_that.uid, _that.userName, _that.profileImageUrl,
            _that.backgroundImageUrl, _that.introduction, _that.track);
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
    TResult? Function(
            String uid,
            String userName,
            String profileImageUrl,
            String backgroundImageUrl,
            String introduction,
            ProfileTrack? track)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserProfile() when $default != null:
        return $default(_that.uid, _that.userName, _that.profileImageUrl,
            _that.backgroundImageUrl, _that.introduction, _that.track);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UserProfile implements UserProfile {
  const _UserProfile(
      {required this.uid,
      required this.userName,
      required this.profileImageUrl,
      required this.backgroundImageUrl,
      this.introduction = '',
      this.track});

  @override
  final String uid;
  @override
  final String userName;
  @override
  final String profileImageUrl;
  @override
  final String backgroundImageUrl;
  @override
  @JsonKey()
  final String introduction;

  /// 프로필 대표곡. 설정하지 않았으면 null.
  @override
  final ProfileTrack? track;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserProfileCopyWith<_UserProfile> get copyWith =>
      __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserProfile &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.backgroundImageUrl, backgroundImageUrl) ||
                other.backgroundImageUrl == backgroundImageUrl) &&
            (identical(other.introduction, introduction) ||
                other.introduction == introduction) &&
            (identical(other.track, track) || other.track == track));
  }

  @override
  int get hashCode => Object.hash(runtimeType, uid, userName, profileImageUrl,
      backgroundImageUrl, introduction, track);

  @override
  String toString() {
    return 'UserProfile(uid: $uid, userName: $userName, profileImageUrl: $profileImageUrl, backgroundImageUrl: $backgroundImageUrl, introduction: $introduction, track: $track)';
  }
}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(
          _UserProfile value, $Res Function(_UserProfile) _then) =
      __$UserProfileCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uid,
      String userName,
      String profileImageUrl,
      String backgroundImageUrl,
      String introduction,
      ProfileTrack? track});

  @override
  $ProfileTrackCopyWith<$Res>? get track;
}

/// @nodoc
class __$UserProfileCopyWithImpl<$Res> implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = null,
    Object? userName = null,
    Object? profileImageUrl = null,
    Object? backgroundImageUrl = null,
    Object? introduction = null,
    Object? track = freezed,
  }) {
    return _then(_UserProfile(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageUrl: null == profileImageUrl
          ? _self.profileImageUrl
          : profileImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundImageUrl: null == backgroundImageUrl
          ? _self.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      introduction: null == introduction
          ? _self.introduction
          : introduction // ignore: cast_nullable_to_non_nullable
              as String,
      track: freezed == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as ProfileTrack?,
    ));
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileTrackCopyWith<$Res>? get track {
    if (_self.track == null) {
      return null;
    }

    return $ProfileTrackCopyWith<$Res>(_self.track!, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

/// @nodoc
mixin _$ProfileTrack {
  String get id;
  String get name;
  String get artistsName;
  String get imageUrl;

  /// Create a copy of ProfileTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileTrackCopyWith<ProfileTrack> get copyWith =>
      _$ProfileTrackCopyWithImpl<ProfileTrack>(
          this as ProfileTrack, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileTrack &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artistsName, artistsName) ||
                other.artistsName == artistsName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, artistsName, imageUrl);

  @override
  String toString() {
    return 'ProfileTrack(id: $id, name: $name, artistsName: $artistsName, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $ProfileTrackCopyWith<$Res> {
  factory $ProfileTrackCopyWith(
          ProfileTrack value, $Res Function(ProfileTrack) _then) =
      _$ProfileTrackCopyWithImpl;
  @useResult
  $Res call({String id, String name, String artistsName, String imageUrl});
}

/// @nodoc
class _$ProfileTrackCopyWithImpl<$Res> implements $ProfileTrackCopyWith<$Res> {
  _$ProfileTrackCopyWithImpl(this._self, this._then);

  final ProfileTrack _self;
  final $Res Function(ProfileTrack) _then;

  /// Create a copy of ProfileTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artistsName = null,
    Object? imageUrl = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artistsName: null == artistsName
          ? _self.artistsName
          : artistsName // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProfileTrack].
extension ProfileTrackPatterns on ProfileTrack {
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
    TResult Function(_ProfileTrack value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileTrack() when $default != null:
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
    TResult Function(_ProfileTrack value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileTrack():
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
    TResult? Function(_ProfileTrack value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileTrack() when $default != null:
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
    TResult Function(
            String id, String name, String artistsName, String imageUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileTrack() when $default != null:
        return $default(
            _that.id, _that.name, _that.artistsName, _that.imageUrl);
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
    TResult Function(
            String id, String name, String artistsName, String imageUrl)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileTrack():
        return $default(
            _that.id, _that.name, _that.artistsName, _that.imageUrl);
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
    TResult? Function(
            String id, String name, String artistsName, String imageUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileTrack() when $default != null:
        return $default(
            _that.id, _that.name, _that.artistsName, _that.imageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProfileTrack implements ProfileTrack {
  const _ProfileTrack(
      {required this.id,
      required this.name,
      required this.artistsName,
      required this.imageUrl});

  @override
  final String id;
  @override
  final String name;
  @override
  final String artistsName;
  @override
  final String imageUrl;

  /// Create a copy of ProfileTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileTrackCopyWith<_ProfileTrack> get copyWith =>
      __$ProfileTrackCopyWithImpl<_ProfileTrack>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileTrack &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artistsName, artistsName) ||
                other.artistsName == artistsName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, artistsName, imageUrl);

  @override
  String toString() {
    return 'ProfileTrack(id: $id, name: $name, artistsName: $artistsName, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class _$ProfileTrackCopyWith<$Res>
    implements $ProfileTrackCopyWith<$Res> {
  factory _$ProfileTrackCopyWith(
          _ProfileTrack value, $Res Function(_ProfileTrack) _then) =
      __$ProfileTrackCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name, String artistsName, String imageUrl});
}

/// @nodoc
class __$ProfileTrackCopyWithImpl<$Res>
    implements _$ProfileTrackCopyWith<$Res> {
  __$ProfileTrackCopyWithImpl(this._self, this._then);

  final _ProfileTrack _self;
  final $Res Function(_ProfileTrack) _then;

  /// Create a copy of ProfileTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artistsName = null,
    Object? imageUrl = null,
  }) {
    return _then(_ProfileTrack(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artistsName: null == artistsName
          ? _self.artistsName
          : artistsName // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
