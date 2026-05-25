
import 'package:flutter/material.dart';

import 'appbar.dart';
import 'bill_download_service.dart'
    if (dart.library.io) 'bill_download_service_io.dart'
    if (dart.library.html) 'bill_download_service_web.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileShell = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobileShell ? const Drawer(child: DashboardSidebar(activeItem: 'Billing', showCollapseButton: false)) : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: 'Billing'),
                const Expanded(child: _BillingBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BillingBody extends StatelessWidget {
  const _BillingBody();

  static const _rows = [
    (
      'BILL-VC-\n2024-001',
      'Amit Verma',
      'Tech Skill Pvt Ltd',
      '₹45,000',
      '10/4/2026',
      _BillStatus.paid,
    ),
    (
      'BILL-VC-\n2024-002',
      'Priya\nGupta',
      'Vocational Training\nCorp',
      '₹38,000',
      '12/4/2026',
      _BillStatus.pending,
    ),
    (
      'BILL-VC-\n2024-003',
      'Rahul\nSharma',
      'Skill India Partners',
      '₹52,000',
      '14/4/2026',
      _BillStatus.approved,
    ),
    (
      'BILL-VC-\n2024-004',
      'Sneha Iyer',
      'Tech Skill Pvt Ltd',
      '₹41,000',
      '13/4/2026',
      _BillStatus.approved,
    ),
    (
      'BILL-VC-\n2024-005',
      'Karan\nMehta',
      'Vocational Training\nCorp',
      '₹47,000',
      '11/4/2026',
      _BillStatus.pending,
    ),
  ];

  static String _statusLabel(_BillStatus status) {
    switch (status) {
      case _BillStatus.paid:
        return 'Paid';
      case _BillStatus.pending:
        return 'Pending';
      case _BillStatus.approved:
        return 'Approved';
    }
  }

  static String _safeFilePart(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|\s]+'), '_').replaceAll('\n', '_');
  }

  static Future<void> _downloadBill(
    BuildContext context,
    (String, String, String, String, String, _BillStatus) row,
  ) async {
    try {
      final billId = row.$1.replaceAll('\n', '');
      final vcName = row.$2.replaceAll('\n', ' ');
      final vtp = row.$3.replaceAll('\n', ' ');
      final amount = row.$4;
      final date = row.$5;
      final status = _statusLabel(row.$6);

      final fileName = '${_safeFilePart(billId)}_bill.txt';
      final content = '''
VC BILL
Bill ID: $billId
VC Name: $vcName
VTP: $vtp
Amount: $amount
Date: $date
Status: $status
Generated On: ${DateTime.now()}
''';
      final savedLocation = await downloadBillFile(fileName: fileName, content: content);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill downloaded: $savedLocation'),
          backgroundColor: const Color(0xFF0F9F6E),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to download bill.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        final pagePadding = isMobile ? 14.0 : 30.0;
        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isMobile),
                const Divider(height: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(pagePadding, 22, pagePadding, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VC Billing Management',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 41 / 2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Track VC payments, invoices and financial transactions',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 30 / 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: const [
                            _MetricCard(
                              title: 'Total Amount',
                              value: '₹223K',
                              valueColor: Color(0xFF1E40AF),
                              icon: Icons.currency_rupee_rounded,
                              iconColor: Color(0xFF1D4ED8),
                            ),
                            _MetricCard(
                              title: 'Paid',
                              value: '₹45K',
                              valueColor: Color(0xFF059669),
                              icon: Icons.check_circle_outline_rounded,
                              iconColor: Color(0xFF00A76F),
                            ),
                            _MetricCard(
                              title: 'Pending',
                              value: '₹85K',
                              valueColor: Color(0xFFC4A555),
                              icon: Icons.access_time_rounded,
                              iconColor: Color(0xFFC8A94E),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _BillsTableCard(
                          isMobile: isMobile,
                          rows: _rows,
                          onDownload: (row) => _downloadBill(context, row),
                        ),
                        const SizedBox(height: 72),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width < 980 ? MediaQuery.of(context).size.width - 28 : 324.0;
    return Container(
      width: cardWidth.clamp(260.0, 324.0).toDouble(),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9CED8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 31 / 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 56 / 2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

enum _BillStatus { paid, pending, approved }

class _BillsTableCard extends StatelessWidget {
  const _BillsTableCard({
    required this.isMobile,
    required this.rows,
    required this.onDownload,
  });

  final bool isMobile;
  final List<(String, String, String, String, String, _BillStatus)> rows;
  final void Function((String, String, String, String, String, _BillStatus)) onDownload;

  @override
  Widget build(BuildContext context) {
    final minWidth = isMobile ? 980.0 : 0.0;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC9CED8), width: 1),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 22, 24, 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'VC Bills by VTP',
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: 36 / 2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFD6DBE4)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: minWidth),
              child: Column(
                children: [
                  const _HeaderRow(),
                  ...rows.map((row) => _BillRow(row: row, onDownload: () => onDownload(row))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          SizedBox(width: 170, child: _HeaderText('Bill ID')),
          SizedBox(width: 138, child: _HeaderText('VC Name')),
          SizedBox(width: 198, child: _HeaderText('VTP')),
          SizedBox(width: 118, child: _HeaderText('Amount')),
          SizedBox(width: 130, child: _HeaderText('Date')),
          SizedBox(width: 158, child: _HeaderText('Status')),
          SizedBox(width: 62, child: _HeaderText('Actions')),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: DashboardColors.text,
        fontSize: 32 / 2,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({required this.row, required this.onDownload});

  final (String, String, String, String, String, _BillStatus) row;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFD6DBE4))),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              row.$1,
              style: const TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 35 / 2,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: 138,
            child: Text(
              row.$2,
              style: const TextStyle(
                color: Color(0xFF020617),
                fontSize: 35 / 2,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: 198,
            child: Text(
              row.$3,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 35 / 2,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(
            width: 118,
            child: Text(
              row.$4,
              style: const TextStyle(
                color: Color(0xFF020617),
                fontSize: 35 / 2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(
              row.$5,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 34 / 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 158, child: _StatusPill(status: row.$6)),
          SizedBox(
            width: 62,
            child: Center(
              child: InkWell(
                onTap: onDownload,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.download_rounded,
                    color: Color(0xFF1D4ED8),
                    size: 22,
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final _BillStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color textColor;
    late final Color borderColor;
    late final Color bgColor;
    late final IconData icon;
    late final String label;

    switch (status) {
      case _BillStatus.paid:
        textColor = const Color(0xFF0F9F6E);
        borderColor = const Color(0xFFA7E3CB);
        bgColor = const Color(0xFFEAF9F3);
        icon = Icons.check_circle_outline_rounded;
        label = 'Paid';
        break;
      case _BillStatus.pending:
        textColor = const Color(0xFFBC9D4B);
        borderColor = const Color(0xFFE2D4AE);
        bgColor = const Color(0xFFFBF6E9);
        icon = Icons.access_time_rounded;
        label = 'Pending';
        break;
      case _BillStatus.approved:
        textColor = const Color(0xFF3B82F6);
        borderColor = const Color(0xFFB7CDFE);
        bgColor = const Color(0xFFEAF2FF);
        icon = Icons.check_circle_outline_rounded;
        label = 'Approved';
        break;
    }

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

