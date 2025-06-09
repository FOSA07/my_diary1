class AppConstants {
  // Database
  static const String diaryBox = 'diary_box';
  
  // App Info
  static const String appName = 'My Diary';
  static const String appVersion = '1.0.0';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Mood Colors
  static const Map<String, int> moodColors = {
    'happy': 0xFFFFD700,
    'sad': 0xFF4169E1,
    'angry': 0xFFDC143C,
    'excited': 0xFFFF6347,
    'calm': 0xFF98FB98,
    'anxious': 0xFFDDA0DD,
    'grateful': 0xFFFFB6C1,
    'neutral': 0xFF808080,
  };
  
  // Categories
  static const List<String> categories = [
    'Personal',
    'Work',
    'Travel',
    'Health',
    'Relationships',
    'Goals',
    'Memories',
    'Thoughts',
  ];
  
  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String fullDateTimeFormat = 'MMM dd, yyyy - hh:mm a';
}
