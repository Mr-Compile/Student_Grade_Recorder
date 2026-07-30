import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:student_grade_recorder/database/database_helper.dart';
import 'package:student_grade_recorder/models/student.dart';
import 'package:student_grade_recorder/screens/student_form_screen.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';
import 'package:student_grade_recorder/utils/csv_exporter.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSection;
  String? _selectedYearLevel;
  List<String> _sections = [];
  List<String> _yearLevels = [];
  String _sortBy = 'fullName';
  bool _sortAscending = true;
  final Set<int> _selectedStudentIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadFilterOptions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final students = await DatabaseHelper.instance.readAllStudents();
    setState(() {
      _students = students;
      _filteredStudents = students;
      _isLoading = false;
    });
  }

  Future<void> _loadFilterOptions() async {
    final sections = await DatabaseHelper.instance.getAllSections();
    final yearLevels = await DatabaseHelper.instance.getAllYearLevels();
    setState(() {
      _sections = sections;
      _yearLevels = yearLevels;
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    String query = _searchController.text.trim();
    List<Student> result = _students;

    if (query.isNotEmpty) {
      result = await DatabaseHelper.instance.searchStudents(query);
    }

    if (_selectedSection != null) {
      result = result.where((s) => s.section == _selectedSection).toList();
    }

    if (_selectedYearLevel != null) {
      result = result.where((s) => s.yearLevel == _selectedYearLevel).toList();
    }

    result = await DatabaseHelper.instance.sortStudents(_sortBy, _sortAscending);

    setState(() {
      _filteredStudents = result;
    });
  }

  Future<void> _deleteStudent(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student? All associated grades will also be deleted.'),
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
      await DatabaseHelper.instance.deleteStudent(id);
      await DatabaseHelper.instance.deleteStudentOnly(id);
      _loadStudents();
      _loadFilterOptions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      }
    }
  }

  Future<void> _deleteSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Students'),
        content: Text('Are you sure you want to delete ${_selectedStudentIds.length} student(s)? All associated grades will also be deleted.'),
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
      for (final id in _selectedStudentIds) {
        await DatabaseHelper.instance.deleteStudent(id);
        await DatabaseHelper.instance.deleteStudentOnly(id);
      }
      setState(() {
        _selectedStudentIds.clear();
        _isSelectionMode = false;
      });
      _loadStudents();
      _loadFilterOptions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Students deleted successfully')),
        );
      }
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedStudentIds.contains(id)) {
        _selectedStudentIds.remove(id);
        if (_selectedStudentIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedStudentIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedStudentIds.length == _filteredStudents.length) {
        _selectedStudentIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedStudentIds.clear();
        for (final student in _filteredStudents) {
          _selectedStudentIds.add(student.id!);
        }
        _isSelectionMode = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(LucideIcons.checkSquare),
              onPressed: _toggleSelectAll,
              tooltip: 'Select All',
            ),
          if (_isSelectionMode && _selectedStudentIds.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: _deleteSelectedStudents,
              tooltip: 'Delete Selected',
              color: AppTheme.redColor,
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: () {
                setState(() {
                  _selectedStudentIds.clear();
                  _isSelectionMode = false;
                });
              },
              tooltip: 'Cancel Selection',
            ),
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(LucideIcons.download),
              onPressed: () => _exportToCsv(),
              tooltip: 'Export CSV',
            ),
          if (!_isSelectionMode)
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.arrowUpDown),
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
                  _sortAscending = !_sortAscending;
                });
                _applyFilters();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'fullName', child: Text('Sort by Name')),
                const PopupMenuItem(value: 'section', child: Text('Sort by Section')),
                const PopupMenuItem(value: 'yearLevel', child: Text('Sort by Year Level')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No students found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _students.isEmpty
                                  ? 'Tap the + button to add a student'
                                  : 'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          final isSelected = _selectedStudentIds.contains(student.id);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: _isSelectionMode
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleSelection(student.id!),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: AppTheme.blueColor.withValues(alpha: 0.1),
                                      child: Icon(LucideIcons.user, color: AppTheme.blueColor),
                                    ),
                              title: Text(
                                student.fullName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Section: ${student.section}'),
                                  Text('Year Level: ${student.yearLevel}'),
                                ],
                              ),
                              trailing: _isSelectionMode
                                  ? null
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.pencil),
                                          color: AppTheme.blueColor,
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => StudentFormScreen(
                                                  student: student,
                                                ),
                                              ),
                                            );
                                            _loadStudents();
                                            _loadFilterOptions();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2),
                                          color: AppTheme.redColor,
                                          onPressed: () => _deleteStudent(student.id!),
                                        ),
                                      ],
                                    ),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(student.id!);
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedStudentIds.add(student.id!);
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentFormScreen(),
            ),
          );
          _loadStudents();
          _loadFilterOptions();
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Student'),
        backgroundColor: AppTheme.greenColor,
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search students...',
              prefixIcon: const Icon(LucideIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Section',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  initialValue: _selectedSection,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Sections')),
                    ..._sections.map((section) {
                      return DropdownMenuItem(value: section, child: Text(section));
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedSection = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Year Level',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  initialValue: _selectedYearLevel,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Year Levels')),
                    ..._yearLevels.map((yearLevel) {
                      return DropdownMenuItem(value: yearLevel, child: Text(yearLevel));
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedYearLevel = value);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCsv() async {
    await CsvExporter.exportStudents(_students);
  }
}
