import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(child: DashboardSidebar(activeItem: 'Dashboard', showCollapseButton: false))
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Dashboard'),
                const Expanded(child: _DashboardBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 980;
        final isTablet = maxWidth >= 980 && maxWidth < 1050;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isMobile),
                const Divider(height: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 14 : 22),
                    child: Column(
                      children: [
                        const _HeroBanner(),
                        const SizedBox(height: 18),
                        _StatsSection(
                          columns: isMobile ? 1 : (isTablet ? 2 : 3),
                        ),
                        const SizedBox(height: 18),
                        const _BillingSection(),
                        const SizedBox(height: 18),
                        _BottomSection(isMobile: maxWidth < 980),
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
                child: _FloatingPlus(),
              ),
          ],
        );
      },
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2552C2),
                Color(0xFF2D65D7),
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -65,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x25FFFFFF),
                    ),
                  ),
                ),
                Positioned(
                  right: 280,
                  bottom: -100,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x12FFFFFF),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 18 : 34,
                    30,
                    isCompact ? 18 : 34,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to SSA-NVEMS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 18 : 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'National Vocational Education Management System Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.pushReplacementNamed(context, '/reports'),
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View Reports',
                                    style: TextStyle(
                                      color: DashboardColors.red,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: DashboardColors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.pushReplacementNamed(context, '/vt-management'),
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0x60FFFFFF), width: 2),
                                borderRadius: BorderRadius.circular(18),
                                color: const Color(0x25FFFFFF),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Add VTP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.columns});

  final int columns;

  static const List<_StatItem> _stats = [
    _StatItem(
      title: 'PM Schools',
      value: '856',
      badge: '+8.5%',
      icon: Icons.account_balance_outlined,
      tileGradient: [Color(0xFF2552C2), Color(0xFF1F43A3)],
    ),
    _StatItem(
      title: 'SS Schools',
      value: '391',
      badge: '+4.2%',
      icon: Icons.account_balance_outlined,
      tileGradient: [Color(0xFF2D65D7), Color(0xFF1F43A3)],
    ),
    _StatItem(
      title: 'Total VTPs',
      value: '124',
      badge: '+6.3%',
      icon: Icons.receipt_long_outlined,
      tileGradient: [Color(0xFF98D2DC), Color(0xFF2D65D7)],
    ),
    _StatItem(
      title: 'Total Students',
      value: '45,892',
      badge: '+12.1%',
      icon: Icons.school_outlined,
      tileGradient: [Color(0xFF2552C2), Color(0xFF1F43A3)],
    ),
    _StatItem(
      title: 'Total VTs',
      value: '3,456',
      badge: 'Today: 3,201/3,456',
      icon: Icons.person_add_alt_1_outlined,
      tileGradient: [Color(0xFF2552C2), Color(0xFF2D65D7)],
    ),
    _StatItem(
      title: 'Total VCs',
      value: '892',
      badge: 'Today: 864/892',
      icon: Icons.manage_search_outlined,
      tileGradient: [Color(0xFF4F86E7), Color(0xFF7398E4)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _stats
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: _StatCard(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered ? const Color(0xFF7398E4) : DashboardColors.border,
            width: 2,
          ),
          boxShadow: _isHovered
              ? const [
                  BoxShadow(
                    color: Color(0x224A81A6),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.item.tileGradient,
                    ),
                  ),
                  child: Icon(widget.item.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCEF3D8),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          '+ ${widget.item.badge}',
                          style: const TextStyle(
                            color: Color(0xFF00853A),
                            fontSize: 14 / 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              widget.item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DashboardColors.text,
                fontSize: 31 / 1.2,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: DashboardColors.text,
                fontSize: 17 / 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillingSection extends StatefulWidget {
  const _BillingSection();

  @override
  State<_BillingSection> createState() => _BillingSectionState();
}

class _BillingSectionState extends State<_BillingSection> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    const bars = [44000.0, 51000.0, 47000.0, 60000.0, 54000.0, 66000.0];
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            runSpacing: 10,
            spacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Billing',
                    style: TextStyle(
                      color: DashboardColors.text,
                      fontSize: 22 / 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Revenue in thousands (Rs)',
                    style: TextStyle(
                      color: DashboardColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: DashboardColors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Rs 3.2L Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16 / 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _YLabels(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            bars.length,
                            (index) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _hoveredIndex = index),
                                  onExit: (_) => setState(() => _hoveredIndex = null),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0x0FE83B52),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: bars[index] / 80000,
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 140),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(9),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: _hoveredIndex == index
                                                      ? const [Color(0xFF4F86E7), Color(0xFF1F43A3)]
                                                      : const [Color(0xFF2552C2), Color(0xFF1F43A3)],
                                                ),
                                                boxShadow: _hoveredIndex == index
                                                    ? const [
                                                        BoxShadow(
                                                          color: Color(0x40EF3348),
                                                          blurRadius: 12,
                                                          offset: Offset(0, 4),
                                                        ),
                                                      ]
                                                    : const [],
                                              ),
                                              child: _hoveredIndex == index
                                                  ? Center(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                          '${labels[index]}\nRs ${bars[index].toInt()}',
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10.5,
                                                            fontWeight: FontWeight.w700,
                                                            height: 1.2,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          labels.length,
                          (index) => Expanded(
                            child: Center(
                              child: Text(
                                labels[index],
                                style: const TextStyle(
                                  color: Color(0xFF7A8595),
                                  fontSize: 18 / 1.2,
                                  fontWeight: FontWeight.w500,
                                ),
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
        ],
      ),
    );
  }
}

class _YLabels extends StatelessWidget {
  const _YLabels();

  @override
  Widget build(BuildContext context) {
    const labels = ['80000', '60000', '40000', '20000', '0'];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: labels
          .map(
            (label) => Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A8595),
                fontWeight: FontWeight.w500,
                fontSize: 17 / 1.2,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return const Column(
        children: [
          _ActivitiesCard(),
          SizedBox(height: 16),
          _RecentActivitiesCard(),
        ],
      );
    }
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 1, child: _ActivitiesCard()),
        SizedBox(width: 16),
        Expanded(flex: 2, child: _RecentActivitiesCard()),
      ],
    );
  }
}

class _ActivitiesCard extends StatefulWidget {
  const _ActivitiesCard();

  @override
  State<_ActivitiesCard> createState() => _ActivitiesCardState();
}

class _ActivitiesCardState extends State<_ActivitiesCard> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    const legendItems = [
      ('Guest Lectures', 145, Color(0xFF2552C2)),
      ('Industrial Visits', 89, Color(0xFF4F86E7)),
      ('Workshops', 234, Color(0xFF0EA779)),
      ('Assessments', 456, Color(0xFFC9A64B)),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activities Distribution',
            style: TextStyle(
              color: DashboardColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 22 / 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: MouseRegion(
              onHover: (event) {
                final idx = _DonutChartPainter.segmentIndexAt(
                  const Size(180, 180),
                  event.localPosition,
                );
                if (_hoveredIndex != idx) {
                  setState(() => _hoveredIndex = idx);
                }
              },
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _DonutChartPainter(highlightIndex: _hoveredIndex),
                    ),
                    if (_hoveredIndex != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: legendItems[_hoveredIndex!].$3,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${legendItems[_hoveredIndex!].$2}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...legendItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: item.$3, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 15 / 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${item.$2}',
                    style: const TextStyle(
                      color: DashboardColors.text,
                      fontSize: 15 / 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  const _RecentActivitiesCard();

  static const entries = [
    ('1', 'New student enrolled', 'Government High School, Delhi', '5 min ago', [Color(0xFF2552C2), Color(0xFF1F43A3)]),
    ('2', 'Guest lecture scheduled', 'Central Vocational Institute', '12 min ago', [Color(0xFF2D65D7), Color(0xFF0F172A)]),
    ('3', 'Attendance report submitted', 'Skill Development Center', '25 min ago', [Color(0xFF7398E4), Color(0xFF2D65D7)]),
    ('4', 'Bill generated and approved', 'Technical Training Hub', '1 hour ago', [Color(0xFF2D65D7), Color(0xFF1F43A3)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activities',
            style: TextStyle(
              color: DashboardColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 22 / 1.2,
            ),
          ),
          const SizedBox(height: 18),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _RecentActivityRow(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityRow extends StatefulWidget {
  const _RecentActivityRow({required this.entry});

  final (String, String, String, String, List<Color>) entry;

  @override
  State<_RecentActivityRow> createState() => _RecentActivityRowState();
}

class _RecentActivityRowState extends State<_RecentActivityRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: _isHovered ? const Color(0xFFF8FAFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered ? const Color(0xFFCFD6ED) : Colors.transparent,
            width: 1.4,
          ),
          boxShadow: _isHovered
              ? const [
                  BoxShadow(
                    color: Color(0x263C6E97),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ]
              : const [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 170),
              scale: _isHovered ? 1.06 : 1,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(colors: entry.$5),
                ),
                child: Center(
                  child: Text(
                    entry.$1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28 / 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.$2,
                    style: const TextStyle(
                      color: DashboardColors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 17 / 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.$3,
                    style: const TextStyle(
                      color: DashboardColors.text,
                      fontWeight: FontWeight.w500,
                      fontSize: 15 / 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                entry.$4,
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 14 / 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({this.highlightIndex});

  final int? highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    const values = [145.0, 89.0, 234.0, 456.0];
    const colors = [
      Color(0xFF2552C2),
      Color(0xFF4F86E7),
      Color(0xFF0EA779),
      Color(0xFFC9A64B),
    ];
    const strokeWidth = 22.0;
    const gap = 0.08;
    final total = values.reduce((a, b) => a + b);
    var start = -math.pi / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.shortestSide - strokeWidth) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = strokeWidth;

    for (var i = 0; i < values.length; i++) {
      final sweep = ((values[i] / total) * math.pi * 2) - gap;
      paint.color = colors[i];
      paint.strokeWidth = i == highlightIndex ? strokeWidth + 4 : strokeWidth;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  static int? segmentIndexAt(Size size, Offset point) {
    const values = [145.0, 89.0, 234.0, 456.0];
    const strokeWidth = 22.0;
    const gap = 0.08;
    final center = Offset(size.width / 2, size.height / 2);
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    final r = math.sqrt(dx * dx + dy * dy);
    final outer = (size.shortestSide - strokeWidth) / 2;
    final inner = outer - strokeWidth;
    if (r < inner || r > outer + 6) return null;

    var angle = math.atan2(dy, dx);
    if (angle < -math.pi / 2) angle += math.pi * 2;
    var start = -math.pi / 2;
    final total = values.reduce((a, b) => a + b);
    for (var i = 0; i < values.length; i++) {
      final sweep = ((values[i] / total) * math.pi * 2) - gap;
      final end = start + sweep;
      if (angle >= start && angle <= end) return i;
      start += sweep + gap;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.highlightIndex != highlightIndex;
}

class _StatItem {
  const _StatItem({
    required this.title,
    required this.value,
    required this.badge,
    required this.icon,
    required this.tileGradient,
  });

  final String title;
  final String value;
  final String badge;
  final IconData icon;
  final List<Color> tileGradient;
}




