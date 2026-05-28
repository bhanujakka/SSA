import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import '../dashboard_top_alert.dart';
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
          backgroundColor: DashboardColors.surface,
          drawer: isMobileShell
              ? const Drawer(
                  child: DashboardSidebar(
                    activeItem: 'Attendance',
                    showCollapseButton: false,
                  ),
                )
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

class AttendencePage extends AttendancePage {
  const AttendencePage({super.key});
}

enum _AttendanceRole { students }

class _AttendanceBody extends StatefulWidget {
  const _AttendanceBody();

  @override
  State<_AttendanceBody> createState() => _AttendanceBodyState();
}

class _AttendanceBodyState extends State<_AttendanceBody> {
  _AttendanceRole _selectedRole = _AttendanceRole.students;

  final Map<_AttendanceRole, List<_AttendancePerson>> _roleData = {
    _AttendanceRole.students: [
      _AttendancePerson('Rajesh Kumar Sharma', 'STU2024001', 'RK', true),
      _AttendancePerson('Priya Devi Patel', 'STU2024002', 'PD', true),
      _AttendancePerson('Amit Singh', 'STU2024003', 'AS', false),
      _AttendancePerson('Sneha Patel', 'STU2024004', 'SP', true),
      _AttendancePerson('Rahul Verma', 'STU2024005', 'RV', true),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadSubmittedStudentAttendance();
  }

  Future<void> _loadSubmittedStudentAttendance() async {
    final submitted = await StudentAttendanceStore.load();
    if (!mounted || submitted.isEmpty) return;

    setState(() {
      _roleData[_AttendanceRole.students] = submitted
          .map(
            (record) => _AttendancePerson(
              record.name,
              record.id,
              record.initials,
              record.present,
            ),
          )
          .toList();
    });
  }

  String get _roleLabel {
    switch (_selectedRole) {
      case _AttendanceRole.students:
        return 'Students';
    }
  }

  String get _todayLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final current = _roleData[_selectedRole]!;
    final total = current.length;
    final presentCount = current.where((person) => person.present).length;
    final rate = total == 0 ? 0 : ((presentCount / total) * 100).round();

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
                      isMobile ? 14 : 30,
                      22,
                      isMobile ? 14 : 30,
                      104,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attendance Management',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Mark and track daily attendance',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 15,
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
                              active:
                                  _selectedRole == _AttendanceRole.students,
                              onTap: () => setState(
                                () => _selectedRole = _AttendanceRole.students,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _MetricsRow(
                          isMobile: isMobile,
                          todayLabel: _todayLabel,
                          presentCount: presentCount,
                          total: total,
                          rate: rate,
                        ),
                        const SizedBox(height: 18),
                        _AttendanceListCard(
                          isMobile: isMobile,
                          roleLabel: _roleLabel,
                          rows: current,
                          onToggle: (person) {
                            setState(() => person.present = !person.present);
                          },
                          onSubmit: () => _submitAttendance(
                            roleLabel: _roleLabel,
                            presentCount: presentCount,
                            total: total,
                            rate: rate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isMobile ? 18 : 24,
              bottom: 28,
              child: const DashboardQuickActionsFab(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAttendance({
    required String roleLabel,
    required int presentCount,
    required int total,
    required int rate,
  }) async {
    final students = _roleData[_AttendanceRole.students]!
        .map(
          (person) => StudentAttendanceRecord(
            name: person.name,
            id: person.id,
            initials: person.initials,
            present: person.present,
            checkIn: person.present ? '10:00 AM' : '--',
            checkOut: person.present ? '5:00 PM' : '--',
            reason: person.present ? '-' : 'Absent',
          ),
        )
        .toList();
    await StudentAttendanceStore.save(students);
    if (!mounted) return;

    showDashboardTopAlert(
      context,
      title: '$roleLabel attendance submitted',
      message: '$presentCount/$total present ($rate%)',
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.isMobile,
    required this.todayLabel,
    required this.presentCount,
    required this.total,
    required this.rate,
  });

  final bool isMobile;
  final String todayLabel;
  final int presentCount;
  final int total;
  final int rate;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard(
        borderColor: const Color(0x5BE8A9B3),
        iconColor: DashboardColors.red,
        icon: Icons.calendar_month_outlined,
        title: todayLabel,
        subtitle: "Today's Date",
      ),
      _MetricCard(
        borderColor: const Color(0x7D74D89A),
        iconColor: const Color(0xFF0CA140),
        icon: Icons.check_circle_outline_rounded,
        title: '$presentCount/$total',
        subtitle: 'Present Today',
      ),
      _AttendanceRateCard(rate: '$rate%'),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (final card in cards) ...[
            card,
            if (card != cards.last) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map(
                (card) => SizedBox(
                  width: width.clamp(240, 360).toDouble(),
                  child: card,
                ),
              )
              .toList(),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 21,
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
            child: Center(
              child: Text(
                rate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
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
    required this.onToggle,
    required this.onSubmit,
  });

  final bool isMobile;
  final String roleLabel;
  final List<_AttendancePerson> rows;
  final ValueChanged<_AttendancePerson> onToggle;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
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
                      fontSize: 18.5,
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
            child: Column(
              children: rows
                  .map(
                    (person) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AttendanceRow(
                        person: person,
                        onToggle: () => onToggle(person),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: Color(0x33E7B3BE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: _HoverLift(
                borderRadius: BorderRadius.circular(16),
                onTap: onSubmit,
                child: Container(
                  width: isMobile ? double.infinity : 230,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Submit Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.person,
    required this.onToggle,
  });

  final _AttendancePerson person;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final bg = person.present ? Colors.white : const Color(0xFFFDF7F8);

    return _HoverLift(
      borderRadius: BorderRadius.circular(16),
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: person.present ? Colors.transparent : const Color(0x77E7B3BE),
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
                  person.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DashboardColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    person.id,
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
            _StatusPill(present: person.present),
          ],
        ),
      ),
    );
  }
}

class _HoverLift extends StatefulWidget {
  const _HoverLift({
    required this.child,
    this.borderRadius,
    this.onTap,
  });

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
              color:
                  present ? const Color(0xFF00953D) : const Color(0xFFD61625),
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendancePerson {
  _AttendancePerson(this.name, this.id, this.initials, this.present);

  final String name;
  final String id;
  final String initials;
  bool present;
}
