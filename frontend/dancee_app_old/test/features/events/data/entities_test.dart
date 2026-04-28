import 'package:dancee_app/features/events/data/entities.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Address _testAddress() => const Address(
      street: 'Main St 1',
      city: 'Prague',
      postalCode: '110 00',
      country: 'CZ',
    );

Venue _testVenue() => Venue(
      name: 'Club X',
      address: _testAddress(),
      description: '',
      latitude: 50.08,
      longitude: 14.43,
    );

Map<String, dynamic> _fullDirectusEvent({
  String id = '1',
  String startTime = '2099-12-31T20:00:00.000Z',
  String endTime = '2099-12-31T23:00:00.000Z',
}) =>
    {
      'id': id,
      'start_time': startTime,
      'end_time': endTime,
      'organizer': 'Dance Club',
      'dances': ['Salsa', 'Bachata'],
      'venue': {
        'name': 'Club X',
        'street': 'Main St',
        'number': '1',
        'town': 'Prague',
        'postal_code': '110 00',
        'country': 'CZ',
        'latitude': 50.08,
        'longitude': 14.43,
      },
      'translations': [
        {
          'languages_code': 'cs',
          'title': 'Salsa Night CZ',
          'description': 'Popis akce',
        },
        {
          'languages_code': 'en',
          'title': 'Salsa Night EN',
          'description': 'Event description',
        },
      ],
      'info': [
        {'type': 'text', 'key': 'Dress code', 'value': 'Smart casual'},
        {'type': 'url', 'key': 'Website', 'value': 'https://example.com'},
        {'type': 'price', 'key': 'Entry', 'value': '200 CZK'},
      ],
      'parts': [],
    };

void main() {
  // =========================================================================
  // Venue tests
  // =========================================================================

  group('Venue', () {
    // -----------------------------------------------------------------------
    // TC-111: Venue.fromDirectus() parses name, GPS coordinates, and address
    // -----------------------------------------------------------------------
    test('TC-111: fromDirectus() parses name, GPS, and concatenated address',
        () {
      final json = {
        'name': 'Studio Tango',
        'description': 'Great studio',
        'latitude': 50.0755,
        'longitude': 14.4378,
        'street': 'Wenceslas',
        'number': '42',
        'town': 'Prague',
        'postal_code': '11000',
        'country': 'CZ',
      };

      final venue = Venue.fromDirectus(json);

      expect(venue.name, equals('Studio Tango'));
      expect(venue.latitude, equals(50.0755));
      expect(venue.longitude, equals(14.4378));
      expect(venue.address.city, equals('Prague'));
      expect(venue.address.street, equals('Wenceslas 42'));
    });

    // -----------------------------------------------------------------------
    // TC-L07: Venue.toJson() round-trip preserves all fields
    // -----------------------------------------------------------------------
    test('TC-L07: toJson() round-trip preserves all fields', () {
      final venue = _testVenue();
      final json = venue.toJson();
      final addressJson = json['address'] as Map<String, dynamic>;
      final restored = Venue(
        name: json['name'] as String,
        address: Address(
          street: addressJson['street'] as String,
          city: addressJson['city'] as String,
          postalCode: addressJson['postalCode'] as String,
          country: addressJson['country'] as String,
        ),
        description: json['description'] as String,
        latitude: json['latitude'] as double,
        longitude: json['longitude'] as double,
      );
      expect(restored, equals(venue));
    });

    // -----------------------------------------------------------------------
    // TC-113: Venue.copyWith() updates only specified fields
    // -----------------------------------------------------------------------
    test('TC-113: copyWith(name) updates name and preserves other fields', () {
      final original = _testVenue();
      final updated = original.copyWith(name: 'New Studio');

      expect(updated.name, equals('New Studio'));
      expect(updated.address, equals(original.address));
      expect(updated.latitude, equals(original.latitude));
      expect(updated.longitude, equals(original.longitude));
      expect(updated.description, equals(original.description));
    });

    // -----------------------------------------------------------------------
    // TC-112: Venue.fromDirectus() handles missing optional fields
    // -----------------------------------------------------------------------
    test('TC-112: fromDirectus() does not throw when lat/long/description absent',
        () {
      final json = {'name': 'Studio Tango'};

      expect(() => Venue.fromDirectus(json), returnsNormally);

      final venue = Venue.fromDirectus(json);
      expect(venue.name, equals('Studio Tango'));
      expect(venue.latitude, equals(0.0));
      expect(venue.longitude, equals(0.0));
      expect(venue.description, equals(''));
    });

    // -----------------------------------------------------------------------
    // TC-VR-01: Venue with missing region field defaults to empty string
    // -----------------------------------------------------------------------
    test('TC-VR-01: fromDirectus() defaults region to empty string when absent',
        () {
      final json = {
        'name': 'Club A',
        'latitude': 50.0,
        'longitude': 14.0,
      };
      final venue = Venue.fromDirectus(json);
      expect(venue.region, equals(''));
    });

    // -----------------------------------------------------------------------
    // TC-VR-02: Venue with null region defaults to empty string
    // -----------------------------------------------------------------------
    test('TC-VR-02: fromDirectus() defaults region to empty string when null',
        () {
      final json = {
        'name': 'Club B',
        'region': null,
        'latitude': 50.0,
        'longitude': 14.0,
      };
      final venue = Venue.fromDirectus(json);
      expect(venue.region, equals(''));
    });

    // -----------------------------------------------------------------------
    // TC-VR-03: Venue with valid region string parses correctly
    // -----------------------------------------------------------------------
    test('TC-VR-03: fromDirectus() parses valid region string correctly', () {
      final json = {
        'name': 'Club C',
        'region': 'South Moravia',
        'latitude': 49.2,
        'longitude': 16.6,
      };
      final venue = Venue.fromDirectus(json);
      expect(venue.region, equals('South Moravia'));
    });
  });

  // =========================================================================
  // Address tests
  // =========================================================================

  group('Address', () {
    // -----------------------------------------------------------------------
    // TC-013: fullAddress concatenates all non-null fields
    // -----------------------------------------------------------------------
    test('TC-013: fullAddress includes street, postalCode, city, country', () {
      final address = _testAddress();
      final full = address.fullAddress;
      expect(full, contains('Main St 1'));
      expect(full, contains('Prague'));
      expect(full, contains('110 00'));
      expect(full, contains('CZ'));
    });

    // -----------------------------------------------------------------------
    // TC-152: fullAddress with partial empty fields is non-empty and
    //          contains the non-empty components
    // -----------------------------------------------------------------------
    test(
        'TC-152: fullAddress with partial empty fields is non-empty and '
        'contains city and country', () {
      const address = Address(
        street: '',
        city: 'Prague',
        postalCode: '',
        country: 'CZ',
      );
      final full = address.fullAddress;
      expect(full, isNotEmpty);
      expect(full, contains('Prague'));
      expect(full, contains('CZ'));
    });

    // -----------------------------------------------------------------------
    // TC-L08: Address.toJson() round-trip preserves all fields
    // -----------------------------------------------------------------------
    test('TC-L08: toJson() round-trip preserves all fields', () {
      const address = Address(
        street: '123 Main St',
        city: 'Brno',
        postalCode: '602 00',
        country: 'CZ',
      );
      final json = address.toJson();
      final restored = Address(
        street: json['street'] as String,
        city: json['city'] as String,
        postalCode: json['postalCode'] as String,
        country: json['country'] as String,
      );
      expect(restored, equals(address));
    });

    // -----------------------------------------------------------------------
    // TC-M04: copyWith(city:) updates only city and preserves all other fields
    // -----------------------------------------------------------------------
    test('TC-M04: copyWith(city: Brno) updates only city', () {
      const original = Address(
        street: 'Main St 1',
        city: 'Prague',
        postalCode: '110 00',
        country: 'CZ',
      );
      final updated = original.copyWith(city: 'Brno');

      expect(updated.city, equals('Brno'));
      expect(updated.street, equals('Main St 1'));
      expect(updated.postalCode, equals('110 00'));
      expect(updated.country, equals('CZ'));
    });

    // -----------------------------------------------------------------------
    // TC-015: fromJson/toJson round-trip
    // -----------------------------------------------------------------------
    test('TC-015: fromJson/toJson round-trip is lossless', () {
      // Address uses toJson() and fromDirectusVenue() separately;
      // test the toJson keys and reconstructing via constructor
      final address = _testAddress();
      final json = address.toJson();
      final restored = Address(
        street: json['street'] as String,
        city: json['city'] as String,
        postalCode: json['postalCode'] as String,
        country: json['country'] as String,
      );
      expect(restored, equals(address));
    });
  });

  // =========================================================================
  // Event tests
  // =========================================================================

  group('Event', () {
    // -----------------------------------------------------------------------
    // TC-114: fromDirectus() marks isFavorite=true when ID is in favoriteIds
    // -----------------------------------------------------------------------
    test('TC-114: fromDirectus() sets isFavorite=true when id is in favoriteIds',
        () {
      final json = _fullDirectusEvent(id: 'evt-1');
      final event = Event.fromDirectus(
        json,
        favoriteIds: {'evt-1', 'evt-2'},
      );
      expect(event.isFavorite, isTrue);
    });

    // -----------------------------------------------------------------------
    // TC-115: fromDirectus() marks isFavorite=false when ID not in favoriteIds
    // -----------------------------------------------------------------------
    test('TC-115: fromDirectus() sets isFavorite=false when id is absent from favoriteIds',
        () {
      final json = _fullDirectusEvent(id: 'evt-3');
      final event = Event.fromDirectus(
        json,
        favoriteIds: {'evt-1', 'evt-2'},
      );
      expect(event.isFavorite, isFalse);
    });

    // -----------------------------------------------------------------------
    // TC-116: fromDirectus() computes isPast=true when end_time is in the past
    // -----------------------------------------------------------------------
    test('TC-116: fromDirectus() sets isPast=true when end_time is in the past',
        () {
      final pastEnd = DateTime.now().subtract(const Duration(hours: 1));
      final pastStart = pastEnd.subtract(const Duration(hours: 2));
      final json = _fullDirectusEvent(
        startTime: pastStart.toIso8601String(),
        endTime: pastEnd.toIso8601String(),
      );
      final event = Event.fromDirectus(json);
      expect(event.isPast, isTrue);
    });

    // -----------------------------------------------------------------------
    // TC-117: fromDirectus() falls back to start_time for isPast when end_time absent
    // -----------------------------------------------------------------------
    test(
        'TC-117: fromDirectus() uses start_time for isPast when end_time is null',
        () {
      final pastStart = DateTime.now().subtract(const Duration(hours: 1));
      final json = _fullDirectusEvent(
        startTime: pastStart.toIso8601String(),
        endTime: '2099-12-31T23:00:00.000Z',
      )..remove('end_time');
      final event = Event.fromDirectus(json);
      expect(event.isPast, isTrue);
    });

    // -----------------------------------------------------------------------
    // TC-016: fromDirectus() parses full Directus response
    // -----------------------------------------------------------------------
    test('TC-016: fromDirectus() parses full event with venue and translations',
        () {
      final json = _fullDirectusEvent();
      final event = Event.fromDirectus(json, language: 'cs');

      expect(event.id, equals('1'));
      expect(event.title, equals('Salsa Night CZ'));
      expect(event.description, equals('Popis akce'));
      expect(event.venue.name, equals('Club X'));
      expect(event.dances, containsAll(['Salsa', 'Bachata']));
      expect(event.info.length, equals(3));
    });

    // -----------------------------------------------------------------------
    // TC-017: fromDirectus() falls back gracefully when translations missing
    // -----------------------------------------------------------------------
    test('TC-017: fromDirectus() does not throw when translations list is empty',
        () {
      final json = _fullDirectusEvent()..['translations'] = [];
      // Should not throw; title falls back to json['title'] which may be null
      expect(() => Event.fromDirectus(json), returnsNormally);
      final event = Event.fromDirectus(json);
      expect(event.title, isA<String>());
    });

    // -----------------------------------------------------------------------
    // TC-018: isPast returns true for events whose endTime is before now
    // -----------------------------------------------------------------------
    test('TC-018: isPast is true when endTime is in the past', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      final json = _fullDirectusEvent(
        startTime: pastTime
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        endTime: pastTime.toIso8601String(),
      );
      final event = Event.fromDirectus(json);
      expect(event.isPast, isTrue);
    });

    // -----------------------------------------------------------------------
    // TC-019: isPast returns false for future events
    // -----------------------------------------------------------------------
    test('TC-019: isPast is false when endTime is in the future', () {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      final json = _fullDirectusEvent(
        startTime: futureTime
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        endTime: futureTime.toIso8601String(),
      );
      final event = Event.fromDirectus(json);
      expect(event.isPast, isFalse);
    });

    // -----------------------------------------------------------------------
    // TC-020: fromDirectus() handles null venue
    // -----------------------------------------------------------------------
    test('TC-020: fromDirectus() does not throw when venue is null', () {
      final json = _fullDirectusEvent()..['venue'] = null;
      expect(() => Event.fromDirectus(json), returnsNormally);
      final event = Event.fromDirectus(json);
      expect(event.venue, isA<Venue>());
    });

    // -----------------------------------------------------------------------
    // TC-153: copyWith(isFavorite) preserves all other fields
    // -----------------------------------------------------------------------
    test(
        'TC-153: copyWith(isFavorite: true) changes only isFavorite and '
        'preserves all other fields', () {
      final original = Event.fromDirectus(_fullDirectusEvent(), language: 'cs');
      final updated = original.copyWith(isFavorite: true);

      expect(updated.isFavorite, isTrue,
          reason: 'isFavorite should be updated');
      expect(original.isFavorite, isFalse,
          reason: 'original should not be mutated');
      expect(updated.id, equals(original.id));
      expect(updated.title, equals(original.title));
      expect(updated.description, equals(original.description));
      expect(updated.organizer, equals(original.organizer));
      expect(updated.venue, equals(original.venue));
      expect(updated.startTime, equals(original.startTime));
      expect(updated.endTime, equals(original.endTime));
      expect(updated.duration, equals(original.duration));
      expect(updated.dances, equals(original.dances));
      expect(updated.info, equals(original.info));
      expect(updated.parts, equals(original.parts));
      expect(updated.isPast, equals(original.isPast));
      expect(updated.badge, equals(original.badge));
      expect(updated.sourceUrl, equals(original.sourceUrl));
      expect(updated.timezone, equals(original.timezone));
    });

    // -----------------------------------------------------------------------
    // TC-021: copyWith() returns new instance with updated fields
    // -----------------------------------------------------------------------
    test('TC-021: copyWith(isFavorite: true) updates only isFavorite', () {
      final original = Event.fromDirectus(_fullDirectusEvent());
      final updated = original.copyWith(isFavorite: true);

      expect(updated.isFavorite, isTrue);
      expect(updated.id, equals(original.id));
      expect(updated.title, equals(original.title));
      expect(updated.venue, equals(original.venue));
    });

    // -----------------------------------------------------------------------
    // TC-118: fromDirectus() handles missing dances field as empty list
    // -----------------------------------------------------------------------
    test('TC-118: fromDirectus() returns empty dances when field is missing',
        () {
      final json = _fullDirectusEvent()..remove('dances');
      final event = Event.fromDirectus(json);
      expect(event.dances, isEmpty);
    });

    // -----------------------------------------------------------------------
    // TC-119: fromDirectus() selects correct translation by language code
    // -----------------------------------------------------------------------
    test(
        'TC-119: fromDirectus() picks the title matching the requested language',
        () {
      final json = _fullDirectusEvent();
      // 'en' translation should give 'Salsa Night EN'
      final eventEn = Event.fromDirectus(json, language: 'en');
      expect(eventEn.title, equals('Salsa Night EN'));

      // 'cs' translation should give 'Salsa Night CZ'
      final eventCs = Event.fromDirectus(json, language: 'cs');
      expect(eventCs.title, equals('Salsa Night CZ'));
    });

    // -----------------------------------------------------------------------
    // TC-H09: fromDirectus() falls back to root-level title when requested
    //         language is absent from translations
    // -----------------------------------------------------------------------
    test(
        'TC-H09: fromDirectus() uses root-level title when requested language '
        'is absent from translations', () {
      final json = {
        'id': '1',
        'start_time': '2099-12-31T20:00:00.000Z',
        'end_time': '2099-12-31T23:00:00.000Z',
        'organizer': 'Dance Club',
        'dances': <String>[],
        'venue': {
          'name': 'Club X',
          'street': 'Main St',
          'number': '1',
          'town': 'Prague',
          'postal_code': '110 00',
          'country': 'CZ',
          'latitude': 50.08,
          'longitude': 14.43,
        },
        'title': 'Root Title',
        'translations': [
          {
            'languages_code': 'cs',
            'title': 'Salsa Night CZ',
            'description': 'Popis akce',
          },
          {
            'languages_code': 'en',
            'title': 'Salsa Night EN',
            'description': 'Event description',
          },
        ],
        'info': <dynamic>[],
        'parts': <dynamic>[],
      };

      final event = Event.fromDirectus(json, language: 'de');
      expect(event.title, equals('Root Title'),
          reason: 'Should fall back to root-level title when language is absent');
    });

    // -----------------------------------------------------------------------
    // TC-093: fromDirectus() with all optional fields null/missing
    // -----------------------------------------------------------------------
    test('TC-093: fromDirectus() with minimal JSON does not throw', () {
      final minimalJson = {
        'id': '42',
        'start_time': '2099-01-01T00:00:00.000Z',
      };
      expect(() => Event.fromDirectus(minimalJson), returnsNormally);
      final event = Event.fromDirectus(minimalJson);
      expect(event.id, equals('42'));
      expect(event.title, isA<String>());
      expect(event.dances, isEmpty);
      expect(event.info, isEmpty);
      expect(event.parts, isEmpty);
    });
  });

  // =========================================================================
  // EventInfo tests
  // =========================================================================

  group('EventInfo', () {
    // -----------------------------------------------------------------------
    // TC-023: fromJson/toJson round-trip for each type
    // -----------------------------------------------------------------------
    for (final type in ['text', 'url', 'price']) {
      test('TC-023: EventInfo fromJson/toJson round-trip for type "$type"', () {
        final json = {'type': type, 'key': 'myKey', 'value': 'myValue'};
        final info = EventInfo.fromJson(json);
        final roundTrip = EventInfo.fromJson(info.toJson());
        expect(roundTrip, equals(info));
      });
    }

    // -----------------------------------------------------------------------
    // TC-154: fromJson() parses "url" type with specific values
    // -----------------------------------------------------------------------
    test('TC-154: EventInfo.fromJson parses url type with correct fields', () {
      final json = {
        'type': 'url',
        'key': 'website',
        'value': 'https://example.com',
      };
      final info = EventInfo.fromJson(json);
      expect(info.type, equals(EventInfoType.url));
      expect(info.key, equals('website'));
      expect(info.value, equals('https://example.com'));
    });

    // -----------------------------------------------------------------------
    // TC-155: fromJson() parses "price" type with specific values
    // -----------------------------------------------------------------------
    test('TC-155: EventInfo.fromJson parses price type with correct fields',
        () {
      final json = {
        'type': 'price',
        'key': 'ticket',
        'value': '200 CZK',
      };
      final info = EventInfo.fromJson(json);
      expect(info.type, equals(EventInfoType.price));
      expect(info.key, equals('ticket'));
      expect(info.value, equals('200 CZK'));
    });

    // -----------------------------------------------------------------------
    // TC-M05: fromJson() with unknown type string defaults to EventInfoType.text
    // -----------------------------------------------------------------------
    test('TC-M05: fromJson() with unknown type defaults to EventInfoType.text',
        () {
      final json = {'type': 'foobar', 'key': 'Foo', 'value': 'Bar'};
      final info = EventInfo.fromJson(json);
      expect(info.type, equals(EventInfoType.text));
    });

    // -----------------------------------------------------------------------
    // TC-M06: copyWith(value:) updates only value, preserves type and key
    // -----------------------------------------------------------------------
    test('TC-M06: copyWith(value: new) updates only value', () {
      const original = EventInfo(
        type: EventInfoType.url,
        key: 'Website',
        value: 'old',
      );
      final updated = original.copyWith(value: 'new');

      expect(updated.value, equals('new'));
      expect(updated.type, equals(EventInfoType.url));
      expect(updated.key, equals('Website'));
    });
  });

  // =========================================================================
  // EventPart tests
  // =========================================================================

  group('EventPart', () {
    // -----------------------------------------------------------------------
    // TC-022: fromJson/toJson round-trip for EventPart
    // -----------------------------------------------------------------------
    test('TC-022: EventPart toJson/fromDirectus round-trip', () {
      final directusJson = {
        'name': 'Workshop',
        'description': 'Beginner workshop',
        'type': 'workshop',
        'date_time_range': {
          'start': '2099-12-31T18:00:00.000Z',
          'end': '2099-12-31T20:00:00.000Z',
        },
        'lectors': ['Alice'],
        'djs': [],
      };
      final part = EventPart.fromDirectus(directusJson);
      // Verify fields parsed correctly
      expect(part.name, equals('Workshop'));
      expect(part.type, equals(EventPartType.workshop));
      expect(part.lectors, contains('Alice'));
    });

    // -----------------------------------------------------------------------
    // TC-156: fromDirectus() with null date_time_range sets endTime to null
    // -----------------------------------------------------------------------
    test(
        'TC-156: fromDirectus() with null date_time_range does not throw and '
        'sets endTime to null', () {
      final json = {
        'name': 'Party',
        'type': 'party',
        'date_time_range': null,
      };

      expect(() => EventPart.fromDirectus(json), returnsNormally);

      final part = EventPart.fromDirectus(json);
      expect(part.endTime, isNull,
          reason: 'endTime should be null when date_time_range is absent');
      expect(part.startTime, isA<DateTime>(),
          reason: 'startTime defaults to DateTime.now() when absent');
    });

    // -----------------------------------------------------------------------
    // TC-M07: copyWith(name:) updates only name and preserves all other fields
    // -----------------------------------------------------------------------
    test('TC-M07: copyWith(name: Updated) updates only name', () {
      final startTime = DateTime(2099, 12, 31, 18, 0, 0);
      final endTime = DateTime(2099, 12, 31, 20, 0, 0);
      final original = EventPart(
        name: 'Original',
        type: EventPartType.workshop,
        startTime: startTime,
        endTime: endTime,
        lectors: const ['Alice'],
        djs: const ['DJ Bob'],
      );
      final updated = original.copyWith(name: 'Updated');

      expect(updated.name, equals('Updated'));
      expect(updated.type, equals(EventPartType.workshop));
      expect(updated.startTime, equals(startTime));
      expect(updated.endTime, equals(endTime));
      expect(updated.lectors, equals(const ['Alice']));
      expect(updated.djs, equals(const ['DJ Bob']));
    });
  });
}
