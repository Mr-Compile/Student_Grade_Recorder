# Navigation Flow Documentation

## Screen Connections

### Main Entry Point
- **main.dart** → `StudentGradeRecorderApp` → `DashboardScreen`

### Dashboard Screen (dashboard_screen.dart)
**Navigation From:** App entry point
**Navigation To:**
1. **Student List Screen** - via "Students" button (Blue)
2. **Subject List Screen** - via "Subjects" button (Purple)
3. **Grade List Screen** - via "Grades" button (Green)
4. **Report Screen** - via "Reports" button (Purple)

**Features:**
- Theme toggle button (Amber) - switches between light/dark mode
- Summary cards showing: Total Students, Total Subjects, Total Grade Records, Overall Average
- Auto-refreshes data when returning from other screens

### Student List Screen (student_list_screen.dart)
**Navigation From:** Dashboard → Students button
**Navigation To:**
1. **Student Form Screen (Add)** - via FAB "+" button (Green)
2. **Student Form Screen (Edit)** - via pencil icon on student card (Blue)
3. **Back to Dashboard** - via back arrow in AppBar

**Features:**
- Displays list of all students with name, section, year level
- Delete button (Red) with confirmation dialog
- Empty state with instructions
- Auto-refreshes after add/edit/delete operations

### Student Form Screen (student_form_screen.dart)
**Navigation From:** 
- Student List → Add button (creates new student)
- Student List → Edit button on student (edits existing student)

**Navigation To:**
- **Back to Student List** - via Cancel button (Gray) or back arrow
- **Back to Student List** - via Save/Update button (Green/Blue) after successful operation

**Features:**
- Form fields: Full Name, Section, Year Level
- Validation for all fields
- Save button (Green) for new students
- Update button (Blue) for editing existing students
- Cancel button (Gray)

### Subject List Screen (subject_list_screen.dart)
**Navigation From:** Dashboard → Subjects button
**Navigation To:**
1. **Subject Form Screen (Add)** - via FAB "+" button (Green)
2. **Subject Form Screen (Edit)** - via pencil icon on subject card (Blue)
3. **Back to Dashboard** - via back arrow in AppBar

**Features:**
- Displays list of all subjects with name and code
- Delete button (Red) with confirmation dialog
- Empty state with instructions
- Auto-refreshes after add/edit/delete operations

### Subject Form Screen (subject_form_screen.dart)
**Navigation From:**
- Subject List → Add button (creates new subject)
- Subject List → Edit button on subject (edits existing subject)

**Navigation To:**
- **Back to Subject List** - via Cancel button (Gray) or back arrow
- **Back to Subject List** - via Save/Update button (Green/Blue) after successful operation

**Features:**
- Form fields: Subject Name, Subject Code
- Validation for all fields
- Unique subject code validation
- Save button (Green) for new subjects
- Update button (Blue) for editing existing subjects
- Cancel button (Gray)

### Grade List Screen (grade_list_screen.dart)
**Navigation From:** Dashboard → Grades button
**Navigation To:**
1. **Grade Form Screen (Add)** - via FAB "+" button (Green)
2. **Grade Form Screen (Edit)** - via pencil icon on grade card (Blue)
3. **Back to Dashboard** - via back arrow in AppBar

**Features:**
- Displays list of all grades with student name, subject, grade value
- Pass/Fail status indicator (60+ = Pass)
- Delete button (Red) with confirmation dialog
- Empty state with instructions
- Auto-refreshes after add/edit/delete operations

### Grade Form Screen (grade_form_screen.dart)
**Navigation From:**
- Grade List → Add button (creates new grade)
- Grade List → Edit button on grade (edits existing grade)

**Navigation To:**
- **Back to Grade List** - via Cancel button (Gray) or back arrow
- **Back to Grade List** - via Save/Update button (Green/Blue) after successful operation

**Features:**
- Dropdown to select Student
- Dropdown to select Subject
- Grade input field (0-100) with validation
- Save button (Green) for new grades
- Update button (Blue) for editing existing grades
- Cancel button (Gray)

### Report Screen (report_screen.dart)
**Navigation From:** Dashboard → Reports button
**Navigation To:**
- **Back to Dashboard** - via back arrow in AppBar

**Features:**
- Generate Report button (Purple)
- Displays per-student reports with:
  - Student name, section, year level
  - List of subject grades
  - Calculated average
  - Pass/Fail status (60+ = Pass)
- Empty state when no students exist
- Loading state during report generation

## Database Operations

### Student Operations
- **Create**: `DatabaseHelper.instance.createStudent(student)`
- **Read**: `DatabaseHelper.instance.readAllStudents()`
- **Update**: `DatabaseHelper.instance.updateStudent(student)`
- **Delete**: `DatabaseHelper.instance.deleteStudent(id)` + `deleteStudentOnly(id)`

### Subject Operations
- **Create**: `DatabaseHelper.instance.createSubject(subject)`
- **Read**: `DatabaseHelper.instance.readAllSubjects()`
- **Update**: `DatabaseHelper.instance.updateSubject(subject)`
- **Delete**: `DatabaseHelper.instance.deleteSubject(id)`

### Grade Operations
- **Create**: `DatabaseHelper.instance.createGrade(grade)`
- **Read**: `DatabaseHelper.instance.readGradesWithDetails()`
- **Update**: `DatabaseHelper.instance.updateGrade(grade)`
- **Delete**: `DatabaseHelper.instance.deleteGrade(id)`

### Report Operations
- **Student Report**: `DatabaseHelper.instance.getStudentReport(studentId)`
- **Student Average**: `DatabaseHelper.instance.getStudentAverage(studentId)`

### Summary Statistics
- **Student Count**: `DatabaseHelper.instance.getStudentCount()`
- **Subject Count**: `DatabaseHelper.instance.getSubjectCount()`
- **Grade Count**: `DatabaseHelper.instance.getGradeCount()`
- **Overall Average**: `DatabaseHelper.instance.getOverallAverage()`

## Theme System
- **ThemeProvider**: Manages theme state across the app
- **Theme Toggle**: Located in Dashboard AppBar (Amber color)
- **Theme Persistence**: Maintained while app is open
- **Themes Available**: Light mode and Dark mode

## Color Coding
- **Add/Save**: Green (#4CAF50)
- **Edit/Update**: Blue (#2196F3)
- **Delete**: Red (#F44336)
- **Cancel/Back**: Gray (#9E9E9E)
- **Generate Report**: Purple (#9C27B0)
- **Theme Toggle**: Amber (#FFC107)

## Data Flow
1. User opens app → Dashboard loads with summary statistics
2. User navigates to list screens → Data loaded from database
3. User adds/edits/deletes → Database operations performed
4. User returns to list → Data refreshed automatically
5. User returns to dashboard → Summary statistics refreshed
6. User generates report → Report data fetched and displayed

## Error Handling
- Form validation on all input fields
- Confirmation dialogs for delete operations
- SnackBar notifications for success/error messages
- Unique constraint handling (subject codes)
- Grade range validation (0-100)
