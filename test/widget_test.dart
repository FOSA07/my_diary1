// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:my_diary1/main.dart';
import 'package:my_diary1/data/models/diary_entry_model.dart';
import 'package:my_diary1/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(DiaryEntryModelAdapter());
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('Diary app loads correctly', (WidgetTester tester) async {
    // Open the test box
    await Hive.openBox<DiaryEntryModel>(AppConstants.diaryBox);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyDiaryApp());
    await tester.pumpAndSettle();

    // Verify that the app title is displayed
    expect(find.text('My Diary'), findsOneWidget);

    // Verify that the empty state is shown
    expect(find.text('Start your diary journey'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Clean up
    await Hive.box<DiaryEntryModel>(AppConstants.diaryBox).clear();
    await Hive.close();
  });
}
