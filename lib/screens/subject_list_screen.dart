import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:student_grade_recorder/database/database_helper.dart';
import 'package:student_grade_recorder/models/subject.dart';
import 'package:student_grade_recorder/screens/subject_form_screen.dart';
import 'package:student_grade_recorder/theme/app_theme.dart';
import 'package:student_grade_recorder/utils/csv_exporter.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'subjectName';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    setState(() => _isLoading = true);
    final subjects = await DatabaseHelper.instance.readAllSubjects();
    setState(() {
      _subjects = subjects;
      _filteredSubjects = subjects;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    String query = _searchController.text.trim();
    List<Subject> result = _subjects;

    if (query.isNotEmpty) {
      result = await DatabaseHelper.instance.searchSubjects(query);
    }

    result = await DatabaseHelper.instance.sortSubjects(_sortBy, _sortAscending);

    setState(() {
      _filteredSubjects = result;
    });
  }

  Future<void> _deleteSubject(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject? All associated grades will also be deleted.'),
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
      await DatabaseHelper.instance.deleteSubject(id);
      _loadSubjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => _exportToCsv(),
            tooltip: 'Export CSV',
          ),
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
              const PopupMenuItem(value: 'subjectName', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'subjectCode', child: Text('Sort by Code')),
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
                : _filteredSubjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.book, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No subjects found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _subjects.isEmpty
                                  ? 'Tap the + button to add a subject'
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
                        itemCount: _filteredSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = _filteredSubjects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.purpleColor.withValues(alpha: 0.1),
                                child: Icon(LucideIcons.book, color: AppTheme.purpleColor),
                              ),
                              title: Text(
                                subject.subjectName,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Code: ${subject.subjectCode}'),
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
                                          builder: (context) => SubjectFormScreen(
                                            subject: subject,
                                          ),
                                        ),
                                      );
                                      _loadSubjects();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(LucideIcons.trash2),
                                    color: AppTheme.redColor,
                                    onPressed: () => _deleteSubject(subject.id!),
                                  ),
                                ],
                              ),
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
              builder: (context) => const SubjectFormScreen(),
            ),
          );
          _loadSubjects();
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Subject'),
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
          hintText: 'Search subjects...',
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
    final subjectMaps = _subjects.map((s) => {
      'id': s.id,
      'subjectName': s.subjectName,
      'subjectCode': s.subjectCode,
    }).toList();
    await CsvExporter.exportSubjects(subjectMaps);
  }
}
