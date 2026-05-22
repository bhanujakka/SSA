import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class ExamMarksPage extends StatefulWidget {
  const ExamMarksPage({super.key});

  @override
  State<ExamMarksPage> createState() => _ExamMarksPageState();
}

class ExamsMarksPage extends ExamMarksPage {
  const ExamsMarksPage({super.key});
}

class _ExamMarksPageState extends State<ExamMarksPage> {
  static const _classes = ['Class 9', 'Class 10', 'Class 11', 'Class 12'];
  static const _terms = [
    _ExamTerm('unit1', 'Unit1'),
    _ExamTerm('unit2', 'Unit2'),
    _ExamTerm('unit3', 'Unit3'),
    _ExamTerm('quarterly', 'Quarterly'),
    _ExamTerm('half_yearly', 'Half Yearly'),
    _ExamTerm('annual', 'Annual'),
    _ExamTerm('practical', 'Practical'),
    _ExamTerm('lab_internal', 'Lab Internal'),
    _ExamTerm('theory', 'Theory'),
  ];
  static const _studentsByClass = {
    'Class 9': [
      _Student('STU001', 'Rajesh Kumar', 'RK'),
      _Student('STU002', 'Priya Sharma', 'PS'),
      _Student('STU003', 'Amit Singh', 'AS'),
    ],
    'Class 10': [
      _Student('STU101', 'Neha Patel', 'NP'),
      _Student('STU102', 'Arjun Mehta', 'AM'),
      _Student('STU103', 'Kavya Nair', 'KN'),
    ],
    'Class 11': [
      _Student('STU201', 'Rohan Das', 'RD'),
      _Student('STU202', 'Meera Iyer', 'MI'),
      _Student('STU203', 'Sahil Khan', 'SK'),
    ],
    'Class 12': [
      _Student('STU301', 'Ananya Rao', 'AR'),
      _Student('STU302', 'Vikram Joshi', 'VJ'),
      _Student('STU303', 'Sneha Reddy', 'SR'),
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  String _selectedClass = _classes.first;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _createControllers();
    _loadSavedMarks();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _createControllers() {
    for (final className in _classes) {
      for (final student in _studentsByClass[className]!) {
        for (final term in _terms) {
          _controllers[_markKey(className, student.id, term.key)] =
              TextEditingController(text: '0');
        }
      }
    }
  }

  Future<void> _loadSavedMarks() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _controllers.entries) {
      entry.value.text = prefs.getString(entry.key) ?? '0';
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMarks() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter marks between 0 and 100')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final student in _studentsByClass[_selectedClass]!) {
        for (final term in _terms) {
          final key = _markKey(_selectedClass, student.id, term.key);
          await prefs.setString(key, _controllers[key]!.text.trim());
        }
      }

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marks saved for $_selectedClass')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save marks. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _markKey(String className, String studentId, String termKey) {
    final normalizedClass = className.toLowerCase().replaceAll(' ', '_');
    return 'exam_marks_${normalizedClass}_${studentId}_$termKey';
  }

  TextEditingController _controllerFor(_Student student, _ExamTerm term) {
    return _controllers[_markKey(_selectedClass, student.id, term.key)]!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(
                    activeItem: 'Exam Marks',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Exam Marks'),
                Expanded(
                  child: _ExamMarksBody(
                    isMobile: isMobile,
                    isLoading: _isLoading,
                    isSaving: _isSaving,
                    formKey: _formKey,
                    selectedClass: _selectedClass,
                    classes: _classes,
                    students: _studentsByClass[_selectedClass]!,
                    terms: _terms,
                    controllerFor: _controllerFor,
                    onClassChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedClass = value);
                      }
                    },
                    onSave: _saveMarks,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExamMarksBody extends StatelessWidget {
  const _ExamMarksBody({
    required this.isMobile,
    required this.isLoading,
    required this.isSaving,
    required this.formKey,
    required this.selectedClass,
    required this.classes,
    required this.students,
    required this.terms,
    required this.controllerFor,
    required this.onClassChanged,
    required this.onSave,
  });

  final bool isMobile;
  final bool isLoading;
  final bool isSaving;
  final GlobalKey<FormState> formKey;
  final String selectedClass;
  final List<String> classes;
  final List<_Student> students;
  final List<_ExamTerm> terms;
  final TextEditingController Function(_Student student, _ExamTerm term)
      controllerFor;
  final ValueChanged<String?> onClassChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            DashboardTopBar(isMobile: isMobile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32,
                  isMobile ? 26 : 36,
                  isMobile ? 16 : 32,
                  118,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Examination Marks',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: isMobile ? 28 : 32,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter internal/external/theory marks',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isMobile ? 16 : 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 30),
                        Form(
                          key: formKey,
                          child: _MarksEntryCard(
                            isMobile: isMobile,
                            isLoading: isLoading,
                            selectedClass: selectedClass,
                            classes: classes,
                            students: students,
                            terms: terms,
                            controllerFor: controllerFor,
                            onClassChanged: onClassChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: isMobile ? 18 : 28,
          bottom: isMobile ? 18 : 30,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SaveMarksButton(
                isMobile: isMobile,
                isSaving: isSaving,
                onPressed: isLoading || isSaving ? null : onSave,
              ),
              SizedBox(width: isMobile ? 10 : 14),
              DashboardQuickActionsFab(size: isMobile ? 58 : 70),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarksEntryCard extends StatelessWidget {
  const _MarksEntryCard({
    required this.isMobile,
    required this.isLoading,
    required this.selectedClass,
    required this.classes,
    required this.students,
    required this.terms,
    required this.controllerFor,
    required this.onClassChanged,
  });

  final bool isMobile;
  final bool isLoading;
  final String selectedClass;
  final List<String> classes;
  final List<_Student> students;
  final List<_ExamTerm> terms;
  final TextEditingController Function(_Student student, _ExamTerm term)
      controllerFor;
  final ValueChanged<String?> onClassChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0DAF2), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MarksHeader(
            isMobile: isMobile,
            selectedClass: selectedClass,
            classes: classes,
            onClassChanged: onClassChanged,
          ),
          SizedBox(height: isMobile ? 22 : 28),
          if (isLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ...students.map(
              (student) => Padding(
                padding: EdgeInsets.only(
                  bottom: student == students.last ? 0 : 24,
                ),
                child: _StudentMarksCard(
                  key: ValueKey(student.id),
                  student: student,
                  terms: terms,
                  controllerFor: controllerFor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MarksHeader extends StatelessWidget {
  const _MarksHeader({
    required this.isMobile,
    required this.selectedClass,
    required this.classes,
    required this.onClassChanged,
  });

  final bool isMobile;
  final String selectedClass;
  final List<String> classes;
  final ValueChanged<String?> onClassChanged;

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        const Icon(
          Icons.workspace_premium_outlined,
          color: Color(0xFF244CC8),
          size: 40,
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marks Entry',
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: 22,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Enter marks for selected class',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final dropdown = SizedBox(
      width: isMobile ? double.infinity : 140,
      child: DropdownButtonFormField<String>(
        initialValue: selectedClass,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD0DAF2), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD0DAF2), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2D65D7), width: 1.5),
          ),
        ),
        style: const TextStyle(
          color: DashboardColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        items: classes
            .map(
              (className) => DropdownMenuItem(
                value: className,
                child: Text(className),
              ),
            )
            .toList(),
        onChanged: onClassChanged,
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 16),
          dropdown,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: 18),
        dropdown,
      ],
    );
  }
}

class _StudentMarksCard extends StatelessWidget {
  const _StudentMarksCard({
    super.key,
    required this.student,
    required this.terms,
    required this.controllerFor,
  });

  final _Student student;
  final List<_ExamTerm> terms;
  final TextEditingController Function(_Student student, _ExamTerm term)
      controllerFor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E7F3), width: 1.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF244CC8), Color(0xFF3485F5)],
                  ),
                ),
                child: Center(
                  child: Text(
                    student.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      student.id,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = _columnCount(constraints.maxWidth);
              const spacing = 18.0;
              final itemWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: 18,
                children: terms
                    .map(
                      (term) => SizedBox(
                        width: itemWidth,
                        child: _MarkInput(
                          key: ValueKey('${student.id}_${term.key}'),
                          label: term.label,
                          controller: controllerFor(student, term),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  int _columnCount(double width) {
    if (width >= 1080) {
      return 5;
    }
    if (width >= 820) {
      return 4;
    }
    if (width >= 520) {
      return 2;
    }
    return 1;
  }
}

class _MarkInput extends StatelessWidget {
  const _MarkInput({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD0DAF2), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFD0DAF2), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2D65D7), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
            ),
          ),
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            final mark = int.tryParse(trimmed);
            if (trimmed.isEmpty || mark == null || mark < 0 || mark > 100) {
              return '0-100';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _SaveMarksButton extends StatelessWidget {
  const _SaveMarksButton({
    required this.isMobile,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isMobile;
  final bool isSaving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 54 : 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 8,
          shadowColor: const Color(0x552552C2),
          backgroundColor: const Color(0xFF244CC8),
          disabledBackgroundColor: const Color(0xFF94A3B8),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 22 : 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Text(
                isMobile ? 'Save' : 'Save Marks',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _Student {
  const _Student(this.id, this.name, this.initials);

  final String id;
  final String name;
  final String initials;
}

class _ExamTerm {
  const _ExamTerm(this.key, this.label);

  final String key;
  final String label;
}
