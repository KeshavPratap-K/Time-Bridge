import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timezone_info.dart';
import '../services/timezone_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/clock_display_card.dart';
import '../widgets/format_toggle.dart';
import '../widgets/how_it_works_sheet.dart';
import '../widgets/timezone_picker_sheet.dart';

class DualClockScreen extends StatefulWidget {
  const DualClockScreen({super.key});

  @override
  State<DualClockScreen> createState() => _DualClockScreenState();
}

class _DualClockScreenState extends State<DualClockScreen> {
  final TimezoneService _timezoneService = TimezoneService();
  Timer? _tickerTimer;

  bool _is24Hour = false;
  bool _isCustomTime = false;
  Duration _customTimeOffset = Duration.zero;

  late TimezoneInfo _selectedTimezone;
  final List<TimezoneInfo> _recentTimezones = [];

  DateTime get _now => DateTime.now();

  /// Effective top clock time (either live system time or custom time with offset)
  DateTime get _topTime {
    if (_isCustomTime) {
      return _now.add(_customTimeOffset);
    }
    return _now;
  }

  /// Bottom clock time converted to the selected timezone
  DateTime get _bottomTime {
    return _timezoneService.convertTime(_topTime, _selectedTimezone.id);
  }

  @override
  void initState() {
    super.initState();
    _timezoneService.init();
    _selectedTimezone = _timezoneService.getDefaultSecondaryTimezone();
    _recentTimezones.add(_selectedTimezone);

    // Populate initial popular recent timezones up to 5
    const initialPopular = [
      'Asia/Tokyo',
      'Europe/London',
      'America/New_York',
      'Asia/Kolkata',
      'Australia/Sydney',
    ];
    for (final id in initialPopular) {
      if (_recentTimezones.length >= 5) break;
      final info = _timezoneService.getTimezoneInfo(id);
      if (info != null && !_recentTimezones.any((tz) => tz.id == info.id)) {
        _recentTimezones.add(info);
      }
    }

    // Tick every second to update clocks live
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _selectTimezone(TimezoneInfo timezone) {
    setState(() {
      _selectedTimezone = timezone;
      _recentTimezones.removeWhere((item) => item.id == timezone.id);
      _recentTimezones.insert(0, timezone);
      if (_recentTimezones.length > 5) {
        _recentTimezones.removeLast();
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  /// Open Material Time Picker popup to customize top clock time
  Future<void> _pickCustomTime() async {
    final current = _topTime;
    final initialTime = TimeOfDay(hour: current.hour, minute: current.minute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'SET SYSTEM TIME OVERRIDE',
      confirmText: 'SET TIME',
      cancelText: 'CANCEL',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: _is24Hour),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final customDateTime = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
        0,
      );

      setState(() {
        _isCustomTime = true;
        _customTimeOffset = customDateTime.difference(_now);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Time adjusted to ${_is24Hour ? "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}" : picked.format(context)}',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Reset back to real system time
  void _resetToSystemTime() {
    setState(() {
      _isCustomTime = false;
      _customTimeOffset = Duration.zero;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Restored live system time'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Open modal bottom sheet to select from all available timezones
  Future<void> _openTimezonePicker() async {
    final selected = await TimezonePickerSheet.show(
      context,
      selectedTimezone: _selectedTimezone,
      referenceTime: _topTime,
      is24Hour: _is24Hour,
    );

    if (selected != null && mounted) {
      _selectTimezone(selected);
    }
  }

  /// Formats the time difference string between top and bottom clocks
  String _getTimeDifferenceString() {
    final diffMinutes = _bottomTime.difference(_topTime).inMinutes;
    if (diffMinutes == 0) return 'Same time';
    final sign = diffMinutes > 0 ? '+' : '-';
    final hours = (diffMinutes.abs() ~/ 60);
    final minutes = (diffMinutes.abs() % 60);
    if (minutes == 0) {
      return '$sign${hours}h from system';
    }
    return '$sign${hours}h ${minutes}m from system';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final topDateTime = _topTime;
    final bottomDateTime = _bottomTime;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 24),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Time Bridge',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'How Time Bridge works',
            onPressed: () => HowItWorksSheet.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Small toggle above top clock to switch between 12/24 hrs format
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Time Format',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FormatToggle(
                    is24Hour: _is24Hour,
                    onChanged: (val) {
                      setState(() {
                        _is24Hour = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Top Row: System time fetched from system in bold large text
              // Edit enabled on click using Material time picker
              ClockDisplayCard(
                title: _isCustomTime ? 'CUSTOM SYSTEM TIME' : 'SYSTEM LOCAL TIME',
                subtitle: 'Tap to edit time with Material picker',
                headerIcon: _isCustomTime ? Icons.edit_calendar_rounded : Icons.access_time_filled,
                dateTime: topDateTime,
                is24Hour: _is24Hour,
                isCustom: _isCustomTime,
                timezoneLabel: 'Local / Device',
                trailingBadge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: _pickCustomTime,
              ),

              // Reset button displayed below if custom time is entered
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _isCustomTime
                    ? Padding(
                        key: const ValueKey('reset_button_container'),
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: FilledButton.tonalIcon(
                            onPressed: _resetToSystemTime,
                            icon: const Icon(Icons.restart_alt_rounded, size: 18),
                            label: const Text('Reset to System Time'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.onErrorContainer,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('no_reset_button')),
              ),

              const SizedBox(height: 20),

              // 3. Middle: Divider with time difference indicator
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_vert_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getTimeDifferenceString(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // 4. Bottom Row: Another clock of same size, clickable to open timezone modal
              ClockDisplayCard(
                title: _selectedTimezone.city.toUpperCase(),
                subtitle: '${_selectedTimezone.region} • Tap to change timezone',
                headerIcon: Icons.public_rounded,
                dateTime: bottomDateTime,
                is24Hour: _is24Hour,
                timezoneLabel: '${_selectedTimezone.id} (${_selectedTimezone.offsetString})',
                trailingBadge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedTimezone.offsetString,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
                onTap: _openTimezonePicker,
              ),

              const SizedBox(height: 24),

              // Recent Timezones (Last 5 selected)
              if (_recentTimezones.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Recent Timezones',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to switch',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._recentTimezones.take(5).map((tz) {
                          final isCurrent = tz.id == _selectedTimezone.id;
                          final tzTime = _timezoneService.convertTime(_topTime, tz.id);
                          final timeStr = DateFormat(
                            _is24Hour ? 'HH:mm' : 'h:mm a',
                          ).format(tzTime);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Material(
                              color: isCurrent
                                  ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => _selectTimezone(tz),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCurrent
                                            ? Icons.check_circle_rounded
                                            : Icons.schedule_rounded,
                                        size: 16,
                                        color: isCurrent
                                            ? colorScheme.primary
                                            : colorScheme.outline,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tz.city,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: isCurrent
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: isCurrent
                                                    ? colorScheme.primary
                                                    : colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${tz.region} • ${tz.offsetString}',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeStr,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent
                                              ? colorScheme.primary
                                              : colorScheme.onSurface,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
