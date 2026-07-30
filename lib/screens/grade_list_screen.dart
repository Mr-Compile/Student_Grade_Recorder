import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:student_grade_recorder/database/database_helper.dart';
import 'package:student_grade_recorder/models/grade.dart';
import 'package:student_grade_recorder/screens/grade_form_screen.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';

class GradeListScreen extends StatefulWidget {
  const GradeListScreen({super.key});

  @override
  State<GradeListScreen> createState() => _GradeListScreenState();
}

class _GradeListScreenState extends State<GradeListScreen> {
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    final grades = await DatabaseHelper.instance.readGradesWithDetails();
    setState(() {
      _grades = grades;
      _isLoading = false;
    });
  }

  Future<void> _deleteGrade(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: const Text('Are you sure you want to delete this grade?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteGrade(id);
      _loadGrades();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _grades.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.fileText, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No grades yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to add a grade',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _grades.length,
                  itemBuilder: (context, index) {
                    final grade = _grades[index];
                    final gradeValue = grade['gradeValue'] as double;
                    final status = gradeValue >= 60 ? 'Passed' : 'Failed';
                    final statusColor = gradeValue >= 60 ? AppTheme.greenColor : AppTheme.redColor;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(
                            gradeValue >= 60 ? LucideIcons.checkCircle : LucideIcons.xCircle,
                            color: statusColor,
                          ),
                        ),
                        title: Text(
                          grade['studentName'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('${grade['subjectName']} (${grade['subjectCode']})'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Grade: ${gradeValue.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(LucideIcons.pencil),
                              color: AppTheme.blueColor,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GradeFormScreen(
                                      grade: Grade.fromMap(grade),
                                    ),
                                  ),
                                );
                                _loadGrades();
                              },
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2),
                              color: AppTheme.redColor,
                              onPressed: () => _deleteGrade(grade['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GradeFormScreen(),
            ),
          );
          _loadGrades();
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Grade'),
        backgroundColor: AppTheme.greenColor,
      ),
    );
  }
}
