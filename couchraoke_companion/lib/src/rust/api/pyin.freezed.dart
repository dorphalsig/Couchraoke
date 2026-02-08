// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pyin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PyinError {
  String get field0 => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) invalidConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? invalidConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? invalidConfig,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PyinError_InvalidConfig value) invalidConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PyinError_InvalidConfig value)? invalidConfig,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PyinError_InvalidConfig value)? invalidConfig,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PyinError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PyinErrorCopyWith<PyinError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PyinErrorCopyWith<$Res> {
  factory $PyinErrorCopyWith(PyinError value, $Res Function(PyinError) then) =
      _$PyinErrorCopyWithImpl<$Res, PyinError>;
  @useResult
  $Res call({String field0});
}

/// @nodoc
class _$PyinErrorCopyWithImpl<$Res, $Val extends PyinError>
    implements $PyinErrorCopyWith<$Res> {
  _$PyinErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PyinError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _value.copyWith(
            field0: null == field0
                ? _value.field0
                : field0 // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PyinError_InvalidConfigImplCopyWith<$Res>
    implements $PyinErrorCopyWith<$Res> {
  factory _$$PyinError_InvalidConfigImplCopyWith(
    _$PyinError_InvalidConfigImpl value,
    $Res Function(_$PyinError_InvalidConfigImpl) then,
  ) = __$$PyinError_InvalidConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field0});
}

/// @nodoc
class __$$PyinError_InvalidConfigImplCopyWithImpl<$Res>
    extends _$PyinErrorCopyWithImpl<$Res, _$PyinError_InvalidConfigImpl>
    implements _$$PyinError_InvalidConfigImplCopyWith<$Res> {
  __$$PyinError_InvalidConfigImplCopyWithImpl(
    _$PyinError_InvalidConfigImpl _value,
    $Res Function(_$PyinError_InvalidConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PyinError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? field0 = null}) {
    return _then(
      _$PyinError_InvalidConfigImpl(
        null == field0
            ? _value.field0
            : field0 // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$PyinError_InvalidConfigImpl extends PyinError_InvalidConfig {
  const _$PyinError_InvalidConfigImpl(this.field0) : super._();

  @override
  final String field0;

  @override
  String toString() {
    return 'PyinError.invalidConfig(field0: $field0)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PyinError_InvalidConfigImpl &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  /// Create a copy of PyinError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PyinError_InvalidConfigImplCopyWith<_$PyinError_InvalidConfigImpl>
  get copyWith =>
      __$$PyinError_InvalidConfigImplCopyWithImpl<
        _$PyinError_InvalidConfigImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String field0) invalidConfig,
  }) {
    return invalidConfig(field0);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String field0)? invalidConfig,
  }) {
    return invalidConfig?.call(field0);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String field0)? invalidConfig,
    required TResult orElse(),
  }) {
    if (invalidConfig != null) {
      return invalidConfig(field0);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PyinError_InvalidConfig value) invalidConfig,
  }) {
    return invalidConfig(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PyinError_InvalidConfig value)? invalidConfig,
  }) {
    return invalidConfig?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PyinError_InvalidConfig value)? invalidConfig,
    required TResult orElse(),
  }) {
    if (invalidConfig != null) {
      return invalidConfig(this);
    }
    return orElse();
  }
}

abstract class PyinError_InvalidConfig extends PyinError {
  const factory PyinError_InvalidConfig(final String field0) =
      _$PyinError_InvalidConfigImpl;
  const PyinError_InvalidConfig._() : super._();

  @override
  String get field0;

  /// Create a copy of PyinError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PyinError_InvalidConfigImplCopyWith<_$PyinError_InvalidConfigImpl>
  get copyWith => throw _privateConstructorUsedError;
}
