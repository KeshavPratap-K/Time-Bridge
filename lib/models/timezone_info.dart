class TimezoneInfo {
  final String id;
  final String city;
  final String region;
  final String offsetString;
  final int offsetMinutes;

  const TimezoneInfo({
    required this.id,
    required this.city,
    required this.region,
    required this.offsetString,
    required this.offsetMinutes,
  });

  /// Formats offset minutes into "+HH:mm" or "-HH:mm" format.
  static String formatOffset(int offsetMinutes) {
    final sign = offsetMinutes >= 0 ? '+' : '-';
    final totalMinutes = offsetMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  /// Parses a timezone ID into human-readable city and region.
  static (String city, String region) parseId(String id) {
    if (id == 'UTC' || id == 'GMT') {
      return (id, 'Standard Time');
    }
    final parts = id.split('/');
    if (parts.length >= 2) {
      final region = parts.first.replaceAll('_', ' ');
      final city = parts.sublist(1).join(' / ').replaceAll('_', ' ');
      return (city, region);
    }
    return (id.replaceAll('_', ' '), 'General');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimezoneInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$city ($offsetString)';
}
