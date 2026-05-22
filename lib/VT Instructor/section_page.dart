import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VTInstructorSectionPage extends StatelessWidget {
  const VTInstructorSectionPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? Drawer(
                  child: DashboardSidebar(
                    activeItem: title,
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile) DashboardSidebarHost(activeItem: title),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          DashboardTopBar(isMobile: isMobile),
                          const Divider(
                            height: 1,
                            color: DashboardColors.border,
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: DashboardColors.text,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: isMobile ? 18 : 32,
                        bottom: 28,
                        child: const DashboardQuickActionsFab(),
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
