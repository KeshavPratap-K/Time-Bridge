import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/timezone_info.dart';

class TimezoneService {
  static final TimezoneService _instance = TimezoneService._internal();
  factory TimezoneService() => _instance;
  TimezoneService._internal();

  bool _initialized = false;
  List<TimezoneInfo> _allTimezones = [];
  final Map<String, TimezoneInfo> _infoById = {};

  void init() {
    if (_initialized) return;
    tz.initializeTimeZones();

    final now = DateTime.now();
    final List<TimezoneInfo> list = [];

    for (final entry in tz.timeZoneDatabase.locations.entries) {
      final id = entry.key;
      final location = entry.value;

      try {
        final tzNow = tz.TZDateTime.from(now, location);
        final offsetMinutes = tzNow.timeZoneOffset.inMinutes;
        final (city, region) = TimezoneInfo.parseId(id);
        final offsetString = TimezoneInfo.formatOffset(offsetMinutes);

        final info = TimezoneInfo(
          id: id,
          city: city,
          region: region,
          offsetString: offsetString,
          offsetMinutes: offsetMinutes,
        );
        list.add(info);
        _infoById[id] = info;
      } catch (_) {
        // Skip invalid locations if any
      }
    }

    // Sort by Region then City
    list.sort((a, b) {
      final regionComp = a.region.compareTo(b.region);
      if (regionComp != 0) return regionComp;
      return a.city.compareTo(b.city);
    });

    _allTimezones = list;
    _initialized = true;
  }

  List<TimezoneInfo> getAllTimezones() {
    init();
    return _allTimezones;
  }

  TimezoneInfo? getTimezoneInfo(String id) {
    init();
    return _infoById[id];
  }

  /// Converts a reference [DateTime] (usually device local or custom reference time)
  /// to the target timezone [id].
  DateTime convertTime(DateTime referenceTime, String timezoneId) {
    init();
    try {
      final location = tz.getLocation(timezoneId);
      return tz.TZDateTime.from(referenceTime, location);
    } catch (_) {
      return referenceTime;
    }
  }

  /// Returns a default timezone to show on the bottom clock.
  /// Defaults to UTC if local matches, or a popular standard timezone.
  TimezoneInfo getDefaultSecondaryTimezone() {
    init();
    // Default to UTC or America/New_York or Asia/Tokyo
    return getTimezoneInfo('UTC') ??
        getTimezoneInfo('America/New_York') ??
        _allTimezones.first;
  }
}
