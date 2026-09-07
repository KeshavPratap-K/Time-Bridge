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

  static const Map<String, List<String>> _knownAliases = {
    // North America - Eastern Time (EST / EDT)
    'America/New_York': ['EST', 'EDT', 'ET', 'Eastern Time', 'Eastern Standard Time', 'Eastern Daylight Time'],
    'America/Detroit': ['EST', 'EDT', 'ET', 'Eastern Time', 'Eastern Standard Time'],
    'America/Toronto': ['EST', 'EDT', 'ET', 'Eastern Time', 'Eastern Standard Time'],
    'America/Montreal': ['EST', 'EDT', 'ET', 'Eastern Time', 'Eastern Standard Time'],
    'America/Indiana/Indianapolis': ['EST', 'EDT', 'ET', 'Eastern Time'],
    'America/Kentucky/Louisville': ['EST', 'EDT', 'ET', 'Eastern Time'],
    'EST': ['EST', 'Eastern Standard Time', 'ET'],
    'EST5EDT': ['EST', 'EDT', 'ET', 'Eastern Time'],
    'America/Panama': ['EST', 'Eastern Standard Time'],
    'America/Jamaica': ['EST', 'Eastern Standard Time'],
    'America/Cancun': ['EST', 'Eastern Standard Time'],

    // North America - Central Time (CST / CDT)
    'America/Chicago': ['CST', 'CDT', 'CT', 'Central Time', 'Central Standard Time', 'Central Daylight Time'],
    'America/Winnipeg': ['CST', 'CDT', 'CT', 'Central Time'],
    'America/Mexico_City': ['CST', 'Central Time', 'Central Standard Time'],
    'CST6CDT': ['CST', 'CDT', 'CT', 'Central Time'],

    // North America - Mountain Time (MST / MDT)
    'America/Denver': ['MST', 'MDT', 'MT', 'Mountain Time', 'Mountain Standard Time', 'Mountain Daylight Time'],
    'America/Phoenix': ['MST', 'Mountain Standard Time', 'Arizona Time'],
    'America/Edmonton': ['MST', 'MDT', 'MT', 'Mountain Time'],
    'MST7MDT': ['MST', 'MDT', 'MT', 'Mountain Time'],

    // North America - Pacific Time (PST / PDT)
    'America/Los_Angeles': ['PST', 'PDT', 'PT', 'Pacific Time', 'Pacific Standard Time', 'Pacific Daylight Time'],
    'America/Vancouver': ['PST', 'PDT', 'PT', 'Pacific Time'],
    'America/Tijuana': ['PST', 'PDT', 'PT', 'Pacific Time'],
    'PST8PDT': ['PST', 'PDT', 'PT', 'Pacific Time'],

    // Other North America
    'America/Anchorage': ['AKST', 'AKDT', 'Alaska Time', 'Alaska Standard Time'],
    'America/Juneau': ['AKST', 'AKDT', 'Alaska Time'],
    'Pacific/Honolulu': ['HST', 'Hawaii Time', 'Hawaii Standard Time'],
    'America/Halifax': ['AST', 'ADT', 'Atlantic Time', 'Atlantic Standard Time'],
    'America/Puerto_Rico': ['AST', 'Atlantic Standard Time'],
    'America/St_Johns': ['NST', 'NDT', 'Newfoundland Time'],

    // Asia - Indian Standard Time (IST)
    'Asia/Kolkata': ['IST', 'Indian Standard Time', 'India Time', 'IST Time'],
    'Asia/Calcutta': ['IST', 'Indian Standard Time', 'India Time', 'IST Time'],
    'Asia/Colombo': ['IST', 'Sri Lanka Time', 'Indian Standard Time'],

    // Asia - Other
    'Asia/Tokyo': ['JST', 'Japan Standard Time', 'Japan Time', 'Tokyo Time'],
    'Asia/Seoul': ['KST', 'Korea Standard Time', 'Korea Time'],
    'Asia/Shanghai': ['CST', 'China Standard Time', 'Beijing Time', 'China Time'],
    'Asia/Chongqing': ['CST', 'China Standard Time'],
    'Asia/Urumqi': ['CST', 'China Standard Time'],
    'Asia/Hong_Kong': ['HKT', 'Hong Kong Time'],
    'Asia/Taipei': ['CST', 'Taiwan Time', 'Taipei Time'],
    'Asia/Singapore': ['SGT', 'Singapore Time', 'Singapore Standard Time'],
    'Asia/Dubai': ['GST', 'Gulf Standard Time', 'UAE Time', 'Dubai Time'],
    'Asia/Muscat': ['GST', 'Gulf Standard Time', 'Oman Time'],
    'Asia/Karachi': ['PKT', 'Pakistan Standard Time'],
    'Asia/Dhaka': ['BST', 'Bangladesh Standard Time'],
    'Asia/Bangkok': ['ICT', 'Indochina Time', 'Thailand Time'],
    'Asia/Ho_Chi_Minh': ['ICT', 'Indochina Time', 'Vietnam Time'],
    'Asia/Jakarta': ['WIB', 'Western Indonesia Time', 'Jakarta Time'],
    'Asia/Makassar': ['WITA', 'Central Indonesia Time'],
    'Asia/Jayapura': ['WIT', 'Eastern Indonesia Time'],
    'Asia/Manila': ['PHT', 'Philippine Time', 'Philippine Standard Time'],
    'Asia/Jerusalem': ['IST', 'IDT', 'Israel Standard Time', 'Israel Time'],
    'Asia/Tel_Aviv': ['IST', 'IDT', 'Israel Standard Time'],
    'Asia/Riyadh': ['AST', 'Arabia Standard Time', 'Saudi Time'],
    'Asia/Kathmandu': ['NPT', 'Nepal Time'],
    'Asia/Kuala_Lumpur': ['MYT', 'Malaysia Time'],

    // Europe - GMT, BST, CET, CEST, EET, EEST, WET, MSK
    'Europe/London': ['GMT', 'BST', 'Greenwich Mean Time', 'British Summer Time', 'UK Time', 'London Time'],
    'Europe/Dublin': ['GMT', 'IST', 'Irish Standard Time', 'Dublin Time'],
    'Europe/Paris': ['CET', 'CEST', 'Central European Time', 'France Time', 'Paris Time'],
    'Europe/Berlin': ['CET', 'CEST', 'Central European Time', 'Germany Time', 'Berlin Time'],
    'Europe/Rome': ['CET', 'CEST', 'Central European Time', 'Italy Time', 'Rome Time'],
    'Europe/Madrid': ['CET', 'CEST', 'Central European Time', 'Spain Time', 'Madrid Time'],
    'Europe/Amsterdam': ['CET', 'CEST', 'Central European Time', 'Netherlands Time'],
    'Europe/Brussels': ['CET', 'CEST', 'Central European Time', 'Belgium Time'],
    'Europe/Vienna': ['CET', 'CEST', 'Central European Time', 'Austria Time'],
    'Europe/Warsaw': ['CET', 'CEST', 'Central European Time', 'Poland Time'],
    'Europe/Zurich': ['CET', 'CEST', 'Central European Time', 'Swiss Time'],
    'Europe/Stockholm': ['CET', 'CEST', 'Central European Time', 'Sweden Time'],
    'Europe/Oslo': ['CET', 'CEST', 'Central European Time', 'Norway Time'],
    'Europe/Copenhagen': ['CET', 'CEST', 'Central European Time', 'Denmark Time'],
    'Europe/Prague': ['CET', 'CEST', 'Central European Time', 'Czech Time'],
    'Europe/Budapest': ['CET', 'CEST', 'Central European Time', 'Hungary Time'],
    'Europe/Athens': ['EET', 'EEST', 'Eastern European Time', 'Greece Time'],
    'Europe/Bucharest': ['EET', 'EEST', 'Eastern European Time', 'Romania Time'],
    'Europe/Helsinki': ['EET', 'EEST', 'Eastern European Time', 'Finland Time'],
    'Europe/Kyiv': ['EET', 'EEST', 'Eastern European Time', 'Ukraine Time'],
    'Europe/Lisbon': ['WET', 'WEST', 'Western European Time', 'Portugal Time'],
    'Europe/Moscow': ['MSK', 'Moscow Standard Time', 'Moscow Time', 'Russia Time'],
    'Europe/Istanbul': ['TRT', 'Turkey Time', 'Istanbul Time'],

    // Australia & Pacific
    'Australia/Sydney': ['AEST', 'AEDT', 'AET', 'Australian Eastern Time', 'Sydney Time', 'EST'],
    'Australia/Melbourne': ['AEST', 'AEDT', 'AET', 'Australian Eastern Time', 'Melbourne Time'],
    'Australia/Brisbane': ['AEST', 'Australian Eastern Standard Time', 'Queensland Time'],
    'Australia/Adelaide': ['ACST', 'ACDT', 'ACT', 'Australian Central Time'],
    'Australia/Darwin': ['ACST', 'Australian Central Standard Time'],
    'Australia/Perth': ['AWST', 'Australian Western Time', 'Perth Time'],
    'Pacific/Auckland': ['NZST', 'NZDT', 'New Zealand Time', 'New Zealand Standard Time'],
    'Pacific/Fiji': ['FJT', 'Fiji Time'],
    'Pacific/Guam': ['ChST', 'Chamorro Standard Time'],

    // South America
    'America/Sao_Paulo': ['BRT', 'BRST', 'Brasilia Time', 'Brazil Time'],
    'America/Argentina/Buenos_Aires': ['ART', 'Argentina Time', 'Buenos Aires Time'],
    'America/Bogota': ['COT', 'Colombia Time'],
    'America/Lima': ['PET', 'Peru Time'],
    'America/Santiago': ['CLT', 'CLST', 'Chile Time'],
    'America/Caracas': ['VET', 'Venezuela Time'],

    // Africa
    'Africa/Cairo': ['EET', 'EEST', 'Egypt Time', 'Cairo Time'],
    'Africa/Johannesburg': ['SAST', 'South Africa Standard Time', 'South Africa Time'],
    'Africa/Nairobi': ['EAT', 'East Africa Time', 'Kenya Time'],
    'Africa/Lagos': ['WAT', 'West Africa Time', 'Nigeria Time'],
    'Africa/Harare': ['CAT', 'Central Africa Time'],

    // UTC / GMT
    'UTC': ['UTC', 'Coordinated Universal Time', 'Universal Time', 'Zulu', 'Z'],
    'GMT': ['GMT', 'Greenwich Mean Time', 'UTC'],
  };

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

        // Collect abbreviations from the location's current time & zone history
        final currentAbbr = tzNow.timeZoneName.trim();
        final aliasSet = <String>{};

        if (currentAbbr.isNotEmpty && RegExp(r'^[A-Za-z]{2,5}$').hasMatch(currentAbbr)) {
          aliasSet.add(currentAbbr);
        }

        for (final zone in location.zones) {
          final abbr = zone.abbreviation.trim();
          if (abbr.isNotEmpty && RegExp(r'^[A-Za-z]{2,5}$').hasMatch(abbr)) {
            aliasSet.add(abbr);
          }
        }

        // Add curated aliases and full names
        final customAliases = _knownAliases[id];
        if (customAliases != null) {
          aliasSet.addAll(customAliases);
        }

        // Determine best primary abbreviation
        String primaryAbbr = currentAbbr;
        if (primaryAbbr.isEmpty || !RegExp(r'^[A-Za-z]{2,5}$').hasMatch(primaryAbbr)) {
          if (customAliases != null && customAliases.isNotEmpty) {
            primaryAbbr = customAliases.first;
          } else if (aliasSet.isNotEmpty) {
            primaryAbbr = aliasSet.first;
          } else {
            primaryAbbr = '';
          }
        }

        final info = TimezoneInfo(
          id: id,
          city: city,
          region: region,
          offsetString: offsetString,
          offsetMinutes: offsetMinutes,
          abbreviation: primaryAbbr,
          aliases: aliasSet.toList(),
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
    return getTimezoneInfo('UTC') ??
        getTimezoneInfo('America/New_York') ??
        _allTimezones.first;
  }
}
