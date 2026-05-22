import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VCMonitoringPage extends StatefulWidget {
  const VCMonitoringPage({super.key});

  @override
  State<VCMonitoringPage> createState() => _VCMonitoringPageState();
}

class _VCMonitoringPageState extends State<VCMonitoringPage> {
  final _formKey = GlobalKey<FormState>();
  final _vcName = TextEditingController();
  final _date = TextEditingController();
  final _timeIn = TextEditingController();
  final _timeOut = TextEditingController();
  final _tradeName = TextEditingController();
  final _vtpName = TextEditingController();
  final _schoolName = TextEditingController();
  final _block = TextEditingController();
  final _email = TextEditingController();
  final _udiseCode = TextEditingController();
  final _principalName = TextEditingController();
  final _contactNo = TextEditingController();
  final _schoolAddress = TextEditingController();
  bool _showReportForm = false;

  @override
  void dispose() {
    _vcName.dispose();
    _date.dispose();
    _timeIn.dispose();
    _timeOut.dispose();
    _tradeName.dispose();
    _vtpName.dispose();
    _schoolName.dispose();
    _block.dispose();
    _email.dispose();
    _udiseCode.dispose();
    _principalName.dispose();
    _contactNo.dispose();
    _schoolAddress.dispose();
    super.dispose();
  }

  void _toggleReportForm() {
    setState(() => _showReportForm = !_showReportForm);
  }

  void _submitReport() {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) return;

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('VC monitoring report submitted')),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    _date.text = _formatDate(picked);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    controller.text = _formatTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileShell = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: _surfaceColor(context),
          drawer: isMobileShell
              ? const Drawer(
                  child: DashboardSidebar(activeItem: 'VC Monitoring', showCollapseButton: false),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: 'VC Monitoring'),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isMobile = width < 700;
        final horizontalPadding = isMobile ? 18.0 : 26.0;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: width < 980),
                Divider(height: 1, color: _borderColor(context)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isMobile ? 22 : 28,
                      horizontalPadding,
                      isMobile ? 132 : 40,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: height - (isMobile ? 270 : 164),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            isMobile: isMobile,
                            showCancel: _showReportForm,
                            onAddReport: _toggleReportForm,
                          ),
                          SizedBox(height: isMobile ? 18 : 22),
                          if (_showReportForm)
                            _VCMonitoringReportForm(
                              formKey: _formKey,
                              vcName: _vcName,
                              date: _date,
                              timeIn: _timeIn,
                              timeOut: _timeOut,
                              tradeName: _tradeName,
                              vtpName: _vtpName,
                              schoolName: _schoolName,
                              block: _block,
                              email: _email,
                              udiseCode: _udiseCode,
                              principalName: _principalName,
                              contactNo: _contactNo,
                              schoolAddress: _schoolAddress,
                              onDateTap: _pickDate,
                              onTimeInTap: () => _pickTime(_timeIn),
                              onTimeOutTap: () => _pickTime(_timeOut),
                              onSubmit: _submitReport,
                            )
                          else
                            Padding(
                              padding: EdgeInsets.only(top: isMobile ? 54 : 42),
                              child: Center(
                                child: _EmptyReportState(isMobile: isMobile),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isMobile ? 20 : 26,
              bottom: isMobile ? 24 : 20,
              child: const DashboardQuickActionsFab(size: 54),
            ),
          ],
        );
      },
    );
  }
}

class VCManagementPage extends StatelessWidget {
  const VCManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VCMonitoringPage();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.isMobile,
    required this.showCancel,
    required this.onAddReport,
  });

  final bool isMobile;
  final bool showCancel;
  final VoidCallback onAddReport;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'VC Monitoring Report',
          style: TextStyle(
            color: _titleColor(context),
            fontSize: 24,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track VC school visit monitoring',
          style: TextStyle(
            color: _mutedColor(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final button = _AddReportButton(showCancel: showCancel, onTap: onAddReport);

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 18),
          Align(alignment: Alignment.centerLeft, child: button),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        const SizedBox(width: 16),
        button,
      ],
    );
  }
}

class _AddReportButton extends StatelessWidget {
  const _AddReportButton({required this.showCancel, required this.onTap});

  final bool showCancel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: DashboardColors.red,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x332552C2),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                showCancel ? Icons.close_rounded : Icons.add_rounded,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                showCancel ? 'Cancel' : 'Add Report',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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

class _EmptyReportState extends StatelessWidget {
  const _EmptyReportState({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final mutedColor = _mutedColor(context);
    return Padding(
      padding: EdgeInsets.only(top: isMobile ? 8 : 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, color: mutedColor, size: 62),
          const SizedBox(height: 12),
          Text(
            'No VC monitoring reports yet. Click "Add Report" to start.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mutedColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _VCMonitoringReportForm extends StatelessWidget {
  const _VCMonitoringReportForm({
    required this.formKey,
    required this.vcName,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.tradeName,
    required this.vtpName,
    required this.schoolName,
    required this.block,
    required this.email,
    required this.udiseCode,
    required this.principalName,
    required this.contactNo,
    required this.schoolAddress,
    required this.onDateTap,
    required this.onTimeInTap,
    required this.onTimeOutTap,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController vcName;
  final TextEditingController date;
  final TextEditingController timeIn;
  final TextEditingController timeOut;
  final TextEditingController tradeName;
  final TextEditingController vtpName;
  final TextEditingController schoolName;
  final TextEditingController block;
  final TextEditingController email;
  final TextEditingController udiseCode;
  final TextEditingController principalName;
  final TextEditingController contactNo;
  final TextEditingController schoolAddress;
  final VoidCallback onDateTap;
  final VoidCallback onTimeInTap;
  final VoidCallback onTimeOutTap;
  final VoidCallback onSubmit;

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _email(String? value) {
    final requiredError = _required(value, 'Email ID');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _phone(String? value) {
    final requiredError = _required(value, 'Contact No');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!.trim())) {
      return 'Enter a valid 10 digit number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 760;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(isWide ? 22 : 16, 18, isWide ? 22 : 16, 18),
      decoration: BoxDecoration(
        color: _cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
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
            Text(
              'VC Monitoring Details',
              style: TextStyle(
                color: _titleColor(context),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _ResponsiveFieldGrid(
              isWide: isWide,
              children: [
                _ReportTextField(
                  label: 'Name of VC',
                  controller: vcName,
                  validator: (value) => _required(value, 'Name of VC'),
                ),
                _ReportTextField(
                  label: 'Date',
                  controller: date,
                  readOnly: true,
                  hintText: 'mm/dd/yyyy',
                  onTap: onDateTap,
                  validator: (value) => _required(value, 'Date'),
                ),
                _ReportTextField(
                  label: 'Time In',
                  controller: timeIn,
                  readOnly: true,
                  hintText: '--:-- --',
                  onTap: onTimeInTap,
                  validator: (value) => _required(value, 'Time In'),
                ),
                _ReportTextField(
                  label: 'Time Out',
                  controller: timeOut,
                  readOnly: true,
                  hintText: '--:-- --',
                  onTap: onTimeOutTap,
                  validator: (value) => _required(value, 'Time Out'),
                ),
                _ReportTextField(
                  label: 'Name of the Trade',
                  controller: tradeName,
                  validator: (value) => _required(value, 'Name of the Trade'),
                ),
                _ReportTextField(
                  label: 'Name of VTP',
                  controller: vtpName,
                  validator: (value) => _required(value, 'Name of VTP'),
                ),
                _ReportTextField(
                  label: 'School Name',
                  controller: schoolName,
                  validator: (value) => _required(value, 'School Name'),
                ),
                _ReportTextField(
                  label: 'Block',
                  controller: block,
                  validator: (value) => _required(value, 'Block'),
                ),
                _ReportTextField(
                  label: 'Email ID',
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _email,
                ),
                _ReportTextField(
                  label: 'UDISE Code',
                  controller: udiseCode,
                  validator: (value) => _required(value, 'UDISE Code'),
                ),
                _ReportTextField(
                  label: 'Principal Name',
                  controller: principalName,
                  validator: (value) => _required(value, 'Principal Name'),
                ),
                _ReportTextField(
                  label: 'Contact No',
                  controller: contactNo,
                  keyboardType: TextInputType.phone,
                  validator: _phone,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ReportTextField(
              label: 'Address of School',
              controller: schoolAddress,
              validator: (value) => _required(value, 'Address of School'),
            ),
            const SizedBox(height: 14),
            Text(
              'More details will be shared via WhatsApp',
              style: TextStyle(
                color: _mutedColor(context),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            _SubmitReportButton(onTap: onSubmit),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.isWide, required this.children});

  final bool isWide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            children[index],
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < children.length; index += 2) ...[
          if (index > 0) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[index]),
              const SizedBox(width: 12),
              Expanded(
                child: index + 1 < children.length
                    ? children[index + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ReportTextField extends StatelessWidget {
  const _ReportTextField({
    required this.label,
    required this.controller,
    this.hintText,
    this.readOnly = false,
    this.keyboardType,
    this.onTap,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = _titleColor(context);
    final mutedColor = _mutedColor(context);
    final fillColor = isDark ? const Color(0xFF111C2D) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label *',
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onTap: onTap,
          validator: validator,
          cursorColor: DashboardColors.blue,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(
              color: mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _fieldBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _fieldBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: DashboardColors.blue),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitReportButton extends StatelessWidget {
  const _SubmitReportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF2447BD), Color(0xFF3B82F6)],
            ),
          ),
          child: const Center(
            child: Text(
              'Submit Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _surfaceColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF0B1220)
    : const Color(0xFFF5F6F8);

Color _borderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF26354D)
    : DashboardColors.border;

Color _cardColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF111827)
    : Colors.white;

Color _titleColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFF8FAFC)
    : const Color(0xFF071B36);

Color _mutedColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFFAAB6C7)
    : const Color(0xFF5D6B82);

Color _fieldBorderColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF31425C)
    : const Color(0xFFC5D1EC);
