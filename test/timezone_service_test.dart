import 'package:flutter_test/flutter_test.dart';
import 'package:dual_clock_app/models/timezone_info.dart';
import 'package:dual_clock_app/services/timezone_service.dart';

void main() {
  group('TimezoneService tests', () {
    final service = TimezoneService();

    setUp(() {
      service.init();
    });

    test('Initializes and loads worldwide timezones', () {
      final zones = service.getAllTimezones();
      expect(zones, isNotEmpty);
      expect(zones.length, greaterThan(100));

      final utc = service.getTimezoneInfo('UTC');
      expect(utc, isNotNull);
      expect(utc!.offsetMinutes, equals(0));
      expect(utc.offsetString, equals('UTC+00:00'));
    });

    test('Parses timezone ID properly into city and region', () {
      final (city1, region1) = TimezoneInfo.parseId('America/New_York');
      expect(city1, equals('New York'));
      expect(region1, equals('America'));

      final (city2, region2) = TimezoneInfo.parseId('Asia/Tokyo');
      expect(city2, equals('Tokyo'));
      expect(region2, equals('Asia'));
    });

    test('Formats offset correctly', () {
      expect(TimezoneInfo.formatOffset(0), equals('UTC+00:00'));
      expect(TimezoneInfo.formatOffset(330), equals('UTC+05:30'));
      expect(TimezoneInfo.formatOffset(-240), equals('UTC-04:00'));
    });

    test('Converts time across timezones consistently', () {
      // 2026-06-01 12:00:00 UTC
      final utcTime = DateTime.utc(2026, 6, 1, 12, 0, 0);

      final tokyoTime = service.convertTime(utcTime, 'Asia/Tokyo');
      // Tokyo is UTC+9
      expect(tokyoTime.hour, equals(21));
      expect(tokyoTime.minute, equals(0));

      final londonTime = service.convertTime(utcTime, 'Europe/London');
      // London in June is BST (UTC+1)
      expect(londonTime.hour, equals(13));
    });
  });
}
