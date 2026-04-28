import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated({
    required String uid,
    required String? email,
    required String? displayName,
    required bool emailVerified,
    required bool isNewUser,
  }) = _Authenticated;
  const factory AuthState.error({required String message}) = _Error;
}
