import 'package:flutter/material.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  final DiaryRepository repository;

  AnalyticsProvider({required this.repository});

  List<DiaryEntry> _entries = [];
  bool _isLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  List<DiaryEntry> get entries => _entries;

  // Load entries for analytics
  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await repository.getAllEntries();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Total entries count
  int get totalEntries => _entries.length;

  // Total words written
  int get totalWords => _entries.fold(0, (sum, entry) => sum + entry.wordCount);

  // Average words per entry
  double get averageWordsPerEntry {
    if (_entries.isEmpty) return 0;
    return totalWords / _entries.length;
  }

  // Writing streak (consecutive days with entries)
  int get currentWritingStreak {
    if (_entries.isEmpty) return 0;

    final sortedEntries = List<DiaryEntry>.from(_entries)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final entry in sortedEntries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      
      final checkDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (entryDate == checkDate || entryDate == checkDate.subtract(const Duration(days: 1))) {
        streak++;
        currentDate = entryDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  // Longest writing streak
  int get longestWritingStreak {
    if (_entries.isEmpty) return 0;

    final entriesByDate = <DateTime, List<DiaryEntry>>{};
    
    for (final entry in _entries) {
      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      
      if (entriesByDate[date] == null) {
        entriesByDate[date] = [];
      }
      entriesByDate[date]!.add(entry);
    }

    final sortedDates = entriesByDate.keys.toList()
      ..sort();

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? previousDate;

    for (final date in sortedDates) {
      if (previousDate == null || date.difference(previousDate).inDays == 1) {
        currentStreak++;
      } else {
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
        currentStreak = 1;
      }
      previousDate = date;
    }

    return maxStreak > currentStreak ? maxStreak : currentStreak;
  }

  // Mood distribution
  Map<String, int> get moodDistribution {
    final distribution = <String, int>{};
    
    for (final entry in _entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    
    return distribution;
  }

  // Most common mood
  String get mostCommonMood {
    if (_entries.isEmpty) return 'neutral';
    
    final distribution = moodDistribution;
    String mostCommon = 'neutral';
    int maxCount = 0;
    
    distribution.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = mood;
      }
    });
    
    return mostCommon;
  }

  // Category distribution
  Map<String, int> get categoryDistribution {
    final distribution = <String, int>{};
    
    for (final entry in _entries) {
      distribution[entry.category] = (distribution[entry.category] ?? 0) + 1;
    }
    
    return distribution;
  }

  // Most used category
  String get mostUsedCategory {
    if (_entries.isEmpty) return 'Personal';
    
    final distribution = categoryDistribution;
    String mostUsed = 'Personal';
    int maxCount = 0;
    
    distribution.forEach((category, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = category;
      }
    });
    
    return mostUsed;
  }

  // Entries this week
  int get entriesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return _entries.where((entry) {
      return entry.createdAt.isAfter(weekStart) && 
             entry.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;
  }

  // Entries this month
  int get entriesThisMonth {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _entries.where((entry) {
      return entry.createdAt.isAfter(monthStart.subtract(const Duration(days: 1))) && 
             entry.createdAt.isBefore(monthEnd.add(const Duration(days: 1)));
    }).length;
  }

  // Writing activity by day of week
  Map<int, int> get writingActivityByDayOfWeek {
    final activity = <int, int>{
      1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0
    };
    
    for (final entry in _entries) {
      activity[entry.createdAt.weekday] = (activity[entry.createdAt.weekday] ?? 0) + 1;
    }
    
    return activity;
  }

  // Most productive day of week
  String get mostProductiveDayOfWeek {
    final activity = writingActivityByDayOfWeek;
    int mostProductiveDay = 1;
    int maxEntries = 0;
    
    activity.forEach((day, count) {
      if (count > maxEntries) {
        maxEntries = count;
        mostProductiveDay = day;
      }
    });
    
    const dayNames = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return dayNames[mostProductiveDay];
  }

  // Mood trends over time (last 30 days)
  List<MoodDataPoint> get moodTrends {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentEntries = _entries.where((entry) {
      return entry.createdAt.isAfter(thirtyDaysAgo);
    }).toList();
    
    recentEntries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final trends = <MoodDataPoint>[];
    
    for (final entry in recentEntries) {
      trends.add(MoodDataPoint(
        date: entry.createdAt,
        mood: entry.mood,
        moodScore: _getMoodScore(entry.mood),
      ));
    }
    
    return trends;
  }

  // Convert mood to numerical score for trending
  double _getMoodScore(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 5.0;
      case 'excited':
        return 4.5;
      case 'grateful':
        return 4.0;
      case 'calm':
        return 3.5;
      case 'neutral':
        return 3.0;
      case 'anxious':
        return 2.5;
      case 'sad':
        return 2.0;
      case 'angry':
        return 1.5;
      default:
        return 3.0;
    }
  }

  // Get favorite entries (marked as favorite)
  List<DiaryEntry> get favoriteEntries {
    return _entries.where((entry) => entry.isFavorite).toList();
  }

  // Get private entries count
  int get privateEntriesCount {
    return _entries.where((entry) => entry.isPrivate).length;
  }

  // Most used tags
  List<TagUsage> get mostUsedTags {
    final tagCounts = <String, int>{};
    
    for (final entry in _entries) {
      for (final tag in entry.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    final tagUsage = tagCounts.entries
        .map((entry) => TagUsage(tag: entry.key, count: entry.value))
        .toList();
    
    tagUsage.sort((a, b) => b.count.compareTo(a.count));
    
    return tagUsage.take(10).toList();
  }
}

// Data classes for analytics
class MoodDataPoint {
  final DateTime date;
  final String mood;
  final double moodScore;

  MoodDataPoint({
    required this.date,
    required this.mood,
    required this.moodScore,
  });
}

class TagUsage {
  final String tag;
  final int count;

  TagUsage({
    required this.tag,
    required this.count,
  });
}
