// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Content {
  String get id;
  String get authorUid;

  /// 작성 당시 작성자 이름 (화면 표시용으로 함께 저장된 값)
  String get authorName;
  String get title;
  String get body;

  /// 예전 게시물의 사진 주소. 사진 업로드를 없앤 뒤 새 게시물은 빈 문자열이다.
  String get imageUrl;
  DateTime get createdAt;
  List<String> get hashTags;

  /// 좋아요를 누른 사용자 uid
  List<String> get likedBy;
  ContentTrack? get track;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentCopyWith<Content> get copyWith =>
      _$ContentCopyWithImpl<Content>(this as Content, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Content &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other.hashTags, hashTags) &&
            const DeepCollectionEquality().equals(other.likedBy, likedBy) &&
            (identical(other.track, track) || other.track == track));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      authorUid,
      authorName,
      title,
      body,
      imageUrl,
      createdAt,
      const DeepCollectionEquality().hash(hashTags),
      const DeepCollectionEquality().hash(likedBy),
      track);

  @override
  String toString() {
    return 'Content(id: $id, authorUid: $authorUid, authorName: $authorName, title: $title, body: $body, imageUrl: $imageUrl, createdAt: $createdAt, hashTags: $hashTags, likedBy: $likedBy, track: $track)';
  }
}

/// @nodoc
abstract mixin class $ContentCopyWith<$Res> {
  factory $ContentCopyWith(Content value, $Res Function(Content) _then) =
      _$ContentCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String authorUid,
      String authorName,
      String title,
      String body,
      String imageUrl,
      DateTime createdAt,
      List<String> hashTags,
      List<String> likedBy,
      ContentTrack? track});

  $ContentTrackCopyWith<$Res>? get track;
}

/// @nodoc
class _$ContentCopyWithImpl<$Res> implements $ContentCopyWith<$Res> {
  _$ContentCopyWithImpl(this._self, this._then);

  final Content _self;
  final $Res Function(Content) _then;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorUid = null,
    Object? authorName = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = null,
    Object? createdAt = null,
    Object? hashTags = null,
    Object? likedBy = null,
    Object? track = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _self.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _self.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hashTags: null == hashTags
          ? _self.hashTags
          : hashTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likedBy: null == likedBy
          ? _self.likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      track: freezed == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as ContentTrack?,
    ));
  }

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentTrackCopyWith<$Res>? get track {
    if (_self.track == null) {
      return null;
    }

    return $ContentTrackCopyWith<$Res>(_self.track!, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Content].
extension ContentPatterns on Content {
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
    TResult Function(_Content value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Content() when $default != null:
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
    TResult Function(_Content value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Content():
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
    TResult? Function(_Content value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Content() when $default != null:
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
            String id,
            String authorUid,
            String authorName,
            String title,
            String body,
            String imageUrl,
            DateTime createdAt,
            List<String> hashTags,
            List<String> likedBy,
            ContentTrack? track)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Content() when $default != null:
        return $default(
            _that.id,
            _that.authorUid,
            _that.authorName,
            _that.title,
            _that.body,
            _that.imageUrl,
            _that.createdAt,
            _that.hashTags,
            _that.likedBy,
            _that.track);
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
            String id,
            String authorUid,
            String authorName,
            String title,
            String body,
            String imageUrl,
            DateTime createdAt,
            List<String> hashTags,
            List<String> likedBy,
            ContentTrack? track)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Content():
        return $default(
            _that.id,
            _that.authorUid,
            _that.authorName,
            _that.title,
            _that.body,
            _that.imageUrl,
            _that.createdAt,
            _that.hashTags,
            _that.likedBy,
            _that.track);
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
            String id,
            String authorUid,
            String authorName,
            String title,
            String body,
            String imageUrl,
            DateTime createdAt,
            List<String> hashTags,
            List<String> likedBy,
            ContentTrack? track)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Content() when $default != null:
        return $default(
            _that.id,
            _that.authorUid,
            _that.authorName,
            _that.title,
            _that.body,
            _that.imageUrl,
            _that.createdAt,
            _that.hashTags,
            _that.likedBy,
            _that.track);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Content extends Content {
  const _Content(
      {required this.id,
      required this.authorUid,
      required this.authorName,
      required this.title,
      required this.body,
      required this.imageUrl,
      required this.createdAt,
      final List<String> hashTags = const <String>[],
      final List<String> likedBy = const <String>[],
      this.track})
      : _hashTags = hashTags,
        _likedBy = likedBy,
        super._();

  @override
  final String id;
  @override
  final String authorUid;

  /// 작성 당시 작성자 이름 (화면 표시용으로 함께 저장된 값)
  @override
  final String authorName;
  @override
  final String title;
  @override
  final String body;

  /// 예전 게시물의 사진 주소. 사진 업로드를 없앤 뒤 새 게시물은 빈 문자열이다.
  @override
  final String imageUrl;
  @override
  final DateTime createdAt;
  final List<String> _hashTags;
  @override
  @JsonKey()
  List<String> get hashTags {
    if (_hashTags is EqualUnmodifiableListView) return _hashTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashTags);
  }

  /// 좋아요를 누른 사용자 uid
  final List<String> _likedBy;

  /// 좋아요를 누른 사용자 uid
  @override
  @JsonKey()
  List<String> get likedBy {
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedBy);
  }

  @override
  final ContentTrack? track;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ContentCopyWith<_Content> get copyWith =>
      __$ContentCopyWithImpl<_Content>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Content &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorUid, authorUid) ||
                other.authorUid == authorUid) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._hashTags, _hashTags) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy) &&
            (identical(other.track, track) || other.track == track));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      authorUid,
      authorName,
      title,
      body,
      imageUrl,
      createdAt,
      const DeepCollectionEquality().hash(_hashTags),
      const DeepCollectionEquality().hash(_likedBy),
      track);

  @override
  String toString() {
    return 'Content(id: $id, authorUid: $authorUid, authorName: $authorName, title: $title, body: $body, imageUrl: $imageUrl, createdAt: $createdAt, hashTags: $hashTags, likedBy: $likedBy, track: $track)';
  }
}

/// @nodoc
abstract mixin class _$ContentCopyWith<$Res> implements $ContentCopyWith<$Res> {
  factory _$ContentCopyWith(_Content value, $Res Function(_Content) _then) =
      __$ContentCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String authorUid,
      String authorName,
      String title,
      String body,
      String imageUrl,
      DateTime createdAt,
      List<String> hashTags,
      List<String> likedBy,
      ContentTrack? track});

  @override
  $ContentTrackCopyWith<$Res>? get track;
}

/// @nodoc
class __$ContentCopyWithImpl<$Res> implements _$ContentCopyWith<$Res> {
  __$ContentCopyWithImpl(this._self, this._then);

  final _Content _self;
  final $Res Function(_Content) _then;

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? authorUid = null,
    Object? authorName = null,
    Object? title = null,
    Object? body = null,
    Object? imageUrl = null,
    Object? createdAt = null,
    Object? hashTags = null,
    Object? likedBy = null,
    Object? track = freezed,
  }) {
    return _then(_Content(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorUid: null == authorUid
          ? _self.authorUid
          : authorUid // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: null == authorName
          ? _self.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hashTags: null == hashTags
          ? _self._hashTags
          : hashTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likedBy: null == likedBy
          ? _self._likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      track: freezed == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as ContentTrack?,
    ));
  }

  /// Create a copy of Content
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentTrackCopyWith<$Res>? get track {
    if (_self.track == null) {
      return null;
    }

    return $ContentTrackCopyWith<$Res>(_self.track!, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

/// @nodoc
mixin _$ContentTrack {
  String get name;
  String get artistsName;
  String get imageUrl;

  /// Create a copy of ContentTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ContentTrackCopyWith<ContentTrack> get copyWith =>
      _$ContentTrackCopyWithImpl<ContentTrack>(
          this as ContentTrack, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ContentTrack &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artistsName, artistsName) ||
                other.artistsName == artistsName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, artistsName, imageUrl);

  @override
  String toString() {
    return 'ContentTrack(name: $name, artistsName: $artistsName, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $ContentTrackCopyWith<$Res> {
  factory $ContentTrackCopyWith(
          ContentTrack value, $Res Function(ContentTrack) _then) =
      _$ContentTrackCopyWithImpl;
  @useResult
  $Res call({String name, String artistsName, String imageUrl});
}

/// @nodoc
class _$ContentTrackCopyWithImpl<$Res> implements $ContentTrackCopyWith<$Res> {
  _$ContentTrackCopyWithImpl(this._self, this._then);

  final ContentTrack _self;
  final $Res Function(ContentTrack) _then;

  /// Create a copy of ContentTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? artistsName = null,
    Object? imageUrl = null,
  }) {
    return _then(_self.copyWith(
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

/// Adds pattern-matching-related methods to [ContentTrack].
extension ContentTrackPatterns on ContentTrack {
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
    TResult Function(_ContentTrack value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContentTrack() when $default != null:
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
    TResult Function(_ContentTrack value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContentTrack():
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
    TResult? Function(_ContentTrack value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContentTrack() when $default != null:
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
    TResult Function(String name, String artistsName, String imageUrl)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ContentTrack() when $default != null:
        return $default(_that.name, _that.artistsName, _that.imageUrl);
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
    TResult Function(String name, String artistsName, String imageUrl) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContentTrack():
        return $default(_that.name, _that.artistsName, _that.imageUrl);
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
    TResult? Function(String name, String artistsName, String imageUrl)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ContentTrack() when $default != null:
        return $default(_that.name, _that.artistsName, _that.imageUrl);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ContentTrack implements ContentTrack {
  const _ContentTrack(
      {required this.name, required this.artistsName, required this.imageUrl});

  @override
  final String name;
  @override
  final String artistsName;
  @override
  final String imageUrl;

  /// Create a copy of ContentTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ContentTrackCopyWith<_ContentTrack> get copyWith =>
      __$ContentTrackCopyWithImpl<_ContentTrack>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ContentTrack &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artistsName, artistsName) ||
                other.artistsName == artistsName) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, artistsName, imageUrl);

  @override
  String toString() {
    return 'ContentTrack(name: $name, artistsName: $artistsName, imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class _$ContentTrackCopyWith<$Res>
    implements $ContentTrackCopyWith<$Res> {
  factory _$ContentTrackCopyWith(
          _ContentTrack value, $Res Function(_ContentTrack) _then) =
      __$ContentTrackCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String artistsName, String imageUrl});
}

/// @nodoc
class __$ContentTrackCopyWithImpl<$Res>
    implements _$ContentTrackCopyWith<$Res> {
  __$ContentTrackCopyWithImpl(this._self, this._then);

  final _ContentTrack _self;
  final $Res Function(_ContentTrack) _then;

  /// Create a copy of ContentTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? artistsName = null,
    Object? imageUrl = null,
  }) {
    return _then(_ContentTrack(
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
mixin _$NewContent {
  String get title;
  String get body;
  ContentTrack get track;
  List<String> get hashTags;

  /// Create a copy of NewContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NewContentCopyWith<NewContent> get copyWith =>
      _$NewContentCopyWithImpl<NewContent>(this as NewContent, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NewContent &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.track, track) || other.track == track) &&
            const DeepCollectionEquality().equals(other.hashTags, hashTags));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, body, track,
      const DeepCollectionEquality().hash(hashTags));

  @override
  String toString() {
    return 'NewContent(title: $title, body: $body, track: $track, hashTags: $hashTags)';
  }
}

/// @nodoc
abstract mixin class $NewContentCopyWith<$Res> {
  factory $NewContentCopyWith(
          NewContent value, $Res Function(NewContent) _then) =
      _$NewContentCopyWithImpl;
  @useResult
  $Res call(
      {String title, String body, ContentTrack track, List<String> hashTags});

  $ContentTrackCopyWith<$Res> get track;
}

/// @nodoc
class _$NewContentCopyWithImpl<$Res> implements $NewContentCopyWith<$Res> {
  _$NewContentCopyWithImpl(this._self, this._then);

  final NewContent _self;
  final $Res Function(NewContent) _then;

  /// Create a copy of NewContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? body = null,
    Object? track = null,
    Object? hashTags = null,
  }) {
    return _then(_self.copyWith(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      track: null == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as ContentTrack,
      hashTags: null == hashTags
          ? _self.hashTags
          : hashTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of NewContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentTrackCopyWith<$Res> get track {
    return $ContentTrackCopyWith<$Res>(_self.track, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

/// Adds pattern-matching-related methods to [NewContent].
extension NewContentPatterns on NewContent {
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
    TResult Function(_NewContent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NewContent() when $default != null:
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
    TResult Function(_NewContent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NewContent():
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
    TResult? Function(_NewContent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NewContent() when $default != null:
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
    TResult Function(String title, String body, ContentTrack track,
            List<String> hashTags)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NewContent() when $default != null:
        return $default(_that.title, _that.body, _that.track, _that.hashTags);
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
    TResult Function(String title, String body, ContentTrack track,
            List<String> hashTags)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NewContent():
        return $default(_that.title, _that.body, _that.track, _that.hashTags);
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
    TResult? Function(String title, String body, ContentTrack track,
            List<String> hashTags)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NewContent() when $default != null:
        return $default(_that.title, _that.body, _that.track, _that.hashTags);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NewContent implements NewContent {
  const _NewContent(
      {required this.title,
      required this.body,
      required this.track,
      final List<String> hashTags = const <String>[]})
      : _hashTags = hashTags;

  @override
  final String title;
  @override
  final String body;
  @override
  final ContentTrack track;
  final List<String> _hashTags;
  @override
  @JsonKey()
  List<String> get hashTags {
    if (_hashTags is EqualUnmodifiableListView) return _hashTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashTags);
  }

  /// Create a copy of NewContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NewContentCopyWith<_NewContent> get copyWith =>
      __$NewContentCopyWithImpl<_NewContent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NewContent &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.track, track) || other.track == track) &&
            const DeepCollectionEquality().equals(other._hashTags, _hashTags));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, body, track,
      const DeepCollectionEquality().hash(_hashTags));

  @override
  String toString() {
    return 'NewContent(title: $title, body: $body, track: $track, hashTags: $hashTags)';
  }
}

/// @nodoc
abstract mixin class _$NewContentCopyWith<$Res>
    implements $NewContentCopyWith<$Res> {
  factory _$NewContentCopyWith(
          _NewContent value, $Res Function(_NewContent) _then) =
      __$NewContentCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String title, String body, ContentTrack track, List<String> hashTags});

  @override
  $ContentTrackCopyWith<$Res> get track;
}

/// @nodoc
class __$NewContentCopyWithImpl<$Res> implements _$NewContentCopyWith<$Res> {
  __$NewContentCopyWithImpl(this._self, this._then);

  final _NewContent _self;
  final $Res Function(_NewContent) _then;

  /// Create a copy of NewContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? title = null,
    Object? body = null,
    Object? track = null,
    Object? hashTags = null,
  }) {
    return _then(_NewContent(
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      track: null == track
          ? _self.track
          : track // ignore: cast_nullable_to_non_nullable
              as ContentTrack,
      hashTags: null == hashTags
          ? _self._hashTags
          : hashTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }

  /// Create a copy of NewContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContentTrackCopyWith<$Res> get track {
    return $ContentTrackCopyWith<$Res>(_self.track, (value) {
      return _then(_self.copyWith(track: value));
    });
  }
}

// dart format on
