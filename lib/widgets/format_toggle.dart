import 'package:flutter/material.dart';

class FormatToggle extends StatelessWidget {
  final bool is24Hour;
  final ValueChanged<bool> onChanged;

  const FormatToggle({
    super.key,
    required this.is24Hour,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment<bool>(
            value: false,
            label: Text('12h'),
            icon: Icon(Icons.wb_sunny_outlined, size: 16),
            tooltip: '12-hour format with AM/PM',
          ),
          ButtonSegment<bool>(
            value: true,
            label: Text('24h'),
            icon: Icon(Icons.timelapse_outlined, size: 16),
            tooltip: '24-hour military format',
          ),
        ],
        showSelectedIcon: false,
        selected: {is24Hour},
        onSelectionChanged: (newSelection) {
          if (newSelection.isNotEmpty) {
            onChanged(newSelection.first);
          }
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return colorScheme.onSurfaceVariant;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
