class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final String? richContent; // For rich text formatting
  final DateTime createdAt;
  final DateTime updatedAt;
  final String mood;
  final String category;
  final List<String> tags;
  final int wordCount;
  final bool isFavorite;
  final bool isPrivate;
  final List<String> attachments; // For future image support
  final double? latitude;
  final double? longitude;
  final String? weather;

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    this.richContent,
    required this.createdAt,
    required this.updatedAt,
    required this.mood,
    required this.category,
    required this.tags,
    this.wordCount = 0,
    this.isFavorite = false,
    this.isPrivate = false,
    this.attachments = const [],
    this.latitude,
    this.longitude,
    this.weather,
  });

  DiaryEntry copyWith({
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
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      richContent: richContent ?? this.richContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      wordCount: wordCount ?? this.wordCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isPrivate: isPrivate ?? this.isPrivate,
      attachments: attachments ?? this.attachments,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weather: weather ?? this.weather,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryEntry &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.richContent == richContent &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.mood == mood &&
        other.category == category &&
        other.wordCount == wordCount &&
        other.isFavorite == isFavorite &&
        other.isPrivate == isPrivate &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.weather == weather &&
        _listEquals(other.tags, tags) &&
        _listEquals(other.attachments, attachments);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      richContent,
      createdAt,
      updatedAt,
      mood,
      category,
      wordCount,
      isFavorite,
      isPrivate,
      latitude,
      longitude,
      weather,
      Object.hashAll(tags),
      Object.hashAll(attachments),
    );
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, mood: $mood, category: $category, tags: $tags)';
  }
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}
