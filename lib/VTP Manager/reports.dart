import 'package:flutter/material.dart';

import 'appbar.dart';
import 'bill_download_service.dart'
    if (dart.library.io) 'bill_download_service_io.dart'
    if (dart.library.html) 'bill_download_service_web.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(activeItem: 'Reports'),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const SizedBox(
                    width: 280,
                    child: DashboardSidebar(activeItem: 'Reports'),
                  ),
                const Expanded(child: _ReportsBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  static const recentReports = [
    _RecentReport(
      title: 'Monthly Attendance Report',
      subtitle: 'Attendance - Generated on 15/4/2026 - 2.4 MB',
      icon: Icons.insert_chart_outlined_rounded,
    ),
    _RecentReport(
      title: 'Student Enrollment Summary',
      subtitle: 'Enrollment - Generated on 14/4/2026 - 1.8 MB',
      icon: Icons.description_outlined,
    ),
    _RecentReport(
      title: 'VTP Performance Analysis',
      subtitle: 'Performance - Generated on 12/4/2026 - 3.2 MB',
      icon: Icons.trending_up_rounded,
    ),
    _RecentReport(
      title: 'Billing & Payment Report',
      subtitle: 'Finance - Generated on 10/4/2026 - 1.5 MB',
      icon: Icons.insert_chart_outlined_rounded,
    ),
  ];

  static String _safeFilePart(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_').toLowerCase();
  }

  static Future<void> _downloadReport(BuildContext context, _RecentReport item) async {
    try {
      final fileName = '${_safeFilePart(item.title)}.txt';
      final content = '''
REPORT
Title: ${item.title}
Details: ${item.subtitle}
Generated On: ${DateTime.now()}
''';
      final savedLocation = await downloadBillFile(fileName: fileName, content: content);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report downloaded: $savedLocation'),
          backgroundColor: const Color(0xFF0F9F6E),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download report.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 980;
        final columns = maxWidth < 700 ? 1 : (maxWidth < 980 ? 2 : 4);

        return Stack(
          children: [
            Column(
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
                        const Text(
                          'Reports & Analytics',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Generate and download comprehensive system reports',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GeneratorCards(columns: columns),
                        const SizedBox(height: 18),
                        _RecentReportsCard(
                          items: recentReports,
                          onDownload: (item) => _downloadReport(context, item),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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

class _GeneratorCards extends StatelessWidget {
  const _GeneratorCards({required this.columns});

  final int columns;

  static const items = [
    'Generate Attendance\nReport',
    'Generate Enrollment\nReport',
    'Generate Performance\nReport',
    'Generate Finance\nReport',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (text) => SizedBox(
                  width: width,
                  child: _GeneratorCard(title: text),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _GeneratorCard extends StatelessWidget {
  const _GeneratorCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 146,
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55E47084), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.insert_chart_outlined_rounded,
            color: DashboardColors.red,
            size: 36,
          ),
          const Spacer(),
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DashboardColors.text,
                fontSize: 36 / 2,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportsCard extends StatelessWidget {
  const _RecentReportsCard({
    required this.items,
    required this.onDownload,
  });

  final List<_RecentReport> items;
  final void Function(_RecentReport item) onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1FEA4A65), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 22, 24, 22),
              child: Row(
                children: [
                  Text(
                    'Recent Reports',
                    style: TextStyle(
                      color: DashboardColors.text,
                      fontSize: 22 / 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0x1FEA4A65)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                children: items
                    .map((item) => _RecentReportRow(item: item, onDownload: () => onDownload(item)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentReportRow extends StatelessWidget {
  const _RecentReportRow({
    required this.item,
    required this.onDownload,
  });

  final _RecentReport item;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 1000;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReportMain(item: item),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _DownloadButton(onTap: onDownload),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _ReportMain(item: item)),
                const SizedBox(width: 16),
                _DownloadButton(onTap: onDownload),
              ],
            ),
    );
  }
}

class _ReportMain extends StatelessWidget {
  const _ReportMain({required this.item});

  final _RecentReport item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DashboardColors.red, Color(0xFF2D65D7)],
            ),
          ),
          child: Icon(item.icon, color: Colors.white, size: 29),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 20 / 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: const TextStyle(
                  color: DashboardColors.text,
                  fontSize: 16 / 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF7E9EC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_rounded, color: DashboardColors.red, size: 21),
              SizedBox(width: 8),
              Text(
                'Download',
                style: TextStyle(
                  color: DashboardColors.red,
                  fontSize: 19 / 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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

class _RecentReport {
  const _RecentReport({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

