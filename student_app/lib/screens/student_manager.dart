import 'package:flutter/material.dart';
import '../database_helper.dart';

class StudentManager extends StatefulWidget {
  const StudentManager({super.key});

  @override
  State<StudentManager> createState() => _StudentManagerState();
}

class _StudentManagerState extends State<StudentManager> {
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _courseController = TextEditingController();

  List<Map<String, dynamic>> _students = [];

  Map<String, dynamic>? _selectedStudent;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _courseController.dispose();

    super.dispose();
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  Future<void> _loadStudents() async {
    setState(() {
      _loading = true;
    });

    final students = await DatabaseHelper.getStudents();

    if (!mounted) return;

    setState(() {
      _students = students;
      _loading = false;
      _selectedStudent = null;
    });
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Future<void> _search() async {
    final results = await DatabaseHelper.searchStudents(
      _searchController.text,
    );

    if (!mounted) return;

    setState(() {
      _students = results;
      _selectedStudent = null;
    });
  }

  // ==========================================================
  // ADD
  // ==========================================================

  Future<void> _addStudent() async {
    _nameController.clear();
    _courseController.clear();

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '➕ Add Student',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(
                      Icons.person_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter student name';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    prefixIcon: Icon(
                      Icons.menu_book_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter course';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                await DatabaseHelper.addStudent(
                  name: _nameController.text.trim(),
                  course: _courseController.text.trim(),
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _loadStudents();

      if (!mounted) return;

      _message(
        'Student added successfully! 🎉',
      );
    }
  }

  // ==========================================================
  // UPDATE
  // ==========================================================

  Future<void> _updateStudent() async {
    if (_selectedStudent == null) {
      _message(
        'Select a student first.',
      );

      return;
    }

    _nameController.text = _selectedStudent!['name'].toString();

    _courseController.text = _selectedStudent!['course'].toString();

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '✏️ Update Student',
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: Icon(
                      Icons.person_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter student name';
                    }

                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course',
                    prefixIcon: Icon(
                      Icons.menu_book_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter course';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                await DatabaseHelper.updateStudent(
                  id: _selectedStudent!['id'] as int,
                  name: _nameController.text.trim(),
                  course: _courseController.text.trim(),
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _loadStudents();

      if (!mounted) return;

      _message(
        'Student updated successfully! ✨',
      );
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> _deleteStudent() async {
    if (_selectedStudent == null) {
      _message(
        'Select a student first.',
      );

      return;
    }

    final name = _selectedStudent!['name'].toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🗑️ Delete Student',
          ),
          content: Text(
            'Delete "$name" from the database?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(
                context,
                false,
              ),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                true,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await DatabaseHelper.deleteStudent(
      _selectedStudent!['id'] as int,
    );

    await _loadStudents();

    if (!mounted) return;

    _message(
      'Student deleted successfully.',
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // ==========================================================
  // COMMAND BUTTON
  // ==========================================================

  Widget _commandButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 105,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(
                  alpha: 0.70,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(
              22,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Manager',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadStudents,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0E7FF),
              Color(0xFFE0F7FF),
              Color(0xFFFFF0F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================================================
              // SEARCH
              // ==================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  15,
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Search by name or course...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                    suffixIcon: IconButton(
                      onPressed: _search,
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ==================================================
              // COMMANDS
              // ==================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _commandButton(
                          icon: Icons.person_add_rounded,
                          title: 'ADD',
                          color: const Color(
                            0xFF8B5CF6,
                          ),
                          onPressed: _addStudent,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        _commandButton(
                          icon: Icons.edit_rounded,
                          title: 'UPDATE',
                          color: const Color(
                            0xFFF59E0B,
                          ),
                          onPressed: _updateStudent,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        _commandButton(
                          icon: Icons.delete_rounded,
                          title: 'DELETE',
                          color: const Color(
                            0xFFEF4444,
                          ),
                          onPressed: _deleteStudent,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        _commandButton(
                          icon: Icons.search_rounded,
                          title: 'SEARCH',
                          color: const Color(
                            0xFF06B6D4,
                          ),
                          onPressed: _search,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ==================================================
              // SELECTED STUDENT
              // ==================================================

              if (_selectedStudent != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF2563EB),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          'Selected: ${_selectedStudent!['name']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedStudent = null;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(
                height: 10,
              ),

              // ==================================================
              // STUDENT LIST
              // ==================================================

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _students.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 80,
                                  color: Color(
                                    0xFF8B5CF6,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  'No students yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Tap ADD to create your first student.',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              20,
                              5,
                              20,
                              20,
                            ),
                            itemCount: _students.length,
                            itemBuilder: (
                              context,
                              index,
                            ) {
                              final student = _students[index];

                              final id = student['id'] as int;

                              final name = student['name'].toString();

                              final course = student['course'].toString();

                              final selected = _selectedStudent != null &&
                                  _selectedStudent!['id'] == id;

                              return Card(
                                elevation: selected ? 8 : 3,
                                margin: const EdgeInsets.only(
                                  bottom: 12,
                                ),
                                color: selected
                                    ? const Color(
                                        0xFFEDE9FE,
                                      )
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      _selectedStudent = student;
                                    });
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 26,
                                    backgroundColor: const Color(
                                      0xFF7C3AED,
                                    ),
                                    child: Text(
                                      name
                                          .substring(
                                            0,
                                            1,
                                          )
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                    ),
                                  ),
                                  subtitle: Text(
                                    course,
                                  ),
                                  trailing: selected
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(
                                            0xFF7C3AED,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.chevron_right_rounded,
                                          color: Colors.grey,
                                        ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
