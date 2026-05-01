// Feature: profile-page-features
// Task 12.3: Property test for contact form required field validation
// Properties covered:
//   Property 5: Contact form required field validation

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// The validation predicate under test
//
// Mirrors `_validate()` from
// `lib/screens/profile/author_contact/sections/contact_form_section.dart`:
//
//   bool _validate() {
//     final subjectError =
//         _selectedSubject.isEmpty ? t.contact.form.typeRequired : null;
//     final titleError = _titleController.text.trim().isEmpty
//         ? t.contact.form.titleRequired
//         : null;
//     final messageError = _messageController.text.trim().isEmpty
//         ? t.contact.form.messageRequired
//         : null;
//     final emailError = _emailController.text.trim().isEmpty
//         ? t.contact.form.emailRequired
//         : null;
//     return subjectError == null &&
//         titleError == null &&
//         messageError == null &&
//         emailError == null;
//   }
//
// Requirements 7.6: validate required fields (type, title, message, reply email)
// before submission; reject when any required field is empty/whitespace-only.
// ---------------------------------------------------------------------------

bool _validateContactForm({
  required String subject,
  required String title,
  required String message,
  required String email,
}) {
  final subjectError = subject.isEmpty;
  final titleError = title.trim().isEmpty;
  final messageError = message.trim().isEmpty;
  final emailError = email.trim().isEmpty;

  return !subjectError && !titleError && !messageError && !emailError;
}

// ---------------------------------------------------------------------------
// Helpers / Generators
// ---------------------------------------------------------------------------

final _rng = Random(99);

const _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const _whitespace = '   \t\n  ';
const _subjectValues = ['bug', 'feature', 'feedback', 'other'];

String _randomString([int length = 8]) {
  return List.generate(length, (_) => _chars[_rng.nextInt(_chars.length)]).join();
}

/// Returns a non-empty, non-whitespace-only string.
String _nonEmpty() => _randomString(4 + _rng.nextInt(12));

/// Returns either an empty string or a whitespace-only string.
String _emptyOrWhitespace() {
  if (_rng.nextBool()) return '';
  final len = 1 + _rng.nextInt(5);
  return List.generate(len, (_) => _whitespace[_rng.nextInt(_whitespace.length)])
      .join();
}

String _randomSubject() => _subjectValues[_rng.nextInt(_subjectValues.length)];

// ---------------------------------------------------------------------------
// Property 5: Contact form required field validation
// ---------------------------------------------------------------------------

void _propertyContactFormValidation() {
  // Requirements: 7.6

  test('P5a: all required fields non-empty → valid (100 iterations)', () {
    for (var i = 0; i < 100; i++) {
      final subject = _randomSubject();
      final title = _nonEmpty();
      final message = _nonEmpty();
      final email = '${_nonEmpty()}@example.com';

      expect(
        _validateContactForm(
          subject: subject,
          title: title,
          message: message,
          email: email,
        ),
        isTrue,
        reason:
            'Iteration $i: all fields non-empty — form should be valid '
            '(subject="$subject", title="$title", message="$message", email="$email")',
      );
    }
  });

  test('P5b: empty subject → invalid (100 iterations)', () {
    for (var i = 0; i < 100; i++) {
      expect(
        _validateContactForm(
          subject: '',
          title: _nonEmpty(),
          message: _nonEmpty(),
          email: _nonEmpty(),
        ),
        isFalse,
        reason: 'Iteration $i: empty subject must cause validation failure',
      );
    }
  });

  test('P5c: empty or whitespace-only title → invalid (100 iterations)', () {
    for (var i = 0; i < 100; i++) {
      expect(
        _validateContactForm(
          subject: _randomSubject(),
          title: _emptyOrWhitespace(),
          message: _nonEmpty(),
          email: _nonEmpty(),
        ),
        isFalse,
        reason: 'Iteration $i: empty/whitespace title must cause validation failure',
      );
    }
  });

  test('P5d: empty or whitespace-only message → invalid (100 iterations)', () {
    for (var i = 0; i < 100; i++) {
      expect(
        _validateContactForm(
          subject: _randomSubject(),
          title: _nonEmpty(),
          message: _emptyOrWhitespace(),
          email: _nonEmpty(),
        ),
        isFalse,
        reason: 'Iteration $i: empty/whitespace message must cause validation failure',
      );
    }
  });

  test('P5e: empty or whitespace-only email → invalid (100 iterations)', () {
    for (var i = 0; i < 100; i++) {
      expect(
        _validateContactForm(
          subject: _randomSubject(),
          title: _nonEmpty(),
          message: _nonEmpty(),
          email: _emptyOrWhitespace(),
        ),
        isFalse,
        reason: 'Iteration $i: empty/whitespace email must cause validation failure',
      );
    }
  });

  test(
    'P5f: random combination — reject when any required field empty/whitespace (200 iterations)',
    () {
      for (var i = 0; i < 200; i++) {
        // Randomly make each required field empty or non-empty
        final subjectEmpty = _rng.nextBool();
        final titleEmpty = _rng.nextBool();
        final messageEmpty = _rng.nextBool();
        final emailEmpty = _rng.nextBool();

        final subject = subjectEmpty ? '' : _randomSubject();
        final title = titleEmpty ? _emptyOrWhitespace() : _nonEmpty();
        final message = messageEmpty ? _emptyOrWhitespace() : _nonEmpty();
        final email = emailEmpty ? _emptyOrWhitespace() : _nonEmpty();

        final anyEmpty =
            subjectEmpty || titleEmpty || messageEmpty || emailEmpty;

        final result = _validateContactForm(
          subject: subject,
          title: title,
          message: message,
          email: email,
        );

        if (anyEmpty) {
          expect(
            result,
            isFalse,
            reason:
                'Iteration $i: at least one required field empty — must be invalid '
                '(subjectEmpty=$subjectEmpty, titleEmpty=$titleEmpty, '
                'messageEmpty=$messageEmpty, emailEmpty=$emailEmpty)',
          );
        } else {
          expect(
            result,
            isTrue,
            reason:
                'Iteration $i: all required fields non-empty — must be valid '
                '(subject="$subject", title="$title", message="$message", email="$email")',
          );
        }
      }
    },
  );

  test('P5g: whitespace-only strings are treated as empty for title/message/email', () {
    const whitespaceInputs = ['', ' ', '   ', '\t', '\n', '  \t  \n  '];

    for (final ws in whitespaceInputs) {
      // Whitespace title
      expect(
        _validateContactForm(
          subject: 'bug',
          title: ws,
          message: 'some message',
          email: 'user@example.com',
        ),
        isFalse,
        reason: '"$ws" as title should be treated as empty',
      );

      // Whitespace message
      expect(
        _validateContactForm(
          subject: 'bug',
          title: 'some title',
          message: ws,
          email: 'user@example.com',
        ),
        isFalse,
        reason: '"$ws" as message should be treated as empty',
      );

      // Whitespace email
      expect(
        _validateContactForm(
          subject: 'bug',
          title: 'some title',
          message: 'some message',
          email: ws,
        ),
        isFalse,
        reason: '"$ws" as email should be treated as empty',
      );
    }
  });

  test('P5h: phone is optional — form valid without phone', () {
    // Phone is not a required field — validation should pass without it.
    expect(
      _validateContactForm(
        subject: 'feedback',
        title: 'My Title',
        message: 'My message body',
        email: 'user@example.com',
      ),
      isTrue,
      reason: 'Phone is optional; form must be valid with only required fields filled',
    );
  });

  test('P5i: validation is deterministic — same inputs always yield same result', () {
    final cases = [
      ('bug', 'Title', 'Message', 'a@b.com'),
      ('', 'Title', 'Message', 'a@b.com'),
      ('bug', '', 'Message', 'a@b.com'),
      ('bug', 'Title', ' ', 'a@b.com'),
      ('bug', 'Title', 'Message', ''),
      ('bug', '  ', '  ', '  '),
    ];

    for (final (subject, title, message, email) in cases) {
      final first = _validateContactForm(
        subject: subject,
        title: title,
        message: message,
        email: email,
      );
      for (var i = 0; i < 10; i++) {
        expect(
          _validateContactForm(
            subject: subject,
            title: title,
            message: message,
            email: email,
          ),
          equals(first),
          reason:
              'Validation must be deterministic for '
              '(subject="$subject", title="$title", message="$message", email="$email")',
        );
      }
    }
  });
}

// ---------------------------------------------------------------------------
// Test entry point
// ---------------------------------------------------------------------------

void main() {
  group('Contact form validation — property tests', () {
    group(
      'Property 5: Contact form required field validation',
      _propertyContactFormValidation,
    );
  });
}
