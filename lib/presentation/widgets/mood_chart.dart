import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/string_extensions.dart';

class MoodChart extends StatelessWidget {
  final Map<String, int> moodDistribution;

  const MoodChart({
    super.key,
    required this.moodDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (moodDistribution.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No mood data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final totalEntries = moodDistribution.values.fold(0, (sum, count) => sum + count);
    final sortedMoods = moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        // Horizontal bar chart
        ...sortedMoods.map((entry) {
          final mood = entry.key;
          final count = entry.value;
          final percentage = (count / totalEntries * 100).round();
          final moodColor = Color(AppConstants.moodColors[mood] ?? 0xFF808080);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Row(
                        children: [
                          Icon(
                            _getMoodIcon(mood),
                            size: 16,
                            color: moodColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              mood.capitalize(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    Expanded(
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: count / totalEntries,
                          child: Container(
                            decoration: BoxDecoration(
                              color: moodColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '$percentage%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: moodColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: AppConstants.defaultPadding),

        // Summary
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total',
                totalEntries.toString(),
                Icons.analytics,
                theme,
              ),
              _buildSummaryItem(
                'Moods',
                moodDistribution.length.toString(),
                Icons.psychology,
                theme,
              ),
              _buildSummaryItem(
                'Top',
                sortedMoods.first.key.capitalize(),
                _getMoodIcon(sortedMoods.first.key),
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'excited':
        return Icons.celebration;
      case 'calm':
        return Icons.self_improvement;
      case 'anxious':
        return Icons.psychology_alt;
      case 'grateful':
        return Icons.favorite;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
