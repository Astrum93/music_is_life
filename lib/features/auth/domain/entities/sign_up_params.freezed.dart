// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignUpParams {
  String get name;
  String get email;
  String get password;
  String get phoneNumber;

  /// Create a copy of SignUpParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignUpParamsCopyWith<SignUpParams> get copyWith =>
      _$SignUpParamsCopyWithImpl<SignUpParams>(
          this as SignUpParams, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignUpParams &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, password, phoneNumber);

  @override
  String toString() {
    return 'SignUpParams(name: $name, email: $email, password: $password, phoneNumber: $phoneNumber)';
  }
}

/// @nodoc
abstract mixin class $SignUpParamsCopyWith<$Res> {
  factory $SignUpParamsCopyWith(
          SignUpParams value, $Res Function(SignUpParams) _then) =
      _$SignUpParamsCopyWithImpl;
  @useResult
  $Res call({String name, String email, String password, String phoneNumber});
}

/// @nodoc
class _$SignUpParamsCopyWithImpl<$Res> implements $SignUpParamsCopyWith<$Res> {
  _$SignUpParamsCopyWithImpl(this._self, this._then);

  final SignUpParams _self;
  final $Res Function(SignUpParams) _then;

  /// Create a copy of SignUpParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? password = null,
    Object? phoneNumber = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [SignUpParams].
extension SignUpParamsPatterns on SignUpParams {
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
    TResult Function(_SignUpParams value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SignUpParams() when $default != null:
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
    TResult Function(_SignUpParams value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpParams():
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
    TResult? Function(_SignUpParams value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpParams() when $default != null:
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
            String name, String email, String password, String phoneNumber)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SignUpParams() when $default != null:
        return $default(
            _that.name, _that.email, _that.password, _that.phoneNumber);
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
            String name, String email, String password, String phoneNumber)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpParams():
        return $default(
            _that.name, _that.email, _that.password, _that.phoneNumber);
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
            String name, String email, String password, String phoneNumber)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpParams() when $default != null:
        return $default(
            _that.name, _that.email, _that.password, _that.phoneNumber);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SignUpParams implements SignUpParams {
  const _SignUpParams(
      {required this.name,
      required this.email,
      required this.password,
      required this.phoneNumber});

  @override
  final String name;
  @override
  final String email;
  @override
  final String password;
  @override
  final String phoneNumber;

  /// Create a copy of SignUpParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SignUpParamsCopyWith<_SignUpParams> get copyWith =>
      __$SignUpParamsCopyWithImpl<_SignUpParams>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SignUpParams &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, password, phoneNumber);

  @override
  String toString() {
    return 'SignUpParams(name: $name, email: $email, password: $password, phoneNumber: $phoneNumber)';
  }
}

/// @nodoc
abstract mixin class _$SignUpParamsCopyWith<$Res>
    implements $SignUpParamsCopyWith<$Res> {
  factory _$SignUpParamsCopyWith(
          _SignUpParams value, $Res Function(_SignUpParams) _then) =
      __$SignUpParamsCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String email, String password, String phoneNumber});
}

/// @nodoc
class __$SignUpParamsCopyWithImpl<$Res>
    implements _$SignUpParamsCopyWith<$Res> {
  __$SignUpParamsCopyWithImpl(this._self, this._then);

  final _SignUpParams _self;
  final $Res Function(_SignUpParams) _then;

  /// Create a copy of SignUpParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? password = null,
    Object? phoneNumber = null,
  }) {
    return _then(_SignUpParams(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _self.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
