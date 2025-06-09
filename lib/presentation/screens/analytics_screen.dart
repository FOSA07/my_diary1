import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/string_extensions.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_card.dart';
import '../widgets/mood_chart.dart';
import '../widgets/category_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, child) {
          if (analyticsProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (analyticsProvider.totalEntries == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'No Data Yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Start writing entries to see your analytics',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => analyticsProvider.loadEntries(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Cards
                  Text(
                    'Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  Row(
                    children: [
                      Expanded(
                        child: AnalyticsCard(
                          title: 'Total Entries',
                          value: analyticsProvider.totalEntries.toString(),
                          icon: Icons.book,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: AnalyticsCard(
                          title: 'Writing Streak',
                          value: '${analyticsProvider.currentWritingStreak} days',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  Row(
                    children: [
                      Expanded(
                        child: AnalyticsCard(
                          title: 'Total Words',
                          value: NumberFormat('#,###').format(analyticsProvider.totalWords),
                          icon: Icons.text_fields,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: AnalyticsCard(
                          title: 'This Month',
                          value: analyticsProvider.entriesThisMonth.toString(),
                          icon: Icons.calendar_month,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Mood Analysis
                  Text(
                    'Mood Analysis',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getMoodIcon(analyticsProvider.mostCommonMood),
                              color: Color(AppConstants.moodColors[analyticsProvider.mostCommonMood] ?? 0xFF808080),
                            ),
                            const SizedBox(width: AppConstants.smallPadding),
                            Text(
                              'Most Common: ${analyticsProvider.mostCommonMood.capitalize()}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        MoodChart(moodDistribution: analyticsProvider.moodDistribution),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Category Analysis
                  Text(
                    'Category Breakdown',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(analyticsProvider.mostUsedCategory),
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: AppConstants.smallPadding),
                            Text(
                              'Most Used: ${analyticsProvider.mostUsedCategory}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        CategoryChart(categoryDistribution: analyticsProvider.categoryDistribution),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Writing Habits
                  Text(
                    'Writing Habits',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Average words per entry',
                          '${analyticsProvider.averageWordsPerEntry.toStringAsFixed(0)} words',
                          Icons.text_snippet,
                          theme,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Most productive day',
                          analyticsProvider.mostProductiveDayOfWeek,
                          Icons.calendar_today,
                          theme,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Longest writing streak',
                          '${analyticsProvider.longestWritingStreak} days',
                          Icons.trending_up,
                          theme,
                        ),
                        const Divider(),
                        _buildStatRow(
                          'Favorite entries',
                          '${analyticsProvider.favoriteEntries.length}',
                          Icons.favorite,
                          theme,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Popular Tags
                  if (analyticsProvider.mostUsedTags.isNotEmpty) ...[
                    Text(
                      'Popular Tags',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    Container(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: Wrap(
                        spacing: AppConstants.smallPadding,
                        runSpacing: AppConstants.smallPadding,
                        children: analyticsProvider.mostUsedTags.take(10).map((tagUsage) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.defaultPadding,
                              vertical: AppConstants.smallPadding,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#${tagUsage.tag}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${tagUsage.count}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.largePadding),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
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
