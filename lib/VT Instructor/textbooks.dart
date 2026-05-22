import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class TextbooksPage extends StatelessWidget {
  const TextbooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileShell = constraints.maxWidth < 980;

        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobileShell
              ? const Drawer(
                  child: DashboardSidebar(
                    activeItem: 'Textbooks',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: 'Textbooks'),
                const Expanded(child: _TextbooksBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TextbooksBody extends StatelessWidget {
  const _TextbooksBody();

  static const _books = [
    _Textbook(
      title: 'Electrical Fundamentals',
      trade: 'Electrician Trade',
      total: 50,
      issued: 45,
    ),
    _Textbook(
      title: 'Computer Basics',
      trade: 'Computer Operator',
      total: 40,
      issued: 38,
    ),
    _Textbook(
      title: 'Plumbing Essentials',
      trade: 'Plumber Trade',
      total: 35,
      issued: 30,
    ),
    _Textbook(
      title: 'Carpentry Skills',
      trade: 'Carpenter Trade',
      total: 30,
      issued: 28,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final horizontalPadding = isMobile ? 16.0 : 32.0;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: constraints.maxWidth < 980),
                const Divider(height: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isMobile ? 24 : 34,
                      horizontalPadding,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1040),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Textbooks Issued to Students',
                              style: TextStyle(
                                color: DashboardColors.text,
                                fontSize: isMobile ? 25 : 29,
                                height: 1.08,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Track textbook distribution and availability',
                              style: TextStyle(
                                color: const Color(0xFF657386),
                                fontSize: isMobile ? 15 : 17,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const _SummaryCards(),
                            const SizedBox(height: 24),
                            for (final book in _books) ...[
                              _TextbookIssueCard(book: book),
                              if (book != _books.last)
                                const SizedBox(height: 16),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isMobile ? 18 : 30,
              bottom: 30,
              child: const DashboardQuickActionsFab(size: 66),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        final cardWidth = isMobile
            ? constraints.maxWidth
            : ((constraints.maxWidth - 48) / 3).clamp(240.0, 330.0);

        final cards = [
          const _SummaryCard(
            icon: Icons.menu_book_outlined,
            value: '155',
            label: 'Total Books',
            iconColor: Color(0xFF2445B5),
            borderColor: Color(0xFFE0E5F1),
            shadowColor: Color(0x220F172A),
          ),
          const _SummaryCard(
            icon: Icons.check_circle_outline_rounded,
            value: '141',
            label: 'Issued Count',
            iconColor: Color(0xFF059669),
            borderColor: Color(0xFF98F0BD),
            shadowColor: Color(0x22059669),
          ),
          const _SummaryCard(
            icon: Icons.cancel_outlined,
            value: '14',
            label: 'Unissued Count',
            iconColor: Color(0xFFE60012),
            borderColor: Color(0xFFFFA5A5),
            shadowColor: Color(0x22E60012),
          ),
        ];

        if (isMobile) {
          return Column(
            children: [
              for (final card in cards) ...[
                SizedBox(width: double.infinity, child: card),
                if (card != cards.last) const SizedBox(height: 14),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 24,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(width: cardWidth.toDouble(), child: card))
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color borderColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 174,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 46, color: iconColor),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF020817),
              fontSize: 30,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5E6878),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextbookIssueCard extends StatelessWidget {
  const _TextbookIssueCard({required this.book});

  final _Textbook book;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return Container(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 16 : 24,
            isCompact ? 18 : 24,
            isCompact ? 16 : 24,
            isCompact ? 20 : 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE4F0), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isCompact
                  ? _MobileHeader(book: book)
                  : _DesktopHeader(book: book),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 7,
                  child: LinearProgressIndicator(
                    value: book.issuedPercent,
                    backgroundColor: const Color(0xFFF0F1F4),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2F6FEA),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${book.issuedPercentageLabel}% Issued',
                  style: const TextStyle(
                    color: Color(0xFF5B6370),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.book});

  final _Textbook book;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _BookIconTile(),
        const SizedBox(width: 16),
        Expanded(child: _BookTitle(book: book)),
        const SizedBox(width: 20),
        _BookStats(book: book),
      ],
    );
  }
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.book});

  final _Textbook book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _BookIconTile(),
            const SizedBox(width: 14),
            Expanded(child: _BookTitle(book: book)),
          ],
        ),
        const SizedBox(height: 18),
        _BookStats(book: book, isMobile: true),
      ],
    );
  }
}

class _BookIconTile extends StatelessWidget {
  const _BookIconTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF2F65D9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.menu_book_outlined,
        color: Colors.white,
        size: 34,
      ),
    );
  }
}

class _BookTitle extends StatelessWidget {
  const _BookTitle({required this.book});

  final _Textbook book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF020817),
            fontSize: 20,
            height: 1.18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          book.trade,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF5E6878),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BookStats extends StatelessWidget {
  const _BookStats({required this.book, this.isMobile = false});

  final _Textbook book;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatValue(
        value: book.total,
        label: 'Total',
        color: const Color(0xFF2445B5),
      ),
      _StatValue(
        value: book.issued,
        label: 'Issued',
        color: const Color(0xFF059669),
      ),
      _StatValue(
        value: book.available,
        label: 'Available',
        color: const Color(0xFFE60012),
      ),
    ];

    if (isMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stats
            .map((stat) => Expanded(child: Center(child: stat)))
            .toList(),
      );
    }

    return SizedBox(
      width: 190,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: stats,
      ),
    );
  }
}

class _StatValue extends StatelessWidget {
  const _StatValue({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 26,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF5E6878),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Textbook {
  const _Textbook({
    required this.title,
    required this.trade,
    required this.total,
    required this.issued,
  });

  final String title;
  final String trade;
  final int total;
  final int issued;

  int get available => total - issued;

  double get issuedPercent => total == 0 ? 0 : issued / total;

  int get issuedPercentageLabel =>
      total == 0 ? 0 : ((issued / total) * 100).round();
}
