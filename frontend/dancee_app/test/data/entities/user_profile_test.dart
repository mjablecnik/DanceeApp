// Feature: profile-page-features
// Task 2.2: Property test for UserProfile serialization round-trip
// Properties covered:
//   Property 1: UserProfile serialization round-trip

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/data/entities/user_profile.dart';

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(42);

String _randomString([int length = 8]) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(
    length,
    (_) => chars[_rng.nextInt(chars.length)],
  ).join();
}

String? _randomNullableString([int length = 8]) =>
    _rng.nextBool() ? _randomString(length) : null;

List<String> _randomDanceTags() {
  const tags = ['salsa', 'bachata', 'tango', 'swing', 'waltz', 'kizomba', 'zouk'];
  final count = _rng.nextInt(tags.length + 1);
  final shuffled = List<String>.from(tags)..shuffle(_rng);
  return shuffled.take(count).toList();
}

const _experienceLevels = ['beginner', 'intermediate', 'advanced', 'professional'];

UserProfile _randomUserProfile() {
  return UserProfile(
    directusUserId: _randomString(12),
    firebaseUid: _randomString(28),
    firstName: _randomString(6),
    lastName: _randomString(8),
    email: '${_randomString(6)}@example.com',
    phone: _randomNullableString(10),
    city: _randomNullableString(8),
    bio: _randomNullableString(40),
    avatarUrl: null, // avatarUrl does not survive toDirectus/fromDirectus round-trip
    danceTags: _randomDanceTags(),
    experienceLevel: _experienceLevels[_rng.nextInt(_experienceLevels.length)],
  );
}

// ---------------------------------------------------------------------------
// Property 1: UserProfile serialization round-trip
// ---------------------------------------------------------------------------

void _propertySerializationRoundTrip() {
  // Feature: profile-page-features, Property 1: UserProfile serialization round-trip
  test(
    'P1: toDirectus() → fromDirectus() preserves all editable fields (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final original = _randomUserProfile();

        // Serialize via toDirectus()
        final directusMap = original.toDirectus();

        // Re-add fields not included in toDirectus() so fromDirectus() can parse them
        final fullJson = {
          ...directusMap,
          'id': original.directusUserId,
          'firebase_uid': original.firebaseUid,
          // No avatar — avatarUrl is null on the original
        };

        // Deserialize via fromDirectus()
        final restored = UserProfile.fromDirectus(fullJson);

        expect(
          restored.directusUserId,
          equals(original.directusUserId),
          reason: 'Iteration $i: directusUserId must survive round-trip',
        );
        expect(
          restored.firebaseUid,
          equals(original.firebaseUid),
          reason: 'Iteration $i: firebaseUid must survive round-trip',
        );
        expect(
          restored.firstName,
          equals(original.firstName),
          reason: 'Iteration $i: firstName must survive round-trip',
        );
        expect(
          restored.lastName,
          equals(original.lastName),
          reason: 'Iteration $i: lastName must survive round-trip',
        );
        expect(
          restored.email,
          equals(original.email),
          reason: 'Iteration $i: email must survive round-trip',
        );
        expect(
          restored.phone,
          equals(original.phone),
          reason: 'Iteration $i: phone must survive round-trip',
        );
        expect(
          restored.city,
          equals(original.city),
          reason: 'Iteration $i: city must survive round-trip',
        );
        expect(
          restored.bio,
          equals(original.bio),
          reason: 'Iteration $i: bio must survive round-trip',
        );
        expect(
          restored.danceTags,
          equals(original.danceTags),
          reason: 'Iteration $i: danceTags must survive round-trip',
        );
        expect(
          restored.experienceLevel,
          equals(original.experienceLevel),
          reason: 'Iteration $i: experienceLevel must survive round-trip',
        );
        // avatarUrl: not encoded by toDirectus() — expected to be null after round-trip
        expect(
          restored.avatarUrl,
          isNull,
          reason: 'Iteration $i: avatarUrl is not encoded by toDirectus() and should be null',
        );
      }
    },
  );

  test(
    'P1b: fullName getter returns trimmed concatenation of firstName and lastName (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final profile = _randomUserProfile();
        final expected = '${profile.firstName} ${profile.lastName}'.trim();
        expect(
          profile.fullName,
          equals(expected),
          reason: 'Iteration $i: fullName should equal trimmed firstName + lastName',
        );
      }
    },
  );

  test(
    'P1c: toDirectus() omits null optional fields (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        // Create a profile with all optional fields set to null
        final profile = UserProfile(
          directusUserId: _randomString(12),
          firebaseUid: _randomString(28),
          firstName: _randomString(6),
          lastName: _randomString(8),
          email: '${_randomString(6)}@example.com',
          phone: null,
          city: null,
          bio: null,
          avatarUrl: null,
          danceTags: _randomDanceTags(),
          experienceLevel: _experienceLevels[_rng.nextInt(_experienceLevels.length)],
        );

        final map = profile.toDirectus();

        expect(
          map.containsKey('phone'),
          isFalse,
          reason: 'Iteration $i: null phone should not appear in toDirectus() output',
        );
        expect(
          map.containsKey('city'),
          isFalse,
          reason: 'Iteration $i: null city should not appear in toDirectus() output',
        );
        expect(
          map.containsKey('bio'),
          isFalse,
          reason: 'Iteration $i: null bio should not appear in toDirectus() output',
        );
      }
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('UserProfile — property tests', () {
    group('Property 1: Serialization round-trip', _propertySerializationRoundTrip);
  });
}
