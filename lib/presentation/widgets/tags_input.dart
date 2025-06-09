import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class TagsInput extends StatefulWidget {
  final TextEditingController controller;
  final List<String> tags;
  final Function(List<String>) onTagsChanged;

  const TagsInput({
    super.key,
    required this.controller,
    required this.tags,
    required this.onTagsChanged,
  });

  @override
  State<TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends State<TagsInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isNotEmpty && !widget.tags.contains(trimmedTag)) {
      final newTags = [...widget.tags, trimmedTag];
      widget.onTagsChanged(newTags);
      widget.controller.text = newTags.join(', ');
    }
  }

  void _removeTag(String tag) {
    final newTags = widget.tags.where((t) => t != tag).toList();
    widget.onTagsChanged(newTags);
    widget.controller.text = newTags.join(', ');
  }

  void _onTextChanged(String text) {
    final tags = text
        .split(',')
        .map((tag) => tag.trim().toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    
    if (tags.length != widget.tags.length || 
        !tags.every((tag) => widget.tags.contains(tag))) {
      widget.onTagsChanged(tags);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags input field
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Tags (comma separated)',
              hintText: 'e.g., work, meeting, important',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final text = widget.controller.text;
                  if (text.isNotEmpty) {
                    final lastTag = text.split(',').last.trim();
                    if (lastTag.isNotEmpty) {
                      _addTag(lastTag);
                    }
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surface,
            ),
            onChanged: _onTextChanged,
            onFieldSubmitted: (value) {
              if (value.isNotEmpty) {
                final lastTag = value.split(',').last.trim();
                if (lastTag.isNotEmpty) {
                  _addTag(lastTag);
                }
              }
            },
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Current tags display
          if (widget.tags.isNotEmpty) ...[
            Text(
              'Current Tags:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Wrap(
              spacing: AppConstants.smallPadding,
              runSpacing: AppConstants.smallPadding,
              children: widget.tags.map((tag) {
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
                      Icon(
                        Icons.tag,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Text(
                      'Add tags to help organize and find your entries later',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppConstants.defaultPadding),

          // Suggested tags (common tags)
          Text(
            'Suggested Tags:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Wrap(
            spacing: AppConstants.smallPadding,
            runSpacing: AppConstants.smallPadding,
            children: _getSuggestedTags().map((tag) {
              final isAlreadyAdded = widget.tags.contains(tag);
              
              return GestureDetector(
                onTap: isAlreadyAdded ? null : () => _addTag(tag),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                  decoration: BoxDecoration(
                    color: isAlreadyAdded
                        ? colorScheme.surfaceVariant.withOpacity(0.5)
                        : colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAlreadyAdded
                          ? colorScheme.outline.withOpacity(0.2)
                          : colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isAlreadyAdded
                          ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                          : colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getSuggestedTags() {
    return [
      'important',
      'work',
      'personal',
      'family',
      'friends',
      'travel',
      'food',
      'exercise',
      'learning',
      'goals',
      'reflection',
      'gratitude',
    ];
  }
}
