import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/local_data_source.dart';
import '../models/diary_entry_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final LocalDataSource localDataSource;

  DiaryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    try {
      final models = await localDataSource.getAllEntries();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all entries: $e');
    }
  }

  @override
  Future<DiaryEntry?> getEntryById(String id) async {
    try {
      final model = await localDataSource.getEntryById(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get entry by ID: $e');
    }
  }

  @override
  Future<void> addEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      await localDataSource.addEntry(model);
    } catch (e) {
      throw Exception('Failed to add entry: $e');
    }
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      await localDataSource.updateEntry(model);
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  @override
  Future<List<DiaryEntry>> searchEntries(String query) async {
    try {
      final models = await localDataSource.searchEntries(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search entries: $e');
    }
  }

  @override
  Future<List<DiaryEntry>> getEntriesByCategory(String category) async {
    try {
      final models = await localDataSource.getEntriesByCategory(category);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get entries by category: $e');
    }
  }

  @override
  Future<List<DiaryEntry>> getEntriesByMood(String mood) async {
    try {
      final models = await localDataSource.getEntriesByMood(mood);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get entries by mood: $e');
    }
  }

  @override
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    try {
      final models = await localDataSource.getEntriesByDateRange(start, end);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get entries by date range: $e');
    }
  }

  @override
  Future<List<DiaryEntry>> getEntriesByTags(List<String> tags) async {
    try {
      final models = await localDataSource.getEntriesByTags(tags);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get entries by tags: $e');
    }
  }
}
