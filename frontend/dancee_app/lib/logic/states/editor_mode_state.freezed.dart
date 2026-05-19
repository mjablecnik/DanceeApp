// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'editor_mode_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$EditorModeState {
  bool get isEditorMode => throw _privateConstructorUsedError;
  bool get isEditor => throw _privateConstructorUsedError;

  /// Create a copy of EditorModeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EditorModeStateCopyWith<EditorModeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EditorModeStateCopyWith<$Res> {
  factory $EditorModeStateCopyWith(
          EditorModeState value, $Res Function(EditorModeState) then) =
      _$EditorModeStateCopyWithImpl<$Res, EditorModeState>;
  @useResult
  $Res call({bool isEditorMode, bool isEditor});
}

/// @nodoc
class _$EditorModeStateCopyWithImpl<$Res, $Val extends EditorModeState>
    implements $EditorModeStateCopyWith<$Res> {
  _$EditorModeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EditorModeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEditorMode = null,
    Object? isEditor = null,
  }) {
    return _then(_value.copyWith(
      isEditorMode: null == isEditorMode
          ? _value.isEditorMode
          : isEditorMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isEditor: null == isEditor
          ? _value.isEditor
          : isEditor // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EditorModeStateImplCopyWith<$Res>
    implements $EditorModeStateCopyWith<$Res> {
  factory _$$EditorModeStateImplCopyWith(_$EditorModeStateImpl value,
          $Res Function(_$EditorModeStateImpl) then) =
      __$$EditorModeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isEditorMode, bool isEditor});
}

/// @nodoc
class __$$EditorModeStateImplCopyWithImpl<$Res>
    extends _$EditorModeStateCopyWithImpl<$Res, _$EditorModeStateImpl>
    implements _$$EditorModeStateImplCopyWith<$Res> {
  __$$EditorModeStateImplCopyWithImpl(
      _$EditorModeStateImpl _value, $Res Function(_$EditorModeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EditorModeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEditorMode = null,
    Object? isEditor = null,
  }) {
    return _then(_$EditorModeStateImpl(
      isEditorMode: null == isEditorMode
          ? _value.isEditorMode
          : isEditorMode // ignore: cast_nullable_to_non_nullable
              as bool,
      isEditor: null == isEditor
          ? _value.isEditor
          : isEditor // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EditorModeStateImpl implements _EditorModeState {
  const _$EditorModeStateImpl(
      {this.isEditorMode = false, this.isEditor = false});

  @override
  @JsonKey()
  final bool isEditorMode;
  @override
  @JsonKey()
  final bool isEditor;

  @override
  String toString() {
    return 'EditorModeState(isEditorMode: $isEditorMode, isEditor: $isEditor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditorModeStateImpl &&
            (identical(other.isEditorMode, isEditorMode) ||
                other.isEditorMode == isEditorMode) &&
            (identical(other.isEditor, isEditor) ||
                other.isEditor == isEditor));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isEditorMode, isEditor);

  /// Create a copy of EditorModeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditorModeStateImplCopyWith<_$EditorModeStateImpl> get copyWith =>
      __$$EditorModeStateImplCopyWithImpl<_$EditorModeStateImpl>(
          this, _$identity);
}

abstract class _EditorModeState implements EditorModeState {
  const factory _EditorModeState(
      {final bool isEditorMode, final bool isEditor}) = _$EditorModeStateImpl;

  @override
  bool get isEditorMode;
  @override
  bool get isEditor;

  /// Create a copy of EditorModeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditorModeStateImplCopyWith<_$EditorModeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
