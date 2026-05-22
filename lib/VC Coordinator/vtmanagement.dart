import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VTManagementPage extends StatelessWidget {
  const VTManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.pageSurface(context),
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(activeItem: 'VT Management', showCollapseButton: false),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'VT Management'),
                const Expanded(child: _VTBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VTBody extends StatefulWidget {
  const _VTBody();

  @override
  State<_VTBody> createState() => _VTBodyState();
}

class _VTBodyState extends State<_VTBody> {
  static const _storageKey = 'vt_management_rows_v1';
  final List<_VTItem> _rows = [
    _VTItem(
      name: 'Sneha Patel',
      mobile: '+91 98765\n43210',
      subject: 'Web\nDevelopment',
      school: 'Govt High\nSchool',
      district: 'New Delhi',
      udise: 'DL-001-2024',
    ),
    _VTItem(
      name: 'Rajesh\nKumar',
      mobile: '+91 98765 43211',
      subject: 'Digital Marketing',
      school: 'Central Institute',
      district: 'Mumbai',
      udise: 'MH-002-\n2024',
    ),
    _VTItem(
      name: 'Anita Singh',
      mobile: '+91 98765 43212',
      subject: 'Graphic Design',
      school: 'Skill Center',
      district: 'Bangalore',
      udise: 'KA-003-2024',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStoredVts();
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
                                  'VT Management',
                                  style: TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Vocational Trainers teaching and performance tracking',
                                  style: TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                            final addButton = InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => showDialog(
                                context: context,
                                barrierColor: const Color(0xA2000000),
                                builder: (_) =>
                                    _AddVTDialog(onAdd: _handleAddVt),
                              ),
                              child: Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: DashboardColors.red,
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
                                      'Add VT',
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
                        const SizedBox(height: 22),
                        _VTTable(
                          rows: _rows,
                          onView: _showVtDetails,
                          onDelete: _confirmDelete,
                        ),
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

  void _handleAddVt(_VTItem item) {
    setState(() {
      _rows.insert(0, item);
    });
    _saveVts();
  }

  void _showVtDetails(_VTItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DashboardColors.border, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VT Details',
                style: TextStyle(
                  color: DashboardColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              _detailLine('Name', item.name),
              _detailLine('Mobile', item.mobile),
              _detailLine('Subject/Trade', item.subject),
              _detailLine('School', item.school),
              _detailLine('District', item.district),
              _detailLine('UDISE', item.udise),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: DashboardColors.red,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(_VTItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DashboardColors.border, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete VT',
                style: TextStyle(
                  color: DashboardColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete ${item.name}?',
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: DashboardColors.text,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: DashboardColors.red,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete != true) return;
    setState(() {
      _rows.remove(item);
    });
    await _saveVts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('VT deleted successfully.')));
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: DashboardColors.text, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _loadStoredVts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final parsed = raw.map(_VTItem.fromStorage).toList();
    if (!mounted) return;
    setState(() {
      _rows
        ..clear()
        ..addAll(parsed);
    });
  }

  Future<void> _saveVts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _rows.map((e) => e.toStorage()).toList();
    await prefs.setStringList(_storageKey, data);
  }
}

class _VTTable extends StatelessWidget {
  const _VTTable({
    required this.rows,
    required this.onView,
    required this.onDelete,
  });

  final List<_VTItem> rows;
  final ValueChanged<_VTItem> onView;
  final ValueChanged<_VTItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.border, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 1050,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFFD9DFF0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 16,
                  ),
                  child: const Row(
                    children: [
                      _HeaderCell('Name', flex: 15),
                      _HeaderCell('Mobile', flex: 16),
                      _HeaderCell('Subject/Trade', flex: 18),
                      _HeaderCell('School', flex: 17),
                      _HeaderCell('District', flex: 13),
                      _HeaderCell('UDISE', flex: 16),
                      _HeaderCell('Actions', flex: 11),
                    ],
                  ),
                ),
                ...rows.asMap().entries.map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: entry.key == rows.length - 1
                          ? null
                          : const Border(
                              bottom: BorderSide(
                                color: DashboardColors.border,
                                width: 1.5,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        _DataCell(entry.value.name, flex: 15),
                        _DataCell(entry.value.mobile, flex: 16),
                        _DataCell(entry.value.subject, flex: 18),
                        _DataCell(entry.value.school, flex: 17),
                        _DataCell(entry.value.district, flex: 13),
                        _UdiseCell(entry.value.udise, flex: 16),
                        _ActionsCell(
                          flex: 11,
                          onView: () => onView(entry.value),
                          onDelete: () => onDelete(entry.value),
                        ),
                      ],
                    ),
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

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: DashboardColors.text,
          fontWeight: FontWeight.w700,
          fontSize: 29 / 2,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.value, {required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: const TextStyle(
          color: DashboardColors.text,
          fontWeight: FontWeight.w500,
          fontSize: 34 / 2,
          height: 1.35,
        ),
      ),
    );
  }
}

class _UdiseCell extends StatelessWidget {
  const _UdiseCell(this.value, {required this.flex});

  final String value;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDDE0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: DashboardColors.red,
              fontWeight: FontWeight.w600,
              fontSize: 30 / 2,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  const _ActionsCell({
    required this.flex,
    required this.onView,
    required this.onDelete,
  });

  final int flex;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onView,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.visibility_outlined,
                color: DashboardColors.red,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 20),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.delete_outline_rounded,
                color: DashboardColors.red,
                size: 20,
              ),
            ),
          ),
        ],
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

class _VTItem {
  const _VTItem({
    required this.name,
    required this.mobile,
    required this.subject,
    required this.school,
    required this.district,
    required this.udise,
  });

  final String name;
  final String mobile;
  final String subject;
  final String school;
  final String district;
  final String udise;

  String toStorage() {
    return [name, mobile, subject, school, district, udise].join('||');
  }

  static _VTItem fromStorage(String raw) {
    final p = raw.split('||');
    if (p.length < 6) {
      return const _VTItem(
        name: 'Unknown VT',
        mobile: '-',
        subject: '-',
        school: '-',
        district: '-',
        udise: '-',
      );
    }
    return _VTItem(
      name: p[0],
      mobile: p[1],
      subject: p[2],
      school: p[3],
      district: p[4],
      udise: p[5],
    );
  }
}

class _AddVTDialog extends StatefulWidget {
  const _AddVTDialog({required this.onAdd});

  final ValueChanged<_VTItem> onAdd;

  @override
  State<_AddVTDialog> createState() => _AddVTDialogState();
}

class _AddVTDialogState extends State<_AddVTDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _dob = TextEditingController();
  final _subCaste = TextEditingController();
  final _nativeState = TextEditingController();
  final _nativeDistrict = TextEditingController();
  final _district = TextEditingController();
  final _mandal = TextEditingController();
  final _school = TextEditingController();
  final _udise = TextEditingController();
  final _sector = TextEditingController();
  final _qualification = TextEditingController();
  final _aadhaar = TextEditingController();
  final _pan = TextEditingController();

  String? _gender;
  String? _caste;
  String? _religion;
  String? _locationType;
  String? _scheme;
  String? _trade;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _dob.dispose();
    _subCaste.dispose();
    _nativeState.dispose();
    _nativeDistrict.dispose();
    _district.dispose();
    _mandal.dispose();
    _school.dispose();
    _udise.dispose();
    _sector.dispose();
    _qualification.dispose();
    _aadhaar.dispose();
    _pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 980;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 26,
        vertical: 14,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1160, maxHeight: 980),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x55E7B3BE), width: 1.5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New VT',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 42 / 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Complete Vocational Trainer Information',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 15,
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
            const Divider(height: 1, color: Color(0x40E7B3BE)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _VTSection(title: 'Personal Information'),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'Full Name *',
                          hint: 'Enter full name',
                          controller: _name,
                          validator: _required,
                        ),
                        right: _VTField(
                          label: 'Mobile Number *',
                          hint: '+91 XXXXX XXXXX',
                          controller: _mobile,
                          keyboardType: TextInputType.phone,
                          validator: _mobileValidator,
                        ),
                      ),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'Gender *',
                          hint: 'Select Gender',
                          dropdown: true,
                          value: _gender,
                          options: const ['Male', 'Female', 'Other'],
                          onChanged: (v) => setState(() => _gender = v),
                          validator: _selectRequired,
                        ),
                        right: _VTField(
                          label: 'Date of Birth *',
                          hint: 'dd-mm-yyyy',
                          controller: _dob,
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onIconTap: () => _pickDate(_dob),
                          validator: _required,
                        ),
                      ),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'Caste *',
                          hint: 'Select Caste',
                          dropdown: true,
                          value: _caste,
                          options: const ['General', 'OBC', 'SC', 'ST'],
                          onChanged: (v) => setState(() => _caste = v),
                          validator: _selectRequired,
                        ),
                        right: _VTField(
                          label: 'Sub-Caste',
                          hint: 'Enter sub-caste',
                          controller: _subCaste,
                        ),
                      ),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'Religion *',
                          hint: 'Select Religion',
                          dropdown: true,
                          value: _religion,
                          options: const [
                            'Hindu',
                            'Muslim',
                            'Christian',
                            'Sikh',
                            'Other',
                          ],
                          onChanged: (v) => setState(() => _religion = v),
                          validator: _selectRequired,
                        ),
                        right: _VTField(
                          label: 'Native State *',
                          hint: 'Enter native state',
                          controller: _nativeState,
                          validator: _required,
                        ),
                      ),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'Native District *',
                          hint: 'Enter native district',
                          controller: _nativeDistrict,
                          validator: _required,
                        ),
                        right: const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),
                      const _VTSection(title: 'School Assignment'),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'District *',
                          hint: 'Enter district',
                          controller: _district,
                          validator: _required,
                        ),
                        right: _VTField(
                          label: 'Mandal *',
                          hint: 'Enter mandal',
                          controller: _mandal,
                          validator: _required,
                        ),
                      ),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'School Name *',
                          hint: 'Enter school name',
                          controller: _school,
                          validator: _required,
                        ),
                        right: _VTField(
                          label: 'UDISE Code *',
                          hint: 'Enter UDISE code',
                          controller: _udise,
                          validator: _required,
                        ),
                      ),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'School Location Type *',
                          hint: 'Select Type',
                          dropdown: true,
                          value: _locationType,
                          options: const ['Urban', 'Rural'],
                          onChanged: (v) => setState(() => _locationType = v),
                          validator: _selectRequired,
                        ),
                        right: _VTField(
                          label: 'Scheme *',
                          hint: 'Select Scheme',
                          dropdown: true,
                          value: _scheme,
                          options: const ['PM', 'SS'],
                          onChanged: (v) => setState(() => _scheme = v),
                          validator: _selectRequired,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _VTSection(title: 'Job Information'),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'VT Job Role / Trade *',
                          hint: 'Select Trade',
                          dropdown: true,
                          value: _trade,
                          options: const [
                            'Beauty & Wellness',
                            'Electronics & Hardware',
                            'Apparel',
                            'IT/ITES',
                            'Agriculture',
                            'Telecom',
                            'Media & Entertainment',
                            'Web Development',
                            'Digital Marketing',
                            'Graphic Design',
                          ],
                          onChanged: (v) => setState(() => _trade = v),
                          validator: _selectRequired,
                        ),
                        right: _VTField(
                          label: 'Sector of School *',
                          hint: 'Enter sector/grade',
                          controller: _sector,
                          validator: _required,
                        ),
                      ),
                      _VTField(
                        label: 'Trade Wise Qualification *',
                        hint: 'Enter qualifications and certifications',
                        controller: _qualification,
                        multiline: true,
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      const _VTSection(title: 'Documents & ID'),
                      _VTRow(
                        compact: isCompact,
                        left: _VTField(
                          label: 'Aadhaar Number *',
                          hint: 'XXXX-XXXX-XXXX',
                          controller: _aadhaar,
                          validator: _aadhaarValidator,
                        ),
                        right: _VTField(
                          label: 'PAN Number *',
                          hint: 'ABCDE1234F',
                          controller: _pan,
                          validator: _panValidator,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0x40E7B3BE)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compactActions = constraints.maxWidth < 420;
                  if (compactActions) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(105, 50),
                            side: const BorderSide(
                              color: Color(0x66E7B3BE),
                              width: 1.6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: DashboardColors.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _submit,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Add VT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(105, 50),
                          side: const BorderSide(
                            color: Color(0x66E7B3BE),
                            width: 1.6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      InkWell(
                        onTap: _submit,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 34),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Add VT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _selectRequired(String? v) =>
      (v == null || v.isEmpty) ? 'Please select' : null;

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  String _formatDate(DateTime date) {
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    return '$dd-$mm-$yyyy';
  }

  String? _mobileValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Invalid mobile number';
    return null;
  }

  String? _aadhaarValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 12) return '12-digit Aadhaar required';
    return null;
  }

  String? _panValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final value = v.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(value))
      return 'Invalid PAN';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final created = _VTItem(
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      subject: _trade ?? '-',
      school: _school.text.trim(),
      district: _district.text.trim(),
      udise: _udise.text.trim(),
    );
    widget.onAdd(created);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('VT added successfully.')));
    Navigator.pop(context);
  }
}

class _VTSection extends StatelessWidget {
  const _VTSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 34 / 2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _VTRow extends StatelessWidget {
  const _VTRow({
    required this.compact,
    required this.left,
    required this.right,
  });

  final bool compact;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          left,
          const SizedBox(height: 10),
          if (right is! SizedBox) right,
          const SizedBox(height: 10),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 16),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _VTField extends StatelessWidget {
  const _VTField({
    required this.label,
    required this.hint,
    this.controller,
    this.dropdown = false,
    this.value,
    this.options,
    this.onChanged,
    this.multiline = false,
    this.validator,
    this.keyboardType,
    this.icon,
    this.readOnly = false,
    this.onIconTap,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool dropdown;
  final String? value;
  final List<String>? options;
  final ValueChanged<String?>? onChanged;
  final bool multiline;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onIconTap;

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
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        if (dropdown)
          DropdownButtonFormField<String>(
            initialValue: value,
            validator: validator,
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: DashboardColors.text,
            ),
            items: (options ?? const <String>[])
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: DashboardColors.text,
                fontSize: 31 / 2,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: DashboardColors.border,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: DashboardColors.border,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.4,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.4,
                ),
              ),
            ),
          )
        else
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            readOnly: readOnly,
            maxLines: multiline ? 3 : 1,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon == null
                  ? null
                  : IconButton(
                      onPressed: onIconTap,
                      icon: Icon(icon, size: 17, color: Colors.black87),
                    ),
              hintStyle: TextStyle(
                color: multiline
                    ? const Color(0xFF7B8FA6)
                    : DashboardColors.text,
                fontSize: 31 / 2,
                fontWeight: FontWeight.w500,
              ),
              filled: multiline,
              fillColor: multiline ? const Color(0xFFF3F4F6) : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: multiline ? 14 : 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: DashboardColors.border,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: DashboardColors.border,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.4,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.4,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
