import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VCPortalPage extends StatelessWidget {
  const VCPortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: _surfaceColor(context),
          drawer: isMobile
              ? const Drawer(child: DashboardSidebar(activeItem: 'VC Portal', showCollapseButton: false))
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'VC Portal'),
                const Expanded(child: _VCPortalBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VCPortalBody extends StatelessWidget {
  const _VCPortalBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final isTablet =
            constraints.maxWidth >= 760 && constraints.maxWidth < 1160;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: constraints.maxWidth < 980),
                Divider(height: 1, color: _borderColor(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 24,
                      24,
                      isMobile ? 14 : 24,
                      120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VC Portal',
                          style: TextStyle(
                            color: _textColor(context),
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'View VT data and attendance details',
                          style: TextStyle(
                            color: _mutedColor(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _StatsGrid(columns: isMobile ? 1 : (isTablet ? 2 : 3)),
                        const SizedBox(height: 18),
                        const _AttendanceDetailsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (!isMobile)
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
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    final items = [
      const _StatItem(
        icon: Icons.person_add_alt_1_outlined,
        value: '4',
        label: 'Total VTs',
        accent: DashboardColors.red,
      ),
      const _StatItem(
        value: '89',
        label: 'Total Present Days',
        accent: Color(0xFF00A878),
        softAccent: Color(0xFF9BE7C0),
      ),
      const _StatItem(
        value: '11',
        label: 'Total Absent Days',
        accent: Color(0xFFFF001B),
        softAccent: Color(0xFFFFA6AE),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 18.0;
        final width =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map(
                (item) => SizedBox(
                  width: width,
                  child: _StatCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.softAccent ?? _borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0x33000000)
                : const Color(0x1F6B7890),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.icon != null)
            Icon(item.icon, color: item.accent, size: 36)
          else
            Text(
              item.value,
              style: TextStyle(
                color: item.accent,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          const Spacer(),
          if (item.icon != null)
            Text(
              item.value,
              style: TextStyle(
                color: _textColor(context),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: _mutedColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDetailsCard extends StatefulWidget {
  const _AttendanceDetailsCard();

  @override
  State<_AttendanceDetailsCard> createState() => _AttendanceDetailsCardState();
}

class _AttendanceDetailsCardState extends State<_AttendanceDetailsCard> {
  String _selectedPeriod = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, isMobile ? 18 : 18, 18, 16),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0x33000000)
                : const Color(0x146B7890),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _AttendanceHeader(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (value) {
              if (value != null) setState(() => _selectedPeriod = value);
            },
          ),
          const SizedBox(height: 20),
          const _AttendanceTable(),
        ],
      ),
    );
  }
}

class _AttendanceHeader extends StatelessWidget {
  const _AttendanceHeader({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final String selectedPeriod;
  final ValueChanged<String?> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;
    final title = Text(
      'VT Attendance Details',
      style: TextStyle(
        color: _textColor(context),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: isMobile ? WrapAlignment.start : WrapAlignment.end,
      children: [
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor(context)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedPeriod,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
              items: const ['Monthly', 'Quarterly', 'Half Yearly', 'Yearly']
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: onPeriodChanged,
              style: TextStyle(
                color: _textColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Absent list download started')),
            );
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Download Absent List'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(184, 32),
            backgroundColor: DashboardColors.red,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, const SizedBox(height: 14), actions],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        actions,
      ],
    );
  }
}

class _AttendanceTable extends StatelessWidget {
  const _AttendanceTable();

  static const _rows = [
    _AttendanceRow(
      'VT001',
      'Krishna Murthy',
      'Govt High School Delhi',
      'Electrician',
      '+91 98765 43210',
      22,
      3,
    ),
    _AttendanceRow(
      'VT002',
      'Lakshmi Devi',
      'Central Vocational Institute',
      'Computer Operator',
      '+91 97654 32109',
      24,
      1,
    ),
    _AttendanceRow(
      'VT003',
      'Ramesh Babu',
      'Skill Development Center',
      'Plumber',
      '+91 96543 21098',
      20,
      5,
    ),
    _AttendanceRow(
      'VT004',
      'Sunita Rao',
      'Technical Training Hub',
      'Carpenter',
      '+91 95432 10987',
      23,
      2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 1040),
        child: Column(
          children: [
            _TableLine(
              isHeader: true,
              cells: const [
                'VT Code',
                'Name',
                'School',
                'Trade',
                'Mobile',
                'Present',
                'Absent',
                'Actions',
              ],
            ),
            ..._rows.map((row) => _TableLine(row: row)),
          ],
        ),
      ),
    );
  }
}

class _TableLine extends StatelessWidget {
  const _TableLine({this.row, this.cells, this.isHeader = false});

  final _AttendanceRow? row;
  final List<String>? cells;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final values =
        cells ??
        [
          row!.code,
          row!.name,
          row!.school,
          row!.trade,
          row!.mobile,
          row!.present.toString(),
          row!.absent.toString(),
          'View',
        ];

    return Container(
      height: isHeader ? 42 : 46,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _borderColor(context).withValues(alpha: 0.7),
          ),
        ),
      ),
      child: Row(
        children: [
          _Cell(width: 96, text: values[0], isHeader: isHeader),
          _Cell(width: 140, text: values[1], isHeader: isHeader),
          _Cell(width: 214, text: values[2], isHeader: isHeader, muted: true),
          _Cell(width: 164, text: values[3], isHeader: isHeader),
          _Cell(width: 154, text: values[4], isHeader: isHeader),
          SizedBox(
            width: 90,
            child: isHeader
                ? _HeaderText(values[5])
                : _CountPill(value: values[5], isPresent: true),
          ),
          SizedBox(
            width: 90,
            child: isHeader
                ? _HeaderText(values[6])
                : _CountPill(value: values[6], isPresent: false),
          ),
          SizedBox(
            width: 92,
            child: isHeader ? _HeaderText(values[7]) : const _ViewButton(),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.width,
    required this.text,
    required this.isHeader,
    this.muted = false,
  });

  final double width;
  final String text;
  final bool isHeader;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isHeader
              ? _textColor(context)
              : (muted ? _mutedColor(context) : _textColor(context)),
          fontSize: isHeader ? 12.5 : 12,
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _textColor(context),
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.value, required this.isPresent});

  final String value;
  final bool isPresent;

  @override
  Widget build(BuildContext context) {
    final color = isPresent ? const Color(0xFF00A878) : const Color(0xFFFF4858);
    final bg = isPresent ? const Color(0xFFE2F5EF) : const Color(0xFFFDE8EA);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening VT attendance details')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: DashboardColors.red,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'View',
                  style: TextStyle(
                    color: DashboardColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _StatItem {
  const _StatItem({
    this.icon,
    required this.value,
    required this.label,
    required this.accent,
    this.softAccent,
  });

  final IconData? icon;
  final String value;
  final String label;
  final Color accent;
  final Color? softAccent;
}

class _AttendanceRow {
  const _AttendanceRow(
    this.code,
    this.name,
    this.school,
    this.trade,
    this.mobile,
    this.present,
    this.absent,
  );

  final String code;
  final String name;
  final String school;
  final String trade;
  final String mobile;
  final int present;
  final int absent;
}

Color _surfaceColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF0B1220)
    : DashboardColors.surface;

Color _cardColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF111827)
    : Colors.white;

Color _borderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF26354D)
    : DashboardColors.border;

Color _textColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : DashboardColors.text;

Color _mutedColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFAAB6C7)
    : const Color(0xFF667085);
