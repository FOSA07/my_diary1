import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/string_extensions.dart';

class MoodSelector extends StatelessWidget {
  final String selectedMood;
  final Function(String) onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final moods = [
      {'name': 'happy', 'icon': Icons.sentiment_very_satisfied, 'label': 'Happy'},
      {'name': 'excited', 'icon': Icons.celebration, 'label': 'Excited'},
      {'name': 'grateful', 'icon': Icons.favorite, 'label': 'Grateful'},
      {'name': 'calm', 'icon': Icons.self_improvement, 'label': 'Calm'},
      {'name': 'neutral', 'icon': Icons.sentiment_neutral, 'label': 'Neutral'},
      {'name': 'anxious', 'icon': Icons.psychology_alt, 'label': 'Anxious'},
      {'name': 'sad', 'icon': Icons.sentiment_very_dissatisfied, 'label': 'Sad'},
      {'name': 'angry', 'icon': Icons.sentiment_dissatisfied, 'label': 'Angry'},
    ];

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          // Grid of mood options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: AppConstants.smallPadding,
              mainAxisSpacing: AppConstants.smallPadding,
            ),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final moodName = mood['name'] as String;
              final moodIcon = mood['icon'] as IconData;
              final moodLabel = mood['label'] as String;
              final isSelected = selectedMood == moodName;
              final moodColor = Color(AppConstants.moodColors[moodName] ?? 0xFF808080);

              return GestureDetector(
                onTap: () => onMoodSelected(moodName),
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? moodColor.withOpacity(0.2)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: isSelected
                          ? moodColor
                          : colorScheme.outline.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        moodIcon,
                        color: isSelected ? moodColor : colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected ? moodColor : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Selected mood display
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
            decoration: BoxDecoration(
              color: Color(AppConstants.moodColors[selectedMood] ?? 0xFF808080)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getMoodIcon(selectedMood),
                  color: Color(AppConstants.moodColors[selectedMood] ?? 0xFF808080),
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'Feeling ${selectedMood.capitalize()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Color(AppConstants.moodColors[selectedMood] ?? 0xFF808080),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
