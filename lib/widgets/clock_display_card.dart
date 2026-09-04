import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockDisplayCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime dateTime;
  final bool is24Hour;
  final VoidCallback onTap;
  final Widget? trailingBadge;
  final Widget? bottomAction;
  final IconData headerIcon;
  final bool isCustom;
  final String? timezoneLabel;

  const ClockDisplayCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.is24Hour,
    required this.onTap,
    required this.headerIcon,
    this.trailingBadge,
    this.bottomAction,
    this.isCustom = false,
    this.timezoneLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Formatting time
    final String timeMain;
    final String? amPm;

    if (is24Hour) {
      timeMain = DateFormat('HH:mm:ss').format(dateTime);
      amPm = null;
    } else {
      timeMain = DateFormat('hh:mm:ss').format(dateTime);
      amPm = DateFormat('a').format(dateTime);
    }

    final dateString = DateFormat('EEEE, MMM d, yyyy').format(dateTime);

    return Card(
      elevation: isCustom ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isCustom
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isCustom ? 1.8 : 1,
        ),
      ),
      color: isCustom
          ? colorScheme.primaryContainer.withValues(alpha: 0.25)
          : colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCustom
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      headerIcon,
                      size: 20,
                      color: isCustom
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isCustom
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCustom && !title.toUpperCase().contains('CUSTOM')) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'CUSTOM',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (trailingBadge != null) ...[
                    const SizedBox(width: 8),
                    trailingBadge!,
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Time Display (Bold Large Text)
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeMain,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: isCustom
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (amPm != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          amPm,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Date & Location information
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      dateString,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (timezoneLabel != null) ...[
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.outline,
                        ),
                      ),
                      Text(
                        timezoneLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (bottomAction != null) ...[
                const SizedBox(height: 12),
                bottomAction!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
