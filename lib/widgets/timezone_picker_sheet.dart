import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/timezone_info.dart';
import '../services/timezone_service.dart';

class TimezonePickerSheet extends StatefulWidget {
  final TimezoneInfo selectedTimezone;
  final DateTime referenceTime;
  final bool is24Hour;

  const TimezonePickerSheet({
    super.key,
    required this.selectedTimezone,
    required this.referenceTime,
    required this.is24Hour,
  });

  static Future<TimezoneInfo?> show(
    BuildContext context, {
    required TimezoneInfo selectedTimezone,
    required DateTime referenceTime,
    required bool is24Hour,
  }) {
    return showModalBottomSheet<TimezoneInfo>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => TimezonePickerSheet(
        selectedTimezone: selectedTimezone,
        referenceTime: referenceTime,
        is24Hour: is24Hour,
      ),
    );
  }

  @override
  State<TimezonePickerSheet> createState() => _TimezonePickerSheetState();
}

class _TimezonePickerSheetState extends State<TimezonePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TimezoneService _service = TimezoneService();
  List<TimezoneInfo> _allTimezones = [];
  List<TimezoneInfo> _filteredTimezones = [];
  String _selectedRegionFilter = 'All';

  final List<String> _popularIds = [
    'UTC',
    'America/New_York',
    'America/Los_Angeles',
    'America/Chicago',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'Asia/Dubai',
    'Asia/Kolkata',
    'Asia/Singapore',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];

  @override
  void initState() {
    super.initState();
    _allTimezones = _service.getAllTimezones();
    _applyFilter();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredTimezones = _allTimezones.where((tz) {
        // Region filter
        if (_selectedRegionFilter == 'Popular') {
          if (!_popularIds.contains(tz.id)) return false;
        } else if (_selectedRegionFilter != 'All' &&
            !tz.region.toLowerCase().contains(_selectedRegionFilter.toLowerCase())) {
          return false;
        }

        // Search text filter
        if (query.isEmpty) return true;

        final matchesCity = tz.city.toLowerCase().contains(query);
        final matchesRegion = tz.region.toLowerCase().contains(query);
        final matchesId = tz.id.toLowerCase().contains(query);
        final matchesOffset = tz.offsetString.toLowerCase().contains(query);

        return matchesCity || matchesRegion || matchesId || matchesOffset;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final regions = ['All', 'Popular', 'Asia', 'America', 'Europe', 'Australia', 'Africa', 'Pacific'];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Title and count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.public, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Select Timezone',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filteredTimezones.length} zones',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search city, country, or offset (e.g. Tokyo, UTC+9)...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                ],
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Region filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: regions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final region = regions[index];
                  final isSelected = _selectedRegionFilter == region;
                  return FilterChip(
                    label: Text(region),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedRegionFilter = region;
                        _applyFilter();
                      });
                    },
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),

            // Timezone list
            Expanded(
              child: _filteredTimezones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No timezones match "${_searchController.text}"',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _filteredTimezones.length,
                      itemBuilder: (context, index) {
                        final tzItem = _filteredTimezones[index];
                        final isSelected = tzItem.id == widget.selectedTimezone.id;

                        // Preview time for this timezone
                        final convertedTime = _service.convertTime(
                          widget.referenceTime,
                          tzItem.id,
                        );
                        final previewFormat = widget.is24Hour ? 'HH:mm' : 'h:mm a';
                        final timeString = DateFormat(previewFormat).format(convertedTime);

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? colorScheme.primary
                                : colorScheme.surfaceContainerHighest,
                            foregroundColor: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            child: Icon(
                              isSelected ? Icons.check : Icons.access_time_rounded,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            tzItem.city,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '${tzItem.region} • ${tzItem.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                timeString,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tzItem.offsetString,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pop(tzItem);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
