import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.pageSurface(context),
          drawer: isMobile
              ? const Drawer(child: DashboardSidebar(activeItem: 'Students', showCollapseButton: false))
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Students'),
                const Expanded(child: _StudentsBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentsBody extends StatefulWidget {
  const _StudentsBody();

  @override
  State<_StudentsBody> createState() => _StudentsBodyState();
}

class _StudentsBodyState extends State<_StudentsBody> {
  static const int _pageSize = 10;
  int _currentPage = 1;
  _StudentsView _selectedView = _StudentsView.studentList;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _StatusFilter _statusFilter = _StatusFilter.all;
  String? _courseFilter;

  final List<_StudentItem> _allStudents = List.generate(50, (index) {
    final i = index + 1;
    final firstNames = [
      'Rajesh',
      'Priya',
      'Amit',
      'Sneha',
      'Rahul',
      'Anita',
      'Vikram',
      'Pooja',
      'Suresh',
      'Kavita',
    ];
    final lastNames = [
      'Kumar',
      'Sharma',
      'Singh',
      'Patel',
      'Verma',
      'Gupta',
      'Reddy',
      'Rao',
      'Joshi',
      'Nair',
    ];
    final schools = [
      'Govt High\nSchool, Delhi',
      'Central\nVocational\nInstitute',
      'Skill\nDevelopment\nCenter',
      'Technical\nTraining Hub',
    ];
    final courses = [
      'Web\nDevelopment',
      'Digital\nMarketing',
      'Graphic Design',
      'Mobile App\nDevelopment',
      'Data Science',
    ];

    return _StudentItem(
      'VT2024${i.toString().padLeft(3, '0')}',
      '${firstNames[index % firstNames.length]}\n${lastNames[index % lastNames.length]}',
      schools[index % schools.length],
      courses[index % courses.length],
      70 + ((index * 7) % 30),
      i % 6 != 0,
    );
  });

  List<_StudentItem> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();
    return _allStudents.where((student) {
      final matchesQuery =
          query.isEmpty ||
          student.rollNo.toLowerCase().contains(query) ||
          student.name.replaceAll('\n', ' ').toLowerCase().contains(query) ||
          student.school.replaceAll('\n', ' ').toLowerCase().contains(query);
      final matchesStatus = switch (_statusFilter) {
        _StatusFilter.all => true,
        _StatusFilter.active => student.isActive,
        _StatusFilter.inactive => !student.isActive,
      };
      final matchesCourse =
          _courseFilter == null ||
          student.course.replaceAll('\n', ' ') == _courseFilter;
      return matchesQuery && matchesStatus && matchesCourse;
    }).toList();
  }

  int get _totalPages {
    final pages = (_filteredStudents.length / _pageSize).ceil();
    return pages == 0 ? 1 : pages;
  }

  List<_StudentItem> get _pagedStudents {
    final list = _filteredStudents;
    if (list.isEmpty) return const [];
    final start = (_currentPage - 1) * _pageSize;
    final safeStart = start.clamp(0, list.length);
    final end = (safeStart + _pageSize).clamp(0, list.length);
    return list.sublist(safeStart, end);
  }

  List<String> get _courseOptions {
    final courses = _allStudents
        .map((student) => student.course.replaceAll('\n', ' '))
        .toSet()
        .toList();
    courses.sort();
    return courses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 1;
    });
  }

  Future<void> _openFilterDialog() async {
    var selectedStatus = _statusFilter;
    var selectedCourse = _courseFilter;

    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Students'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<_StatusFilter>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(
                    value: _StatusFilter.all,
                    child: Text('All'),
                  ),
                  DropdownMenuItem(
                    value: _StatusFilter.active,
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: _StatusFilter.inactive,
                    child: Text('Inactive'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => selectedStatus = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: selectedCourse,
                decoration: const InputDecoration(labelText: 'Course'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Courses'),
                  ),
                  ..._courseOptions.map(
                    (course) => DropdownMenuItem<String?>(
                      value: course,
                      child: Text(course),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    setDialogState(() => selectedCourse = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = _StatusFilter.all;
                  _courseFilter = null;
                  _currentPage = 1;
                });
                Navigator.pop(context, false);
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );

    if (shouldApply == true) {
      setState(() {
        _statusFilter = selectedStatus;
        _courseFilter = selectedCourse;
        _currentPage = 1;
      });
    }
  }

  Future<void> _exportStudents() async {
    final students = _filteredStudents;
    if (students.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No students to export.')));
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('Roll No,Name,School,Course,Attendance,Status');
    for (final student in students) {
      buffer.writeln(
        [
          _csv(student.rollNo),
          _csv(student.name.replaceAll('\n', ' ')),
          _csv(student.school.replaceAll('\n', ' ')),
          _csv(student.course.replaceAll('\n', ' ')),
          _csv('${student.attendance}%'),
          _csv(student.isActive ? 'Active' : 'Inactive'),
        ].join(','),
      );
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Exported ${students.length} students. CSV copied to clipboard.',
        ),
      ),
    );
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';

  void _handleAddStudent(_StudentItem student) {
    setState(() {
      _allStudents.insert(0, student);
      _currentPage = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student added successfully.')),
    );
  }

  void _viewStudentDetails(_StudentItem student) {
    showDialog(
      context: context,
      builder: (context) => _ViewStudentDialog(student: student),
    );
  }

  void _editStudent(_StudentItem student) {
    showDialog(
      context: context,
      builder: (context) => _EditStudentDialog(
        student: student,
        onSave: (updatedStudent) {
          setState(() {
            final index = _allStudents.indexWhere(
              (item) => item.rollNo == student.rollNo,
            );
            if (index != -1) {
              _allStudents[index] = updatedStudent;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Student updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _deleteStudent(_StudentItem student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text(
          'Are you sure you want to delete ${student.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardColors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _allStudents.remove(student);
                // Adjust current page if necessary
                if (_currentPage > _totalPages && _totalPages > 0) {
                  _currentPage = _totalPages;
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${student.name} deleted successfully.'),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 980;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isMobile),
                Divider(height: 1, color: DashboardColors.borderFor(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 32,
                      22,
                      isMobile ? 14 : 32,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, headerConstraints) {
                            final compact = headerConstraints.maxWidth < 940;
                            final titleBlock = const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student Management',
                                  style: TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 48 / 2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage student registrations, profiles, and academic records',
                                  style: TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 18 / 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                            final addButton = InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => showDialog(
                                context: context,
                                barrierColor: const Color(0xA6000000),
                                builder: (_) => _AddStudentDialog(
                                  onAddStudent: _handleAddStudent,
                                ),
                              ),
                              child: Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      DashboardColors.red,
                                      Color(0xFF2D65D7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x26EC3347),
                                      blurRadius: 16,
                                      spreadRadius: 1,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Add New Student',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (compact) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  titleBlock,
                                  const SizedBox(height: 14),
                                  addButton,
                                ],
                              );
                            }
                            return Row(
                              children: [titleBlock, const Spacer(), addButton],
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _SegmentedTabs(
                          isCompact: isMobile,
                          selectedView: _selectedView,
                          onViewChanged: (view) =>
                              setState(() => _selectedView = view),
                        ),
                        const SizedBox(height: 18),
                        if (_selectedView == _StudentsView.studentList)
                          _StudentTableCard(
                            students: _pagedStudents,
                            hasFilters:
                                _statusFilter != _StatusFilter.all ||
                                _courseFilter != null,
                            isCompact: isMobile,
                            currentPage: _currentPage,
                            totalItems: _filteredStudents.length,
                            totalPages: _totalPages,
                            searchController: _searchController,
                            onSearchChanged: _onSearchChanged,
                            onFilterTap: _openFilterDialog,
                            onExportTap: _exportStudents,
                            onPrevious: _currentPage > 1
                                ? () => setState(() => _currentPage--)
                                : null,
                            onNext: _currentPage < _totalPages
                                ? () => setState(() => _currentPage++)
                                : null,
                            onSelectPage: (page) =>
                                setState(() => _currentPage = page),
                            onViewStudent: _viewStudentDetails,
                            onEditStudent: _editStudent,
                            onDeleteStudent: _deleteStudent,
                          )
                        else
                          const _AddStudentSection(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(right: 24, bottom: 36, child: _FloatingPlus()),
          ],
        );
      },
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.isCompact,
    required this.selectedView,
    required this.onViewChanged,
  });

  final bool isCompact;
  final _StudentsView selectedView;
  final ValueChanged<_StudentsView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? double.infinity : 520,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFD9DFF0),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTabButton(
              label: 'Student List',
              selected: selectedView == _StudentsView.studentList,
              onTap: () => onViewChanged(_StudentsView.studentList),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegmentTabButton(
              label: 'Add Student',
              selected: selectedView == _StudentsView.addStudent,
              onTap: () => onViewChanged(_StudentsView.addStudent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTabButton extends StatelessWidget {
  const _SegmentTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = selected
        ? BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [DashboardColors.red, Color(0xFF2D65D7)],
            ),
            borderRadius: BorderRadius.circular(14),
          )
        : BoxDecoration(borderRadius: BorderRadius.circular(14));

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        decoration: decoration,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : DashboardColors.text,
              fontSize: 16 / 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddStudentSection extends StatefulWidget {
  const _AddStudentSection();

  @override
  State<_AddStudentSection> createState() => _AddStudentSectionState();
}

class _AddStudentSectionState extends State<_AddStudentSection> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  String? _gender;
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  final _rollNoController = TextEditingController();
  final _schoolController = TextEditingController();
  final _courseController = TextEditingController();
  final _batchController = TextEditingController();

  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _addressController = TextEditingController();

  final Map<String, String> _uploadedDocuments = {};

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _rollNoController.dispose();
    _schoolController.dispose();
    _courseController.dispose();
    _batchController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 780;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1FF0445A), width: 2),
      ),
      child: Column(
        children: [
          _AccordionSection(
            title: 'Personal Details',
            isMobile: isMobile,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _LabeledField(
                  label: 'First Name',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: _fieldDecoration('Enter first name'),
                  ),
                ),
                _LabeledField(
                  label: 'Last Name',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: _fieldDecoration('Enter last name'),
                  ),
                ),
                _LabeledField(
                  label: 'Date of Birth',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: _pickDob,
                    decoration: _fieldDecoration('dd-mm-yyyy').copyWith(
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ),
                _LabeledField(
                  label: 'Gender',
                  expand: isMobile,
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: _fieldDecoration('Select gender'),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                ),
                _LabeledField(
                  label: 'Mobile Number',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration('Enter mobile number'),
                  ),
                ),
                _LabeledField(
                  label: 'Email',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration('Enter email'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AccordionSection(
            title: 'Academic Details',
            isMobile: isMobile,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _LabeledField(
                  label: 'Roll No',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _rollNoController,
                    decoration: _fieldDecoration('Enter roll no'),
                  ),
                ),
                _LabeledField(
                  label: 'School',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _schoolController,
                    decoration: _fieldDecoration('Enter school'),
                  ),
                ),
                _LabeledField(
                  label: 'Course',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _courseController,
                    decoration: _fieldDecoration('Enter course'),
                  ),
                ),
                _LabeledField(
                  label: 'Batch',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _batchController,
                    decoration: _fieldDecoration('Enter batch'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AccordionSection(
            title: 'Parent/Guardian Details',
            isMobile: isMobile,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _LabeledField(
                  label: 'Parent Name',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _parentNameController,
                    decoration: _fieldDecoration('Enter parent name'),
                  ),
                ),
                _LabeledField(
                  label: 'Parent Phone No',
                  expand: isMobile,
                  child: TextFormField(
                    controller: _parentPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration('Enter parent phone no'),
                  ),
                ),
                _LabeledField(
                  label: 'Address',
                  expand: true,
                  child: TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: _fieldDecoration('Enter address'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AccordionSection(
            title: 'Documents Upload',
            isMobile: isMobile,
            child: Column(
              children: [
                _UploadRow(
                  label: 'Aadhaar Card',
                  uploadedFile: _uploadedDocuments['Aadhaar Card'],
                  onUpload: () => _uploadDocument('Aadhaar Card'),
                ),
                const SizedBox(height: 10),
                _UploadRow(
                  label: 'Passport Photo',
                  uploadedFile: _uploadedDocuments['Passport Photo'],
                  onUpload: () => _uploadDocument('Passport Photo'),
                ),
                const SizedBox(height: 10),
                _UploadRow(
                  label: 'School Certificate',
                  uploadedFile: _uploadedDocuments['School Certificate'],
                  onUpload: () => _uploadDocument('School Certificate'),
                ),
                const SizedBox(height: 10),
                _UploadRow(
                  label: 'Additional Document',
                  uploadedFile: _uploadedDocuments['Additional Document'],
                  onUpload: () => _uploadDocument('Additional Document'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ActionButton(
                  label: 'Save Draft',
                  backgroundColor: const Color(0xFFE9EEF4),
                  textColor: const Color(0xFF2D65D7),
                  onPressed: _saveDraft,
                  fullWidth: true,
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  label: 'Submit Registration',
                  backgroundColor: const Color(0xFF2552C2),
                  textColor: Colors.white,
                  onPressed: _submitRegistration,
                  fullWidth: true,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: 'Save Draft',
                  backgroundColor: const Color(0xFFE9EEF4),
                  textColor: const Color(0xFF2D65D7),
                  onPressed: _saveDraft,
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  label: 'Submit Registration',
                  backgroundColor: const Color(0xFF2552C2),
                  textColor: Colors.white,
                  onPressed: _submitRegistration,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 16, now.month, now.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    final dd = picked.day.toString().padLeft(2, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    _dobController.text = '$dd-$mm-${picked.year}';
    setState(() {});
  }

  Future<void> _uploadDocument(String documentType) async {
    final controller = TextEditingController();
    final fileName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload $documentType'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter file name (example.pdf)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (fileName == null || fileName.isEmpty) return;
    setState(() => _uploadedDocuments[documentType] = fileName);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$documentType uploaded: $fileName')),
    );
  }

  void _saveDraft() {
    // Basic validation for draft save
    final hasAnyData =
        _firstNameController.text.isNotEmpty ||
        _lastNameController.text.isNotEmpty ||
        _rollNoController.text.isNotEmpty ||
        _schoolController.text.isNotEmpty ||
        _courseController.text.isNotEmpty;

    if (!hasAnyData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill at least one field to save draft.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // In a real app, this would save to local storage or database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _submitRegistration() {
    // Validation for required fields
    final errors = <String>[];

    if (_firstNameController.text.trim().isEmpty) {
      errors.add('First Name is required');
    }
    if (_lastNameController.text.trim().isEmpty) {
      errors.add('Last Name is required');
    }
    if (_rollNoController.text.trim().isEmpty) {
      errors.add('Roll No is required');
    }
    if (_schoolController.text.trim().isEmpty) {
      errors.add('School is required');
    }
    if (_courseController.text.trim().isEmpty) {
      errors.add('Course is required');
    }
    if (_gender == null || _gender!.isEmpty) {
      errors.add('Gender is required');
    }
    if (_mobileController.text.trim().isEmpty) {
      errors.add('Mobile Number is required');
    }
    if (_emailController.text.trim().isEmpty) {
      errors.add('Email is required');
    }
    if (_parentNameController.text.trim().isEmpty) {
      errors.add('Parent Name is required');
    }
    if (_parentPhoneController.text.trim().isEmpty) {
      errors.add('Parent Phone No is required');
    }
    if (_addressController.text.trim().isEmpty) {
      errors.add('Address is required');
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Errors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors.map((error) => Text('• $error')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Create student object
    final student = _StudentItem(
      _rollNoController.text.trim(),
      '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
      _schoolController.text.trim(),
      _courseController.text.trim(),
      0, // Default attendance
      true, // Default active status
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${student.name} registration submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form after successful submission
    _clearForm();
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _dobController.clear();
    _gender = null;
    _mobileController.clear();
    _emailController.clear();
    _rollNoController.clear();
    _schoolController.clear();
    _courseController.clear();
    _batchController.clear();
    _parentNameController.clear();
    _parentPhoneController.clear();
    _addressController.clear();
    _uploadedDocuments.clear();
    setState(() {});
  }

  InputDecoration _fieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB8C3E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2552C2), width: 1.4),
      ),
    );
  }
}

class _AccordionSection extends StatefulWidget {
  const _AccordionSection({
    required this.title,
    required this.child,
    required this.isMobile,
  });

  final String title;
  final Widget child;
  final bool isMobile;

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2552C2), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
          collapsedIconColor: const Color(0xFF6B7280),
          iconColor: const Color(0xFF6B7280),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          title: Text(
            widget.title,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [widget.child],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.child,
    this.expand = false,
  });

  final String label;
  final Widget child;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      width: expand ? double.infinity : 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
    return field;
  }
}

class _UploadRow extends StatelessWidget {
  const _UploadRow({
    required this.label,
    required this.uploadedFile,
    required this.onUpload,
  });

  final String label;
  final String? uploadedFile;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasFile = uploadedFile != null && uploadedFile!.isNotEmpty;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 460;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasFile) ...[
                const SizedBox(height: 6),
                Text(
                  uploadedFile!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2552C2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2552C2),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(hasFile ? 'Re-upload' : 'Upload'),
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasFile)
              Expanded(
                child: Text(
                  uploadedFile!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2552C2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2552C2),
                foregroundColor: Colors.white,
              ),
              child: Text(hasFile ? 'Re-upload' : 'Upload'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.fullWidth = false,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Container(
        height: 48,
        width: fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: DashboardColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: DashboardColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewStudentDialog extends StatelessWidget {
  const _ViewStudentDialog({required this.student});

  final _StudentItem student;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Student Details',
                      style: TextStyle(
                        color: DashboardColors.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: DashboardColors.text,
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFD9DFF0)),
              const SizedBox(height: 16),
              _DetailRow(label: 'Roll No', value: student.rollNo),
              _DetailRow(label: 'Name', value: student.name),
              _DetailRow(label: 'School', value: student.school),
              _DetailRow(label: 'Course', value: student.course),
              _DetailRow(label: 'Attendance', value: '${student.attendance}%'),
              _DetailRow(
                label: 'Status',
                value: student.isActive ? 'Active' : 'Inactive',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditStudentDialog extends StatefulWidget {
  const _EditStudentDialog({required this.student, required this.onSave});

  final _StudentItem student;
  final ValueChanged<_StudentItem> onSave;

  @override
  State<_EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<_EditStudentDialog> {
  late final TextEditingController _rollNoController;
  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;
  late final TextEditingController _courseController;
  late final TextEditingController _attendanceController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _rollNoController = TextEditingController(text: widget.student.rollNo);
    _nameController = TextEditingController(text: widget.student.name);
    _schoolController = TextEditingController(text: widget.student.school);
    _courseController = TextEditingController(text: widget.student.course);
    _attendanceController = TextEditingController(
      text: widget.student.attendance.toString(),
    );
    _isActive = widget.student.isActive;
  }

  @override
  void dispose() {
    _rollNoController.dispose();
    _nameController.dispose();
    _schoolController.dispose();
    _courseController.dispose();
    _attendanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit Student',
                        style: TextStyle(
                          color: DashboardColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: DashboardColors.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _EditField(label: 'Roll No', controller: _rollNoController),
                const SizedBox(height: 12),
                _EditField(label: 'Name', controller: _nameController),
                const SizedBox(height: 12),
                _EditField(label: 'School', controller: _schoolController),
                const SizedBox(height: 12),
                _EditField(label: 'Course', controller: _courseController),
                const SizedBox(height: 12),
                _EditField(
                  label: 'Attendance (%)',
                  controller: _attendanceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        color: DashboardColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<bool>(
                        initialValue: _isActive,
                        decoration: _editFieldDecoration('Select status'),
                        items: const [
                          DropdownMenuItem(value: true, child: Text('Active')),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _isActive = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2552C2),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 44),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveChanges() {
    final rollNo = _rollNoController.text.trim();
    final name = _nameController.text.trim();
    final school = _schoolController.text.trim();
    final course = _courseController.text.trim();
    final attendance = int.tryParse(_attendanceController.text.trim()) ?? -1;

    final errors = <String>[];
    if (rollNo.isEmpty) errors.add('Roll No is required.');
    if (name.isEmpty) errors.add('Name is required.');
    if (school.isEmpty) errors.add('School is required.');
    if (course.isEmpty) errors.add('Course is required.');
    if (attendance < 0 || attendance > 100) {
      errors.add('Attendance must be between 0 and 100.');
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors.map((error) => Text('• $error')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onSave(
      _StudentItem(rollNo, name, school, course, attendance, _isActive),
    );
    Navigator.pop(context);
  }

  InputDecoration _editFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB8C3E6), width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2552C2), width: 1.5),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: DashboardColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFB8C3E6),
                width: 1.3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2552C2),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentTableCard extends StatelessWidget {
  const _StudentTableCard({
    required this.students,
    required this.hasFilters,
    required this.isCompact,
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.onExportTap,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectPage,
    required this.onViewStudent,
    required this.onEditStudent,
    required this.onDeleteStudent,
  });

  final List<_StudentItem> students;
  final bool hasFilters;
  final bool isCompact;
  final int currentPage;
  final int totalItems;
  final int totalPages;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final VoidCallback onExportTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onSelectPage;
  final ValueChanged<_StudentItem> onViewStudent;
  final ValueChanged<_StudentItem> onEditStudent;
  final ValueChanged<_StudentItem> onDeleteStudent;

  @override
  Widget build(BuildContext context) {
    final start = totalItems == 0 ? 0 : ((currentPage - 1) * 10) + 1;
    final end = (start + students.length - 1).clamp(0, totalItems);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1FF0445A), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: isCompact
                  ? Column(
                      children: [
                        _SearchBar(
                          controller: searchController,
                          onChanged: onSearchChanged,
                        ),
                        const SizedBox(height: 10),
                        _TableActions(
                          hasFilters: hasFilters,
                          onFilterTap: onFilterTap,
                          onExportTap: onExportTap,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _SearchBar(
                            controller: searchController,
                            onChanged: onSearchChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _TableActions(
                          hasFilters: hasFilters,
                          onFilterTap: onFilterTap,
                          onExportTap: onExportTap,
                        ),
                      ],
                    ),
            ),
            const Divider(height: 1, color: Color(0x1FF0445A)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: isCompact ? 920 : 1040,
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFFF5F3F4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: const Row(
                        children: [
                          _HeadCell('Roll No', flex: 8),
                          _HeadCell('Name', flex: 10),
                          _HeadCell('School', flex: 12),
                          _HeadCell('Course', flex: 10),
                          _HeadCell('Attendance', flex: 8),
                          _HeadCell('Status', flex: 6),
                          _HeadCell('Actions', flex: 10),
                        ],
                      ),
                    ),
                    ...students.asMap().entries.map(
                      (entry) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: entry.key == students.length - 1
                              ? null
                              : const Border(
                                  bottom: BorderSide(
                                    color: DashboardColors.border,
                                    width: 1.2,
                                  ),
                                ),
                        ),
                        child: Row(
                          children: [
                            _BodyCell(entry.value.rollNo, flex: 8),
                            _BodyCell(entry.value.name, flex: 10, isBold: true),
                            _BodyCell(entry.value.school, flex: 12),
                            _BodyCell(entry.value.course, flex: 10),
                            _AttendanceCell(
                              percent: entry.value.attendance,
                              flex: 8,
                            ),
                            _StatusCell(
                              isActive: entry.value.isActive,
                              flex: 6,
                            ),
                            _ActionCell(
                              flex: 10,
                              student: entry.value,
                              onView: () => onViewStudent(entry.value),
                              onEdit: () => onEditStudent(entry.value),
                              onDelete: () => onDeleteStudent(entry.value),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (students.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Text(
                  'No students found for current search/filter.',
                  style: TextStyle(
                    color: Color(0xFF7F90A4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const Divider(height: 1, color: Color(0x1FF0445A)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: isCompact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Showing $start to $end of $totalItems students',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 14 / 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        _Pagination(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          onPrevious: onPrevious,
                          onNext: onNext,
                          onSelectPage: onSelectPage,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          'Showing $start to $end of $totalItems students',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 14 / 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        _Pagination(
                          currentPage: currentPage,
                          totalPages: totalPages,
                          onPrevious: onPrevious,
                          onNext: onNext,
                          onSelectPage: onSelectPage,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x44E06075), width: 2),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
          prefixIconConstraints: BoxConstraints(minWidth: 46),
          hintText: 'Search by name, roll number, or school...',
          hintStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 33 / 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TableActions extends StatelessWidget {
  const _TableActions({
    required this.hasFilters,
    required this.onFilterTap,
    required this.onExportTap,
  });

  final bool hasFilters;
  final VoidCallback onFilterTap;
  final VoidCallback onExportTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _ActionChip(
          icon: Icons.filter_alt_outlined,
          text: hasFilters ? 'Filter On' : 'Filter',
          background: const Color(0xFFF7EBEE),
          textColor: DashboardColors.red,
          onTap: onFilterTap,
        ),
        _ActionChip(
          icon: Icons.download_rounded,
          text: 'Export',
          background: const Color(0xFFE9EEF4),
          textColor: const Color(0xFF2D65D7),
          onTap: onExportTap,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.text,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16 / 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell(this.text, {required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: DashboardColors.text,
          fontSize: 35 / 2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(this.text, {required this.flex, this.isBold = false});

  final String text;
  final int flex;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: DashboardColors.text,
          fontSize: 36 / 2,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          height: 1.35,
        ),
      ),
    );
  }
}

class _AttendanceCell extends StatelessWidget {
  const _AttendanceCell({required this.percent, required this.flex});

  final int percent;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 9,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [DashboardColors.red, Color(0xFF2D65D7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$percent%',
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 33 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({required this.isActive, required this.flex});

  final bool isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD1F0D8) : const Color(0xFFFFDDE0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: isActive ? const Color(0xFF00853A) : DashboardColors.red,
              fontSize: 30 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({
    required this.flex,
    required this.student,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final int flex;
  final _StudentItem student;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.remove_red_eye_outlined,
              color: DashboardColors.red,
              size: 18,
            ),
            onPressed: onView,
            tooltip: 'View Student Details',
          ),
          const SizedBox(width: 6),
          IconButton(
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF2D65D7),
              size: 18,
            ),
            onPressed: onEdit,
            tooltip: 'Edit Student',
          ),
          const SizedBox(width: 6),
          IconButton(
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: DashboardColors.red,
              size: 18,
            ),
            onPressed: onDelete,
            tooltip: 'Delete Student',
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectPage,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onSelectPage;

  @override
  Widget build(BuildContext context) {
    final pages = List<int>.generate(totalPages, (index) => index + 1);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _PageButton(
          label: 'Previous',
          wide: true,
          muted: onPrevious == null,
          onTap: onPrevious,
        ),
        ...pages.map(
          (page) => _PageButton(
            label: '$page',
            active: currentPage == page,
            onTap: () => onSelectPage(page),
          ),
        ),
        _PageButton(
          label: 'Next',
          wide: true,
          muted: onNext == null,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    this.active = false,
    this.wide = false,
    this.muted = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final bool wide;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 40,
        constraints: BoxConstraints(minWidth: wide ? 84 : 40),
        padding: EdgeInsets.symmetric(horizontal: wide ? 14 : 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [DashboardColors.red, Color(0xFF2D65D7)],
                )
              : null,
          color: active ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DashboardColors.border, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : (muted ? const Color(0xFF9BA8B8) : DashboardColors.text),
              fontSize: 15 / 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingPlus extends StatelessWidget {
  const _FloatingPlus();

  @override
  Widget build(BuildContext context) {
    return const DashboardQuickActionsFab();
  }
}

class _StudentItem {
  const _StudentItem(
    this.rollNo,
    this.name,
    this.school,
    this.course,
    this.attendance,
    this.isActive,
  );

  final String rollNo;
  final String name;
  final String school;
  final String course;
  final int attendance;
  final bool isActive;
}

enum _StatusFilter { all, active, inactive }

enum _StudentsView { studentList, addStudent }

class _AddStudentDialog extends StatefulWidget {
  const _AddStudentDialog({required this.onAddStudent});

  final ValueChanged<_StudentItem> onAddStudent;

  @override
  State<_AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<_AddStudentDialog> {
  final Map<String, String?> _dropdownValues = {};
  final Map<String, TextEditingController> _textControllers = {};
  final List<_FormSectionDef> _sections = const [
    _FormSectionDef(
      title: 'Personal Details',
      fields: [
        _FieldDef(label: 'First Name', kind: _FieldKind.text),
        _FieldDef(label: 'Middle Name', kind: _FieldKind.text),
        _FieldDef(label: 'Last Name', kind: _FieldKind.text),
        _FieldDef(label: 'Date of Birth', kind: _FieldKind.date),
        _FieldDef(label: 'Age', kind: _FieldKind.text),
        _FieldDef(
          label: 'Gender',
          kind: _FieldKind.dropdown,
          options: ['Male', 'Female', 'Other'],
        ),
        _FieldDef(
          label: 'Social Category',
          kind: _FieldKind.dropdown,
          options: ['General', 'OBC', 'SC', 'ST', 'EWS'],
        ),
        _FieldDef(label: 'Aadhaar Number', kind: _FieldKind.text),
      ],
    ),
    _FormSectionDef(
      title: 'Parent Details',
      fields: [
        _FieldDef(label: "Father's Name", kind: _FieldKind.text),
        _FieldDef(label: "Mother's Name", kind: _FieldKind.text),
        _FieldDef(label: 'Parent Mobile Number', kind: _FieldKind.text),
        _FieldDef(label: 'Alternate Mobile Number', kind: _FieldKind.text),
      ],
    ),
    _FormSectionDef(
      title: 'Academic Details',
      fields: [
        _FieldDef(label: 'Roll No', kind: _FieldKind.text),
        _FieldDef(
          label: 'Class Standard',
          kind: _FieldKind.dropdown,
          options: [
            'Class 1',
            'Class 2',
            'Class 3',
            'Class 4',
            'Class 5',
            'Class 6',
            'Class 7',
            'Class 8',
            'Class 9',
            'Class 10',
            'Class 11',
            'Class 12',
          ],
        ),
        _FieldDef(
          label: 'School',
          kind: _FieldKind.dropdown,
          options: [
            'Govt High School, Delhi',
            'Central Vocational Institute',
            'Skill Development Center',
          ],
        ),
        _FieldDef(
          label: 'Trade / Stream',
          kind: _FieldKind.dropdown,
          options: [
            'MPC (Maths, Physics, Chemistry)',
            'MEC (Maths, Economics, Commerce)',
            'BIPC (Biology, Physics, Chemistry)',
            'Web Development',
            'Digital Marketing',
            'Graphic Design',
            'Beauty & Wellness',
            'IT/ITES',
            'Agriculture',
          ],
        ),
        _FieldDef(label: 'Previous Qualification', kind: _FieldKind.text),
      ],
    ),
    _FormSectionDef(
      title: 'Additional Information',
      fields: [
        _FieldDef(
          label: 'Interested in Higher Education?',
          kind: _FieldKind.dropdown,
          options: ['Yes', 'No'],
        ),
        _FieldDef(
          label: 'Interested in Upskilling?',
          kind: _FieldKind.dropdown,
          options: ['Yes', 'No'],
        ),
        _FieldDef(
          label: 'Interested in Apprenticeship (NAPS)?',
          kind: _FieldKind.dropdown,
          options: ['Yes', 'No'],
        ),
        _FieldDef(
          label: 'Interested in Career Counselling?',
          kind: _FieldKind.dropdown,
          options: ['Yes', 'No'],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    for (final section in _sections) {
      for (final field in section.fields) {
        if (field.kind != _FieldKind.dropdown) {
          _textControllers[_fieldKey(section.title, field.label)] =
              TextEditingController();
        }
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 920;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 24,
        vertical: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 18, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Student',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 42 / 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Complete student information',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16 / 1.2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: DashboardColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFD9DFF0)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                child: Column(
                  children: _sections
                      .map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StudentAccordionSection(
                            title: section.title,
                            fields: section.fields,
                            compact: compact,
                            values: _dropdownValues,
                            textControllers: _textControllers,
                            onChanged: (key, value) {
                              setState(() {
                                _dropdownValues[key] = value;
                              });
                            },
                            onDateTap: _pickDateForKey,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFD9DFF0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactActions = constraints.maxWidth < 430;
                  final submitButton = InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      final rollNo =
                          _textControllers[_fieldKey(
                                'Academic Details',
                                'Roll No',
                              )]
                              ?.text
                              .trim() ??
                          '';
                      final firstName =
                          _textControllers[_fieldKey(
                                'Personal Details',
                                'First Name',
                              )]
                              ?.text
                              .trim() ??
                          '';
                      final middleName =
                          _textControllers[_fieldKey(
                                'Personal Details',
                                'Middle Name',
                              )]
                              ?.text
                              .trim() ??
                          '';
                      final lastName =
                          _textControllers[_fieldKey(
                                'Personal Details',
                                'Last Name',
                              )]
                              ?.text
                              .trim() ??
                          '';
                      final school =
                          _dropdownValues[_fieldKey(
                            'Academic Details',
                            'School',
                          )] ??
                          '-';
                      final stream =
                          _dropdownValues[_fieldKey(
                            'Academic Details',
                            'Trade / Stream',
                          )] ??
                          '-';

                      if (rollNo.isEmpty ||
                          firstName.isEmpty ||
                          school == '-') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill Roll No, First Name, and School.',
                            ),
                          ),
                        );
                        return;
                      }

                      final fullName = [
                        firstName,
                        middleName,
                        lastName,
                      ].where((part) => part.isNotEmpty).join(' ');

                      widget.onAddStudent(
                        _StudentItem(rollNo, fullName, school, stream, 0, true),
                      );
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 48,
                      width: compactActions ? double.infinity : null,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          'Add Student',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                  if (compactActions) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(96, 48),
                            side: const BorderSide(
                              color: Color(0xFFD9DFF0),
                              width: 1.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: DashboardColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        submitButton,
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(96, 48),
                          side: const BorderSide(
                            color: Color(0xFFD9DFF0),
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      submitButton,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDateForKey(String key) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 15, now.month, now.day),
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    final dd = picked.day.toString().padLeft(2, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final yyyy = picked.year.toString();
    _textControllers[key]?.text = '$dd-$mm-$yyyy';
    setState(() {});
  }
}

class _StudentAccordionSection extends StatelessWidget {
  const _StudentAccordionSection({
    required this.title,
    required this.fields,
    required this.compact,
    required this.values,
    required this.textControllers,
    required this.onChanged,
    required this.onDateTap,
  });

  final String title;
  final List<_FieldDef> fields;
  final bool compact;
  final Map<String, String?> values;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String? value) onChanged;
  final ValueChanged<String> onDateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2552C2), width: 1.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
          collapsedIconColor: const Color(0xFF6B7280),
          iconColor: const Color(0xFF6B7280),
          title: Text(
            title,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final sectionCompact = compact || constraints.maxWidth < 900;
                final fieldWidth = sectionCompact
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 14) / 2;
                return Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: fields
                      .map(
                        (field) => SizedBox(
                          width: fieldWidth,
                          child: _StudentField(
                            label: field.label,
                            kind: field.kind,
                            value: values[_fieldKey(title, field.label)],
                            controller:
                                textControllers[_fieldKey(title, field.label)],
                            options: field.options ?? const [],
                            onChanged: (val) =>
                                onChanged(_fieldKey(title, field.label), val),
                            onDateTap: () =>
                                onDateTap(_fieldKey(title, field.label)),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentField extends StatelessWidget {
  const _StudentField({
    required this.label,
    required this.kind,
    required this.value,
    required this.controller,
    required this.options,
    required this.onChanged,
    this.onDateTap,
  });

  final String label;
  final _FieldKind kind;
  final String? value;
  final TextEditingController? controller;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onDateTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        if (kind == _FieldKind.dropdown)
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            onChanged: onChanged,
            items: options
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            decoration: _inputDecoration('Select $label'),
          )
        else
          TextFormField(
            controller: controller,
            readOnly: kind == _FieldKind.date,
            onTap: kind == _FieldKind.date ? onDateTap : null,
            decoration:
                _inputDecoration(
                  kind == _FieldKind.date ? 'dd-mm-yyyy' : 'Enter $label',
                ).copyWith(
                  suffixIcon: kind == _FieldKind.date
                      ? const Icon(Icons.calendar_today_outlined, size: 18)
                      : null,
                ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB8C3E6), width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2552C2), width: 1.5),
      ),
    );
  }
}

class _FormSectionDef {
  const _FormSectionDef({required this.title, required this.fields});

  final String title;
  final List<_FieldDef> fields;
}

class _FieldDef {
  const _FieldDef({required this.label, required this.kind, this.options});

  final String label;
  final _FieldKind kind;
  final List<String>? options;
}

enum _FieldKind { text, dropdown, date }

String _fieldKey(String section, String label) => '$section::$label';
