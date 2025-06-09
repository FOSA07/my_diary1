import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_data_source.dart';
import 'data/models/diary_entry_model.dart';
import 'data/repositories/diary_repository_impl.dart';
import 'domain/repositories/diary_repository.dart';
import 'presentation/providers/diary_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/security_provider.dart';
import 'presentation/providers/analytics_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(DiaryEntryModelAdapter());

  // Open boxes
  await Hive.openBox<DiaryEntryModel>(AppConstants.diaryBox);

  runApp(const MyDiaryApp());
}

class MyDiaryApp extends StatelessWidget {
  const MyDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DiaryRepository>(
          create: (_) => DiaryRepositoryImpl(
            localDataSource: LocalDataSource(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DiaryProvider(
            repository: context.read<DiaryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SecurityProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AnalyticsProvider(
            repository: context.read<DiaryRepository>(),
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, SecurityProvider>(
        builder: (context, themeProvider, securityProvider, child) {
          return MaterialApp(
            title: 'My Diary',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: securityProvider.isLocked ? const LockScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}
