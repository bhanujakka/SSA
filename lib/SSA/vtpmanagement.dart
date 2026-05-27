import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      address: 'New Delhi, Delhi - 110001',
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
      address: 'Mumbai, Maharashtra - 400001',
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
      address: 'Bengaluru, Karnataka - 560001',
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
              const _InfoLabel('Address:'),
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
            _InfoValue(item.address),
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
        _DetailLine(label: 'Address:', value: item.address),
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
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Text(
        value,
        textAlign: TextAlign.right,
        softWrap: true,
        style: const TextStyle(
          color: DashboardColors.text,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
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
    required this.address,
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
  final String address;
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
      address,
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
        address: '-',
        email: '-',
        mobile: '-',
        vtCount: 0,
        schoolCount: 0,
        verified: false,
      );
    }

    if (p.length == 9) {
      return _VTPItem(
        name: p[0],
        code: p[1],
        pan: p[2],
        tan: p[3],
        address: '-',
        email: p[4],
        mobile: p[5],
        vtCount: int.tryParse(p[6]) ?? 0,
        schoolCount: int.tryParse(p[7]) ?? 0,
        verified: p[8] == '1',
      );
    }

    return _VTPItem(
      name: p[0],
      code: p[1],
      pan: p[2],
      tan: p[3],
      address: p[4],
      email: p[5],
      mobile: p[6],
      vtCount: int.tryParse(p[7]) ?? 0,
      schoolCount: int.tryParse(p[8]) ?? 0,
      verified: p[9] == '1',
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
  final _pan = TextEditingController();
  final _tan = TextEditingController();
  final _address = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _vts = TextEditingController(text: '0');
  final _schools = TextEditingController(text: '0');

  @override
  void dispose() {
    _name.dispose();
    _pan.dispose();
    _tan.dispose();
    _address.dispose();
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
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 18, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New VTP',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Enter VTP organization details',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 440;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Field(
                            label: 'VTP Name *',
                            hintText: 'Enter VTP organization name',
                            controller: _name,
                            validator: _nameValidator,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 12),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'PAN Number *',
                              hintText: 'ABCDE1234F',
                              controller: _pan,
                              validator: _panValidator,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[a-zA-Z0-9]'),
                                ),
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            right: _Field(
                              label: 'TAN Number *',
                              hintText: 'DELM12345A',
                              controller: _tan,
                              validator: _tanValidator,
                              textCapitalization: TextCapitalization.characters,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[a-zA-Z0-9]'),
                                ),
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                          ),
                          _Field(
                            label: 'Full Address *',
                            hintText: 'Street, Area, City, State - Pincode',
                            controller: _address,
                            validator: _addressValidator,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 12),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'Number of VTs *',
                              hintText: '0',
                              controller: _vts,
                              keyboardType: TextInputType.number,
                              validator: _numberValidator,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            right: _Field(
                              label: 'Number of PM Schools *',
                              hintText: '0',
                              controller: _schools,
                              keyboardType: TextInputType.number,
                              validator: _numberValidator,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          _FormRow(
                            compact: compact,
                            left: _Field(
                              label: 'Email ID *',
                              hintText: 'contact@vtp.com',
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              validator: _emailValidator,
                            ),
                            right: _Field(
                              label: 'Mobile Number *',
                              hintText: '+91 XXXXX XXXXX',
                              controller: _mobile,
                              keyboardType: TextInputType.phone,
                              validator: _mobileValidator,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp('[0-9+ ]'),
                                ),
                                LengthLimitingTextInputFormatter(16),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(104, 50),
                      side: const BorderSide(
                        color: DashboardColors.border,
                        width: 1.2,
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
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(104, 50),
                      backgroundColor: DashboardColors.blue,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: DashboardColors.blue.withValues(alpha: 0.28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
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
    return value == null || value.trim().isEmpty
        ? 'This field is required'
        : null;
  }

  String? _nameValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final trimmed = value!.trim();
    if (trimmed.length < 3) return 'Enter at least 3 characters';
    if (!RegExp(r'^[a-zA-Z0-9 .,&()-]+$').hasMatch(trimmed)) {
      return 'Use only letters, numbers, and basic punctuation';
    }
    return null;
  }

  String? _panValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    return RegExp(
      r'^[A-Z]{5}[0-9]{4}[A-Z]$',
    ).hasMatch(value!.trim().toUpperCase())
        ? null
        : 'Enter a valid PAN';
  }

  String? _tanValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    return RegExp(
      r'^[A-Z]{4}[0-9]{5}[A-Z]$',
    ).hasMatch(value!.trim().toUpperCase())
        ? null
        : 'Enter a valid TAN';
  }

  String? _addressValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final trimmed = value!.trim();
    if (trimmed.length < 10) return 'Enter the complete address';
    if (!RegExp(r'\b\d{6}\b').hasMatch(trimmed)) {
      return 'Include a 6 digit pincode';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())
        ? null
        : 'Enter a valid email';
  }

  String? _mobileValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    final mobile = digits.length > 10 && digits.startsWith('91')
        ? digits.substring(digits.length - 10)
        : digits;
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final number = int.tryParse(value!.trim());
    if (number == null) return 'Enter a valid number';
    if (number < 0) return 'Enter 0 or more';
    if (number > 9999) return 'Enter a realistic count';
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onAdd(
      _VTPItem(
        name: _name.text.trim(),
        code: _generateCode(),
        pan: _pan.text.trim().toUpperCase(),
        tan: _tan.text.trim().toUpperCase(),
        address: _address.text.trim(),
        email: _email.text.trim(),
        mobile: _mobile.text.trim(),
        vtCount: int.tryParse(_vts.text.trim()) ?? 0,
        schoolCount: int.tryParse(_schools.text.trim()) ?? 0,
        verified: true,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('VTP added successfully.')));
    Navigator.pop(context);
  }

  String _generateCode() {
    final timestamp = DateTime.now().millisecondsSinceEpoch % 100000;
    return 'VTP${timestamp.toString().padLeft(5, '0')}';
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
    this.hintText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator ?? _required,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF7C8797),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: DashboardColors.border,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: DashboardColors.blue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? 'This field is required'
        : null;
  }
}
