// Feature: profile-page-features
// Task 2.4: Property test for ContactMessage serialization completeness
// Properties covered:
//   Property 4: ContactMessage serialization completeness

import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:dancee_app/data/entities/contact_message.dart';
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

ContactMessageType _randomType() {
  const values = ContactMessageType.values;
  return values[_rng.nextInt(values.length)];
}

DeviceInfoData _randomDeviceInfo() {
  return DeviceInfoData(
    appVersion: '${_rng.nextInt(5)}.${_rng.nextInt(10)}.${_rng.nextInt(20)}',
    device: _randomString(12),
    os: 'Android ${_rng.nextInt(10) + 10}',
  );
}

ContactMessage _randomContactMessage() {
  return ContactMessage(
    type: _randomType(),
    title: _randomString(16),
    body: _randomString(64),
    replyEmail: '${_randomString(6)}@example.com',
    phone: _randomNullableString(10),
    deviceInfo: _randomDeviceInfo(),
    firebaseUid: _randomString(28),
  );
}

// ---------------------------------------------------------------------------
// Property 4: ContactMessage serialization completeness
// ---------------------------------------------------------------------------

void _propertySerializationCompleteness() {
  test(
    'P4: toDirectus() contains all required keys with matching values (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final msg = _randomContactMessage();
        final map = msg.toDirectus();

        // Required keys must always be present
        expect(
          map.containsKey('type'),
          isTrue,
          reason: 'Iteration $i: "type" key must be present',
        );
        expect(
          map.containsKey('title'),
          isTrue,
          reason: 'Iteration $i: "title" key must be present',
        );
        expect(
          map.containsKey('message'),
          isTrue,
          reason: 'Iteration $i: "message" key must be present',
        );
        expect(
          map.containsKey('reply_email'),
          isTrue,
          reason: 'Iteration $i: "reply_email" key must be present',
        );
        expect(
          map.containsKey('device_info'),
          isTrue,
          reason: 'Iteration $i: "device_info" key must be present',
        );

        // Values must match the source fields
        expect(
          map['type'],
          equals(msg.type.name),
          reason: 'Iteration $i: type value must match enum name',
        );
        expect(
          map['title'],
          equals(msg.title),
          reason: 'Iteration $i: title value must match',
        );
        expect(
          map['message'],
          equals(msg.body),
          reason: 'Iteration $i: message value must match body',
        );
        expect(
          map['reply_email'],
          equals(msg.replyEmail),
          reason: 'Iteration $i: reply_email value must match',
        );

        // device_info must be a JSON-encoded object with required sub-keys
        final deviceInfoRaw = map['device_info'];
        expect(
          deviceInfoRaw,
          isA<String>(),
          reason: 'Iteration $i: device_info must be a JSON string',
        );
        final deviceInfo = jsonDecode(deviceInfoRaw as String) as Map<String, dynamic>;
        expect(
          deviceInfo.containsKey('app_version'),
          isTrue,
          reason: 'Iteration $i: device_info must contain "app_version"',
        );
        expect(
          deviceInfo.containsKey('device_model'),
          isTrue,
          reason: 'Iteration $i: device_info must contain "device_model"',
        );
        expect(
          deviceInfo.containsKey('os_version'),
          isTrue,
          reason: 'Iteration $i: device_info must contain "os_version"',
        );
        expect(
          deviceInfo.containsKey('firebase_uid'),
          isTrue,
          reason: 'Iteration $i: device_info must contain "firebase_uid"',
        );
        expect(
          deviceInfo['app_version'],
          equals(msg.deviceInfo.appVersion),
          reason: 'Iteration $i: device_info.app_version must match',
        );
        expect(
          deviceInfo['device_model'],
          equals(msg.deviceInfo.device),
          reason: 'Iteration $i: device_info.device_model must match',
        );
        expect(
          deviceInfo['os_version'],
          equals(msg.deviceInfo.os),
          reason: 'Iteration $i: device_info.os_version must match',
        );
        expect(
          deviceInfo['firebase_uid'],
          equals(msg.firebaseUid),
          reason: 'Iteration $i: device_info.firebase_uid must match',
        );
      }
    },
  );

  test(
    'P4b: toDirectus() includes "phone" key only when phone is non-null (100 iterations)',
    () {
      for (var i = 0; i < 100; i++) {
        final msg = _randomContactMessage();
        final map = msg.toDirectus();

        if (msg.phone != null) {
          expect(
            map.containsKey('phone'),
            isTrue,
            reason: 'Iteration $i: non-null phone must appear in output',
          );
          expect(
            map['phone'],
            equals(msg.phone),
            reason: 'Iteration $i: phone value must match',
          );
        } else {
          expect(
            map.containsKey('phone'),
            isFalse,
            reason: 'Iteration $i: null phone must not appear in output',
          );
        }
      }
    },
  );

  test(
    'P4c: type enum covers all four variants (bug, feature, feedback, other)',
    () {
      final observed = <String>{};
      // Run enough iterations so all four variants are almost certain to appear
      for (var i = 0; i < 200; i++) {
        final msg = _randomContactMessage();
        observed.add(msg.toDirectus()['type'] as String);
      }
      expect(
        observed,
        containsAll(['bug', 'feature', 'feedback', 'other']),
        reason: 'All four ContactMessageType variants must be representable in toDirectus()',
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('ContactMessage — property tests', () {
    group('Property 4: Serialization completeness', _propertySerializationCompleteness);
  });
}
