import 'package:hive/hive.dart';
import '../../domain/entities/diary_entry.dart';

part 'diary_entry_model.g.dart';

@HiveType(typeId: 0)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String mood;

  @HiveField(6)
  String category;

  @HiveField(7)
  List<String> tags;

  @HiveField(8)
  String? richContent;

  @HiveField(9)
  int wordCount;

  @HiveField(10)
  bool isFavorite;

  @HiveField(11)
  bool isPrivate;

  @HiveField(12)
  List<String> attachments;

  @HiveField(13)
  double? latitude;

  @HiveField(14)
  double? longitude;

  @HiveField(15)
  String? weather;

  DiaryEntryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.mood,
    required this.category,
    required this.tags,
    this.richContent,
    this.wordCount = 0,
    this.isFavorite = false,
    this.isPrivate = false,
    this.attachments = const [],
    this.latitude,
    this.longitude,
    this.weather,
  });

  // Convert from domain entity
  factory DiaryEntryModel.fromEntity(DiaryEntry entry) {
    return DiaryEntryModel(
      id: entry.id,
      title: entry.title,
      content: entry.content,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      mood: entry.mood,
      category: entry.category,
      tags: List<String>.from(entry.tags),
      richContent: entry.richContent,
      wordCount: entry.wordCount,
      isFavorite: entry.isFavorite,
      isPrivate: entry.isPrivate,
      attachments: List<String>.from(entry.attachments),
      latitude: entry.latitude,
      longitude: entry.longitude,
      weather: entry.weather,
    );
  }

  // Convert to domain entity
  DiaryEntry toEntity() {
    return DiaryEntry(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      mood: mood,
      category: category,
      tags: List<String>.from(tags),
      richContent: richContent,
      wordCount: wordCount,
      isFavorite: isFavorite,
      isPrivate: isPrivate,
      attachments: List<String>.from(attachments),
      latitude: latitude,
      longitude: longitude,
      weather: weather,
    );
  }

  // Create a copy with updated fields
  DiaryEntryModel copyWith({
    String? id,
    String? title,
    String? content,
    String? richContent,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mood,
    String? category,
    List<String>? tags,
    int? wordCount,
    bool? isFavorite,
    bool? isPrivate,
    List<String>? attachments,
    double? latitude,
    double? longitude,
    String? weather,
  }) {
    return DiaryEntryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      richContent: richContent ?? this.richContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
      category: category ?? this.category,
      tags: tags ?? List<String>.from(this.tags),
      wordCount: wordCount ?? this.wordCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isPrivate: isPrivate ?? this.isPrivate,
      attachments: attachments ?? List<String>.from(this.attachments),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weather: weather ?? this.weather,
    );
  }

  @override
  String toString() {
    return 'DiaryEntryModel(id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, mood: $mood, category: $category, tags: $tags)';
  }
}
