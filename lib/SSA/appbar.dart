import 'package:flutter/material.dart';
import 'dashboard_colors.dart';
import 'sidebar.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 96 : 92,
      color: DashboardColors.top,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: DashboardColors.blue,
                  ),
                );
              },
            ),
          const Expanded(
            child: _SearchBox(
              extraTargets: [
                _SearchTarget(
                  label: 'Schedule Lecture',
                  route: '/ssa/schedule-lecture',
                ),
              ],
            ),
          ),
          if (isMobile) ...[
            const SizedBox(width: 8),
            const _CircleButton(icon: Icons.wb_sunny_outlined, size: 42),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _CircleButton(
                  icon: Icons.notifications_none_rounded,
                  size: 42,
                  tooltip: 'Notifications',
                  onTap: () => _openNotifications(context),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: DashboardColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: DashboardColors.red,
              child: Icon(Icons.person_outline, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            _CircleButton(
              icon: Icons.logout_rounded,
              size: 42,
              tooltip: 'Logout',
              onTap: () => _logout(context),
            ),
          ],
          if (!isMobile) ...[
            const SizedBox(width: 12),
            const _CircleButton(icon: Icons.wb_sunny_outlined),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _CircleButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Notifications',
                  onTap: () => _openNotifications(context),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: DashboardColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFD9DFF0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: DashboardColors.red,
                    child: Icon(Icons.person_outline, color: Colors.white),
                  ),
                  SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          color: DashboardColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        'SSA Admin',
                        style: TextStyle(
                          color: Color(0xFF355776),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _CircleButton(
              icon: Icons.logout_rounded,
              tooltip: 'Logout',
              onTap: () => _logout(context),
            ),
          ],
        ],
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == '/notifications') return;
    Navigator.of(context).pushNamed('/notifications');
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}

class _SearchTarget {
  const _SearchTarget({required this.label, required this.route});

  final String label;
  final String route;
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({this.extraTargets = const []});

  final List<_SearchTarget> extraTargets;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardColors.border, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _handleSearch(context, value),
        decoration: const InputDecoration(
          icon: Icon(
            Icons.search_rounded,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        style: const TextStyle(
          color: DashboardColors.text,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleSearch(BuildContext context, String value) {
    final query = _normalize(value);
    if (query.isEmpty) return;

    for (final item in DashboardSidebar.menuItems) {
      final label = item.$1;
      if (_matches(query, label)) {
        Navigator.of(context).pushNamed(item.$3);
        return;
      }
    }

    for (final target in extraTargets) {
      if (_matches(query, target.label)) {
        Navigator.of(context).pushNamed(target.route);
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No page found for "$value"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _matches(String query, String label) {
    final normalizedLabel = _normalize(label);
    return normalizedLabel.contains(query) || query.contains(normalizedLabel);
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    this.size = 50,
    this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: DashboardColors.border, width: 2),
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: DashboardColors.blue, size: size <= 42 ? 20 : 22),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
