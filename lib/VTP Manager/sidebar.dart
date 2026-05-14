import 'package:flutter/material.dart';
import 'dashboard_colors.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({
    super.key,
    this.activeItem = 'Dashboard',
  });

  final String activeItem;

  static const menuItems = [
    ('Dashboard', Icons.grid_view_rounded, '/dashboard'),
    ('VC Management', Icons.supervised_user_circle_outlined, '/vc-management'),
    ('VT Management', Icons.person_add_alt_1_outlined, '/vt-management'),
    ('Students', Icons.school_outlined, '/students'),
    ('Attendance', Icons.event_note_outlined, '/attendance'),
    ('Billing', Icons.currency_rupee_rounded, '/billing'),
    ('Reports', Icons.bar_chart_rounded, '/reports'),
    ('My Profile', Icons.person_outline_rounded, '/my-profile'),
  ];

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  static double _lastOffset = 0;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: _lastOffset);
  }

  @override
  void dispose() {
    _lastOffset = _scrollController.hasClients ? _scrollController.offset : _lastOffset;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DashboardColors.sidebar,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: DashboardColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'SSA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NVEMS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17.5,
                      ),
                    ),
                    Text(
                      'Vocational Education',
                      style: TextStyle(
                        color: Color(0xFFAEBDD3),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.666,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x408DB3D3)),
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              radius: const Radius.circular(10),
              thickness: 8,
              child: ListView(
                controller: _scrollController,
                primary: false,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                children: DashboardSidebar.menuItems
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Stack(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _handleNavigation(context, item),
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: item.$1 == widget.activeItem
                                        ? DashboardColors.red
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      Icon(
                                        item.$2,
                                        color: Colors.white,
                                        size: 23,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.$1,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.166,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (item.$1 == widget.activeItem)
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
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0x408DB3D3)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2D65D7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chevron_left_rounded, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Collapse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.333,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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

