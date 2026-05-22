import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'sidebar.dart';

class InternshipsPage extends StatefulWidget {
  const InternshipsPage({super.key});

  @override
  State<InternshipsPage> createState() => _InternshipsPageState();
}

class _InternshipsPageState extends State<InternshipsPage> {
  static const _prefsKey = 'internship_records';
  static const _pmShriOptions = ['PM-Shri', 'SS'];
  static const _genderOptions = ['Male', 'Female', 'Other'];

  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  List<_InternshipRecord> _records = [];
  DateTime? _dob;
  String _pmShri = _pmShriOptions.first;
  String _gender = _genderOptions.first;
  bool _isLoading = true;
  bool _isFormOpen = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final field in _allTextFields) field.key!: TextEditingController(),
    };
    _loadRecords();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final rawRecords = prefs.getString(_prefsKey);
    try {
      if (rawRecords != null) {
        final decoded = jsonDecode(rawRecords) as List<dynamic>;
        _records = decoded
            .map(
              (entry) => _InternshipRecord.fromJson(
                entry as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    } catch (_) {
      _records = [];
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_records.map((record) => record.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> _submitRecord() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select student DOB')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final values = {
        for (final entry in _controllers.entries) entry.key: entry.value.text.trim(),
      };
      final record = _InternshipRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        values: values,
        pmShri: _pmShri,
        gender: _gender,
        dob: _dob!,
        createdAt: DateTime.now(),
      );

      _records = [record, ..._records];
      await _saveRecords();
      if (!mounted) {
        return;
      }
      _clearForm();
      setState(() => _isFormOpen = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internship record submitted')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save record. Try again.')),
      );
    } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
  }

  Future<void> _deleteRecord(String id) async {
    setState(() => _records = _records.where((record) => record.id != id).toList());
    await _saveRecords();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Internship record deleted')),
      );
    }
  }

  void _openForm() {
    setState(() => _isFormOpen = true);
  }

  void _cancelForm() {
    _clearForm();
    setState(() => _isFormOpen = false);
  }

  void _clearForm() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
    _formKey.currentState?.reset();
    _dob = null;
    _pmShri = _pmShriOptions.first;
    _gender = _genderOptions.first;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 16, now.month, now.day),
      firstDate: DateTime(now.year - 40),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _dob = picked);
    }
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
                    activeItem: 'Internships',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Internships'),
                Expanded(
                  child: _InternshipsBody(
                    isMobile: isMobile,
                    isLoading: _isLoading,
                    isFormOpen: _isFormOpen,
                    isSaving: _isSaving,
                    records: _records,
                    formKey: _formKey,
                    controllers: _controllers,
                    pmShri: _pmShri,
                    gender: _gender,
                    dob: _dob,
                    pmShriOptions: _pmShriOptions,
                    genderOptions: _genderOptions,
                    onOpenForm: _openForm,
                    onCancelForm: _cancelForm,
                    onSubmit: _submitRecord,
                    onDelete: _deleteRecord,
                    onPickDob: _pickDob,
                    onPmShriChanged: (value) {
                      if (value != null) {
                        setState(() => _pmShri = value);
                      }
                    },
                    onGenderChanged: (value) {
                      if (value != null) {
                        setState(() => _gender = value);
                      }
                    },
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

class _InternshipsBody extends StatelessWidget {
  const _InternshipsBody({
    required this.isMobile,
    required this.isLoading,
    required this.isFormOpen,
    required this.isSaving,
    required this.records,
    required this.formKey,
    required this.controllers,
    required this.pmShri,
    required this.gender,
    required this.dob,
    required this.pmShriOptions,
    required this.genderOptions,
    required this.onOpenForm,
    required this.onCancelForm,
    required this.onSubmit,
    required this.onDelete,
    required this.onPickDob,
    required this.onPmShriChanged,
    required this.onGenderChanged,
  });

  final bool isMobile;
  final bool isLoading;
  final bool isFormOpen;
  final bool isSaving;
  final List<_InternshipRecord> records;
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> controllers;
  final String pmShri;
  final String gender;
  final DateTime? dob;
  final List<String> pmShriOptions;
  final List<String> genderOptions;
  final VoidCallback onOpenForm;
  final VoidCallback onCancelForm;
  final VoidCallback onSubmit;
  final ValueChanged<String> onDelete;
  final VoidCallback onPickDob;
  final ValueChanged<String?> onPmShriChanged;
  final ValueChanged<String?> onGenderChanged;

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
                  110,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InternshipsHeader(
                        isMobile: isMobile,
                        isFormOpen: isFormOpen,
                        onOpenForm: onOpenForm,
                        onCancelForm: onCancelForm,
                      ),
                      SizedBox(height: isFormOpen ? 18 : 90),
                      if (isLoading)
                        const SizedBox(
                          height: 280,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (isFormOpen)
                        _InternshipFormCard(
                          formKey: formKey,
                          controllers: controllers,
                          pmShri: pmShri,
                          gender: gender,
                          dob: dob,
                          pmShriOptions: pmShriOptions,
                          genderOptions: genderOptions,
                          isSaving: isSaving,
                          onPickDob: onPickDob,
                          onPmShriChanged: onPmShriChanged,
                          onGenderChanged: onGenderChanged,
                          onSubmit: onSubmit,
                        )
                      else if (records.isEmpty)
                        _InternshipEmptyState(onOpenForm: onOpenForm)
                      else
                        _InternshipRecordsList(
                          records: records,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: isMobile ? 18 : 28,
          bottom: isMobile ? 18 : 30,
          child: _InternshipFab(
            size: isMobile ? 58 : 70,
            onPressed: onOpenForm,
          ),
        ),
      ],
    );
  }
}

class _InternshipFab extends StatelessWidget {
  const _InternshipFab({required this.size, required this.onPressed});

  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x44EC3347),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Icon(Icons.add, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}

class _InternshipsHeader extends StatelessWidget {
  const _InternshipsHeader({
    required this.isMobile,
    required this.isFormOpen,
    required this.onOpenForm,
    required this.onCancelForm,
  });

  final bool isMobile;
  final bool isFormOpen;
  final VoidCallback onOpenForm;
  final VoidCallback onCancelForm;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Internships',
          style: TextStyle(
            color: DashboardColors.text,
            fontSize: isMobile ? 28 : 32,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Manage student internship records',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: isMobile ? 16 : 19,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    final button = _HeaderActionButton(
      label: isFormOpen ? 'Cancel' : 'Add Internship',
      icon: isFormOpen ? Icons.close_rounded : Icons.add_rounded,
      onPressed: isFormOpen ? onCancelForm : onOpenForm,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: button),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 20),
        button,
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shadowColor: const Color(0x442552C2),
          backgroundColor: const Color(0xFF2D65D7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _InternshipEmptyState extends StatelessWidget {
  const _InternshipEmptyState({required this.onOpenForm});

  final VoidCallback onOpenForm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: InkWell(
          onTap: onOpenForm,
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.business_center_outlined,
                  color: Color(0xFF6B7280),
                  size: 86,
                ),
                SizedBox(height: 22),
                Text(
                  'No internship records yet. Click "Add Internship" to start.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InternshipFormCard extends StatelessWidget {
  const _InternshipFormCard({
    required this.formKey,
    required this.controllers,
    required this.pmShri,
    required this.gender,
    required this.dob,
    required this.pmShriOptions,
    required this.genderOptions,
    required this.isSaving,
    required this.onPickDob,
    required this.onPmShriChanged,
    required this.onGenderChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> controllers;
  final String pmShri;
  final String gender;
  final DateTime? dob;
  final List<String> pmShriOptions;
  final List<String> genderOptions;
  final bool isSaving;
  final VoidCallback onPickDob;
  final ValueChanged<String?> onPmShriChanged;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
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
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Internship Details'),
            _ResponsiveFieldGrid(
              children: [
                _TextFieldSpec('vtpName', 'VTP Name *'),
                _TextFieldSpec('vcName', 'VC Name *'),
                _TextFieldSpec('udiseCode', 'UDISE Code *', type: _InputType.number),
                _TextFieldSpec('schoolName', 'School Name *'),
                _TextFieldSpec('block', 'Block *'),
                _TextFieldSpec('district', 'District *'),
                _TextFieldSpec.dropdown(
                  label: 'PM Shri/SS *',
                  value: pmShri,
                  options: pmShriOptions,
                  onChanged: onPmShriChanged,
                ),
                _TextFieldSpec('trade', 'Trade *'),
                _TextFieldSpec('vtName', 'VT Name *'),
                _TextFieldSpec('vtMobile', 'VT Mobile *', type: _InputType.phone),
                _TextFieldSpec(
                  'yearOfApproval',
                  'Year of Approval *',
                  type: _InputType.year,
                ),
                _TextFieldSpec('upgradedCategory', 'Upgraded Category *'),
                _TextFieldSpec(
                  'standard12Count',
                  'No. for 12th Standard *',
                  type: _InputType.number,
                ),
              ],
              controllers: controllers,
            ),
            const _FormDivider(),
            const _SectionTitle('Student Information'),
            _ResponsiveFieldGrid(
              children: [
                _TextFieldSpec('studentName', 'Student Name *'),
                _TextFieldSpec(
                  'studentTrade',
                  'Trade of Student *',
                  hint: 'e.g., MPC, MEC',
                ),
                _TextFieldSpec.dropdown(
                  label: 'Gender *',
                  value: gender,
                  options: genderOptions,
                  onChanged: onGenderChanged,
                ),
                _TextFieldSpec.date(
                  label: 'DOB *',
                  value: dob == null ? 'dd-mm-yyyy' : _formatDate(dob!),
                  onTap: onPickDob,
                ),
                _TextFieldSpec(
                  'studentMobile',
                  'Mobile No. of Student/Parent *',
                  type: _InputType.phone,
                  fullWidth: true,
                ),
              ],
              controllers: controllers,
            ),
            const _FormDivider(),
            const _SectionTitle('Employer Information'),
            _ResponsiveFieldGrid(
              children: [
                _TextFieldSpec(
                  'organizationName',
                  'Organization/Store/Firm Name *',
                  fullWidth: true,
                ),
                _TextFieldSpec(
                  'managerName',
                  'Employer/Owner/Incharge/Manager Name *',
                  fullWidth: true,
                ),
                _TextFieldSpec(
                  'fullAddress',
                  'Full Address (Village, Street, Full Address) *',
                  fullWidth: true,
                ),
                _TextFieldSpec('employerBlock', 'Block *'),
                _TextFieldSpec('mandal', 'Mandal *'),
                _TextFieldSpec('employerDistrict', 'District *'),
                _TextFieldSpec(
                  'employerMobile',
                  'Mobile No. of Employer *',
                  type: _InputType.phone,
                ),
                _TextFieldSpec(
                  'employerEmail',
                  'Email ID of Employer *',
                  type: _InputType.email,
                  fullWidth: true,
                ),
              ],
              controllers: controllers,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D65D7),
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    : const Text(
                        'Submit Internship Record',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({
    required this.children,
    required this.controllers,
  });

  final List<_TextFieldSpec> children;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final isTwoColumn = constraints.maxWidth >= 760;
        final columnWidth = isTwoColumn
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: children.map((spec) {
            return SizedBox(
              width: spec.fullWidth || !isTwoColumn
                  ? constraints.maxWidth
                  : columnWidth,
              child: _InternshipField(
                spec: spec,
                controller: spec.key == null ? null : controllers[spec.key],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _InternshipField extends StatelessWidget {
  const _InternshipField({required this.spec, required this.controller});

  final _TextFieldSpec spec;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          spec.label,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        if (spec.dropdownOptions != null)
          DropdownButtonFormField<String>(
            value: spec.dropdownValue,
            items: spec.dropdownOptions!
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
            onChanged: spec.onDropdownChanged,
            decoration: _inputDecoration(),
            validator: (value) => _requiredValidator(value),
          )
        else if (spec.isDate)
          InkWell(
            onTap: spec.onDateTap,
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: _inputDecoration(
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(
                spec.dateValue!,
                style: TextStyle(
                  color: spec.dateValue == 'dd-mm-yyyy'
                      ? const Color(0xFF6B7280)
                      : DashboardColors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: spec.type.keyboardType,
            inputFormatters: spec.type.inputFormatters,
            decoration: _inputDecoration(hintText: spec.hint),
            validator: (value) => _validateText(value, spec.type),
          ),
      ],
    );
  }
}

class _InternshipRecordsList extends StatelessWidget {
  const _InternshipRecordsList({
    required this.records,
    required this.onDelete,
  });

  final List<_InternshipRecord> records;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: records
          .map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _InternshipRecordCard(
                record: record,
                onDelete: () => onDelete(record.id),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InternshipRecordCard extends StatelessWidget {
  const _InternshipRecordCard({
    required this.record,
    required this.onDelete,
  });

  final _InternshipRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0DAF2), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: const Icon(
              Icons.business_center_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Wrap(
              spacing: 26,
              runSpacing: 12,
              children: [
                _RecordInfo(
                  label: 'Student',
                  value: record.values['studentName'] ?? '-',
                ),
                _RecordInfo(
                  label: 'Organization',
                  value: record.values['organizationName'] ?? '-',
                ),
                _RecordInfo(
                  label: 'Trade',
                  value: record.values['studentTrade'] ?? '-',
                ),
                _RecordInfo(label: 'DOB', value: _formatDate(record.dob)),
                _RecordInfo(
                  label: 'Employer Mobile',
                  value: record.values['employerMobile'] ?? '-',
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFDC2626),
          ),
        ],
      ),
    );
  }
}

class _RecordInfo extends StatelessWidget {
  const _RecordInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: DashboardColors.text,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FormDivider extends StatelessWidget {
  const _FormDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Divider(height: 1, color: Color(0xFFDCE4F3), thickness: 1.4),
    );
  }
}

class _TextFieldSpec {
  const _TextFieldSpec(
    this.key,
    this.label, {
    this.type = _InputType.text,
    this.hint,
    this.fullWidth = false,
  })  : dropdownOptions = null,
        dropdownValue = null,
        onDropdownChanged = null,
        isDate = false,
        dateValue = null,
        onDateTap = null;

  const _TextFieldSpec.dropdown({
    required this.label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    this.fullWidth = false,
  })  : key = null,
        hint = null,
        type = _InputType.text,
        dropdownOptions = options,
        dropdownValue = value,
        onDropdownChanged = onChanged,
        isDate = false,
        dateValue = null,
        onDateTap = null;

  const _TextFieldSpec.date({
    required this.label,
    required String value,
    required VoidCallback onTap,
    this.fullWidth = false,
  })  : key = null,
        hint = null,
        type = _InputType.text,
        dropdownOptions = null,
        dropdownValue = null,
        onDropdownChanged = null,
        isDate = true,
        dateValue = value,
        onDateTap = onTap;

  final String? key;
  final String label;
  final _InputType type;
  final String? hint;
  final bool fullWidth;
  final List<String>? dropdownOptions;
  final String? dropdownValue;
  final ValueChanged<String?>? onDropdownChanged;
  final bool isDate;
  final String? dateValue;
  final VoidCallback? onDateTap;
}

enum _InputType {
  text,
  number,
  phone,
  email,
  year;

  TextInputType get keyboardType {
    return switch (this) {
      _InputType.number || _InputType.phone || _InputType.year =>
        TextInputType.number,
      _InputType.email => TextInputType.emailAddress,
      _InputType.text => TextInputType.text,
    };
  }

  List<TextInputFormatter> get inputFormatters {
    return switch (this) {
      _InputType.number => [FilteringTextInputFormatter.digitsOnly],
      _InputType.phone => [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      _InputType.year => [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
      _ => const [],
    };
  }
}

class _InternshipRecord {
  const _InternshipRecord({
    required this.id,
    required this.values,
    required this.pmShri,
    required this.gender,
    required this.dob,
    required this.createdAt,
  });

  factory _InternshipRecord.fromJson(Map<String, dynamic> json) {
    return _InternshipRecord(
      id: json['id'] as String,
      values: Map<String, String>.from(json['values'] as Map),
      pmShri: json['pmShri'] as String,
      gender: json['gender'] as String,
      dob: DateTime.parse(json['dob'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final Map<String, String> values;
  final String pmShri;
  final String gender;
  final DateTime dob;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'values': values,
      'pmShri': pmShri,
      'gender': gender,
      'dob': dob.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

const _allTextFields = [
  _TextFieldSpec('vtpName', 'VTP Name *'),
  _TextFieldSpec('vcName', 'VC Name *'),
  _TextFieldSpec('udiseCode', 'UDISE Code *'),
  _TextFieldSpec('schoolName', 'School Name *'),
  _TextFieldSpec('block', 'Block *'),
  _TextFieldSpec('district', 'District *'),
  _TextFieldSpec('trade', 'Trade *'),
  _TextFieldSpec('vtName', 'VT Name *'),
  _TextFieldSpec('vtMobile', 'VT Mobile *'),
  _TextFieldSpec('yearOfApproval', 'Year of Approval *'),
  _TextFieldSpec('upgradedCategory', 'Upgraded Category *'),
  _TextFieldSpec('standard12Count', 'No. for 12th Standard *'),
  _TextFieldSpec('studentName', 'Student Name *'),
  _TextFieldSpec('studentTrade', 'Trade of Student *'),
  _TextFieldSpec('studentMobile', 'Mobile No. of Student/Parent *'),
  _TextFieldSpec('organizationName', 'Organization/Store/Firm Name *'),
  _TextFieldSpec('managerName', 'Employer/Owner/Incharge/Manager Name *'),
  _TextFieldSpec('fullAddress', 'Full Address *'),
  _TextFieldSpec('employerBlock', 'Block *'),
  _TextFieldSpec('mandal', 'Mandal *'),
  _TextFieldSpec('employerDistrict', 'District *'),
  _TextFieldSpec('employerMobile', 'Mobile No. of Employer *'),
  _TextFieldSpec('employerEmail', 'Email ID of Employer *'),
];

InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
  return InputDecoration(
    isDense: true,
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFD0DAF2), width: 1.4),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFD0DAF2), width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF2D65D7), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
    ),
  );
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _validateText(String? value, _InputType type) {
  final requiredError = _requiredValidator(value);
  if (requiredError != null) {
    return requiredError;
  }
  final text = value!.trim();

  if (type == _InputType.phone && text.length != 10) {
    return 'Enter 10 digits';
  }
  if (type == _InputType.year && text.length != 4) {
    return 'Enter valid year';
  }
  if (type == _InputType.email) {
    final isEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    if (!isEmail) {
      return 'Enter valid email';
    }
  }
  return null;
}

String _formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}-${twoDigits(date.month)}-${date.year}';
}
