import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'sidebar.dart';

class SectionTemplatePage extends StatelessWidget {
  const SectionTemplatePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.activeItem,
  });

  final String title;
  final String subtitle;
  final String activeItem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.pageSurface(context),
          drawer: isMobile
              ? Drawer(
                  child: DashboardSidebar(
                    activeItem: activeItem,
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile) DashboardSidebarHost(activeItem: activeItem),
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopBar(isMobile: isMobile),
                      Divider(
                        height: 1,
                        color: DashboardColors.borderFor(context),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 14 : 32,
                            22,
                            isMobile ? 14 : 32,
                            24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: DashboardColors.textFor(context),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: DashboardColors.mutedTextFor(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: DashboardColors.cardSurface(context),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: DashboardColors.borderFor(context),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'Content area',
                                  style: TextStyle(
                                    color: DashboardColors.textFor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
