import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../models/student.dart';
import '../models/subject.dart';

class CsvExporter {
  static Future<void> exportStudents(List<Student> students) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Full Name', 'Section', 'Year Level'],
      ...students.map((student) => [
        student.id,
        student.fullName,
        student.section,
        student.yearLevel,
      ]),
    ];

    final String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/students_export.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Student Data Export');
  }

  static Future<void> exportGrades(List<Map<String, dynamic>> grades) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Student Name', 'Subject Name', 'Subject Code', 'Grade', 'Status'],
      ...grades.map((grade) {
        final gradeValue = grade['gradeValue'] as double;
        final status = gradeValue >= 60 ? 'Passed' : 'Failed';
        return [
          grade['id'],
          grade['studentName'],
          grade['subjectName'],
          grade['subjectCode'],
          gradeValue.toStringAsFixed(2),
          status,
        ];
      }),
    ];

    final String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/grades_export.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Grade Data Export');
  }

  static Future<void> exportSubjects(List<Map<String, dynamic>> subjects) async {
    final List<List<dynamic>> rows = [
      ['ID', 'Subject Name', 'Subject Code'],
      ...subjects.map((subject) => [
        subject['id'],
        subject['subjectName'],
        subject['subjectCode'],
      ]),
    ];

    final String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/subjects_export.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'Subject Data Export');
  }
}
