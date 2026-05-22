import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'sidebar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileShell = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobileShell
              ? const Drawer(child: DashboardSidebar(activeItem: '', showCollapseButton: false))
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: ''),
                const Expanded(child: _NotificationsBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationsBody extends StatefulWidget {
  const _NotificationsBody();

  @override
  State<_NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<_NotificationsBody> {
  late final List<_NotificationItem> _items;
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    _items = [
      _NotificationItem(
        title: 'Attendance report submitted',
        message: 'Government High School, Delhi submitted today\'s VT attendance.',
        time: '5 min ago',
        icon: Icons.event_available_outlined,
        color: const Color(0xFF0EA779),
        unread: true,
      ),
      _NotificationItem(
        title: 'Bill approval pending',
        message: 'Technical Training Hub has a monthly bill waiting for review.',
        time: '22 min ago',
        icon: Icons.receipt_long_outlined,
        color: DashboardColors.blue,
        unread: true,
      ),
      _NotificationItem(
        title: 'Guest lecture scheduled',
        message: 'Central Vocational Institute scheduled a guest lecture for Friday.',
        time: '1 hour ago',
        icon: Icons.campaign_outlined,
        color: const Color(0xFFC9A64B),
      ),
      _NotificationItem(
        title: 'New student enrolled',
        message: 'A new student profile was added under PM School South Zone.',
        time: 'Yesterday',
        icon: Icons.school_outlined,
        color: const Color(0xFF4F86E7),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        final visibleItems = _filter == _NotificationFilter.unread
            ? _items.where((item) => item.unread).toList()
            : _items;
        final unreadCount = _items.where((item) => item.unread).length;

        return Column(
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
                    _Header(
                      unreadCount: unreadCount,
                      onMarkAllRead: unreadCount == 0 ? null : _markAllRead,
                    ),
                    const SizedBox(height: 18),
                    _FilterBar(
                      selected: _filter,
                      onChanged: (value) => setState(() => _filter = value),
                    ),
                    const SizedBox(height: 18),
                    if (visibleItems.isEmpty)
                      const _EmptyState()
                    else
                      Column(
                        children: visibleItems
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _NotificationTile(
                                  item: item,
                                  onTap: () => _markRead(item),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _markRead(_NotificationItem item) {
    if (!item.unread) return;
    setState(() => item.unread = false);
  }

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.unread = false;
      }
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: DashboardColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Review system alerts and recent updates',
              style: TextStyle(
                color: DashboardColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: unreadCount == 0 ? const Color(0xFFE7F4ED) : const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DashboardColors.border, width: 1.4),
          ),
          child: Text(
            '$unreadCount unread',
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onMarkAllRead,
          icon: const Icon(Icons.done_all_rounded, size: 19),
          label: const Text('Mark all read'),
          style: TextButton.styleFrom(
            foregroundColor: DashboardColors.blue,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.onChanged,
  });

  final _NotificationFilter selected;
  final ValueChanged<_NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_NotificationFilter>(
      segments: const [
        ButtonSegment(
          value: _NotificationFilter.all,
          label: Text('All'),
          icon: Icon(Icons.inbox_outlined),
        ),
        ButtonSegment(
          value: _NotificationFilter.unread,
          label: Text('Unread'),
          icon: Icon(Icons.mark_email_unread_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (value) => onChanged(value.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : DashboardColors.text,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? DashboardColors.blue
              : Colors.white,
        ),
        side: const WidgetStatePropertyAll(
          BorderSide(color: DashboardColors.border, width: 1.5),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final _NotificationItem item;
  final VoidCallback onTap;

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: item.unread ? const Color(0xFFF8FAFF) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: item.unread || _isHovered
                    ? const Color(0xFFBFCBEA)
                    : DashboardColors.border,
                width: 1.6,
              ),
              boxShadow: _isHovered
                  ? const [
                      BoxShadow(
                        color: Color(0x1F4A81A6),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: item.color, size: 25),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                color: DashboardColors.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (item.unread)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 5, left: 8),
                              decoration: const BoxDecoration(
                                color: DashboardColors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.message,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DashboardColors.border, width: 1.6),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: DashboardColors.blue,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No unread notifications',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

enum _NotificationFilter { all, unread }

class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.unread = false,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  bool unread;
}
