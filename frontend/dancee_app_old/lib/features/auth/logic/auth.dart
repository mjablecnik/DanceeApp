import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/auth_repository.dart';
import '../data/entities.dart';

part 'auth.freezed.dart';

// ============================================================================
// State
// ============================================================================

/// State for the AuthCubit.
///
/// Uses freezed for immutability and union types:
/// - [initial]: Before any auth check has been performed
/// - [loading]: While an auth operation is in progress
/// - [authenticated]: User is authenticated (carries [User] entity)
/// - [unauthenticated]: User is not authenticated
/// - [error]: An error occurred during an auth operation
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;

  const factory AuthState.loading() = AuthLoading;

  const factory AuthState.authenticated(User user) = AuthAuthenticated;

  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  const factory AuthState.error(String message) = AuthError;
}

// ============================================================================
// Cubit
// ============================================================================

/// Cubit for managing authentication state.
///
/// Placeholder implementation — all methods emit [AuthUnauthenticated]
/// until backend auth endpoints are integrated.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState.initial());

  /// Authenticates a user with email and password.
  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());
    // TODO: Implement with repository
    emit(const AuthState.unauthenticated());
  }

  /// Registers a new user account.
  Future<void> register(String email, String password, String displayName) async {
    emit(const AuthState.loading());
    // TODO: Implement with repository
    emit(const AuthState.unauthenticated());
  }

  /// Logs out the current user.
  Future<void> logout() async {
    emit(const AuthState.loading());
    // TODO: Implement with repository
    emit(const AuthState.unauthenticated());
  }

  /// Checks the current authentication status.
  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    // TODO: Implement with repository
    emit(const AuthState.unauthenticated());
  }
}
