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
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? Drawer(child: DashboardSidebar(activeItem: activeItem))
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  SizedBox(
                    width: 280,
                    child: DashboardSidebar(activeItem: activeItem),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopBar(isMobile: isMobile),
                      const Divider(height: 1, color: DashboardColors.border),
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
                                style: const TextStyle(
                                  color: DashboardColors.text,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: DashboardColors.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: DashboardColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  'Content area',
                                  style: TextStyle(
                                    color: DashboardColors.text,
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
