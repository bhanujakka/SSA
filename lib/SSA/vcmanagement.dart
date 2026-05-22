import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VCManagementPage extends StatelessWidget {
  const VCManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(activeItem: 'VC Management', showCollapseButton: false),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'VC Management'),
                const Expanded(child: _VCBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VCBody extends StatefulWidget {
  const _VCBody();

  @override
  State<_VCBody> createState() => _VCBodyState();
}

class _VCBodyState extends State<_VCBody> {
  static const _storageKey = 'vc_management_items_v1';
  final List<_VCItem> _vcItems = [
    _VCItem(
      initials: 'AV',
      name: 'Amit Verma',
      status: 'Active',
      email: 'amit.v@vtp.com',
      phone: '+91 98765 43210',
      schools: 5,
      isActive: true,
    ),
    _VCItem(
      initials: 'PG',
      name: 'Priya Gupta',
      status: 'Active',
      email: 'priya.g@vtp.com',
      phone: '+91 98765 43211',
      schools: 4,
      isActive: true,
    ),
    _VCItem(
      initials: 'RS',
      name: 'Rahul Sharma',
      status: 'Inactive',
      email: 'rahul.s@vtp.com',
      phone: '+91 98765 43212',
      schools: 6,
      isActive: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStoredVcs();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 980;
        final columns = isMobile ? 1 : 3;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isMobile),
                const Divider(height: 1, color: DashboardColors.border),
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
                                  'VC Management',
                                  style: TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 48 / 2,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Vocational Coordinators monitoring and verification',
                                  style: TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 18 / 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                            final action = InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => showDialog(
                                context: context,
                                barrierColor: const Color(0xA2000000),
                                builder: (_) => _AddVCDialog(onAdd: _handleAddVc),
                              ),
                              child: Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(horizontal: 26),
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
                                      'Add VC',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 34 / 2,
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
                                  action,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                titleBlock,
                                const Spacer(),
                                action,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 22),
                        _VCCardsGrid(items: _vcItems, columns: columns),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              right: 24,
              bottom: 36,
              child: _FloatingPlus(),
            ),
          ],
        );
      },
    );
  }

  void _handleAddVc(_VCItem item) {
    setState(() {
      _vcItems.insert(0, item);
    });
    _saveVcs();
  }

  Future<void> _loadStoredVcs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final parsed = raw.map(_VCItem.fromStorage).toList();
    if (!mounted) return;
    setState(() {
      _vcItems
        ..clear()
        ..addAll(parsed);
    });
  }

  Future<void> _saveVcs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _vcItems.map((e) => e.toStorage()).toList();
    await prefs.setStringList(_storageKey, data);
  }
}

class _VCCardsGrid extends StatelessWidget {
  const _VCCardsGrid({required this.items, required this.columns});

  final List<_VCItem> items;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final width = (constraints.maxWidth - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _VCCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _VCCard extends StatefulWidget {
  const _VCCard({required this.item});

  final _VCItem item;

  @override
  State<_VCCard> createState() => _VCCardState();
}

class _VCCardState extends State<_VCCard> {
  bool _isHovered = false;

  void _openProfileDialog() {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xA6000000),
      builder: (context) => _VCProfileDialog(item: widget.item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _openProfileDialog,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFFF7FBFF) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isHovered ? const Color(0xFF7398E4) : DashboardColors.border,
                width: 2,
              ),
              boxShadow: _isHovered
                  ? const [
                      BoxShadow(
                        color: Color(0x1F3D739B),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: DashboardColors.red,
                      child: Text(
                        item.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20 / 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: DashboardColors.text,
                                fontSize: 39 / 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: item.isActive
                                    ? const Color(0xFFD1F0D8)
                                    : const Color(0xFFFFDDE0),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                item.status,
                                style: TextStyle(
                                  color: item.isActive
                                      ? const Color(0xFF00853A)
                                      : const Color(0xFF2552C2),
                                  fontSize: 14 / 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  item.email,
                  style: const TextStyle(
                    color: DashboardColors.text,
                    fontSize: 31 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.phone,
                  style: const TextStyle(
                    color: DashboardColors.text,
                    fontSize: 31 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(color: DashboardColors.border, thickness: 2),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${item.schools}\n',
                        style: const TextStyle(
                          color: DashboardColors.red,
                          fontSize: 48 / 2,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const TextSpan(
                        text: 'Schools Assigned',
                        style: TextStyle(
                          color: DashboardColors.text,
                          fontSize: 30 / 2,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
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

class _VCProfileDialog extends StatelessWidget {
  const _VCProfileDialog({required this.item});

  final _VCItem item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'VC Profile - ${item.name}',
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 40 / 2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: DashboardColors.text),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFD9DFF0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 10),
              child: Column(
                children: [
                  _ProfileRow(label: 'Name', value: item.name),
                  _ProfileRow(label: 'Email', value: item.email),
                  _ProfileRow(label: 'Phone', value: item.phone.replaceAll(' ', '')),
                  _ProfileRow(label: 'Schools Assigned', value: '${item.schools}'),
                  _ProfileRow(label: 'Status', value: item.status, isLast: true),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFD9DFF0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 18, 26, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18 / 1.2,
                          ),
                        ),
                      ),
                    ),
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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFFD9DFF0), width: 1),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 18 / 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 18 / 1.2,
              fontWeight: FontWeight.w700,
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

class _VCItem {
  const _VCItem({
    required this.initials,
    required this.name,
    required this.status,
    required this.email,
    required this.phone,
    required this.schools,
    required this.isActive,
  });

  final String initials;
  final String name;
  final String status;
  final String email;
  final String phone;
  final int schools;
  final bool isActive;

  String toStorage() {
    return [
      initials,
      name,
      status,
      email,
      phone,
      schools.toString(),
      isActive ? '1' : '0',
    ].join('||');
  }

  static _VCItem fromStorage(String raw) {
    final p = raw.split('||');
    if (p.length < 7) {
      return const _VCItem(
        initials: 'VC',
        name: 'Unknown VC',
        status: 'Active',
        email: '-',
        phone: '-',
        schools: 0,
        isActive: true,
      );
    }
    return _VCItem(
      initials: p[0],
      name: p[1],
      status: p[2],
      email: p[3],
      phone: p[4],
      schools: int.tryParse(p[5]) ?? 0,
      isActive: p[6] == '1',
    );
  }
}

class _AddVCDialog extends StatefulWidget {
  const _AddVCDialog({required this.onAdd});

  final ValueChanged<_VCItem> onAdd;

  @override
  State<_AddVCDialog> createState() => _AddVCDialogState();
}

class _AddVCDialogState extends State<_AddVCDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _dob = TextEditingController();
  final _age = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _village = TextEditingController();
  final _mandal = TextEditingController();
  final _district = TextEditingController();
  final _state = TextEditingController();
  final _pincode = TextEditingController();
  final _qualification = TextEditingController();
  final _experience = TextEditingController();
  final _employeeId = TextEditingController();
  final _doj = TextEditingController();
  final _aadhaar = TextEditingController();
  final _pan = TextEditingController();

  String? _gender;
  String? _vtp;

  @override
  void dispose() {
    _fullName.dispose();
    _dob.dispose();
    _age.dispose();
    _email.dispose();
    _phone.dispose();
    _street.dispose();
    _village.dispose();
    _mandal.dispose();
    _district.dispose();
    _state.dispose();
    _pincode.dispose();
    _qualification.dispose();
    _experience.dispose();
    _employeeId.dispose();
    _doj.dispose();
    _aadhaar.dispose();
    _pan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 22, vertical: 18),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 900),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x55E7B3BE), width: 1.5),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New VC',
                          style: TextStyle(color: DashboardColors.text, fontSize: 40 / 2, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Vocational Coordinator details',
                          style: TextStyle(color: DashboardColors.text, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: DashboardColors.text),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0x40E7B3BE)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormSection(title: 'Personal Information'),
                      _TwoFieldRow(
                        compact: isCompact,
                        left: _FieldBox(label: 'Full Name *', hint: 'Enter VC name', controller: _fullName, validator: _required),
                        right: _FieldBox(
                          label: 'Gender *',
                          hint: 'Select Gender',
                          dropdown: true,
                          value: _gender,
                          options: const ['Male', 'Female', 'Other'],
                          onChanged: (v) => setState(() => _gender = v),
                          validator: (v) => v == null || v.isEmpty ? 'Please select gender' : null,
                        ),
                      ),
                      _TwoFieldRow(
                        compact: isCompact,
                        left: _FieldBox(
                          label: 'Date of Birth *',
                          hint: 'dd-mm-yyyy',
                          controller: _dob,
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onIconTap: () => _pickDate(_dob),
                          validator: _required,
                        ),
                        right: _FieldBox(
                          label: 'Age *',
                          hint: 'Age',
                          controller: _age,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final n = int.tryParse(v.trim());
                            if (n == null || n < 18 || n > 70) return 'Enter valid age';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _FormSection(title: 'Contact Information'),
                      _TwoFieldRow(
                        compact: isCompact,
                        left: _FieldBox(
                          label: 'Email *',
                          hint: 'vc@vtp.com',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                            return ok ? null : 'Invalid email';
                          },
                        ),
                        right: _FieldBox(
                          label: 'Phone Number *',
                          hint: '+91 XXXXX XXXXX',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                            return digits.length >= 10 ? null : 'Invalid phone number';
                          },
                        ),
                      ),
                      _TwoFieldRow(compact: isCompact, left: _FieldBox(label: 'Street/Door No *', hint: 'Enter street address', controller: _street, validator: _required), right: _FieldBox(label: 'Village/Town *', hint: 'Enter village', controller: _village, validator: _required)),
                      _TwoFieldRow(compact: isCompact, left: _FieldBox(label: 'Mandal *', hint: 'Enter mandal', controller: _mandal, validator: _required), right: _FieldBox(label: 'District *', hint: 'Enter district', controller: _district, validator: _required)),
                      _TwoFieldRow(
                        compact: isCompact,
                        left: _FieldBox(label: 'State *', hint: 'Enter state', controller: _state, validator: _required),
                        right: _FieldBox(
                          label: 'Pincode *',
                          hint: 'Enter pincode',
                          controller: _pincode,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            return RegExp(r'^\d{6}$').hasMatch(v.trim()) ? null : '6-digit pincode required';
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _FormSection(title: 'Professional Information'),
                      _TwoFieldRow(compact: isCompact, left: _FieldBox(label: 'Qualification *', hint: 'Enter qualification', controller: _qualification, validator: _required), right: _FieldBox(label: 'Experience (Years) *', hint: 'Years of experience', controller: _experience, keyboardType: TextInputType.number, validator: _required)),
                      _TwoFieldRow(
                        compact: isCompact,
                        left: _FieldBox(label: 'Employee ID *', hint: 'Enter employee ID', controller: _employeeId, validator: _required),
                        right: _FieldBox(
                          label: 'Date of Joining *',
                          hint: 'dd-mm-yyyy',
                          controller: _doj,
                          icon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onIconTap: () => _pickDate(_doj),
                          validator: _required,
                        ),
                      ),
                      _FieldBox(
                        label: 'Assign to VTP *',
                        hint: 'Select VTP',
                        dropdown: true,
                        value: _vtp,
                        options: const [
                          'Tech Skill Pvt Ltd',
                          'Vocational Training Corp',
                          'Skill India Partners',
                        ],
                        onChanged: (v) => setState(() => _vtp = v),
                        validator: (v) => v == null || v.isEmpty ? 'Please select VTP' : null,
                      ),
                      const SizedBox(height: 14),
                      const _FormSection(title: 'Document Information'),
                      _TwoFieldRow(
                        compact: isCompact,
                        left: _FieldBox(
                          label: 'Aadhaar Number *',
                          hint: 'Enter Aadhaar number',
                          controller: _aadhaar,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                            return digits.length == 12 ? null : '12-digit Aadhaar required';
                          },
                        ),
                        right: _FieldBox(
                          label: 'PAN Number *',
                          hint: 'Enter PAN number',
                          controller: _pan,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            return RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$').hasMatch(v.trim().toUpperCase())
                                ? null
                                : 'Invalid PAN format';
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0x40E7B3BE)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
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
                            minimumSize: const Size(105, 52),
                            side: const BorderSide(color: Color(0x66E7B3BE), width: 1.6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Cancel', style: TextStyle(color: DashboardColors.text, fontWeight: FontWeight.w700, fontSize: 17)),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _submit,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF2552C2), Color(0xFF2D65D7)]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(child: Text('Add VC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18))),
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
                          minimumSize: const Size(105, 52),
                          side: const BorderSide(color: Color(0x66E7B3BE), width: 1.6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: DashboardColors.text, fontWeight: FontWeight.w700, fontSize: 17)),
                      ),
                      const SizedBox(width: 14),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _submit,
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color(0xFF2552C2), Color(0xFF2D65D7)]),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Text('Add VC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18))),
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

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final created = _VCItem(
      initials: _initialsFromName(_fullName.text),
      name: _fullName.text.trim(),
      status: 'Active',
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      schools: 0,
      isActive: true,
    );
    widget.onAdd(created);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VC added successfully.')),
    );
    Navigator.pop(context);
  }

  String _initialsFromName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'VC';
    if (parts.length == 1) {
      final first = parts.first;
      return first.length >= 2 ? first.substring(0, 2).toUpperCase() : '${first[0].toUpperCase()}C';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: DashboardColors.text, fontSize: 19 / 1.2, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Divider(color: DashboardColors.border, height: 1, thickness: 1.4),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TwoFieldRow extends StatelessWidget {
  const _TwoFieldRow({required this.compact, required this.left, required this.right});

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
          right,
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

class _FieldBox extends StatelessWidget {
  const _FieldBox({
    required this.label,
    required this.hint,
    this.controller,
    this.dropdown = false,
    this.value,
    this.options,
    this.onChanged,
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
          style: const TextStyle(color: DashboardColors.text, fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 6),
        if (dropdown)
          DropdownButtonFormField<String>(
            initialValue: value,
            validator: validator,
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: DashboardColors.text),
            items: (options ?? const <String>[]).map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: DashboardColors.text, fontSize: 15 / 1.1, fontWeight: FontWeight.w500),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DashboardColors.border, width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DashboardColors.border, width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.4)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.4)),
            ),
          )
        else
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: icon == null
                  ? null
                  : IconButton(
                      onPressed: onIconTap,
                      icon: Icon(icon, size: 17, color: Colors.black87),
                    ),
              hintStyle: const TextStyle(color: DashboardColors.text, fontSize: 15 / 1.1, fontWeight: FontWeight.w500),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DashboardColors.border, width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: DashboardColors.border, width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.4)),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.4)),
            ),
          ),
      ],
    );
  }
}


