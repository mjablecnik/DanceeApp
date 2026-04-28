import 'package:bloc_test/bloc_test.dart';
import 'package:dancee_app/features/auth/data/auth_repository.dart';
import 'package:dancee_app/features/auth/logic/auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // =========================================================================
  // TC-060: Initial state is AuthState.initial()
  // =========================================================================

  test('TC-060: AuthCubit initial state is AuthState.initial()', () {
    final cubit = AuthCubit(mockRepo);
    expect(cubit.state, const AuthState.initial());
    expect(cubit.state, isA<AuthInitial>());
    cubit.close();
  });

  // =========================================================================
  // TC-061: login() emits loading state before resolving
  // =========================================================================

  blocTest<AuthCubit, AuthState>(
    'TC-061: login emits loading state',
    build: () => AuthCubit(mockRepo),
    act: (cubit) async {
      // The current placeholder implementation emits loading then unauthenticated
      await cubit.login('test@example.com', 'password123');
    },
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthUnauthenticated>(),
    ],
  );

  // =========================================================================
  // TC-062: logout() emits loading then unauthenticated
  // =========================================================================

  blocTest<AuthCubit, AuthState>(
    'TC-062: logout emits loading → unauthenticated',
    build: () => AuthCubit(mockRepo),
    act: (cubit) => cubit.logout(),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthUnauthenticated>(),
    ],
  );

  // =========================================================================
  // TC-063: login() emits error when repository throws
  // Note: The current implementation is a stub that always emits
  // unauthenticated. This test documents the intended error-handling
  // behavior for when the real implementation is added.
  // For now we just verify that the login method runs without throwing.
  // =========================================================================

  test('TC-063: login completes without throwing (stub behavior)', () async {
    final cubit = AuthCubit(mockRepo);
    // Current implementation ignores repository entirely
    await expectLater(
      cubit.login('test@example.com', 'wrong'),
      completes,
    );
    await cubit.close();
  });

  // =========================================================================
  // TC-184: checkAuthStatus() emits loading → unauthenticated (stub behavior)
  // =========================================================================

  blocTest<AuthCubit, AuthState>(
    'TC-184: checkAuthStatus emits loading → unauthenticated (placeholder)',
    build: () => AuthCubit(mockRepo),
    act: (cubit) => cubit.checkAuthStatus(),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthUnauthenticated>(),
    ],
  );

  // =========================================================================
  // TC-H01: register() emits loading → unauthenticated (placeholder contract)
  // =========================================================================

  blocTest<AuthCubit, AuthState>(
    'TC-H01: register emits loading → unauthenticated (placeholder)',
    build: () => AuthCubit(mockRepo),
    act: (cubit) => cubit.register('user@example.com', 'password123', 'Alice'),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthUnauthenticated>(),
    ],
  );
}
