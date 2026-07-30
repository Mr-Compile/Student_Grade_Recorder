import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/subject.dart';
import '../models/grade.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('student_grade_recorder.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Students Table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        section TEXT NOT NULL,
        yearLevel TEXT NOT NULL
      )
    ''');

    // Subjects Table
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectName TEXT NOT NULL,
        subjectCode TEXT NOT NULL UNIQUE
      )
    ''');

    // Grades Table
    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        subjectId INTEGER NOT NULL,
        gradeValue REAL NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE
      )
    ''');
  }

  // Student CRUD Operations
  Future<int> createStudent(Student student) async {
    final db = await instance.database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> readAllStudents() async {
    final db = await instance.database;
    final result = await db.query('students', orderBy: 'fullName ASC');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> readStudent(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'students',
      columns: ['id', 'fullName', 'section', 'yearLevel'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateStudent(Student student) async {
    final db = await instance.database;
    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete(
      'grades',
      where: 'studentId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStudentOnly(int id) async {
    final db = await instance.database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Subject CRUD Operations
  Future<int> createSubject(Subject subject) async {
    final db = await instance.database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<List<Subject>> readAllSubjects() async {
    final db = await instance.database;
    final result = await db.query('subjects', orderBy: 'subjectName ASC');
    return result.map((map) => Subject.fromMap(map)).toList();
  }

  Future<Subject?> readSubject(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'subjects',
      columns: ['id', 'subjectName', 'subjectCode'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Subject.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await instance.database;
    return db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await instance.database;
    await db.delete(
      'grades',
      where: 'subjectId = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Grade CRUD Operations
  Future<int> createGrade(Grade grade) async {
    final db = await instance.database;
    return await db.insert('grades', grade.toMap());
  }

  Future<List<Grade>> readAllGrades() async {
    final db = await instance.database;
    final result = await db.query('grades');
    return result.map((map) => Grade.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> readGradesWithDetails() async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        grades.id,
        grades.studentId,
        grades.subjectId,
        grades.gradeValue,
        students.fullName as studentName,
        subjects.subjectName,
        subjects.subjectCode
      FROM grades
      INNER JOIN students ON grades.studentId = students.id
      INNER JOIN subjects ON grades.subjectId = subjects.id
      ORDER BY students.fullName ASC
    ''');
    return result;
  }

  Future<Grade?> readGrade(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'grades',
      columns: ['id', 'studentId', 'subjectId', 'gradeValue'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Grade.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateGrade(Grade grade) async {
    final db = await instance.database;
    return db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  Future<int> deleteGrade(int id) async {
    final db = await instance.database;
    return await db.delete(
      'grades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Summary Statistics
  Future<int> getStudentCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM students');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getSubjectCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM subjects');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getGradeCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM grades');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getOverallAverage() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT AVG(gradeValue) as avg FROM grades');
    final avg = result.first['avg'] as double?;
    return avg ?? 0.0;
  }

  // Report Data
  Future<List<Map<String, dynamic>>> getStudentReport(int studentId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT 
        subjects.subjectName,
        subjects.subjectCode,
        grades.gradeValue
      FROM grades
      INNER JOIN subjects ON grades.subjectId = subjects.id
      WHERE grades.studentId = ?
      ORDER BY subjects.subjectName ASC
    ''', [studentId]);
    return result;
  }

  Future<double> getStudentAverage(int studentId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT AVG(gradeValue) as avg
      FROM grades
      WHERE studentId = ?
    ''', [studentId]);
    final avg = result.first['avg'] as double?;
    return avg ?? 0.0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
