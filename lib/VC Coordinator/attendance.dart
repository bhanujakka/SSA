import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';
import '../student_attendance_store.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileShell = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.pageSurface(context),
          drawer: isMobileShell
              ? const Drawer(child: DashboardSidebar(activeItem: 'Attendance', showCollapseButton: false))
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: 'Attendance'),
                const Expanded(child: _AttendanceBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _AttendanceRole { students, vts }

class _AttendanceBody extends StatefulWidget {
  const _AttendanceBody();

  @override
  State<_AttendanceBody> createState() => _AttendanceBodyState();
}

class _AttendanceBodyState extends State<_AttendanceBody> {
  _AttendanceRole _selectedRole = _AttendanceRole.students;

  final _roleData = <_AttendanceRole, List<(String, String, String, bool, String, String, String)>>{
    _AttendanceRole.students: [
      ('Rajesh Kumar', 'STU2024001', 'RK', true, '10:00 AM', '5:00 PM', '-'),
      ('Priya Sharma', 'STU2024002', 'PS', true, '10:00 AM', '5:00 PM', '-'),
      ('Amit Singh', 'STU2024003', 'AS', false, '--', '--', 'Absent'),
      ('Sneha Patel', 'STU2024004', 'SP', true, '10:00 AM', '5:00 PM', '-'),
      ('Rahul Verma', 'STU2024005', 'RV', true, '10:00 AM', '5:00 PM', '-'),
    ],
    _AttendanceRole.vts: [
      ('Anita Verma', 'VT2024001', 'AV', true, '10:00 AM', '5:00 PM', '-'),
      ('Rohit Das', 'VT2024002', 'RD', true, '10:00 AM', '5:00 PM', '-'),
      ('Meena Joshi', 'VT2024003', 'MJ', true, '10:00 AM', '5:00 PM', '-'),
      ('Sunil Yadav', 'VT2024004', 'SY', false, '--', '--', 'Absent'),
      ('Nisha Khan', 'VT2024005', 'NK', true, '10:00 AM', '5:00 PM', '-'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSubmittedStudentAttendance();
    _loadSubmittedVtAttendance();
  }

  Future<void> _loadSubmittedStudentAttendance() async {
    final submitted = await StudentAttendanceStore.load();
    if (!mounted || submitted.isEmpty) return;

    setState(() {
      _roleData[_AttendanceRole.students] = submitted
          .map(
            (record) => (
              record.name,
              record.id,
              record.initials,
              record.present,
              record.checkIn,
              record.checkOut,
              record.reason,
            ),
          )
          .toList();
    });
  }

  Future<void> _loadSubmittedVtAttendance() async {
    final submitted = await VtAttendanceStore.load();
    if (!mounted || submitted == null) return;

    setState(() {
      final current = _roleData[_AttendanceRole.vts]!;
      _roleData[_AttendanceRole.vts] = [
        (
          submitted.name,
          submitted.id,
          submitted.initials,
          submitted.present,
          submitted.checkIn,
          submitted.checkOut,
          submitted.reason,
        ),
        ...current.where((row) => row.$2 != submitted.id),
      ];
    });
  }

  String get _roleLabel {
    switch (_selectedRole) {
      case _AttendanceRole.students:
        return 'Students';
      case _AttendanceRole.vts:
        return 'VTs';
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _roleData[_selectedRole]!;
    final total = current.length;
    final presentCount = current.where((s) => s.$4).length;
    final rate = total == 0 ? 0 : ((presentCount / total) * 100).round();

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
                      isMobile ? 14 : 30,
                      22,
                      isMobile ? 14 : 30,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Management',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 41 / 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Mark and track daily attendance',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 30 / 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            _RoleChip(
                              text: 'Students',
                              icon: Icons.school_outlined,
                              active: _selectedRole == _AttendanceRole.students,
                              onTap: () => setState(
                                () => _selectedRole = _AttendanceRole.students,
                              ),
                            ),
                            _RoleChip(
                              text: 'VTs',
                              icon: Icons.person_outline_rounded,
                              active: _selectedRole == _AttendanceRole.vts,
                              onTap: () => setState(
                                () => _selectedRole = _AttendanceRole.vts,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        if (isMobile)
                          Column(
                            children: [
                              const _MetricCard(
                                borderColor: Color(0x5BE8A9B3),
                                iconColor: DashboardColors.red,
                                icon: Icons.calendar_month_outlined,
                                title: '5 May 2026',
                                subtitle: "Today's Date",
                              ),
                              const SizedBox(height: 12),
                              _MetricCard(
                                borderColor: const Color(0x7D74D89A),
                                iconColor: const Color(0xFF0CA140),
                                icon: Icons.check_circle_outline_rounded,
                                title: '$presentCount/$total',
                                subtitle: 'Present Today',
                              ),
                              const SizedBox(height: 12),
                              _AttendanceRateCard(rate: '$rate%'),
                            ],
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 330,
                                  child: _MetricCard(
                                    borderColor: Color(0x5BE8A9B3),
                                    iconColor: DashboardColors.red,
                                    icon: Icons.calendar_month_outlined,
                                    title: '5 May 2026',
                                    subtitle: "Today's Date",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 330,
                                  child: _MetricCard(
                                    borderColor: const Color(0x7D74D89A),
                                    iconColor: const Color(0xFF0CA140),
                                    icon: Icons.check_circle_outline_rounded,
                                    title: '$presentCount/$total',
                                    subtitle: 'Present Today',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 330,
                                  child: _AttendanceRateCard(rate: '$rate%'),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 18),
                        _AttendanceListCard(
                          isMobile: isMobile,
                          roleLabel: _roleLabel,
                          rows: current,
                        ),
                        const SizedBox(height: 72),
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

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.text,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final String text;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverLift(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: active
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                )
              : null,
          color: active ? null : Colors.white,
          border: Border.all(
            color: active ? Colors.transparent : const Color(0x88E7B3BE),
            width: 1.6,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.white : DashboardColors.text,
              size: 21,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : DashboardColors.text,
                fontSize: 32 / 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 20, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 42),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 25 / 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 15.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRateCard extends StatelessWidget {
  const _AttendanceRateCard({required this.rate});

  final String rate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 16, 24, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x88E7B3BE), width: 1.7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                  ),
                ),
              ),
              Text(
                rate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Attendance Rate',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 15.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceListCard extends StatelessWidget {
  const _AttendanceListCard({
    required this.isMobile,
    required this.roleLabel,
    required this.rows,
  });

  final bool isMobile;
  final String roleLabel;
  final List<(String, String, String, bool, String, String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final showTimeColumns = roleLabel != 'Students';
    final tableWidth = showTimeColumns
        ? (isMobile ? 900.0 : MediaQuery.of(context).size.width - 360.0)
        : (isMobile ? 520.0 : MediaQuery.of(context).size.width - 360.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55E8A9B3), width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 22),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mark Attendance - $roleLabel',
                    style: const TextStyle(
                      color: DashboardColors.text,
                      fontSize: 37 / 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x33E7B3BE)),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 26,
              10,
              isMobile ? 14 : 26,
              12,
            ),
            child: showTimeColumns
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        children: [
                          const _AttendanceTableHeader(),
                          const SizedBox(height: 8),
                          ...rows.map(
                            (row) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _AttendanceRow(
                                name: row.$1,
                                id: row.$2,
                                initials: row.$3,
                                present: row.$4,
                                checkIn: row.$5,
                                checkOut: row.$6,
                                reason: row.$7,
                                showTimeColumns: showTimeColumns,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: rows
                        .map(
                          (row) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AttendanceRow(
                              name: row.$1,
                              id: row.$2,
                              initials: row.$3,
                              present: row.$4,
                              checkIn: row.$5,
                              checkOut: row.$6,
                              reason: row.$7,
                              showTimeColumns: showTimeColumns,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTableHeader extends StatelessWidget {
  const _AttendanceTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          _HeaderCell(label: 'Name', flex: 3),
          _HeaderCell(label: 'ID', flex: 2),
          _HeaderCell(label: 'Checkin', flex: 2),
          _HeaderCell(label: 'Checkout', flex: 2),
          _HeaderCell(label: 'Reason', flex: 3),
          _HeaderCell(label: 'Present/Absent', flex: 2),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.flex});

  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: DashboardColors.text,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.name,
    required this.id,
    required this.initials,
    required this.present,
    required this.checkIn,
    required this.checkOut,
    required this.reason,
    required this.showTimeColumns,
  });

  final String name;
  final String id;
  final String initials;
  final bool present;
  final String checkIn;
  final String checkOut;
  final String reason;
  final bool showTimeColumns;

  @override
  Widget build(BuildContext context) {
    final bg = present ? Colors.white : const Color(0xFFFDF7F8);

    if (!showTimeColumns) {
      return _HoverLift(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: present ? Colors.transparent : const Color(0x77E7B3BE),
              width: 1.4,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18 / 1.2,
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
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 34 / 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 14.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(present: present),
            ],
          ),
        ),
      );
    }

    return _HoverLift(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: present ? Colors.transparent : const Color(0x77E7B3BE),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18 / 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 34 / 2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _AttendanceTextCell(text: id, flex: 2),
            _AttendanceTextCell(text: checkIn, flex: 2),
            _AttendanceTextCell(text: checkOut, flex: 2),
            _AttendanceTextCell(text: reason, flex: 3),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusPill(present: present),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTextCell extends StatelessWidget {
  const _AttendanceTextCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  const _HoverLift({required this.child, this.borderRadius, this.onTap});

  final Widget child;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(14),
          boxShadow: _hovered
              ? const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(14),
          child: InkWell(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(14),
            onTap: widget.onTap,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.present});

  final bool present;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: present ? const Color(0xFFD5F4DF) : const Color(0xFFFBE1E3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            present
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: present ? const Color(0xFF00953D) : const Color(0xFFD61625),
            size: 23,
          ),
          const SizedBox(width: 6),
          Text(
            present ? 'Present' : 'Absent',
            style: TextStyle(
              color: present
                  ? const Color(0xFF00953D)
                  : const Color(0xFFD61625),
              fontSize: 31 / 2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SmallFloatingPlus extends StatelessWidget {
  const _SmallFloatingPlus({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          BoxShadow(color: Color(0x33EC3347), blurRadius: 18, spreadRadius: 3),
        ],
      ),
      child: Icon(Icons.add, color: Colors.white, size: size * 0.52),
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
