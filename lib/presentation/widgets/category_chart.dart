import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, int> categoryDistribution;

  const CategoryChart({
    super.key,
    required this.categoryDistribution,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (categoryDistribution.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No category data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final totalEntries = categoryDistribution.values.fold(0, (sum, count) => sum + count);
    final sortedCategories = categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Generate colors for categories
    final categoryColors = <String, Color>{};
    final baseColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    for (int i = 0; i < sortedCategories.length; i++) {
      categoryColors[sortedCategories[i].key] = baseColors[i % baseColors.length];
    }

    return Column(
      children: [
        // Horizontal bar chart
        ...sortedCategories.map((entry) {
          final category = entry.key;
          final count = entry.value;
          final percentage = (count / totalEntries * 100).round();
          final categoryColor = categoryColors[category]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(category),
                            size: 16,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              category,
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
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '$count ($percentage%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
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

        // Pie chart representation using circular indicators
        Container(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simple circular representation
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                      ),
                    ),
                    // Segments
                    ...sortedCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final categoryEntry = entry.value;
                      final category = categoryEntry.key;
                      final count = categoryEntry.value;
                      final percentage = count / totalEntries;
                      final categoryColor = categoryColors[category]!;

                      return Positioned(
                        top: 10 + (index * 15.0),
                        left: 10 + (index * 15.0),
                        child: Container(
                          width: 80 - (index * 30.0),
                          height: 80 - (index * 30.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: categoryColor,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.largePadding),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: sortedCategories.take(4).map((entry) {
                    final category = entry.key;
                    final count = entry.value;
                    final categoryColor = categoryColors[category]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$category ($count)',
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Summary
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.3),
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
                'Categories',
                categoryDistribution.length.toString(),
                Icons.category,
                theme,
              ),
              _buildSummaryItem(
                'Top',
                sortedCategories.first.key,
                _getCategoryIcon(sortedCategories.first.key),
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
          color: theme.colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.secondary,
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return Icons.person;
      case 'work':
        return Icons.work;
      case 'travel':
        return Icons.flight;
      case 'health':
        return Icons.health_and_safety;
      case 'relationships':
        return Icons.favorite;
      case 'goals':
        return Icons.flag;
      case 'memories':
        return Icons.photo_album;
      case 'thoughts':
        return Icons.psychology;
      default:
        return Icons.category;
    }
  }
}
