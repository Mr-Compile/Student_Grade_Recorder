import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:student_grade_recorder/database/database_helper.dart';
import 'package:student_grade_recorder/screens/student_list_screen.dart';
import 'package:student_grade_recorder/screens/subject_list_screen.dart';
import 'package:student_grade_recorder/screens/grade_list_screen.dart';
import 'package:student_grade_recorder/screens/report_screen.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';
import 'package:student_grade_recorder/theme/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const DashboardScreen({super.key, required this.themeProvider});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalStudents = 0;
  int _totalSubjects = 0;
  int _totalGrades = 0;
  double _overallAverage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final students = await db.getStudentCount();
    final subjects = await db.getSubjectCount();
    final grades = await db.getGradeCount();
    final average = await db.getOverallAverage();

    setState(() {
      _totalStudents = students;
      _totalSubjects = subjects;
      _totalGrades = grades;
      _overallAverage = average;
    });
  }

  void _toggleTheme() {
    widget.themeProvider.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Recorder'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeProvider.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
            ),
            onPressed: _toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildSummaryCard(
                icon: LucideIcons.users,
                title: 'Total Students',
                value: _totalStudents.toString(),
                color: AppTheme.blueColor,
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                icon: LucideIcons.book,
                title: 'Total Subjects',
                value: _totalSubjects.toString(),
                color: AppTheme.purpleColor,
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                icon: LucideIcons.fileText,
                title: 'Total Grade Records',
                value: _totalGrades.toString(),
                color: AppTheme.greenColor,
              ),
              const SizedBox(height: 16),
              _buildSummaryCard(
                icon: LucideIcons.barChart3,
                title: 'Overall Average',
                value: _overallAverage.toStringAsFixed(2),
                color: AppTheme.amberColor,
              ),
              const SizedBox(height: 32),
              _buildNavigationButton(
                icon: LucideIcons.users,
                label: 'Students',
                color: AppTheme.blueColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentListScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationButton(
                icon: LucideIcons.book,
                label: 'Subjects',
                color: AppTheme.purpleColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubjectListScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationButton(
                icon: LucideIcons.fileText,
                label: 'Grades',
                color: AppTheme.greenColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GradeListScreen(),
                    ),
                  ).then((_) => _loadData());
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationButton(
                icon: LucideIcons.barChart2,
                label: 'Reports',
                color: AppTheme.purpleColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
