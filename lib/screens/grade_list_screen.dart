import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:student_grade_recorder/database/database_helper.dart';
import 'package:student_grade_recorder/models/grade.dart';
import 'package:student_grade_recorder/screens/grade_form_screen.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';
import 'package:student_grade_recorder/utils/csv_exporter.dart';

class GradeListScreen extends StatefulWidget {
  const GradeListScreen({super.key});

  @override
  State<GradeListScreen> createState() => GradeListScreenState();
}

class GradeListScreenState extends State<GradeListScreen> {
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> _filteredGrades = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'studentName';
  bool _sortAscending = true;
  final Set<int> _selectedGradeIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    loadGrades();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadGrades() async {
    setState(() => _isLoading = true);
    final grades = await DatabaseHelper.instance.readGradesWithDetails();
    setState(() {
      _grades = grades;
      _filteredGrades = grades;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    String query = _searchController.text.trim();
    List<Map<String, dynamic>> result = _grades;

    if (query.isNotEmpty) {
      result = await DatabaseHelper.instance.searchGrades(query);
    }

    result = await DatabaseHelper.instance.sortGrades(_sortBy, _sortAscending);

    setState(() {
      _filteredGrades = result;
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
      loadGrades();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade deleted successfully')),
        );
      }
    }
  }

  Future<void> _deleteSelectedGrades() async {
    if (_selectedGradeIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Grades'),
        content: Text('Are you sure you want to delete ${_selectedGradeIds.length} grade(s)?'),
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
      for (final id in _selectedGradeIds) {
        await DatabaseHelper.instance.deleteGrade(id);
      }
      setState(() {
        _selectedGradeIds.clear();
        _isSelectionMode = false;
      });
      loadGrades();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grades deleted successfully')),
        );
      }
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedGradeIds.contains(id)) {
        _selectedGradeIds.remove(id);
        if (_selectedGradeIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedGradeIds.add(id);
        _isSelectionMode = true;
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedGradeIds.length == _filteredGrades.length) {
        _selectedGradeIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedGradeIds.clear();
        for (final grade in _filteredGrades) {
          _selectedGradeIds.add(grade['id'] as int);
        }
        _isSelectionMode = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(LucideIcons.checkSquare),
              onPressed: _toggleSelectAll,
              tooltip: 'Select All',
            ),
          if (_isSelectionMode && _selectedGradeIds.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: _deleteSelectedGrades,
              tooltip: 'Delete Selected',
              color: AppTheme.redColor,
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(LucideIcons.x),
              onPressed: () {
                setState(() {
                  _selectedGradeIds.clear();
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
                const PopupMenuItem(value: 'studentName', child: Text('Sort by Student')),
                const PopupMenuItem(value: 'subjectName', child: Text('Sort by Subject')),
                const PopupMenuItem(value: 'gradeValue', child: Text('Sort by Grade')),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGrades.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.fileText, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No grades found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _grades.isEmpty
                                  ? 'Tap the + button to add a grade'
                                  : 'Try adjusting your search',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredGrades.length,
                        itemBuilder: (context, index) {
                          final grade = _filteredGrades[index];
                          final gradeValue = grade['gradeValue'] as double;
                          final status = gradeValue >= 60 ? 'Passed' : 'Failed';
                          final statusColor = gradeValue >= 60 ? AppTheme.greenColor : AppTheme.redColor;
                          final isSelected = _selectedGradeIds.contains(grade['id']);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: _isSelectionMode
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleSelection(grade['id'] as int),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: statusColor.withValues(alpha: 0.1),
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
                                          color: statusColor.withValues(alpha: 0.1),
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
                                                builder: (context) => GradeFormScreen(
                                                  grade: Grade.fromMap(grade),
                                                ),
                                              ),
                                            );
                                            loadGrades();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.trash2),
                                          color: AppTheme.redColor,
                                          onPressed: () => _deleteGrade(grade['id'] as int),
                                        ),
                                      ],
                                    ),
                              onTap: () {
                                if (_isSelectionMode) {
                                  _toggleSelection(grade['id'] as int);
                                }
                              },
                              onLongPress: () {
                                if (!_isSelectionMode) {
                                  setState(() {
                                    _isSelectionMode = true;
                                    _selectedGradeIds.add(grade['id'] as int);
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
              builder: (context) => const GradeFormScreen(),
            ),
          );
          loadGrades();
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Grade'),
        backgroundColor: AppTheme.greenColor,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search grades by student or subject...',
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
    );
  }

  Future<void> _exportToCsv() async {
    await CsvExporter.exportGrades(_grades);
  }
}
