// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatRoom {
  String get id;
  String get name;
  String get imageUrl;

  /// 멤버 uid (Firestore 쿼리·보안 규칙용)
  List<String> get memberUids;

  /// 멤버 uid -> 화면에 보여줄 이름
  Map<String, String> get memberNames;

  /// 즐겨찾기(좋아요)한 멤버 uid
  List<String> get likedBy;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatRoomCopyWith<ChatRoom> get copyWith =>
      _$ChatRoomCopyWithImpl<ChatRoom>(this as ChatRoom, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatRoom &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other.memberUids, memberUids) &&
            const DeepCollectionEquality()
                .equals(other.memberNames, memberNames) &&
            const DeepCollectionEquality().equals(other.likedBy, likedBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      imageUrl,
      const DeepCollectionEquality().hash(memberUids),
      const DeepCollectionEquality().hash(memberNames),
      const DeepCollectionEquality().hash(likedBy));

  @override
  String toString() {
    return 'ChatRoom(id: $id, name: $name, imageUrl: $imageUrl, memberUids: $memberUids, memberNames: $memberNames, likedBy: $likedBy)';
  }
}

/// @nodoc
abstract mixin class $ChatRoomCopyWith<$Res> {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) _then) =
      _$ChatRoomCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String imageUrl,
      List<String> memberUids,
      Map<String, String> memberNames,
      List<String> likedBy});
}

/// @nodoc
class _$ChatRoomCopyWithImpl<$Res> implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._self, this._then);

  final ChatRoom _self;
  final $Res Function(ChatRoom) _then;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? memberUids = null,
    Object? memberNames = null,
    Object? likedBy = null,
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
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      memberUids: null == memberUids
          ? _self.memberUids
          : memberUids // ignore: cast_nullable_to_non_nullable
              as List<String>,
      memberNames: null == memberNames
          ? _self.memberNames
          : memberNames // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      likedBy: null == likedBy
          ? _self.likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatRoom].
extension ChatRoomPatterns on ChatRoom {
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
    TResult Function(_ChatRoom value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatRoom() when $default != null:
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
    TResult Function(_ChatRoom value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatRoom():
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
    TResult? Function(_ChatRoom value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatRoom() when $default != null:
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
            String name,
            String imageUrl,
            List<String> memberUids,
            Map<String, String> memberNames,
            List<String> likedBy)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatRoom() when $default != null:
        return $default(_that.id, _that.name, _that.imageUrl, _that.memberUids,
            _that.memberNames, _that.likedBy);
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
            String name,
            String imageUrl,
            List<String> memberUids,
            Map<String, String> memberNames,
            List<String> likedBy)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatRoom():
        return $default(_that.id, _that.name, _that.imageUrl, _that.memberUids,
            _that.memberNames, _that.likedBy);
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
            String name,
            String imageUrl,
            List<String> memberUids,
            Map<String, String> memberNames,
            List<String> likedBy)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatRoom() when $default != null:
        return $default(_that.id, _that.name, _that.imageUrl, _that.memberUids,
            _that.memberNames, _that.likedBy);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChatRoom extends ChatRoom {
  const _ChatRoom(
      {required this.id,
      required this.name,
      this.imageUrl = '',
      final List<String> memberUids = const <String>[],
      final Map<String, String> memberNames = const <String, String>{},
      final List<String> likedBy = const <String>[]})
      : _memberUids = memberUids,
        _memberNames = memberNames,
        _likedBy = likedBy,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String imageUrl;

  /// 멤버 uid (Firestore 쿼리·보안 규칙용)
  final List<String> _memberUids;

  /// 멤버 uid (Firestore 쿼리·보안 규칙용)
  @override
  @JsonKey()
  List<String> get memberUids {
    if (_memberUids is EqualUnmodifiableListView) return _memberUids;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberUids);
  }

  /// 멤버 uid -> 화면에 보여줄 이름
  final Map<String, String> _memberNames;

  /// 멤버 uid -> 화면에 보여줄 이름
  @override
  @JsonKey()
  Map<String, String> get memberNames {
    if (_memberNames is EqualUnmodifiableMapView) return _memberNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_memberNames);
  }

  /// 즐겨찾기(좋아요)한 멤버 uid
  final List<String> _likedBy;

  /// 즐겨찾기(좋아요)한 멤버 uid
  @override
  @JsonKey()
  List<String> get likedBy {
    if (_likedBy is EqualUnmodifiableListView) return _likedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_likedBy);
  }

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatRoomCopyWith<_ChatRoom> get copyWith =>
      __$ChatRoomCopyWithImpl<_ChatRoom>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatRoom &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality()
                .equals(other._memberUids, _memberUids) &&
            const DeepCollectionEquality()
                .equals(other._memberNames, _memberNames) &&
            const DeepCollectionEquality().equals(other._likedBy, _likedBy));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      imageUrl,
      const DeepCollectionEquality().hash(_memberUids),
      const DeepCollectionEquality().hash(_memberNames),
      const DeepCollectionEquality().hash(_likedBy));

  @override
  String toString() {
    return 'ChatRoom(id: $id, name: $name, imageUrl: $imageUrl, memberUids: $memberUids, memberNames: $memberNames, likedBy: $likedBy)';
  }
}

/// @nodoc
abstract mixin class _$ChatRoomCopyWith<$Res>
    implements $ChatRoomCopyWith<$Res> {
  factory _$ChatRoomCopyWith(_ChatRoom value, $Res Function(_ChatRoom) _then) =
      __$ChatRoomCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String imageUrl,
      List<String> memberUids,
      Map<String, String> memberNames,
      List<String> likedBy});
}

/// @nodoc
class __$ChatRoomCopyWithImpl<$Res> implements _$ChatRoomCopyWith<$Res> {
  __$ChatRoomCopyWithImpl(this._self, this._then);

  final _ChatRoom _self;
  final $Res Function(_ChatRoom) _then;

  /// Create a copy of ChatRoom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? memberUids = null,
    Object? memberNames = null,
    Object? likedBy = null,
  }) {
    return _then(_ChatRoom(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      memberUids: null == memberUids
          ? _self._memberUids
          : memberUids // ignore: cast_nullable_to_non_nullable
              as List<String>,
      memberNames: null == memberNames
          ? _self._memberNames
          : memberNames // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      likedBy: null == likedBy
          ? _self._likedBy
          : likedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
mixin _$ChatMessage {
  String get id;
  String get senderUid;

  /// 보낸 당시 이름 (화면 표시용으로 함께 저장된 값)
  String get senderName;
  String get text;
  DateTime get sentAt;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderUid, senderUid) ||
                other.senderUid == senderUid) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, senderUid, senderName, text, sentAt);

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderUid: $senderUid, senderName: $senderName, text: $text, sentAt: $sentAt)';
  }
}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) _then) =
      _$ChatMessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String senderUid,
      String senderName,
      String text,
      DateTime sentAt});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res> implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderUid = null,
    Object? senderName = null,
    Object? text = null,
    Object? sentAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderUid: null == senderUid
          ? _self.senderUid
          : senderUid // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _self.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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
    TResult Function(_ChatMessage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
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
    TResult Function(_ChatMessage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage():
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
    TResult? Function(_ChatMessage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
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
    TResult Function(String id, String senderUid, String senderName,
            String text, DateTime sentAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(_that.id, _that.senderUid, _that.senderName, _that.text,
            _that.sentAt);
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
    TResult Function(String id, String senderUid, String senderName,
            String text, DateTime sentAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage():
        return $default(_that.id, _that.senderUid, _that.senderName, _that.text,
            _that.sentAt);
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
    TResult? Function(String id, String senderUid, String senderName,
            String text, DateTime sentAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatMessage() when $default != null:
        return $default(_that.id, _that.senderUid, _that.senderName, _that.text,
            _that.sentAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChatMessage implements ChatMessage {
  const _ChatMessage(
      {required this.id,
      required this.senderUid,
      required this.senderName,
      required this.text,
      required this.sentAt});

  @override
  final String id;
  @override
  final String senderUid;

  /// 보낸 당시 이름 (화면 표시용으로 함께 저장된 값)
  @override
  final String senderName;
  @override
  final String text;
  @override
  final DateTime sentAt;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatMessageCopyWith<_ChatMessage> get copyWith =>
      __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderUid, senderUid) ||
                other.senderUid == senderUid) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, senderUid, senderName, text, sentAt);

  @override
  String toString() {
    return 'ChatMessage(id: $id, senderUid: $senderUid, senderName: $senderName, text: $text, sentAt: $sentAt)';
  }
}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(
          _ChatMessage value, $Res Function(_ChatMessage) _then) =
      __$ChatMessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String senderUid,
      String senderName,
      String text,
      DateTime sentAt});
}

/// @nodoc
class __$ChatMessageCopyWithImpl<$Res> implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

  /// Create a copy of ChatMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? senderUid = null,
    Object? senderName = null,
    Object? text = null,
    Object? sentAt = null,
  }) {
    return _then(_ChatMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderUid: null == senderUid
          ? _self.senderUid
          : senderUid // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _self.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
