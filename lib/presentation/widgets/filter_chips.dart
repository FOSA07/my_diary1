import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/string_extensions.dart';

class FilterChips extends StatelessWidget {
  final List<String> categories;
  final List<String> moods;
  final String? selectedCategory;
  final String? selectedMood;
  final Function(String?) onCategorySelected;
  final Function(String?) onMoodSelected;

  const FilterChips({
    super.key,
    required this.categories,
    required this.moods,
    required this.selectedCategory,
    required this.selectedMood,
    required this.onCategorySelected,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categories.isEmpty && moods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        if (categories.isNotEmpty) ...[
          Text(
            'Categories',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All categories chip
                FilterChip(
                  label: const Text('All'),
                  selected: selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      onCategorySelected(null);
                    }
                  },
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                
                // Category chips
                ...categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.smallPadding),
                    child: FilterChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        onCategorySelected(selected ? category : null);
                      },
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.primary,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        // Spacing between categories and moods
        if (categories.isNotEmpty && moods.isNotEmpty)
          const SizedBox(height: AppConstants.defaultPadding),

        // Moods
        if (moods.isNotEmpty) ...[
          Text(
            'Moods',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All moods chip
                FilterChip(
                  label: const Text('All'),
                  selected: selectedMood == null,
                  onSelected: (selected) {
                    if (selected) {
                      onMoodSelected(null);
                    }
                  },
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.secondaryContainer,
                  checkmarkColor: colorScheme.secondary,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                
                // Mood chips
                ...moods.map((mood) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppConstants.smallPadding),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMoodIcon(mood),
                            size: 16,
                            color: selectedMood == mood
                                ? colorScheme.secondary
                                : Color(AppConstants.moodColors[mood] ?? 0xFF808080),
                          ),
                          const SizedBox(width: 4),
                          Text(mood.capitalize()),
                        ],
                      ),
                      selected: selectedMood == mood,
                      onSelected: (selected) {
                        onMoodSelected(selected ? mood : null);
                      },
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.secondaryContainer,
                      checkmarkColor: colorScheme.secondary,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
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
