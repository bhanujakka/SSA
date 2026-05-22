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
          backgroundColor: DashboardColors.surface,
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
    const _VTItem(
      name: 'Sneha Patel',
      mobile: '+91 98765 43210',
      subject: 'Web Development',
      school: 'Govt High School',
      district: 'New Delhi',
      udise: 'DL-001-2024',
    ),
    const _VTItem(
      name: 'Rajesh Kumar',
      mobile: '+91 98765 43211',
      subject: 'Digital Marketing',
      school: 'Central Institute',
      district: 'Mumbai',
      udise: 'MH-002-2024',
    ),
    const _VTItem(
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
        final isMobile = constraints.maxWidth < 980;

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
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PageHeader(
                          compact: constraints.maxWidth < 760,
                          onAdd: _openAddDialog,
                        ),
                        const SizedBox(height: 22),
                        _VTTable(
                          rows: _rows,
                          onView: _showVtDetails,
                          onDelete: _confirmDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              right: 24,
              bottom: 36,
              child: DashboardQuickActionsFab(),
            ),
          ],
        );
      },
    );
  }

  void _openAddDialog() {
    showDialog<void>(
      context: context,
      barrierColor: const Color(0xA2000000),
      builder: (_) => _AddVTDialog(onAdd: _handleAddVt),
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
          width: 520,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
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
              const SizedBox(height: 14),
              _DetailLine(label: 'Name', value: item.name),
              _DetailLine(label: 'Mobile', value: item.mobile),
              _DetailLine(label: 'Subject/Trade', value: item.subject),
              _DetailLine(label: 'School', value: item.school),
              _DetailLine(label: 'District', value: item.district),
              _DetailLine(label: 'UDISE', value: item.udise),
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
      builder: (context) => AlertDialog(
        title: const Text('Delete VT'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
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
    await prefs.setStringList(
      _storageKey,
      _rows.map((item) => item.toStorage()).toList(),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.compact, required this.onAdd});

  final bool compact;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    const titleBlock = Column(
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
      onTap: onAdd,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: DashboardColors.red,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x262552C2),
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
        children: [titleBlock, const SizedBox(height: 14), addButton],
      );
    }

    return Row(children: [titleBlock, const Spacer(), addButton]);
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
          fontSize: 14.5,
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
          fontSize: 17,
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
              fontSize: 15,
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
          const SizedBox(width: 20),
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

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
  final _subject = TextEditingController();
  final _school = TextEditingController();
  final _district = TextEditingController();
  final _udise = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _subject.dispose();
    _school.dispose();
    _district.dispose();
    _udise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 18, 12),
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
                            fontSize: 21,
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
            const Divider(height: 1, color: DashboardColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;
                      return Column(
                        children: [
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'Full Name *',
                              controller: _name,
                            ),
                            right: _Field(
                              label: 'Mobile Number *',
                              controller: _mobile,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'Subject/Trade *',
                              controller: _subject,
                            ),
                            right: _Field(
                              label: 'School Name *',
                              controller: _school,
                            ),
                          ),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'District *',
                              controller: _district,
                            ),
                            right: _Field(
                              label: 'UDISE Code *',
                              controller: _udise,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: DashboardColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(105, 50),
                      side: const BorderSide(
                        color: DashboardColors.border,
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
                  ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      backgroundColor: DashboardColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add VT',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAdd(
      _VTItem(
        name: _name.text.trim(),
        mobile: _mobile.text.trim(),
        subject: _subject.text.trim(),
        school: _school.text.trim(),
        district: _district.text.trim(),
        udise: _udise.text.trim(),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('VT added successfully.')));
    Navigator.pop(context);
  }
}

class _FormRow extends StatelessWidget {
  const _FormRow({
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
          const SizedBox(height: 12),
          right,
          const SizedBox(height: 12),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DashboardColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: DashboardColors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}
