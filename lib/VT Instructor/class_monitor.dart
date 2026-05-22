import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class ClassMonitorPage extends StatelessWidget {
  const ClassMonitorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(
                    activeItem: 'Class Monitor',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Class Monitor'),
                const Expanded(child: _ClassMonitorBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClassMonitorBody extends StatefulWidget {
  const _ClassMonitorBody();

  @override
  State<_ClassMonitorBody> createState() => _ClassMonitorBodyState();
}

class _ClassMonitorBodyState extends State<_ClassMonitorBody> {
  final _dateController = TextEditingController(text: '08-05-2026');
  final List<_PeriodEntry> _periods = List.generate(
    8,
    (index) => _PeriodEntry(period: index + 1),
  );

  @override
  void dispose() {
    _dateController.dispose();
    for (final period in _periods) {
      period.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final isShellMobile = constraints.maxWidth < 980;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isShellMobile),
                const Divider(height: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16 : 32,
                      isMobile ? 28 : 34,
                      isMobile ? 16 : 32,
                      108,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Class Monitor',
                          style: TextStyle(
                            color: Color(0xFF020817),
                            fontSize: 29,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '8-Period class timetable and activity tracker',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _RegisterCard(
                          isMobile: isMobile,
                          dateController: _dateController,
                          periods: _periods,
                          onPickDate: _pickDate,
                          onSave: _saveTimetable,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isMobile ? 16 : 32,
              bottom: 28,
              child: const DashboardQuickActionsFab(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 5, 8),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      _dateController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    });
  }

  void _saveTimetable() {
    final filled = _periods
        .where(
          (period) =>
              period.subject.text.trim().isNotEmpty ||
              period.topic.text.trim().isNotEmpty ||
              period.activity.text.trim().isNotEmpty,
        )
        .length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Class timetable saved for ${_dateController.text}. $filled periods updated.',
        ),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    required this.isMobile,
    required this.dateController,
    required this.periods,
    required this.onPickDate,
    required this.onSave,
  });

  final bool isMobile;
  final TextEditingController dateController;
  final List<_PeriodEntry> periods;
  final VoidCallback onPickDate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 24,
        isMobile ? 20 : 28,
        isMobile ? 16 : 24,
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCD8F8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x170F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _RegisterHeader(
            isMobile: isMobile,
            dateController: dateController,
            onPickDate: onPickDate,
          ),
          const SizedBox(height: 26),
          ...periods.map(
            (period) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PeriodRow(
                entry: period,
                isMobile: isMobile,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : 210,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_outlined, size: 20),
                label: const Text('Save Timetable'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2552C2),
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: const Color(0x553475E6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader({
    required this.isMobile,
    required this.dateController,
    required this.onPickDate,
  });

  final bool isMobile;
  final TextEditingController dateController;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        const Icon(
          Icons.desktop_windows_outlined,
          color: Color(0xFF2552C2),
          size: 38,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Daily Class Register',
                style: TextStyle(
                  color: Color(0xFF020817),
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Record what was taught and done',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final dateField = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Date:',
          style: TextStyle(
            color: Color(0xFF020817),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 178,
          child: _DateField(
            controller: dateController,
            onTap: onPickDate,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 18),
          dateField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        dateField,
      ],
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.entry,
    required this.isMobile,
  });

  final _PeriodEntry entry;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 16,
        isMobile ? 16 : 22,
        isMobile ? 14 : 16,
        isMobile ? 16 : 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7F2), width: 1),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PeriodIdentity(entry: entry),
                const SizedBox(height: 16),
                _PeriodInputs(entry: entry, isMobile: true),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 230, child: _PeriodIdentity(entry: entry)),
                Expanded(child: _PeriodInputs(entry: entry, isMobile: false)),
              ],
            ),
    );
  }
}

class _PeriodIdentity extends StatelessWidget {
  const _PeriodIdentity({required this.entry});

  final _PeriodEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2D65D7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              'P${entry.period}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Period ${entry.period}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF020817),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '9:00 - 9:45',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 13,
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

class _PeriodInputs extends StatelessWidget {
  const _PeriodInputs({
    required this.entry,
    required this.isMobile,
  });

  final _PeriodEntry entry;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final inputs = [
      _MonitorInput(
        label: 'Subject',
        hint: 'Enter subject',
        controller: entry.subject,
      ),
      _MonitorInput(
        label: 'Topic Taught',
        hint: 'Enter topic',
        controller: entry.topic,
      ),
      _MonitorInput(
        label: 'Activity Done',
        hint: 'Enter activity',
        controller: entry.activity,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (final input in inputs) ...[
            input,
            if (input != inputs.last) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var index = 0; index < inputs.length; index++) ...[
          Expanded(child: inputs[index]),
          if (index != inputs.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _MonitorInput extends StatelessWidget {
  const _MonitorInput({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            inputFormatters: [
              LengthLimitingTextInputFormatter(60),
            ],
            style: const TextStyle(
              color: Color(0xFF020817),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              border: _fieldBorder(),
              enabledBorder: _fieldBorder(),
              focusedBorder: _fieldBorder(color: const Color(0xFF3475E6)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.onTap,
  });

  final TextEditingController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF020817),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          suffixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF020817),
            size: 17,
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          border: _fieldBorder(),
          enabledBorder: _fieldBorder(),
          focusedBorder: _fieldBorder(color: const Color(0xFF3475E6)),
        ),
      ),
    );
  }
}

OutlineInputBorder _fieldBorder({Color color = const Color(0xFFC7D4F5)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1),
  );
}

class _PeriodEntry {
  _PeriodEntry({required this.period});

  final int period;
  final subject = TextEditingController();
  final topic = TextEditingController();
  final activity = TextEditingController();

  void dispose() {
    subject.dispose();
    topic.dispose();
    activity.dispose();
  }
}
