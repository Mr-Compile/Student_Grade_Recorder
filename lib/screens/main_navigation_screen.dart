import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:student_grade_recorder/screens/dashboard_screen.dart';
import 'package:student_grade_recorder/screens/student_list_screen.dart';
import 'package:student_grade_recorder/screens/subject_list_screen.dart';
import 'package:student_grade_recorder/screens/grade_list_screen.dart';
import 'package:student_grade_recorder/screens/report_screen.dart';
import 'package:student_grade_recorder/theme/theme_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const MainNavigationScreen({super.key, required this.themeProvider});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [];
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  final GlobalKey<StudentListScreenState> _studentListKey = GlobalKey<StudentListScreenState>();
  final GlobalKey<SubjectListScreenState> _subjectListKey = GlobalKey<SubjectListScreenState>();
  final GlobalKey<GradeListScreenState> _gradeListKey = GlobalKey<GradeListScreenState>();
  final GlobalKey<ReportScreenState> _reportKey = GlobalKey<ReportScreenState>();

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      DashboardScreen(key: _dashboardKey, themeProvider: widget.themeProvider),
      StudentListScreen(key: _studentListKey),
      SubjectListScreen(key: _subjectListKey),
      GradeListScreen(key: _gradeListKey),
      ReportScreen(key: _reportKey),
    ]);
  }

  void _refreshCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        _dashboardKey.currentState?.loadData();
        break;
      case 1:
        _studentListKey.currentState?.loadStudents();
        _studentListKey.currentState?.loadFilterOptions();
        break;
      case 2:
        _subjectListKey.currentState?.loadSubjects();
        break;
      case 3:
        _gradeListKey.currentState?.loadGrades();
        break;
      case 4:
        _reportKey.currentState?.loadStudents();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          _refreshCurrentScreen();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.book),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.fileText),
            label: 'Grades',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.barChart2),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
