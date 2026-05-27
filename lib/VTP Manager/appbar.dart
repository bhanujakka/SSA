import 'package:flutter/material.dart';
import 'dashboard_colors.dart';

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
          const Spacer(),
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
                        'VTP Manager',
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

