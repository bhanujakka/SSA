import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VTPManagementPage extends StatelessWidget {
  const VTPManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(activeItem: 'VTP Management', showCollapseButton: false),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'VTP Management'),
                const Expanded(child: _VTPBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VTPBody extends StatefulWidget {
  const _VTPBody();

  @override
  State<_VTPBody> createState() => _VTPBodyState();
}

class _VTPBodyState extends State<_VTPBody> {
  static const _storageKey = 'vtp_management_rows_v1';

  final List<_VTPItem> _items = [
    const _VTPItem(
      name: 'Tech Skill Pvt Ltd',
      code: 'VTP001',
      pan: 'ABCDE1234F',
      tan: 'DELM12345A',
      email: 'techskill@vtp.com',
      mobile: '+91 98765 43210',
      vtCount: 89,
      schoolCount: 15,
      verified: true,
    ),
    const _VTPItem(
      name: 'Vocational Training Corp',
      code: 'VTP002',
      pan: 'FGHIJ5678K',
      tan: 'MUMH67890B',
      email: 'voctraining@vtp.com',
      mobile: '+91 97654 32109',
      vtCount: 67,
      schoolCount: 12,
      verified: true,
    ),
    const _VTPItem(
      name: 'Skill India Partners',
      code: 'VTP003',
      pan: 'LMNOP9012Q',
      tan: 'BANG23456C',
      email: 'skillindia@vtp.com',
      mobile: '+91 96543 21098',
      vtCount: 54,
      schoolCount: 9,
      verified: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadStoredItems();
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
                      28,
                      isMobile ? 14 : 32,
                      110,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          compact: constraints.maxWidth < 760,
                          onAdd: _openAddDialog,
                          onDownload: _downloadAll,
                        ),
                        const SizedBox(height: 26),
                        ..._items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: _VTPCard(item: item),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              right: 24,
              bottom: 32,
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
      builder: (_) => _AddVTPDialog(onAdd: _handleAdd),
    );
  }

  void _downloadAll() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('VTP list download started.')));
  }

  void _handleAdd(_VTPItem item) {
    setState(() {
      _items.insert(0, item);
    });
    _saveItems();
  }

  Future<void> _loadStoredItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final parsed = raw.map(_VTPItem.fromStorage).toList();
    if (!mounted) return;
    setState(() {
      _items
        ..clear()
        ..addAll(parsed);
    });
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _items.map((item) => item.toStorage()).toList(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.compact,
    required this.onAdd,
    required this.onDownload,
  });

  final bool compact;
  final VoidCallback onAdd;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    const titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VTP Management',
          style: TextStyle(
            color: DashboardColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Vocational Training Provider organizations',
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 14,
      runSpacing: 12,
      children: [
        _HeaderButton(
          label: 'Download All',
          icon: Icons.download_rounded,
          outlined: true,
          onTap: onDownload,
        ),
        _HeaderButton(label: 'Add VTP', icon: Icons.add_rounded, onTap: onAdd),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [titleBlock, const SizedBox(height: 16), actions],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [titleBlock, const Spacer(), actions],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : DashboardColors.blue,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: DashboardColors.red, width: 1.4)
              : null,
          boxShadow: outlined
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x252D65D7),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: outlined ? DashboardColors.red : Colors.white,
              size: 21,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: outlined ? DashboardColors.red : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VTPCard extends StatelessWidget {
  const _VTPCard({required this.item});

  final _VTPItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return Container(
          padding: EdgeInsets.fromLTRB(
            compact ? 18 : 26,
            compact ? 20 : 26,
            compact ? 18 : 26,
            compact ? 18 : 22,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              compact ? _CompactDetails(item: item) : _WideDetails(item: item),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 18),
              _StatsRow(item: item, compact: compact),
            ],
          ),
        );
      },
    );
  }
}

class _WideDetails extends StatelessWidget {
  const _WideDetails({required this.item});

  final _VTPItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProviderIcon(),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Code: ${item.code}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const _InfoLabel('PAN:'),
              const SizedBox(height: 10),
              const _InfoLabel('TAN:'),
              const SizedBox(height: 10),
              const _InfoLabel('Email:'),
              const SizedBox(height: 10),
              const _InfoLabel('Mobile:'),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatusPill(verified: item.verified),
            const SizedBox(height: 28),
            _InfoValue(item.pan),
            const SizedBox(height: 12),
            _InfoValue(item.tan),
            const SizedBox(height: 12),
            _InfoValue(item.email),
            const SizedBox(height: 12),
            _InfoValue(item.mobile),
          ],
        ),
      ],
    );
  }
}

class _CompactDetails extends StatelessWidget {
  const _CompactDetails({required this.item});

  final _VTPItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProviderIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: DashboardColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${item.code}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatusPill(verified: item.verified),
        const SizedBox(height: 18),
        _DetailLine(label: 'PAN:', value: item.pan),
        _DetailLine(label: 'TAN:', value: item.tan),
        _DetailLine(label: 'Email:', value: item.email),
        _DetailLine(label: 'Mobile:', value: item.mobile),
      ],
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: DashboardColors.blue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.business_rounded, color: Colors.white, size: 36),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    final color = verified ? const Color(0xFF07866F) : const Color(0xFFB58D23);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: verified ? const Color(0xFFE4F6F1) : const Color(0xFFFBF6E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: color, size: 17),
          const SizedBox(width: 5),
          Text(
            verified ? 'Verified' : 'Pending',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLabel extends StatelessWidget {
  const _InfoLabel(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InfoValue extends StatelessWidget {
  const _InfoValue(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      textAlign: TextAlign.right,
      style: const TextStyle(
        color: DashboardColors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 72, child: _InfoLabel(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: DashboardColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.item, required this.compact});

  final _VTPItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final stats = <Widget>[
      _StatBlock(value: item.vtCount.toString(), label: 'VTs'),
      _StatBlock(value: item.schoolCount.toString(), label: 'PM Schools'),
    ];

    if (compact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 160),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stats,
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: DashboardColors.blue,
            fontSize: 25,
            height: 1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VTPItem {
  const _VTPItem({
    required this.name,
    required this.code,
    required this.pan,
    required this.tan,
    required this.email,
    required this.mobile,
    required this.vtCount,
    required this.schoolCount,
    required this.verified,
  });

  final String name;
  final String code;
  final String pan;
  final String tan;
  final String email;
  final String mobile;
  final int vtCount;
  final int schoolCount;
  final bool verified;

  String toStorage() {
    return [
      name,
      code,
      pan,
      tan,
      email,
      mobile,
      vtCount.toString(),
      schoolCount.toString(),
      verified ? '1' : '0',
    ].join('||');
  }

  static _VTPItem fromStorage(String raw) {
    final p = raw.split('||');
    if (p.length < 9) {
      return const _VTPItem(
        name: 'Unknown VTP',
        code: 'VTP000',
        pan: '-',
        tan: '-',
        email: '-',
        mobile: '-',
        vtCount: 0,
        schoolCount: 0,
        verified: false,
      );
    }

    return _VTPItem(
      name: p[0],
      code: p[1],
      pan: p[2],
      tan: p[3],
      email: p[4],
      mobile: p[5],
      vtCount: int.tryParse(p[6]) ?? 0,
      schoolCount: int.tryParse(p[7]) ?? 0,
      verified: p[8] == '1',
    );
  }
}

class _AddVTPDialog extends StatefulWidget {
  const _AddVTPDialog({required this.onAdd});

  final ValueChanged<_VTPItem> onAdd;

  @override
  State<_AddVTPDialog> createState() => _AddVTPDialogState();
}

class _AddVTPDialogState extends State<_AddVTPDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _pan = TextEditingController();
  final _tan = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _vts = TextEditingController(text: '0');
  final _schools = TextEditingController(text: '0');
  bool _verified = true;

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _pan.dispose();
    _tan.dispose();
    _email.dispose();
    _mobile.dispose();
    _vts.dispose();
    _schools.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 18, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add New VTP',
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
            ),
            const Divider(height: 1, color: DashboardColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
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
                              label: 'VTP Name *',
                              controller: _name,
                            ),
                            right: _Field(label: 'Code *', controller: _code),
                          ),
                          _FormRow(
                            compact: compact,
                            left: _Field(label: 'PAN *', controller: _pan),
                            right: _Field(label: 'TAN *', controller: _tan),
                          ),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'Email *',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: _emailValidator,
                            ),
                            right: _Field(
                              label: 'Mobile *',
                              controller: _mobile,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'VTs *',
                              controller: _vts,
                              keyboardType: TextInputType.number,
                              validator: _numberValidator,
                            ),
                            right: _Field(
                              label: 'PM Schools *',
                              controller: _schools,
                              keyboardType: TextInputType.number,
                              validator: _numberValidator,
                            ),
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _verified,
                            activeThumbColor: DashboardColors.blue,
                            title: const Text(
                              'Verified',
                              style: TextStyle(
                                color: DashboardColors.text,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => _verified = value),
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
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(104, 50),
                      side: const BorderSide(
                        color: DashboardColors.border,
                        width: 1.6,
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
                  ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 50),
                      backgroundColor: DashboardColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add VTP',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }

  String? _emailValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
        ? null
        : 'Invalid email';
  }

  String? _numberValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    return int.tryParse(value!.trim()) == null ? 'Enter a number' : null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAdd(
      _VTPItem(
        name: _name.text.trim(),
        code: _code.text.trim(),
        pan: _pan.text.trim().toUpperCase(),
        tan: _tan.text.trim().toUpperCase(),
        email: _email.text.trim(),
        mobile: _mobile.text.trim(),
        vtCount: int.tryParse(_vts.text.trim()) ?? 0,
        schoolCount: int.tryParse(_schools.text.trim()) ?? 0,
        verified: _verified,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('VTP added successfully.')));
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
    this.validator,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator ?? _required,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: DashboardColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DashboardColors.blue, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Required' : null;
  }
}
