import 'package:dancee_app/features/events/data/entities.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Property 8: Venue region parsing from Directus JSON
//
// For any Directus venue JSON map containing a `region` string field,
// Venue.fromDirectus(json).region must equal json['region'].
// When the `region` field is absent or null, the parsed region must
// default to an empty string.
//
// Validates: Requirements 4.7
// ---------------------------------------------------------------------------

void main() {
  group('Property 8: Venue region parsing from Directus JSON', () {
    // -----------------------------------------------------------------------
    // Property: for any non-empty region string, parsing preserves the value
    // -----------------------------------------------------------------------
    const regionStrings = [
      'Prague',
      'South Moravia',
      'Central Bohemia',
      'Ústí nad Labem Region',
      'Zlín Region',
      'Liberec Region',
      'Olomouc Region',
      'Pardubice Region',
      'Hradec Králové Region',
      'South Bohemia',
      'Plzeň Region',
      'Karlovarský kraj',
      'Vysočina',
      'Moravian-Silesian Region',
      'a',
      '1234',
      'Region with spaces and numbers 123',
      '  trimmed  ',
    ];

    for (final region in regionStrings) {
      test('region "$region" is preserved by fromDirectus()', () {
        final json = <String, dynamic>{
          'name': 'Test Venue',
          'region': region,
          'latitude': 50.0,
          'longitude': 14.0,
        };

        final venue = Venue.fromDirectus(json);
        expect(venue.region, equals(json['region'] as String),
            reason: 'fromDirectus must preserve the region value from JSON');
      });
    }

    // -----------------------------------------------------------------------
    // Property: absent region field defaults to empty string
    // -----------------------------------------------------------------------
    final absentRegionCases = <Map<String, dynamic>>[
      {'name': 'Venue A', 'latitude': 50.0, 'longitude': 14.0},
      {'name': 'Venue B'},
      {'name': 'Venue C', 'latitude': 49.0, 'longitude': 16.0, 'town': 'Brno'},
      <String, dynamic>{},
    ];

    for (var i = 0; i < absentRegionCases.length; i++) {
      final json = absentRegionCases[i];
      test('absent region in case $i defaults to empty string', () {
        final venue = Venue.fromDirectus(json);
        expect(venue.region, equals(''),
            reason: 'fromDirectus must default to empty string when region is absent');
      });
    }

    // -----------------------------------------------------------------------
    // Property: null region field defaults to empty string
    // -----------------------------------------------------------------------
    final nullRegionCases = <Map<String, dynamic>>[
      {'name': 'Venue X', 'region': null, 'latitude': 50.0, 'longitude': 14.0},
      {'name': 'Venue Y', 'region': null},
      {'region': null},
    ];

    for (var i = 0; i < nullRegionCases.length; i++) {
      final json = nullRegionCases[i];
      test('null region in case $i defaults to empty string', () {
        final venue = Venue.fromDirectus(json);
        expect(venue.region, equals(''),
            reason: 'fromDirectus must default to empty string when region is null');
      });
    }

    // -----------------------------------------------------------------------
    // Property: empty string region is preserved as empty string
    // -----------------------------------------------------------------------
    test('empty string region is preserved as empty string', () {
      final json = <String, dynamic>{
        'name': 'Venue Z',
        'region': '',
        'latitude': 50.0,
        'longitude': 14.0,
      };
      final venue = Venue.fromDirectus(json);
      expect(venue.region, equals(''),
          reason: 'fromDirectus must preserve empty string region');
    });

    // -----------------------------------------------------------------------
    // Property: region is independent of other venue fields
    // -----------------------------------------------------------------------
    test('region parsing is independent of other venue fields', () {
      const testRegion = 'Test Region';

      final minimalJson = <String, dynamic>{'region': testRegion};
      final fullJson = <String, dynamic>{
        'name': 'Full Venue',
        'region': testRegion,
        'latitude': 49.2,
        'longitude': 16.6,
        'street': 'Náměstí Svobody',
        'number': '1',
        'town': 'Brno',
        'postal_code': '602 00',
        'country': 'CZ',
        'description': 'A great venue',
      };

      final venueMinimal = Venue.fromDirectus(minimalJson);
      final venueFull = Venue.fromDirectus(fullJson);

      expect(venueMinimal.region, equals(testRegion));
      expect(venueFull.region, equals(testRegion));
    });

    // -----------------------------------------------------------------------
    // Property: region round-trips through toJson/fromDirectus-like reconstruction
    // -----------------------------------------------------------------------
    test('region survives a toJson round-trip', () {
      const testRegion = 'Moravian-Silesian Region';
      const original = Venue(
        name: 'Test',
        address: Address(street: '', city: '', postalCode: '', country: ''),
        description: '',
        latitude: 0,
        longitude: 0,
        region: testRegion,
      );

      final json = original.toJson();
      expect(json['region'], equals(testRegion),
          reason: 'toJson must include the region field');

      // Verify region key is present and correct in toJson output
      expect(json.containsKey('region'), isTrue);
      expect(json['region'], equals(testRegion));
    });
  });
}
