// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Track {
  /// Spotify 곡 ID (spotify:track:{id})
  String get id;
  String get name;
  String get artistsName;
  String get imageUrl;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TrackCopyWith<Track> get copyWith =>
      _$TrackCopyWithImpl<Track>(this as Track, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Track &&
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
    return 'Track(id: $id, name: $name, artistsName: $artistsName, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res> {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) =
      _$TrackCopyWithImpl;
  @useResult
  $Res call({String id, String name, String artistsName, String imageUrl});
}

/// @nodoc
class _$TrackCopyWithImpl<$Res> implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

  /// Create a copy of Track
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

/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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
    TResult Function(_Track value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Track() when $default != null:
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
    TResult Function(_Track value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Track():
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
    TResult? Function(_Track value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Track() when $default != null:
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
      case _Track() when $default != null:
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
      case _Track():
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
      case _Track() when $default != null:
        return $default(
            _that.id, _that.name, _that.artistsName, _that.imageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Track implements Track {
  const _Track(
      {required this.id,
      required this.name,
      required this.artistsName,
      required this.imageUrl});

  /// Spotify 곡 ID (spotify:track:{id})
  @override
  final String id;
  @override
  final String name;
  @override
  final String artistsName;
  @override
  final String imageUrl;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TrackCopyWith<_Track> get copyWith =>
      __$TrackCopyWithImpl<_Track>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Track &&
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
    return 'Track(id: $id, name: $name, artistsName: $artistsName, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) =
      __$TrackCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name, String artistsName, String imageUrl});
}

/// @nodoc
class __$TrackCopyWithImpl<$Res> implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artistsName = null,
    Object? imageUrl = null,
  }) {
    return _then(_Track(
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

/// @nodoc
mixin _$PlaylistEntry {
  /// 문서 ID. 예전에 담은 곡은 곡 제목, 새로 담은 곡은 Spotify 곡 ID다.
  String get docId;
  Track get track;
  DateTime get addedAt;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlaylistEntryCopyWith<PlaylistEntry> get copyWith =>
      _$PlaylistEntryCopyWithImpl<PlaylistEntry>(
          this as PlaylistEntry, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlaylistEntry &&
            (identical(other.docId, docId) || other.docId == docId) &&
            (identical(other.track, track) || other.track == track) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, docId, track, addedAt);

  @override
  String toString() {
    return 'PlaylistEntry(docId: $docId, track: $track, addedAt: $addedAt)';
  }
}

/// @nodoc
abstract mixin class $PlaylistEntryCopyWith<$Res> {
  factory $PlaylistEntryCopyWith(
          PlaylistEntry value, $Res Function(PlaylistEntry) _then) =
      _$PlaylistEntryCopyWithImpl;
  @useResult
  $Res call({String docId, Track track, DateTime addedAt});

  $TrackCopyWith<$Res> get track;
}

/// @nodoc
class _$PlaylistEntryCopyWithImpl<$Res>
    implements $PlaylistEntryCopyWith<$Res> {
  _$PlaylistEntryCopyWithImpl(this._self, this._then);

  final PlaylistEntry _self;
  final $Res Function(PlaylistEntry) _then;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? docId = null,
    Object? track = null,
    Object? addedAt = null,
  }) {
    return _then(_self.copyWith(
      docId: null == docId
          ? _self.docId
          : docId // ignore: cast_nullable_to_non_nullable
              as String,
      track: null == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as Track,
      addedAt: null == addedAt
          ? _self.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackCopyWith<$Res> get track {
    return $TrackCopyWith<$Res>(_self.track, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

/// Adds pattern-matching-related methods to [PlaylistEntry].
extension PlaylistEntryPatterns on PlaylistEntry {
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
    TResult Function(_PlaylistEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaylistEntry() when $default != null:
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
    TResult Function(_PlaylistEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaylistEntry():
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
    TResult? Function(_PlaylistEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaylistEntry() when $default != null:
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
    TResult Function(String docId, Track track, DateTime addedAt)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PlaylistEntry() when $default != null:
        return $default(_that.docId, _that.track, _that.addedAt);
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
    TResult Function(String docId, Track track, DateTime addedAt) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaylistEntry():
        return $default(_that.docId, _that.track, _that.addedAt);
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
    TResult? Function(String docId, Track track, DateTime addedAt)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PlaylistEntry() when $default != null:
        return $default(_that.docId, _that.track, _that.addedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PlaylistEntry implements PlaylistEntry {
  const _PlaylistEntry(
      {required this.docId, required this.track, required this.addedAt});

  /// 문서 ID. 예전에 담은 곡은 곡 제목, 새로 담은 곡은 Spotify 곡 ID다.
  @override
  final String docId;
  @override
  final Track track;
  @override
  final DateTime addedAt;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlaylistEntryCopyWith<_PlaylistEntry> get copyWith =>
      __$PlaylistEntryCopyWithImpl<_PlaylistEntry>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlaylistEntry &&
            (identical(other.docId, docId) || other.docId == docId) &&
            (identical(other.track, track) || other.track == track) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, docId, track, addedAt);

  @override
  String toString() {
    return 'PlaylistEntry(docId: $docId, track: $track, addedAt: $addedAt)';
  }
}

/// @nodoc
abstract mixin class _$PlaylistEntryCopyWith<$Res>
    implements $PlaylistEntryCopyWith<$Res> {
  factory _$PlaylistEntryCopyWith(
          _PlaylistEntry value, $Res Function(_PlaylistEntry) _then) =
      __$PlaylistEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String docId, Track track, DateTime addedAt});

  @override
  $TrackCopyWith<$Res> get track;
}

/// @nodoc
class __$PlaylistEntryCopyWithImpl<$Res>
    implements _$PlaylistEntryCopyWith<$Res> {
  __$PlaylistEntryCopyWithImpl(this._self, this._then);

  final _PlaylistEntry _self;
  final $Res Function(_PlaylistEntry) _then;

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? docId = null,
    Object? track = null,
    Object? addedAt = null,
  }) {
    return _then(_PlaylistEntry(
      docId: null == docId
          ? _self.docId
          : docId // ignore: cast_nullable_to_non_nullable
              as String,
      track: null == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as Track,
      addedAt: null == addedAt
          ? _self.addedAt
          : addedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }

  /// Create a copy of PlaylistEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackCopyWith<$Res> get track {
    return $TrackCopyWith<$Res>(_self.track, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

// dart format on
