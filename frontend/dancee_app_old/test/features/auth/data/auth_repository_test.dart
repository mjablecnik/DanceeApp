import 'package:dancee_app/core/clients.dart';
import 'package:dancee_app/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectusClient extends Mock implements DirectusClient {}

void main() {
  late MockDirectusClient mockClient;
  late AuthRepository repository;

  setUp(() {
    mockClient = MockDirectusClient();
    repository = AuthRepository(mockClient);
  });

  // =========================================================================
  // TC-180: All AuthRepository methods throw UnimplementedError
  // =========================================================================

  group('AuthRepository placeholder contract', () {
    test('TC-180: login() throws UnimplementedError', () async {
      await expectLater(
        () => repository.login('user@example.com', 'password'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('TC-181: register() throws UnimplementedError', () async {
      await expectLater(
        () => repository.register('user@example.com', 'password', 'Alice'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('TC-182: logout() throws UnimplementedError', () async {
      await expectLater(
        () => repository.logout(),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('TC-183: getCurrentUser() throws UnimplementedError', () async {
      await expectLater(
        () => repository.getCurrentUser(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
