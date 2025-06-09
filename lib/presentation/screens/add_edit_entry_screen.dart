import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/string_extensions.dart';
import '../../domain/entities/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../widgets/mood_selector.dart';
import '../widgets/category_selector.dart';
import '../widgets/tags_input.dart';

class AddEditEntryScreen extends StatefulWidget {
  final String? entryId;

  const AddEditEntryScreen({
    super.key,
    this.entryId,
  });

  @override
  State<AddEditEntryScreen> createState() => _AddEditEntryScreenState();
}

class _AddEditEntryScreenState extends State<AddEditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  String _selectedMood = 'neutral';
  String _selectedCategory = 'Personal';
  List<String> _tags = [];
  bool _isLoading = false;
  DiaryEntry? _existingEntry;

  bool get _isEditing => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingEntry();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _loadExistingEntry() {
    final diaryProvider = context.read<DiaryProvider>();
    _existingEntry = diaryProvider.getEntryById(widget.entryId!);
    
    if (_existingEntry != null) {
      _titleController.text = _existingEntry!.title;
      _contentController.text = _existingEntry!.content;
      _selectedMood = _existingEntry!.mood;
      _selectedCategory = _existingEntry!.category;
      _tags = List<String>.from(_existingEntry!.tags);
      _tagsController.text = _tags.join(', ');
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final content = _contentController.text.trim();
      final wordCount = content.wordCount;

      final entry = DiaryEntry(
        id: _existingEntry?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        content: content,
        createdAt: _existingEntry?.createdAt ?? now,
        updatedAt: now,
        mood: _selectedMood,
        category: _selectedCategory,
        tags: _tags,
        wordCount: wordCount,
        isFavorite: _existingEntry?.isFavorite ?? false,
        isPrivate: _existingEntry?.isPrivate ?? false,
        attachments: _existingEntry?.attachments ?? [],
      );

      final diaryProvider = context.read<DiaryProvider>();
      
      if (_isEditing) {
        await diaryProvider.updateEntry(entry);
      } else {
        await diaryProvider.addEntry(entry);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Entry updated!' : 'Entry saved!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          if (_isEditing && _existingEntry != null)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Entry Info'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Created: ${DateFormat(AppConstants.fullDateTimeFormat).format(_existingEntry!.createdAt)}'),
                        const SizedBox(height: 8),
                        Text('Updated: ${DateFormat(AppConstants.fullDateTimeFormat).format(_existingEntry!.updatedAt)}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Info'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What\'s on your mind?',
                ),
                style: theme.textTheme.titleMedium,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Content Field
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Write your thoughts here...',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Mood Selector
              Text(
                'Mood',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              MoodSelector(
                selectedMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() {
                    _selectedMood = mood;
                  });
                },
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Category Selector
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              CategorySelector(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Tags Input
              Text(
                'Tags',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              TagsInput(
                controller: _tagsController,
                tags: _tags,
                onTagsChanged: (tags) {
                  setState(() {
                    _tags = tags;
                  });
                },
              ),

              const SizedBox(height: AppConstants.largePadding * 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: AppConstants.defaultPadding,
          right: AppConstants.defaultPadding,
          bottom: MediaQuery.of(context).padding.bottom + AppConstants.defaultPadding,
          top: AppConstants.defaultPadding,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEntry,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
