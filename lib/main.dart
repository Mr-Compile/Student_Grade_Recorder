import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:student_grade_recorder/screens/main_navigation_screen.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';
import 'package:student_grade_recorder/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const StudentGradeRecorderApp());
}

class StudentGradeRecorderApp extends StatefulWidget {
  const StudentGradeRecorderApp({super.key});

  @override
  State<StudentGradeRecorderApp> createState() => _StudentGradeRecorderAppState();
}

class _StudentGradeRecorderAppState extends State<StudentGradeRecorderApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, child) {
        return MaterialApp(
          title: 'Student Grade Recorder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeProvider.themeMode,
          home: MainNavigationScreen(themeProvider: _themeProvider),
        );
      },
    );
  }
}
