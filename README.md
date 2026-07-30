# Student Grade Recorder

A beginner-friendly Flutter educational application for recording and managing student grades. This app demonstrates CRUD operations, SQLite database usage, and clean UI design principles.

## Features

- **Student Management**: Create, read, update, and delete student records
- **Subject Management**: Create, read, update, and delete subject records
- **Grade Recording**: Record grades for students in specific subjects
- **Automatic Calculations**: Compute averages and pass/fail status automatically
- **Report Generation**: Generate comprehensive student grade reports
- **Theme Support**: Light and dark mode with theme toggle
- **Offline Storage**: All data stored locally using SQLite

## Tech Stack

- **Flutter**: Cross-platform mobile app framework
- **Dart**: Programming language
- **SQLite**: Local database using `sqflite` package
- **Material 3**: Modern Material Design
- **Lucide Icons**: Beautiful icon set

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/                        # Data models
│   ├── student.dart
│   ├── subject.dart
│   └── grade.dart
├── database/                      # Database helper
│   └── database_helper.dart
├── theme/                         # Theme configuration
│   ├── app_theme.dart
│   └── theme_provider.dart
└── screens/                       # UI screens
    ├── dashboard_screen.dart
    ├── student_list_screen.dart
    ├── student_form_screen.dart
    ├── subject_list_screen.dart
    ├── subject_form_screen.dart
    ├── grade_list_screen.dart
    ├── grade_form_screen.dart
    └── report_screen.dart
```

## Database Schema

### Students Table
```sql
CREATE TABLE students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  fullName TEXT NOT NULL,
  section TEXT NOT NULL,
  yearLevel TEXT NOT NULL
)
```

### Subjects Table
```sql
CREATE TABLE subjects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  subjectName TEXT NOT NULL,
  subjectCode TEXT NOT NULL UNIQUE
)
```

### Grades Table
```sql
CREATE TABLE grades (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  studentId INTEGER NOT NULL,
  subjectId INTEGER NOT NULL,
  gradeValue REAL NOT NULL,
  FOREIGN KEY (studentId) REFERENCES students (id) ON DELETE CASCADE,
  FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE
)
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extension
- Android Emulator or physical device

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Student_Grade_Recorder
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

### Dashboard
- View summary statistics (total students, subjects, grades, overall average)
- Navigate to Students, Subjects, Grades, and Reports screens
- Toggle between light and dark theme

### Students
- View list of all students
- Add new students with name, section, and year level
- Edit existing student information
- Delete students (also deletes associated grades)

### Subjects
- View list of all subjects
- Add new subjects with name and code
- Edit existing subject information
- Delete subjects (also deletes associated grades)

### Grades
- View list of all grades with student and subject details
- Add new grades by selecting student, subject, and entering grade (0-100)
- Edit existing grades
- Delete individual grades
- View pass/fail status (60+ is passing)

### Reports
- Generate comprehensive reports for all students
- View individual subject grades
- See calculated average and pass/fail status per student

## Color Scheme

- **Add/Save**: Green (#4CAF50)
- **Edit/Update**: Blue (#2196F3)
- **Delete**: Red (#F44336)
- **Cancel/Back**: Gray (#9E9E9E)
- **Generate Report**: Purple (#9C27B0)
- **Theme Toggle**: Amber (#FFC107)

## Educational Value

This project demonstrates:
- CRUD operations with SQLite
- Material 3 design principles
- State management in Flutter
- Form validation
- Navigation between screens
- Theme switching
- Database relationships and foreign keys
- Data aggregation and reporting

## License

This project is created for educational purposes.

## Author

Created as a learning resource for beginner IT students.
