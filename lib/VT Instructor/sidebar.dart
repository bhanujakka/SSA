import 'package:flutter/material.dart';
import 'dashboard_colors.dart';

class DashboardSidebarController {
  static const double expandedWidth = 280;
  static const double collapsedWidth = 88;
  static final ValueNotifier<bool> isCollapsed = ValueNotifier<bool>(false);

  static void toggle() {
    isCollapsed.value = !isCollapsed.value;
  }
}

class DashboardSidebarHost extends StatelessWidget {
  const DashboardSidebarHost({
    super.key,
    required this.activeItem,
  });

  final String activeItem;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DashboardSidebarController.isCollapsed,
      builder: (context, isCollapsed, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: isCollapsed
              ? DashboardSidebarController.collapsedWidth
              : DashboardSidebarController.expandedWidth,
          child: DashboardSidebar(
            activeItem: activeItem,
            isCollapsed: isCollapsed,
          ),
        );
      },
    );
  }
}

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({
    super.key,
    this.activeItem = 'Dashboard',
    this.isCollapsed = false,
    this.showCollapseButton = true,
  });

  final String activeItem;
  final bool isCollapsed;
  final bool showCollapseButton;

  static const menuItems = [
    ('Dashboard', Icons.grid_view_rounded, '/vt-instructor/dashboard'),
    ('Students', Icons.school_outlined, '/vt-instructor/students'),
    (
      'Student Enrollment',
      Icons.person_add_alt_1_outlined,
      '/vt-instructor/student-enrollment'
    ),
    (
      'Exit Survey',
      Icons.assignment_turned_in_outlined,
      '/vt-instructor/exit-survey'
    ),
    ('Attendance', Icons.event_note_outlined, '/vt-instructor/attendance'),
    (
      'Class Monitor',
      Icons.fact_check_outlined,
      '/vt-instructor/class-monitor'
    ),
    ('Textbooks', Icons.menu_book_outlined, '/vt-instructor/textbooks'),
    (
      'VC Monitoring',
      Icons.supervised_user_circle_outlined,
      '/vt-instructor/vc-monitoring'
    ),
    (
      'Raw Materials',
      Icons.inventory_2_outlined,
      '/vt-instructor/raw-materials'
    ),
    (
      'Parent Teacher Meeting',
      Icons.groups_2_outlined,
      '/vt-instructor/parent-teacher-meeting'
    ),
    ('Internships', Icons.work_outline_rounded, '/vt-instructor/internships'),
    ('Exam Marks', Icons.grade_outlined, '/vt-instructor/exam-marks'),
    (
      'Teaching Register',
      Icons.app_registration_outlined,
      '/vt-instructor/teaching-register'
    ),
    // (
    //   'Schedule Lecture',
    //   Icons.event_note_outlined,
    //   '/vt-instructor/schedule-lecture'
    // ),
    ('Lesson Plan', Icons.event_available_outlined, '/vt-instructor/lesson-plan'),
    ('My Profile', Icons.person_outline_rounded, '/vt-instructor/my-profile'),
  ];

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  static const double _iconRailWidth = 64;
  static double _lastOffset = 0;
  late final ScrollController _scrollController;
  bool _isCollapseButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: _lastOffset);
  }

  @override
  void dispose() {
    _lastOffset = _scrollController.hasClients
        ? _scrollController.offset
        : _lastOffset;
    _scrollController.dispose();
    super.dispose();
  }

  void _setCollapseButtonPressed(bool value) {
    if (!mounted) return;
    setState(() => _isCollapseButtonPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = widget.isCollapsed;
    return LayoutBuilder(
      builder: (context, constraints) {
        final showExpandedContent =
            !isCollapsed && constraints.maxWidth >= 180;
        final menuList = ListView(
          controller: _scrollController,
          primary: false,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            12,
            14,
            12,
            showExpandedContent ? 18 : 14,
          ),
          children: DashboardSidebar.menuItems
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SidebarMenuItem(
                    item: item,
                    isActive: item.$1 == widget.activeItem,
                    isCollapsed: !showExpandedContent,
                    onTap: () => _handleNavigation(context, item),
                  ),
                ),
              )
              .toList(),
        );

        return Container(
          color: DashboardColors.sidebar,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  22,
                  showExpandedContent ? 22 : 12,
                  20,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: _iconRailWidth,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: showExpandedContent ? 52 : 44,
                          height: showExpandedContent ? 52 : 44,
                          decoration: const BoxDecoration(
                            color: DashboardColors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'SSA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: showExpandedContent ? 14 : 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showExpandedContent) ...[
                      const SizedBox(width: 12),
                      const Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NVEMS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17.5,
                              ),
                            ),
                            Text(
                              'Vocational Education',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFAEBDD3),
                                fontWeight: FontWeight.w600,
                                fontSize: 11.666,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0x408DB3D3)),
              Expanded(
                child: !showExpandedContent
                    ? menuList
                    : Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        radius: const Radius.circular(10),
                        thickness: 8,
                        child: menuList,
                      ),
              ),
              if (widget.showCollapseButton) ...[
                const Divider(height: 1, color: Color(0x408DB3D3)),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    12,
                    showExpandedContent ? 16 : 12,
                    showExpandedContent ? 16 : 12,
                    showExpandedContent ? 16 : 12,
                  ),
                  child: Tooltip(
                    message: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTapDown: (_) => _setCollapseButtonPressed(true),
                        onTapCancel: () => _setCollapseButtonPressed(false),
                        onTapUp: (_) => _setCollapseButtonPressed(false),
                        onTap: DashboardSidebarController.toggle,
                        child: AnimatedScale(
                          scale: _isCollapseButtonPressed ? 0.94 : 1,
                          duration: const Duration(milliseconds: 180),
                          curve: _isCollapseButtonPressed
                              ? Curves.easeOut
                              : Curves.elasticOut,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D65D7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final canShowLabel = showExpandedContent &&
                                      constraints.maxWidth >= 88;

                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: _iconRailWidth,
                                        child: Icon(
                                          isCollapsed
                                              ? Icons.chevron_right_rounded
                                              : Icons.chevron_left_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (canShowLabel) ...[
                                        const SizedBox(width: 4),
                                        const Flexible(
                                          child: Text(
                                            'Collapse',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.333,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(BuildContext context, (String, IconData, String) item) {
    if (item.$1 == widget.activeItem) {
      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
        Navigator.of(context).pop();
      }
      return;
    }
    final navigator = Navigator.of(context);
    final route = item.$3;
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      navigator.pop();
      Future.delayed(Duration.zero, () {
        navigator.pushReplacementNamed(route);
      });
      return;
    }
    navigator.pushReplacementNamed(route);
  }
}

class _SidebarMenuItem extends StatelessWidget {
  const _SidebarMenuItem({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  final (String, IconData, String) item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  static const double _iconRailWidth = 64;

  @override
  Widget build(BuildContext context) {
    final tile = Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: isActive ? DashboardColors.red : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final iconRailWidth = isCollapsed
                      ? constraints.maxWidth
                      : _iconRailWidth.clamp(0, constraints.maxWidth);

                  return Row(
                    children: [
                      SizedBox(
                        width: iconRailWidth.toDouble(),
                        child: Icon(item.$2, color: Colors.white, size: 23),
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.166,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        if (isActive)
          Positioned(
            right: 0,
            top: 11,
            child: Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );

    if (!isCollapsed) return tile;
    return Tooltip(message: item.$1, child: tile);
  }
}
