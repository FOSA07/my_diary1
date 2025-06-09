import '../entities/diary_entry.dart';

abstract class DiaryRepository {
  /// Get all diary entries
  Future<List<DiaryEntry>> getAllEntries();

  /// Get diary entry by ID
  Future<DiaryEntry?> getEntryById(String id);

  /// Add a new diary entry
  Future<void> addEntry(DiaryEntry entry);

  /// Update an existing diary entry
  Future<void> updateEntry(DiaryEntry entry);

  /// Delete a diary entry
  Future<void> deleteEntry(String id);

  /// Search entries by title or content
  Future<List<DiaryEntry>> searchEntries(String query);

  /// Get entries by category
  Future<List<DiaryEntry>> getEntriesByCategory(String category);

  /// Get entries by mood
  Future<List<DiaryEntry>> getEntriesByMood(String mood);

  /// Get entries by date range
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end);

  /// Get entries with specific tags
  Future<List<DiaryEntry>> getEntriesByTags(List<String> tags);
}
