import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../models/diary_entry_model.dart';

class LocalDataSource {
  Box<DiaryEntryModel> get _box => Hive.box<DiaryEntryModel>(AppConstants.diaryBox);

  /// Get all diary entries from local storage
  Future<List<DiaryEntryModel>> getAllEntries() async {
    try {
      final entries = _box.values.toList();
      // Sort by creation date (newest first)
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (e) {
      throw Exception('Failed to get entries: $e');
    }
  }

  /// Get diary entry by ID
  Future<DiaryEntryModel?> getEntryById(String id) async {
    try {
      return _box.values.firstWhere(
        (entry) => entry.id == id,
        orElse: () => throw StateError('Entry not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Add a new diary entry
  Future<void> addEntry(DiaryEntryModel entry) async {
    try {
      await _box.add(entry);
    } catch (e) {
      throw Exception('Failed to add entry: $e');
    }
  }

  /// Update an existing diary entry
  Future<void> updateEntry(DiaryEntryModel entry) async {
    try {
      final index = _box.values.toList().indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        await _box.putAt(index, entry);
      } else {
        throw Exception('Entry not found');
      }
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  /// Delete a diary entry
  Future<void> deleteEntry(String id) async {
    try {
      final index = _box.values.toList().indexWhere((e) => e.id == id);
      if (index != -1) {
        await _box.deleteAt(index);
      } else {
        throw Exception('Entry not found');
      }
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  /// Search entries by title or content
  Future<List<DiaryEntryModel>> searchEntries(String query) async {
    try {
      final allEntries = await getAllEntries();
      final lowercaseQuery = query.toLowerCase();
      
      return allEntries.where((entry) {
        return entry.title.toLowerCase().contains(lowercaseQuery) ||
               entry.content.toLowerCase().contains(lowercaseQuery) ||
               entry.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search entries: $e');
    }
  }

  /// Get entries by category
  Future<List<DiaryEntryModel>> getEntriesByCategory(String category) async {
    try {
      final allEntries = await getAllEntries();
      return allEntries.where((entry) => entry.category == category).toList();
    } catch (e) {
      throw Exception('Failed to get entries by category: $e');
    }
  }

  /// Get entries by mood
  Future<List<DiaryEntryModel>> getEntriesByMood(String mood) async {
    try {
      final allEntries = await getAllEntries();
      return allEntries.where((entry) => entry.mood == mood).toList();
    } catch (e) {
      throw Exception('Failed to get entries by mood: $e');
    }
  }

  /// Get entries by date range
  Future<List<DiaryEntryModel>> getEntriesByDateRange(DateTime start, DateTime end) async {
    try {
      final allEntries = await getAllEntries();
      return allEntries.where((entry) {
        return entry.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
               entry.createdAt.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get entries by date range: $e');
    }
  }

  /// Get entries with specific tags
  Future<List<DiaryEntryModel>> getEntriesByTags(List<String> tags) async {
    try {
      final allEntries = await getAllEntries();
      return allEntries.where((entry) {
        return tags.any((tag) => entry.tags.contains(tag));
      }).toList();
    } catch (e) {
      throw Exception('Failed to get entries by tags: $e');
    }
  }
}
