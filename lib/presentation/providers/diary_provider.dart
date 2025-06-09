import 'package:flutter/material.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';

class DiaryProvider extends ChangeNotifier {
  final DiaryRepository repository;

  DiaryProvider({required this.repository}) {
    loadEntries();
  }

  List<DiaryEntry> _entries = [];
  List<DiaryEntry> _filteredEntries = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedMood;

  // Getters
  List<DiaryEntry> get entries => _filteredEntries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedMood => _selectedMood;
  bool get hasEntries => _entries.isNotEmpty;
  int get totalEntries => _entries.length;

  // Load all entries
  Future<void> loadEntries() async {
    _setLoading(true);
    _setError(null);

    try {
      _entries = await repository.getAllEntries();
      _applyFilters();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add new entry
  Future<void> addEntry(DiaryEntry entry) async {
    _setLoading(true);
    _setError(null);

    try {
      await repository.addEntry(entry);
      await loadEntries(); // Reload to get updated list
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update existing entry
  Future<void> updateEntry(DiaryEntry entry) async {
    _setLoading(true);
    _setError(null);

    try {
      await repository.updateEntry(entry);
      await loadEntries(); // Reload to get updated list
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Delete entry
  Future<void> deleteEntry(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await repository.deleteEntry(id);
      await loadEntries(); // Reload to get updated list
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get entry by ID
  DiaryEntry? getEntryById(String id) {
    try {
      return _entries.firstWhere((entry) => entry.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search entries
  void searchEntries(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Filter by mood
  void filterByMood(String? mood) {
    _selectedMood = mood;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedMood = null;
    _applyFilters();
    notifyListeners();
  }

  // Get entries by date range
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    try {
      return await repository.getEntriesByDateRange(start, end);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get unique categories from all entries
  List<String> get availableCategories {
    final categories = _entries.map((entry) => entry.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get unique moods from all entries
  List<String> get availableMoods {
    final moods = _entries.map((entry) => entry.mood).toSet().toList();
    moods.sort();
    return moods;
  }

  // Get unique tags from all entries
  List<String> get availableTags {
    final tags = <String>{};
    for (final entry in _entries) {
      tags.addAll(entry.tags);
    }
    final tagList = tags.toList();
    tagList.sort();
    return tagList;
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEntries = _entries.where((entry) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch = entry.title.toLowerCase().contains(query) ||
            entry.content.toLowerCase().contains(query) ||
            entry.tags.any((tag) => tag.toLowerCase().contains(query));
        if (!matchesSearch) return false;
      }

      // Category filter
      if (_selectedCategory != null && entry.category != _selectedCategory) {
        return false;
      }

      // Mood filter
      if (_selectedMood != null && entry.mood != _selectedMood) {
        return false;
      }

      return true;
    }).toList();
  }
}
