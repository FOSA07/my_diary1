import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../providers/diary_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_entry_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
            tooltip: 'Analytics',
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.themeIcon),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: 'Theme: ${themeProvider.themeModeName}',
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
                case 'clear_filters':
                  context.read<DiaryProvider>().clearFilters();
                  break;
                case 'refresh':
                  context.read<DiaryProvider>().loadEntries();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear_filters',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear Filters'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (diaryProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diaryProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => diaryProvider.loadEntries(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    SearchBarWidget(
                      onSearch: (query) => diaryProvider.searchEntries(query),
                      initialValue: diaryProvider.searchQuery,
                    ),
                    const SizedBox(height: 12),
                    FilterChips(
                      categories: diaryProvider.availableCategories,
                      moods: diaryProvider.availableMoods,
                      selectedCategory: diaryProvider.selectedCategory,
                      selectedMood: diaryProvider.selectedMood,
                      onCategorySelected: (category) =>
                          diaryProvider.filterByCategory(category),
                      onMoodSelected: (mood) =>
                          diaryProvider.filterByMood(mood),
                    ),
                  ],
                ),
              ),

              // Entries List
              Expanded(
                child: diaryProvider.entries.isEmpty
                    ? EmptyStateWidget(
                        hasFilters: diaryProvider.searchQuery.isNotEmpty ||
                            diaryProvider.selectedCategory != null ||
                            diaryProvider.selectedMood != null,
                        onClearFilters: () => diaryProvider.clearFilters(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => diaryProvider.loadEntries(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppConstants.defaultPadding),
                          itemCount: diaryProvider.entries.length,
                          itemBuilder: (context, index) {
                            final entry = diaryProvider.entries[index];
                            return DiaryEntryCard(
                              entry: entry,
                              onTap: () => _navigateToEditEntry(entry.id),
                              onDelete: () => _showDeleteDialog(entry.id),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddEntry,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  void _navigateToAddEntry() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditEntryScreen(),
      ),
    );
  }

  void _navigateToEditEntry(String entryId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditEntryScreen(entryId: entryId),
      ),
    );
  }

  void _showDeleteDialog(String entryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DiaryProvider>().deleteEntry(entryId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
