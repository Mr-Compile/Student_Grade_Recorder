import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:student_grade_recorder/database/database_helper.dart';
import 'package:student_grade_recorder/models/grade.dart';
import 'package:student_grade_recorder/models/student.dart';
import 'package:student_grade_recorder/models/subject.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';

class GradeFormScreen extends StatefulWidget {
  final Grade? grade;

  const GradeFormScreen({super.key, this.grade});

  @override
  State<GradeFormScreen> createState() => _GradeFormScreenState();
}

class _GradeFormScreenState extends State<GradeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  
  List<Student> _students = [];
  List<Subject> _subjects = [];
  Student? _selectedStudent;
  Subject? _selectedSubject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.grade != null) {
      _gradeController.text = widget.grade!.gradeValue.toString();
    }
  }

  Future<void> _loadData() async {
    final students = await DatabaseHelper.instance.readAllStudents();
    final subjects = await DatabaseHelper.instance.readAllSubjects();
    
    if (widget.grade != null) {
      _selectedStudent = await DatabaseHelper.instance.readStudent(widget.grade!.studentId);
      _selectedSubject = await DatabaseHelper.instance.readSubject(widget.grade!.subjectId);
    }

    setState(() {
      _students = students;
      _subjects = subjects;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStudent == null || _selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a student and subject'),
            backgroundColor: AppTheme.redColor,
          ),
        );
        return;
      }

      final gradeValue = double.tryParse(_gradeController.text);
      if (gradeValue == null || gradeValue < 0 || gradeValue > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade must be between 0 and 100'),
            backgroundColor: AppTheme.redColor,
          ),
        );
        return;
      }

      final grade = Grade(
        id: widget.grade?.id,
        studentId: _selectedStudent!.id!,
        subjectId: _selectedSubject!.id!,
        gradeValue: gradeValue,
      );

      if (widget.grade == null) {
        await DatabaseHelper.instance.createGrade(grade);
      } else {
        await DatabaseHelper.instance.updateGrade(grade);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.grade == null
                  ? 'Grade added successfully'
                  : 'Grade updated successfully',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.grade != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Grade' : 'Add Grade'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Student>(
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                      initialValue: _selectedStudent,
                      items: _students.map((student) {
                        return DropdownMenuItem<Student>(
                          value: student,
                          child: Text(student.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedStudent = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a student';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Subject>(
                      decoration: const InputDecoration(
                        labelText: 'Select Subject',
                        prefixIcon: Icon(LucideIcons.book),
                      ),
                      initialValue: _selectedSubject,
                      items: _subjects.map((subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text('${subject.subjectName} (${subject.subjectCode})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedSubject = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _gradeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Grade (0-100)',
                        prefixIcon: Icon(LucideIcons.percent),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a grade';
                        }
                        final gradeValue = double.tryParse(value);
                        if (gradeValue == null) {
                          return 'Please enter a valid number';
                        }
                        if (gradeValue < 0 || gradeValue > 100) {
                          return 'Grade must be between 0 and 100';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.grayColor,
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveGrade,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditing
                                  ? AppTheme.blueColor
                                  : AppTheme.greenColor,
                            ),
                            child: Text(isEditing ? 'Update' : 'Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
