import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../VTP Manager/bill_download_service.dart'
    if (dart.library.io) '../VTP Manager/bill_download_service_io.dart'
    if (dart.library.html) '../VTP Manager/bill_download_service_web.dart';
import 'appbar.dart';
import 'sidebar.dart';

class StudentEnrollmentPage extends StatelessWidget {
  const StudentEnrollmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(
                    activeItem: 'Student Enrollment',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Student Enrollment'),
                const Expanded(child: _EnrollmentBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnrollmentBody extends StatefulWidget {
  const _EnrollmentBody();

  @override
  State<_EnrollmentBody> createState() => _EnrollmentBodyState();
}

class _EnrollmentBodyState extends State<_EnrollmentBody> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _age = TextEditingController();
  final _aadhaar = TextEditingController();
  final _father = TextEditingController();
  final _mother = TextEditingController();
  final _mobile = TextEditingController();
  final _trade = TextEditingController();
  String _gender = 'Male';
  bool _showForm = false;

  final List<_EnrollmentStudent> _students = [
    const _EnrollmentStudent(
      name: 'Rajesh Kumar Sharma',
      age: '16',
      aadhaar: '1234-5678-9012',
      mobile: '+91 98765 43210',
      dob: '2008-05-15',
      father: 'Vijay Sharma',
      trade: 'Electrician',
      gender: 'Male',
      mother: 'Sunita Sharma',
      enrolled: '2024-04-01',
    ),
    const _EnrollmentStudent(
      name: 'Priya Devi Patel',
      age: '15',
      aadhaar: '2345-6789-0123',
      mobile: '+91 97654 32109',
      dob: '2009-08-22',
      father: 'Ramesh Patel',
      trade: 'Computer Operator',
      gender: 'Female',
      mother: 'Lakshmi Patel',
      enrolled: '2024-04-02',
    ),
  ];

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _dob.dispose();
    _age.dispose();
    _aadhaar.dispose();
    _father.dispose();
    _mother.dispose();
    _mobile.dispose();
    _trade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: constraints.maxWidth < 980),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 16 : 32,
                      isCompact ? 24 : 34,
                      isCompact ? 16 : 32,
                      96,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeader(
                          isCompact: isCompact,
                          isAdding: _showForm,
                          onAddTap: _toggleForm,
                          onDownloadTap: _downloadEnrollmentData,
                        ),
                        const SizedBox(height: 28),
                        if (_showForm) ...[
                          _EnrollmentForm(
                            formKey: _formKey,
                            firstName: _firstName,
                            middleName: _middleName,
                            lastName: _lastName,
                            dob: _dob,
                            age: _age,
                            aadhaar: _aadhaar,
                            father: _father,
                            mother: _mother,
                            mobile: _mobile,
                            trade: _trade,
                            gender: _gender,
                            onGenderChanged: (value) {
                              if (value == null) return;
                              setState(() => _gender = value);
                            },
                            onPickDate: _pickDate,
                            onSubmit: _enrollStudent,
                          ),
                          const SizedBox(height: 24),
                        ],
                        ..._students.map(
                          (student) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _EnrollmentCard(student: student),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isCompact ? 16 : 32,
              bottom: 28,
              child: _AddStudentFab(onTap: _toggleForm),
            ),
          ],
        );
      },
    );
  }

  void _toggleForm() {
    setState(() => _showForm = !_showForm);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    _dob.text =
        '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year.toString().padLeft(4, '0')}';
  }

  void _enrollStudent() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final middle = _middleName.text.trim();
    final fullName = [
      _firstName.text.trim(),
      if (middle.isNotEmpty) middle,
      _lastName.text.trim(),
    ].join(' ');
    final now = DateTime.now();

    setState(() {
      _students.insert(
        0,
        _EnrollmentStudent(
          name: fullName,
          age: _age.text.trim(),
          aadhaar: _aadhaar.text.trim(),
          mobile: _mobile.text.trim(),
          dob: _dob.text.trim(),
          father: _father.text.trim(),
          trade: _trade.text.trim(),
          gender: _gender,
          mother: _mother.text.trim(),
          enrolled:
              '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        ),
      );
      _showForm = false;
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fullName enrolled successfully.')),
    );
  }

  void _clearForm() {
    _firstName.clear();
    _middleName.clear();
    _lastName.clear();
    _dob.clear();
    _age.clear();
    _aadhaar.clear();
    _father.clear();
    _mother.clear();
    _mobile.clear();
    _trade.clear();
    _gender = 'Male';
  }

  Future<void> _downloadEnrollmentData() async {
    final header = [
      'Name',
      'Age',
      'Aadhaar',
      'Mobile',
      'DOB',
      'Father',
      'Trade',
      'Gender',
      'Mother',
      'Enrolled',
    ].map(_csv).join(',');
    final rows = _students.map((student) {
      return [
        student.name,
        student.age,
        student.aadhaar,
        student.mobile,
        student.dob,
        student.father,
        student.trade,
        student.gender,
        student.mother,
        student.enrolled,
      ].map(_csv).join(',');
    }).join('\n');

    try {
      final location = await downloadBillFile(
        fileName: 'student_enrollment_data.csv',
        content: '$header\n$rows',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrollment data downloaded: $location')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download enrollment data.')),
      );
    }
  }

  String _csv(String value) => '"${value.replaceAll('"', '""')}"';
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.isCompact,
    required this.isAdding,
    required this.onAddTap,
    required this.onDownloadTap,
  });

  final bool isCompact;
  final bool isAdding;
  final VoidCallback onAddTap;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final titleBlock = const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Enrollment Data',
          style: TextStyle(
            color: Color(0xFF020817),
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage student enrollment records',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _HeaderButton(
          label: 'Download',
          icon: Icons.download_rounded,
          isPrimary: false,
          onTap: onDownloadTap,
        ),
        _HeaderButton(
          label: isAdding ? 'Cancel' : 'Add Student',
          icon: Icons.add_rounded,
          isPrimary: true,
          onTap: onAddTap,
        ),
      ],
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 18),
          actions,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        actions,
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isPrimary ? Colors.white : const Color(0xFF1D4ED8);

    return Material(
      color: isPrimary ? const Color(0xFF3475E6) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: isPrimary ? 8 : 0,
      shadowColor: isPrimary ? const Color(0x553475E6) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isPrimary ? const Color(0xFF3475E6) : const Color(0xFF1D4ED8),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: foreground),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrollmentForm extends StatelessWidget {
  const _EnrollmentForm({
    required this.formKey,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dob,
    required this.age,
    required this.aadhaar,
    required this.father,
    required this.mother,
    required this.mobile,
    required this.trade,
    required this.gender,
    required this.onGenderChanged,
    required this.onPickDate,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstName;
  final TextEditingController middleName;
  final TextEditingController lastName;
  final TextEditingController dob;
  final TextEditingController age;
  final TextEditingController aadhaar;
  final TextEditingController father;
  final TextEditingController mother;
  final TextEditingController mobile;
  final TextEditingController trade;
  final String gender;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        Widget fieldRow(Widget first, Widget second) {
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                first,
                const SizedBox(height: 14),
                second,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 16),
              Expanded(child: second),
            ],
          );
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB8C7FF), width: 1.1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enroll New Student',
                  style: TextStyle(
                    color: Color(0xFF020817),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Column(
                  children: [
                    fieldRow(
                      _FormFieldBox(
                        label: 'First Name *',
                        controller: firstName,
                        inputFormatters: [_nameFormatter],
                        validator: _validateName,
                      ),
                      _FormFieldBox(
                        label: 'Middle Name',
                        controller: middleName,
                        isRequired: false,
                        inputFormatters: [_nameFormatter],
                        validator: _validateOptionalName,
                      ),
                    ),
                    const SizedBox(height: 14),
                    fieldRow(
                      _FormFieldBox(
                        label: 'Last Name *',
                        controller: lastName,
                        inputFormatters: [_nameFormatter],
                        validator: _validateName,
                      ),
                      _FormFieldBox(
                        label: 'Date of Birth *',
                        controller: dob,
                        hint: 'dd-mm-yyyy',
                        readOnly: true,
                        suffixIcon: Icons.calendar_today_outlined,
                        onTap: onPickDate,
                        validator: _validateDob,
                      ),
                    ),
                    const SizedBox(height: 14),
                    fieldRow(
                      _FormFieldBox(
                        label: 'Age *',
                        controller: age,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_digitsOnly, _maxLength(2)],
                        validator: _validateAge,
                      ),
                      _GenderField(
                        value: gender,
                        onChanged: onGenderChanged,
                      ),
                    ),
                    const SizedBox(height: 14),
                    fieldRow(
                      _FormFieldBox(
                        label: 'Aadhaar Number *',
                        controller: aadhaar,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_digitsOnly, _maxLength(12)],
                        validator: _validateAadhaar,
                      ),
                      _FormFieldBox(
                        label: 'Father Name *',
                        controller: father,
                        inputFormatters: [_nameFormatter],
                        validator: _validateName,
                      ),
                    ),
                    const SizedBox(height: 14),
                    fieldRow(
                      _FormFieldBox(
                        label: 'Mother Name *',
                        controller: mother,
                        inputFormatters: [_nameFormatter],
                        validator: _validateName,
                      ),
                      _FormFieldBox(
                        label: 'Mobile Number *',
                        controller: mobile,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_digitsOnly, _maxLength(10)],
                        validator: _validateMobile,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FormFieldBox(
                      label: 'Trade Specification *',
                      controller: trade,
                      validator: _validateTrade,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3475E6),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: const Color(0x553475E6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Enroll Student',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _FormFieldBox extends StatelessWidget {
  const _FormFieldBox({
    required this.label,
    required this.controller,
    this.isRequired = true,
    this.hint,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final String? hint;
  final bool readOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF020817),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator ??
                (isRequired ? _requiredValidator : (_) => null),
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              border: _fieldBorder(),
              enabledBorder: _fieldBorder(),
              focusedBorder: _fieldBorder(color: const Color(0xFF3475E6)),
              errorBorder: _fieldBorder(color: const Color(0xFFEF4444)),
              focusedErrorBorder: _fieldBorder(color: const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

String? _validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Required';
  if (text.length < 2) return 'At least 2 letters';
  if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(text)) {
    return 'Use letters only';
  }
  return null;
}

String? _validateOptionalName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return _validateName(text);
}

String? _validateDob(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Required';

  final parts = text.split('-');
  if (parts.length != 3) return 'Use dd-mm-yyyy';
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return 'Invalid date';

  final date = DateTime(year, month, day);
  final isSameDate =
      date.year == year && date.month == month && date.day == day;
  if (!isSameDate) return 'Invalid date';
  if (date.isAfter(DateTime.now())) return 'Future date not allowed';
  if (date.isBefore(DateTime(1990))) return 'Date is too old';
  return null;
}

String? _validateAge(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Required';
  final age = int.tryParse(text);
  if (age == null) return 'Numbers only';
  if (age < 10 || age > 25) return 'Age must be 10-25';
  return null;
}

String? _validateAadhaar(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Required';
  if (digits.length != 12) return 'Enter 12 digits';
  if (RegExp(r'^(\d)\1{11}$').hasMatch(digits)) return 'Invalid number';
  return null;
}

String? _validateMobile(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Required';
  final mobile = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  if (mobile.length != 10) return 'Enter 10 digits';
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
    return 'Invalid mobile';
  }
  return null;
}

String? _validateTrade(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Required';
  if (text.length < 3) return 'At least 3 characters';
  return null;
}

final _digitsOnly = FilteringTextInputFormatter.digitsOnly;
final _nameFormatter = FilteringTextInputFormatter.allow(
  RegExp(r"[A-Za-z .'-]"),
);

LengthLimitingTextInputFormatter _maxLength(int length) {
  return LengthLimitingTextInputFormatter(length);
}

class _GenderField extends StatelessWidget {
  const _GenderField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gender *',
            style: TextStyle(
              color: Color(0xFF020817),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              border: _fieldBorder(),
              enabledBorder: _fieldBorder(),
              focusedBorder: _fieldBorder(color: const Color(0xFF3475E6)),
            ),
          ),
        ],
      ),
    );
  }
}

OutlineInputBorder _fieldBorder({Color color = const Color(0xFFCBD5F5)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1),
  );
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.student});

  final _EnrollmentStudent student;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            isNarrow ? 18 : 24,
            isNarrow ? 18 : 24,
            isNarrow ? 18 : 24,
            isNarrow ? 18 : 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB8C7FF), width: 1.1),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StudentIdentity(student: student),
                    const SizedBox(height: 18),
                    _DetailsGrid(student: student, columns: 1),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StudentIdentity(student: student),
                    const SizedBox(width: 72),
                    Expanded(
                      child: _DetailsGrid(student: student, columns: 2),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _StudentIdentity extends StatelessWidget {
  const _StudentIdentity({required this.student});

  final _EnrollmentStudent student;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, 330.0).toDouble()
            : 330.0;

        return SizedBox(
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF3367D8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_outlined,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF020817),
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoLine(label: 'Age', value: student.age),
                    const SizedBox(height: 10),
                    _InfoLine(label: 'Aadhaar', value: student.aadhaar),
                    const SizedBox(height: 10),
                    _InfoLine(label: 'Mobile', value: student.mobile),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({
    required this.student,
    required this.columns,
  });

  final _EnrollmentStudent student;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('DOB', student.dob),
      ('Father', student.father),
      ('Trade', student.trade),
      ('Gender', student.gender),
      ('Mother', student.mother),
      ('Enrolled', student.enrolled),
    ];

    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InfoLine(label: item.$1, value: item.$2),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _DetailsColumn(items: items.take(3).toList())),
        const SizedBox(width: 36),
        Expanded(child: _DetailsColumn(items: items.skip(3).toList())),
      ],
    );
  }
}

class _DetailsColumn extends StatelessWidget {
  const _DetailsColumn({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _InfoLine(label: item.$1, value: item.$2),
            ),
          )
          .toList(),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
          height: 1.25,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFF020817),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStudentFab extends StatelessWidget {
  const _AddStudentFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2F67D8),
        border: Border.all(color: const Color(0xFFFFD6BD), width: 5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332F67D8),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: IconButton(
        tooltip: 'Add Student',
        onPressed: onTap,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
      ),
    );
  }
}

class _EnrollmentStudent {
  const _EnrollmentStudent({
    required this.name,
    required this.age,
    required this.aadhaar,
    required this.mobile,
    required this.dob,
    required this.father,
    required this.trade,
    required this.gender,
    required this.mother,
    required this.enrolled,
  });

  final String name;
  final String age;
  final String aadhaar;
  final String mobile;
  final String dob;
  final String father;
  final String trade;
  final String gender;
  final String mother;
  final String enrolled;
}
