import 'package:flutter/material.dart';
import 'app_logo.dart';

class HowItWorksSheet extends StatelessWidget {
  const HowItWorksSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const HowItWorksSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How Time Bridge Works',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Quick guide to features & controls',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),

            // Explanatory steps
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _FeatureStepCard(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: colorScheme.primary,
                    stepNumber: '1',
                    title: 'System Time (Top Clock)',
                    description:
                        'Displays your live device time in large, bold digits. Tapping the card opens the Material Time Picker to set a custom time.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureStepCard(
                    icon: Icons.timelapse_rounded,
                    iconColor: colorScheme.tertiary,
                    stepNumber: '2',
                    title: '12h / 24h Format Toggle',
                    description:
                        'Located right above the top clock. Switch instantly between standard 12-hour time (with AM/PM) and 24-hour military time.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureStepCard(
                    icon: Icons.restart_alt_rounded,
                    iconColor: colorScheme.error,
                    stepNumber: '3',
                    title: 'Custom Time & Reset',
                    description:
                        'When you set a custom time, the clock advances from that time and a "Reset to System Time" button appears below to restore live device time anytime.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureStepCard(
                    icon: Icons.public_rounded,
                    iconColor: colorScheme.secondary,
                    stepNumber: '4',
                    title: 'World Timezone (Bottom Clock)',
                    description:
                        'Shows the matching time in any global timezone. Tap it to browse or search hundreds of IANA world timezones with live previews.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureStepCard(
                    icon: Icons.swap_vert_rounded,
                    iconColor: colorScheme.primary,
                    stepNumber: '5',
                    title: 'Time Difference Indicator',
                    description:
                        'The center divider displays the exact hour and minute difference between your top clock and the selected world timezone.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureStepCard(
                    icon: Icons.brightness_auto_rounded,
                    iconColor: colorScheme.outline,
                    stepNumber: '6',
                    title: 'System Theme Integration',
                    description:
                        'The app automatically follows your device\'s system theme, transitioning smoothly between Light and Dark modes.',
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Got it, Let\'s Go!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FeatureStepCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String stepNumber;
  final String title;
  final String description;

  const _FeatureStepCard({
    required this.icon,
    required this.iconColor,
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
