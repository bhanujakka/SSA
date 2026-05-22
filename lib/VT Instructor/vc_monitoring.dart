import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VCMonitoringPage extends StatelessWidget {
  const VCMonitoringPage({super.key});

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
                    activeItem: 'VC Monitoring',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: 'VC Monitoring'),
                const Expanded(child: _VCMonitoringBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VCMonitoringBody extends StatefulWidget {
  const _VCMonitoringBody();

  @override
  State<_VCMonitoringBody> createState() => _VCMonitoringBodyState();
}

class _VCMonitoringBodyState extends State<_VCMonitoringBody> {
  final _formKey = GlobalKey<FormState>();
  final _vcNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeInController = TextEditingController();
  final _timeOutController = TextEditingController();
  final _tradeController = TextEditingController();
  final _vtpController = TextEditingController();
  final _schoolController = TextEditingController();
  final _blockController = TextEditingController();
  final _emailController = TextEditingController();
  final _udiseController = TextEditingController();

  final List<_VCReport> _reports = [];
  bool _isAdding = false;

  @override
  void dispose() {
    _vcNameController.dispose();
    _dateController.dispose();
    _timeInController.dispose();
    _timeOutController.dispose();
    _tradeController.dispose();
    _vtpController.dispose();
    _schoolController.dispose();
    _blockController.dispose();
    _emailController.dispose();
    _udiseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 720;
        final isMobileShell = constraints.maxWidth < 980;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isMobileShell),
                const Divider(height: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 18 : 32,
                      isMobile ? 26 : 34,
                      isMobile ? 18 : 32,
                      120,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 92 - 1 - 154)
                            .clamp(360.0, double.infinity)
                            .toDouble(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PageHeader(
                            isMobile: isMobile,
                            isAdding: _isAdding,
                            onToggle: _toggleForm,
                          ),
                          SizedBox(
                            height: _isAdding
                                ? 28
                                : isMobile
                                    ? 82
                                    : 78,
                          ),
                          if (_isAdding)
                            _VCMonitoringForm(
                              formKey: _formKey,
                              vcNameController: _vcNameController,
                              dateController: _dateController,
                              timeInController: _timeInController,
                              timeOutController: _timeOutController,
                              tradeController: _tradeController,
                              vtpController: _vtpController,
                              schoolController: _schoolController,
                              blockController: _blockController,
                              emailController: _emailController,
                              udiseController: _udiseController,
                              onPickDate: _pickDate,
                              onPickTimeIn: () => _pickTime(_timeInController),
                              onPickTimeOut: () =>
                                  _pickTime(_timeOutController),
                              onSubmit: _submitReport,
                              onReset: _clearForm,
                            )
                          else if (_reports.isEmpty)
                            const _EmptyReportState()
                          else
                            _ReportList(reports: _reports),
                        ],
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

  void _toggleForm() {
    setState(() {
      if (_isAdding) _clearForm();
      _isAdding = !_isAdding;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null) return;
    _dateController.text = _formatDate(picked);
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    controller.text = _formatTime(picked);
  }

  void _submitReport() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      _reports.insert(
        0,
        _VCReport(
          vcName: _vcNameController.text.trim(),
          date: _dateController.text.trim(),
          timeIn: _timeInController.text.trim(),
          timeOut: _timeOutController.text.trim(),
          trade: _tradeController.text.trim(),
          vtp: _vtpController.text.trim(),
          school: _schoolController.text.trim(),
          block: _blockController.text.trim(),
          email: _emailController.text.trim(),
          udise: _udiseController.text.trim(),
        ),
      );
      _isAdding = false;
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VC monitoring report submitted.')),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _vcNameController.clear();
    _dateController.clear();
    _timeInController.clear();
    _timeOutController.clear();
    _tradeController.clear();
    _vtpController.clear();
    _schoolController.clear();
    _blockController.clear();
    _emailController.clear();
    _udiseController.clear();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.isMobile,
    required this.isAdding,
    required this.onToggle,
  });

  final bool isMobile;
  final bool isAdding;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VC Monitoring Report',
          style: TextStyle(
            color: const Color(0xFF020817),
            fontSize: isMobile ? 25 : 29,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track VC school visit monitoring',
          style: TextStyle(
            color: const Color(0xFF657386),
            fontSize: isMobile ? 15 : 17,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: _AddReportButton(
              isAdding: isAdding,
              onTap: onToggle,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 20),
        _AddReportButton(isAdding: isAdding, onTap: onToggle),
      ],
    );
  }
}

class _AddReportButton extends StatelessWidget {
  const _AddReportButton({
    required this.isAdding,
    required this.onTap,
  });

  final bool isAdding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF2552C2), Color(0xFF3476F4)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2B2563EB),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 9),
              Text(
                isAdding ? 'Cancel' : 'Add Report',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VCMonitoringForm extends StatelessWidget {
  const _VCMonitoringForm({
    required this.formKey,
    required this.vcNameController,
    required this.dateController,
    required this.timeInController,
    required this.timeOutController,
    required this.tradeController,
    required this.vtpController,
    required this.schoolController,
    required this.blockController,
    required this.emailController,
    required this.udiseController,
    required this.onPickDate,
    required this.onPickTimeIn,
    required this.onPickTimeOut,
    required this.onSubmit,
    required this.onReset,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController vcNameController;
  final TextEditingController dateController;
  final TextEditingController timeInController;
  final TextEditingController timeOutController;
  final TextEditingController tradeController;
  final TextEditingController vtpController;
  final TextEditingController schoolController;
  final TextEditingController blockController;
  final TextEditingController emailController;
  final TextEditingController udiseController;
  final VoidCallback onPickDate;
  final VoidCallback onPickTimeIn;
  final VoidCallback onPickTimeOut;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 720;
        const fieldGap = 16.0;
        final horizontalPadding = isMobile ? 18.0 : 24.0;
        final availableFieldWidth = (constraints.maxWidth -
                (horizontalPadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final columnCount = isMobile ? 1 : 2;
        final fieldWidth =
            (availableFieldWidth - (fieldGap * (columnCount - 1))) /
                columnCount;
        final fields = [
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Name of VC *',
            child: _ReportTextField(
              controller: vcNameController,
              validator: (value) => _required(value, 'Name of VC'),
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Date *',
            child: _ReportTextField(
              controller: dateController,
              readOnly: true,
              hintText: 'dd-mm-yyyy',
              suffixIcon: Icons.calendar_today_outlined,
              onTap: onPickDate,
              validator: _date,
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Time In *',
            child: _ReportTextField(
              controller: timeInController,
              readOnly: true,
              hintText: '--:--',
              suffixIcon: Icons.access_time,
              onTap: onPickTimeIn,
              validator: _time,
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Time Out *',
            child: _ReportTextField(
              controller: timeOutController,
              readOnly: true,
              hintText: '--:--',
              suffixIcon: Icons.access_time,
              onTap: onPickTimeOut,
              validator: _time,
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Name of the Trade *',
            child: _ReportTextField(
              controller: tradeController,
              validator: (value) => _required(value, 'Name of the trade'),
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Name of VTP *',
            child: _ReportTextField(
              controller: vtpController,
              validator: (value) => _required(value, 'Name of VTP'),
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'School Name *',
            child: _ReportTextField(
              controller: schoolController,
              validator: (value) => _required(value, 'School name'),
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Block *',
            child: _ReportTextField(
              controller: blockController,
              validator: (value) => _required(value, 'Block'),
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'Email ID *',
            child: _ReportTextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: _email,
            ),
          ),
          _FormFieldShell(
            width: fieldWidth.toDouble(),
            label: 'UDISE Code *',
            child: _ReportTextField(
              controller: udiseController,
              keyboardType: TextInputType.number,
              validator: _udise,
            ),
          ),
        ];

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isMobile ? 22 : 26,
            horizontalPadding,
            isMobile ? 22 : 26,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFCCD7EE), width: 1.1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x110F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VC Monitoring Details',
                  style: TextStyle(
                    color: Color(0xFF020817),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _ResponsiveFieldGrid(
                  fields: fields,
                  isMobile: isMobile,
                  gap: fieldGap,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SecondaryButton(label: 'Reset', onTap: onReset),
                    _SubmitButton(onTap: onSubmit),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? _date(String? value) {
    final required = _required(value, 'Date');
    if (required != null) return required;
    final pattern = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (!pattern.hasMatch(value!.trim())) return 'Use dd-mm-yyyy format';
    return null;
  }

  static String? _time(String? value) {
    final required = _required(value, 'Time');
    if (required != null) return required;
    final pattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!pattern.hasMatch(value!.trim())) return 'Use hh:mm format';
    return null;
  }

  static String? _email(String? value) {
    final required = _required(value, 'Email ID');
    if (required != null) return required;
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value!.trim())) return 'Enter a valid email ID';
    return null;
  }

  static String? _udise(String? value) {
    final required = _required(value, 'UDISE code');
    if (required != null) return required;
    if (!RegExp(r'^\d{11}$').hasMatch(value!.trim())) {
      return 'UDISE code must be 11 digits';
    }
    return null;
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({
    required this.fields,
    required this.isMobile,
    required this.gap,
  });

  final List<Widget> fields;
  final bool isMobile;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            fields[index],
            if (index != fields.length - 1) SizedBox(height: gap),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < fields.length; index += 2) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: fields[index]),
              SizedBox(width: gap),
              Expanded(child: fields[index + 1]),
            ],
          ),
          if (index + 2 < fields.length) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class _FormFieldShell extends StatelessWidget {
  const _FormFieldShell({
    required this.width,
    required this.label,
    required this.child,
  });

  final double width;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF020817),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          child,
        ],
      ),
    );
  }
}

class _ReportTextField extends StatelessWidget {
  const _ReportTextField({
    required this.controller,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.hintText,
    this.suffixIcon,
    this.onTap,
  });

  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final String? hintText;
  final IconData? suffixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        color: Color(0xFF020817),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF020817),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: const Color(0xFF020817), size: 18),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: _fieldBorder(const Color(0xFFCCD7EE)),
        focusedBorder: _fieldBorder(const Color(0xFF3476F4), width: 1.4),
        errorBorder: _fieldBorder(const Color(0xFFE60012), width: 1.2),
        focusedErrorBorder: _fieldBorder(const Color(0xFFE60012), width: 1.4),
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFF2F65D9),
        foregroundColor: Colors.white,
        fixedSize: const Size(154, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text(
        'Submit Report',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF020817),
        fixedSize: const Size(104, 46),
        side: const BorderSide(color: Color(0xFFCCD7EE)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    );
  }
}

class _EmptyReportState extends StatelessWidget {
  const _EmptyReportState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_outlined,
            color: Color(0xFF6B7280),
            size: 78,
          ),
          SizedBox(height: 17),
          Text(
            'No VC monitoring reports yet. Click "Add Report" to start.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF657386),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({required this.reports});

  final List<_VCReport> reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: reports
          .map(
            (report) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDE4F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F65D9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.school,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF020817),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.vcName} - ${report.date} - ${report.timeIn}-${report.timeOut}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF657386),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _VCReport {
  const _VCReport({
    required this.vcName,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.trade,
    required this.vtp,
    required this.school,
    required this.block,
    required this.email,
    required this.udise,
  });

  final String vcName;
  final String date;
  final String timeIn;
  final String timeOut;
  final String trade;
  final String vtp;
  final String school;
  final String block;
  final String email;
  final String udise;
}
