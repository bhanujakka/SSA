import 'package:flutter/material.dart';

import 'dashboard_colors.dart';

class DashboardQuickActionsFab extends StatelessWidget {
  const DashboardQuickActionsFab({super.key, this.size = 66});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: () => _openQuickActions(context),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x44EC3347),
                blurRadius: 24,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Icon(Icons.add, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }

  void _openQuickActions(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;
    if (isMobile) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _QuickActionsSheet(
          onSelect: (action) => _handleAction(sheetContext, action),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned(
              right: 100,
              bottom: 120,
              child: _QuickActionsMenu(
                onSelect: (action) => _handleAction(dialogContext, action),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleAction(BuildContext context, _QuickAction action) {
    Navigator.of(context).pop();
    switch (action) {
      case _QuickAction.addStudent:
        Navigator.of(context).pushNamed('/vt-instructor/students');
        break;
      case _QuickAction.markAttendance:
        Navigator.of(context).pushNamed('/vt-instructor/attendance');
        break;
      case _QuickAction.scheduleLecture:
        Navigator.of(context).pushNamed('/vt-instructor/schedule-lecture');
        break;
    }
  }
}

class _QuickActionsMenu extends StatelessWidget {
  const _QuickActionsMenu({required this.onSelect});

  final ValueChanged<_QuickAction> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E7F3), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2955709A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuickActionTile(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Add Student',
            subtitle: 'Create a new student profile',
            onTap: () => onSelect(_QuickAction.addStudent),
          ),
          const SizedBox(height: 8),
          _QuickActionTile(
            icon: Icons.fact_check_outlined,
            title: 'Mark Attendance',
            subtitle: 'Update today attendance status',
            onTap: () => onSelect(_QuickAction.markAttendance),
          ),
          const SizedBox(height: 8),
          _QuickActionTile(
            icon: Icons.event_note_outlined,
            title: 'Schedule Lecture',
            subtitle: 'Plan the next lecture session',
            onTap: () => onSelect(_QuickAction.scheduleLecture),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet({required this.onSelect});

  final ValueChanged<_QuickAction> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: _QuickActionsMenu(onSelect: onSelect),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFF),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5B6A80),
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _QuickAction {
  addStudent,
  markAttendance,
  scheduleLecture,
}
