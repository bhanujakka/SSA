import 'package:flutter/material.dart';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class ScheduleLecturePage extends StatelessWidget {
  const ScheduleLecturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(activeItem: 'Schedule Lecture'),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const SizedBox(
                    width: 280,
                    child: DashboardSidebar(activeItem: 'Schedule Lecture'),
                  ),
                const Expanded(child: _ScheduleLectureBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleLectureBody extends StatefulWidget {
  const _ScheduleLectureBody();

  @override
  State<_ScheduleLectureBody> createState() => _ScheduleLectureBodyState();
}

class _ScheduleLectureBodyState extends State<_ScheduleLectureBody> {
  final _reportFormKey = GlobalKey<FormState>();
  final _voucherFormKey = GlobalKey<FormState>();
  bool _showAddReportForm = false;
  bool _showPaymentVoucher = false;
  String? _selectedClass = 'Class 9';
  String? _selectedScheme = 'SS';
  String? _selectedVoucherClass = 'Class 9';
  final _schoolName = TextEditingController();
  final _tradeName = TextEditingController();
  final _jobRole = TextEditingController();
  final _vtName = TextEditingController();
  final _vtMobile = TextEditingController();
  final _glDate = TextEditingController();
  final _glLecturerName = TextEditingController();
  final _glTime = TextEditingController();
  final _glExperienceYears = TextEditingController();
  final _glWorkingAddress = TextEditingController();
  final _glDistanceKm = TextEditingController();
  final _unitNumber = TextEditingController();
  final _chapterDescription = TextEditingController();
  final _glConductedLastMonth = TextEditingController();
  final _studentsEnrolled = TextEditingController();
  final _studentsPresentInGl = TextEditingController();
  final _glFeedback = TextEditingController();
  final _voucherNo = TextEditingController();
  final _voucherDate = TextEditingController();
  final _voucherMonth = TextEditingController();
  final _voucherGuestFaculty = TextEditingController();
  final _voucherContactNumber = TextEditingController();
  final _voucherAmountFigures = TextEditingController();
  final _voucherAmountWords = TextEditingController();
  final _voucherSchoolName = TextEditingController();
  final _voucherStudentCount = TextEditingController();
  final _voucherVtName = TextEditingController();
  final _voucherVtMobile = TextEditingController();
  final _voucherGuestFacultyName = TextEditingController();
  final _voucherGuestFacultyMobile = TextEditingController();
  final _voucherPrincipalName = TextEditingController();
  final _voucherPrincipalMobile = TextEditingController();

  void _toggleReportForm() {
    setState(() {
      _showAddReportForm = !_showAddReportForm;
      if (!_showAddReportForm) _showPaymentVoucher = false;
    });
  }

  void _continueToPaymentVoucher() {
    final formState = _reportFormKey.currentState;
    if (formState == null) return;

    if (formState.validate()) {
      FocusScope.of(context).unfocus();
      _voucherSchoolName.text = _schoolName.text;
      _voucherVtName.text = _vtName.text;
      _voucherVtMobile.text = _vtMobile.text;
      _voucherGuestFaculty.text = _glLecturerName.text;
      _voucherGuestFacultyName.text = _glLecturerName.text;
      _voucherStudentCount.text = _studentsPresentInGl.text;
      _selectedVoucherClass = _selectedClass;
      setState(() => _showPaymentVoucher = true);
    }
  }

  void _submitPaymentVoucher() {
    final formState = _voucherFormKey.currentState;
    if (formState == null) return;

    if (formState.validate()) {
      FocusScope.of(context).unfocus();
      _showTopRightPopup('Complete report submitted');
    }
  }

  void _showTopRightPopup(String message) {
    final overlay = Overlay.of(context);
    final isMobile = MediaQuery.of(context).size.width < 700;
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: isMobile ? 12 : 24,
          left: isMobile ? 12 : null,
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: isMobile ? Alignment.topCenter : Alignment.topRight,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF15803D),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  DateTime _initialDateFor(TextEditingController controller) {
    final match = RegExp(
      r'^(\d{2})-(\d{2})-(\d{4})$',
    ).firstMatch(controller.text.trim());
    if (match == null) return DateTime.now();

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return DateTime.now();

    final parsed = DateTime(year, month, day);
    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return DateTime.now();
    }
    return parsed;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialDateFor(controller),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2F5FD2),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    controller.text = _formatDate(picked);
  }

  @override
  void dispose() {
    _schoolName.dispose();
    _tradeName.dispose();
    _jobRole.dispose();
    _vtName.dispose();
    _vtMobile.dispose();
    _glDate.dispose();
    _glLecturerName.dispose();
    _glTime.dispose();
    _glExperienceYears.dispose();
    _glWorkingAddress.dispose();
    _glDistanceKm.dispose();
    _unitNumber.dispose();
    _chapterDescription.dispose();
    _glConductedLastMonth.dispose();
    _studentsEnrolled.dispose();
    _studentsPresentInGl.dispose();
    _glFeedback.dispose();
    _voucherNo.dispose();
    _voucherDate.dispose();
    _voucherMonth.dispose();
    _voucherGuestFaculty.dispose();
    _voucherContactNumber.dispose();
    _voucherAmountFigures.dispose();
    _voucherAmountWords.dispose();
    _voucherSchoolName.dispose();
    _voucherStudentCount.dispose();
    _voucherVtName.dispose();
    _voucherVtMobile.dispose();
    _voucherGuestFacultyName.dispose();
    _voucherGuestFacultyMobile.dispose();
    _voucherPrincipalName.dispose();
    _voucherPrincipalMobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 980;
        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: isMobile),
                const Divider(height: 1, color: DashboardColors.border),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 12 : 24,
                      16,
                      isMobile ? 12 : 24,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LectureHeader(),
                              const SizedBox(height: 14),
                              _AddReportButton(
                                showCancel: _showAddReportForm,
                                onTap: _toggleReportForm,
                              ),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Expanded(child: _LectureHeader()),
                              const SizedBox(width: 16),
                              _AddReportButton(
                                showCancel: _showAddReportForm,
                                onTap: _toggleReportForm,
                              ),
                            ],
                          ),
                        const SizedBox(height: 18),
                        if (_showPaymentVoucher)
                          _PaymentVoucherForm(
                            formKey: _voucherFormKey,
                            voucherNo: _voucherNo,
                            date: _voucherDate,
                            onDateTap: () => _pickDate(_voucherDate),
                            month: _voucherMonth,
                            guestFaculty: _voucherGuestFaculty,
                            contactNumber: _voucherContactNumber,
                            amountFigures: _voucherAmountFigures,
                            amountWords: _voucherAmountWords,
                            schoolName: _voucherSchoolName,
                            selectedClass: _selectedVoucherClass,
                            onClassChanged: (value) =>
                                setState(() => _selectedVoucherClass = value),
                            studentCount: _voucherStudentCount,
                            vtName: _voucherVtName,
                            vtMobile: _voucherVtMobile,
                            guestFacultyName: _voucherGuestFacultyName,
                            guestFacultyMobile: _voucherGuestFacultyMobile,
                            principalName: _voucherPrincipalName,
                            principalMobile: _voucherPrincipalMobile,
                            onSubmit: _submitPaymentVoucher,
                          )
                        else if (_showAddReportForm)
                          _GuestLectureReportForm(
                            formKey: _reportFormKey,
                            schoolName: _schoolName,
                            tradeName: _tradeName,
                            jobRole: _jobRole,
                            vtName: _vtName,
                            vtMobile: _vtMobile,
                            glDate: _glDate,
                            onGlDateTap: () => _pickDate(_glDate),
                            glLecturerName: _glLecturerName,
                            glTime: _glTime,
                            glExperienceYears: _glExperienceYears,
                            glWorkingAddress: _glWorkingAddress,
                            glDistanceKm: _glDistanceKm,
                            unitNumber: _unitNumber,
                            chapterDescription: _chapterDescription,
                            glConductedLastMonth: _glConductedLastMonth,
                            studentsEnrolled: _studentsEnrolled,
                            studentsPresentInGl: _studentsPresentInGl,
                            glFeedback: _glFeedback,
                            selectedClass: _selectedClass,
                            selectedScheme: _selectedScheme,
                            onClassChanged: (value) =>
                                setState(() => _selectedClass = value),
                            onSchemeChanged: (value) =>
                                setState(() => _selectedScheme = value),
                            onSubmit: _continueToPaymentVoucher,
                          )
                        else
                          _EmptyLectureState(
                            onTap: () =>
                                setState(() => _showAddReportForm = true),
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
              child: DashboardQuickActionsFab(),
            ),
          ],
        );
      },
    );
  }
}

class _LectureHeader extends StatelessWidget {
  const _LectureHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guest Lecture Management',
          style: TextStyle(
            color: Color(0xFF0E1730),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Schedule and manage guest lecture sessions',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
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
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF274AB8), Color(0xFF3B82F6)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2E4A81A6),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 6),
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
      ),
    );
  }
}

class _GuestLectureReportForm extends StatelessWidget {
  const _GuestLectureReportForm({
    required this.formKey,
    required this.schoolName,
    required this.tradeName,
    required this.jobRole,
    required this.vtName,
    required this.vtMobile,
    required this.glDate,
    required this.glLecturerName,
    required this.glTime,
    required this.glExperienceYears,
    required this.glWorkingAddress,
    required this.glDistanceKm,
    required this.unitNumber,
    required this.chapterDescription,
    required this.glConductedLastMonth,
    required this.studentsEnrolled,
    required this.studentsPresentInGl,
    required this.glFeedback,
    required this.selectedClass,
    required this.selectedScheme,
    required this.onGlDateTap,
    required this.onClassChanged,
    required this.onSchemeChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController schoolName;
  final TextEditingController tradeName;
  final TextEditingController jobRole;
  final TextEditingController vtName;
  final TextEditingController vtMobile;
  final TextEditingController glDate;
  final TextEditingController glLecturerName;
  final TextEditingController glTime;
  final TextEditingController glExperienceYears;
  final TextEditingController glWorkingAddress;
  final TextEditingController glDistanceKm;
  final TextEditingController unitNumber;
  final TextEditingController chapterDescription;
  final TextEditingController glConductedLastMonth;
  final TextEditingController studentsEnrolled;
  final TextEditingController studentsPresentInGl;
  final TextEditingController glFeedback;
  final String? selectedClass;
  final String? selectedScheme;
  final VoidCallback onGlDateTap;
  final ValueChanged<String?> onClassChanged;
  final ValueChanged<String?> onSchemeChanged;
  final VoidCallback onSubmit;

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _mobileNumber(String? value) {
    final requiredError = _requiredField(value, 'VT mobile number');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!.trim())) {
      return 'Enter a valid 10 digit mobile number';
    }
    return null;
  }

  String? _date(String? value) {
    final requiredError = _requiredField(value, 'Date of conducting GL');
    if (requiredError != null) return requiredError;
    final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value!.trim());
    if (match == null) return 'Use dd-mm-yyyy format';

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final parsed = DateTime(year, month, day);
    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return 'Enter a valid date';
    }
    return null;
  }

  String? _time(String? value) {
    final requiredError = _requiredField(value, 'Time of GL');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value!.trim())) {
      return 'Use hh:mm format';
    }
    return null;
  }

  String? _positiveNumber(String? value, String label) {
    final requiredError = _requiredField(value, label);
    if (requiredError != null) return requiredError;
    final number = num.tryParse(value!.trim());
    if (number == null || number <= 0) return 'Enter a valid number';
    return null;
  }

  String? _wholeNumber(String? value, String label, {bool allowZero = true}) {
    final requiredError = _requiredField(value, label);
    if (requiredError != null) return requiredError;
    final number = int.tryParse(value!.trim());
    if (number == null || number < 0 || (!allowZero && number == 0)) {
      return 'Enter a valid whole number';
    }
    return null;
  }

  String? _studentsPresent(String? value) {
    final error = _wholeNumber(
      value,
      'Students present in GL',
      allowZero: false,
    );
    if (error != null) return error;

    final enrolled = int.tryParse(studentsEnrolled.text.trim());
    final present = int.tryParse(value!.trim());
    if (enrolled != null && present != null && present > enrolled) {
      return 'Present students cannot exceed enrolled students';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 980;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 22,
        isMobile ? 16 : 20,
        isMobile ? 14 : 22,
        20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC7D1E8), width: 1.5),
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guest Lecture Report',
              style: TextStyle(
                color: Color(0xFF121A2F),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Name of School *',
                controller: schoolName,
                validator: (value) => _requiredField(value, 'Name of school'),
              ),
              right: _SelectField(
                label: 'Class *',
                value: selectedClass,
                options: const ['Class 9', 'Class 10', 'Class 11', 'Class 12'],
                onChanged: onClassChanged,
                validator: (value) => _requiredField(value, 'Class'),
              ),
            ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _SelectField(
              label: 'Scheme *',
              value: selectedScheme,
              options: const ['SS', 'PM'],
              onChanged: onSchemeChanged,
              validator: (value) => _requiredField(value, 'Scheme'),
            ),
            right: _InputField(
              label: 'Name of the Trade *',
              controller: tradeName,
              validator: (value) => _requiredField(value, 'Name of the trade'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Name of Job Role *',
              controller: jobRole,
              validator: (value) => _requiredField(value, 'Name of job role'),
            ),
            right: _InputField(
              label: 'VT Name *',
              controller: vtName,
              validator: (value) => _requiredField(value, 'VT name'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'VT Mobile Number *',
              controller: vtMobile,
              keyboardType: TextInputType.phone,
              validator: _mobileNumber,
            ),
            right: const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Guest Lecturer Details',
            style: TextStyle(
              color: Color(0xFF121A2F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Date of Conducting GL *',
              controller: glDate,
              hint: 'dd-mm-yyyy',
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: onGlDateTap,
              suffixIcon: Icons.calendar_today_outlined,
              validator: _date,
            ),
            right: _InputField(
              label: 'Name of Guest Lecturer *',
              controller: glLecturerName,
              validator: (value) =>
                  _requiredField(value, 'Name of guest lecturer'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Time of GL *',
              controller: glTime,
              hint: 'hh:mm',
              keyboardType: TextInputType.datetime,
              validator: _time,
            ),
            right: _InputField(
              label: 'Number of Experience (Years) *',
              controller: glExperienceYears,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  _positiveNumber(value, 'Number of experience'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Full Address of Working Place *',
              controller: glWorkingAddress,
              maxLines: 3,
              validator: (value) =>
                  _requiredField(value, 'Full address of working place'),
            ),
            right: _InputField(
              label: 'Distance Between School & Guest Lecturer (KM) *',
              controller: glDistanceKm,
              keyboardType: TextInputType.number,
              validator: (value) => _positiveNumber(value, 'Distance'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Curriculum Details',
            style: TextStyle(
              color: Color(0xFF121A2F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Unit Number *',
              controller: unitNumber,
              keyboardType: TextInputType.number,
              validator: (value) => _wholeNumber(
                value,
                'Unit number',
                allowZero: false,
              ),
            ),
            right: _InputField(
              label: 'Chapter Description *',
              controller: chapterDescription,
              maxLines: 3,
              validator: (value) =>
                  _requiredField(value, 'Chapter description'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: "No. of GL's Conducted Last Month *",
              controller: glConductedLastMonth,
              keyboardType: TextInputType.number,
              validator: (value) =>
                  _wholeNumber(value, "GL's conducted last month"),
            ),
            right: const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Student Attendance',
            style: TextStyle(
              color: Color(0xFF121A2F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'No. of Students Enrolled in Class *',
              controller: studentsEnrolled,
              keyboardType: TextInputType.number,
              validator: (value) => _wholeNumber(
                value,
                'Students enrolled in class',
                allowZero: false,
              ),
            ),
            right: _InputField(
              label: 'No. of Students Present in GL *',
              controller: studentsPresentInGl,
              keyboardType: TextInputType.number,
              validator: _studentsPresent,
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Feedback of GL',
              controller: glFeedback,
              maxLines: 4,
            ),
            right: const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Proofs - GL Photos with GPS',
            style: TextStyle(
              color: Color(0xFF121A2F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _GlProofsUploadCard(isMobile: isMobile),
          const SizedBox(height: 20),
          Align(
            alignment: isMobile ? Alignment.center : Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : null,
              child: ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Continue to Payment Voucher'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2F5FD2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 24,
                    vertical: isMobile ? 13 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _PaymentVoucherForm extends StatelessWidget {
  const _PaymentVoucherForm({
    required this.formKey,
    required this.voucherNo,
    required this.date,
    required this.onDateTap,
    required this.month,
    required this.guestFaculty,
    required this.contactNumber,
    required this.amountFigures,
    required this.amountWords,
    required this.schoolName,
    required this.selectedClass,
    required this.onClassChanged,
    required this.studentCount,
    required this.vtName,
    required this.vtMobile,
    required this.guestFacultyName,
    required this.guestFacultyMobile,
    required this.principalName,
    required this.principalMobile,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController voucherNo;
  final TextEditingController date;
  final VoidCallback onDateTap;
  final TextEditingController month;
  final TextEditingController guestFaculty;
  final TextEditingController contactNumber;
  final TextEditingController amountFigures;
  final TextEditingController amountWords;
  final TextEditingController schoolName;
  final String? selectedClass;
  final ValueChanged<String?> onClassChanged;
  final TextEditingController studentCount;
  final TextEditingController vtName;
  final TextEditingController vtMobile;
  final TextEditingController guestFacultyName;
  final TextEditingController guestFacultyMobile;
  final TextEditingController principalName;
  final TextEditingController principalMobile;
  final VoidCallback onSubmit;

  String? _requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _date(String? value) {
    final requiredError = _requiredField(value, 'Date');
    if (requiredError != null) return requiredError;
    final match = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$').firstMatch(value!.trim());
    if (match == null) return 'Use dd-mm-yyyy format';

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final parsed = DateTime(year, month, day);
    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return 'Enter a valid date';
    }
    return null;
  }

  String? _mobileNumber(String? value) {
    final requiredError = _requiredField(value, 'Mobile number');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!.trim())) {
      return 'Enter a valid 10 digit mobile number';
    }
    return null;
  }

  String? _positiveAmount(String? value) {
    final requiredError = _requiredField(value, 'Amount paid');
    if (requiredError != null) return requiredError;
    final amount = num.tryParse(value!.trim());
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }

  String? _studentCount(String? value) {
    final requiredError = _requiredField(value, 'No. of students');
    if (requiredError != null) return requiredError;
    final count = int.tryParse(value!.trim());
    if (count == null || count <= 0) return 'Enter a valid student count';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 980;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 24,
        isMobile ? 16 : 24,
        isMobile ? 14 : 24,
        24,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBDECCF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Voucher',
              style: TextStyle(
                color: Color(0xFF030B1C),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Voucher No *',
                controller: voucherNo,
                validator: (value) => _requiredField(value, 'Voucher no'),
              ),
              right: _InputField(
                label: 'Date *',
                controller: date,
                hint: 'dd-mm-yyyy',
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: onDateTap,
                suffixIcon: Icons.calendar_today_outlined,
                validator: _date,
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Month *',
                controller: month,
                hint: 'e.g., May, 2026',
                validator: (value) => _requiredField(value, 'Month'),
              ),
              right: _InputField(
                label: 'Name of Guest Faculty *',
                controller: guestFaculty,
                validator: (value) =>
                    _requiredField(value, 'Name of guest faculty'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Contact Number *',
                controller: contactNumber,
                keyboardType: TextInputType.phone,
                validator: _mobileNumber,
              ),
              right: _InputField(
                label: 'Amount Paid (Figures) *',
                controller: amountFigures,
                keyboardType: TextInputType.number,
                validator: _positiveAmount,
              ),
            ),
            const SizedBox(height: 12),
            _InputField(
              label: 'Amount Paid (Words) *',
              controller: amountWords,
              hint: 'e.g., Five Thousand Rupees Only',
              validator: (value) => _requiredField(value, 'Amount paid words'),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Name of School *',
                controller: schoolName,
                validator: (value) => _requiredField(value, 'Name of school'),
              ),
              right: _SelectField(
                label: 'Class *',
                value: selectedClass,
                options: const ['Class 9', 'Class 10', 'Class 11', 'Class 12'],
                onChanged: onClassChanged,
                validator: (value) => _requiredField(value, 'Class'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'No. of Students *',
                controller: studentCount,
                keyboardType: TextInputType.number,
                validator: _studentCount,
              ),
              right: const SizedBox.shrink(),
            ),
            const _VoucherDivider(),
            const _VoucherSectionTitle('Prepared By (VT)'),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'VT Name *',
                controller: vtName,
                validator: (value) => _requiredField(value, 'VT name'),
              ),
              right: _InputField(
                label: 'VT Mobile *',
                controller: vtMobile,
                keyboardType: TextInputType.phone,
                validator: _mobileNumber,
              ),
            ),
            const _VoucherDivider(),
            const _VoucherSectionTitle('Received By (Guest Faculty)'),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Guest Faculty Name *',
                controller: guestFacultyName,
                validator: (value) =>
                    _requiredField(value, 'Guest faculty name'),
              ),
              right: _InputField(
                label: 'Guest Faculty Mobile *',
                controller: guestFacultyMobile,
                keyboardType: TextInputType.phone,
                validator: _mobileNumber,
              ),
            ),
            const _VoucherDivider(),
            const _VoucherSectionTitle('Verified By (Principal)'),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Principal Name *',
                controller: principalName,
                validator: (value) => _requiredField(value, 'Principal name'),
              ),
              right: _InputField(
                label: 'Principal Mobile *',
                controller: principalMobile,
                keyboardType: TextInputType.phone,
                validator: _mobileNumber,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF2F5FD2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 13 : 14,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Submit Complete Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherSectionTitle extends StatelessWidget {
  const _VoucherSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF030B1C),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _VoucherDivider extends StatelessWidget {
  const _VoucherDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Divider(height: 1, color: Color(0xFFE1E5EE)),
    );
  }
}

class _GlProofsUploadCard extends StatefulWidget {
  const _GlProofsUploadCard({required this.isMobile});

  final bool isMobile;

  @override
  State<_GlProofsUploadCard> createState() => _GlProofsUploadCardState();
}

class _GlProofsUploadCardState extends State<_GlProofsUploadCard> {
  bool _isPicking = false;
  String? _validationMessage;
  List<_GlPhotoProof> _selectedPhotos = const [];

  Future<void> _pickPhotos() async {
    if (_isPicking) return;
    setState(() {
      _isPicking = true;
      _validationMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (!mounted) return;
      if (result == null || result.files.isEmpty) {
        setState(() => _isPicking = false);
        return;
      }

      final selected = <_GlPhotoProof>[];
      for (final file in result.files) {
        final bytes = file.bytes;
        final hasGps = bytes != null && await _containsGpsExif(bytes);
        selected.add(
          _GlPhotoProof(name: file.name, sizeBytes: file.size, hasGps: hasGps),
        );
      }

      final missingGpsCount = selected.where((e) => !e.hasGps).length;

      setState(() {
        _selectedPhotos = selected;
        _isPicking = false;
        _validationMessage = missingGpsCount == 0
            ? 'All selected photos include GPS metadata.'
            : '$missingGpsCount photo(s) are missing GPS metadata. Please re-capture with location enabled.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPicking = false;
        _validationMessage =
            'Could not read selected photos. Please try again.';
      });
    }
  }

  Future<bool> _containsGpsExif(List<int> bytes) async {
    try {
      final exif = await readExifFromBytes(bytes);
      final hasLatitude = exif.entries.any(
        (entry) =>
            entry.key.contains('GPS GPSLatitude') &&
            entry.value.printable.trim().isNotEmpty &&
            entry.value.printable != '[0, 0, 0]' &&
            entry.value.printable != '[0/0, 0/0, 0/0]',
      );
      final hasLongitude = exif.entries.any(
        (entry) =>
            entry.key.contains('GPS GPSLongitude') &&
            entry.value.printable.trim().isNotEmpty &&
            entry.value.printable != '[0, 0, 0]' &&
            entry.value.printable != '[0/0, 0/0, 0/0]',
      );
      return hasLatitude && hasLongitude;
    } catch (_) {
      return false;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 180 : 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6B8CF4),
          width: 1.6,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 26,
            vertical: isMobile ? 16 : 22,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.file_upload_outlined,
                color: const Color(0xFF2A54C4),
                size: isMobile ? 42 : 50,
              ),
              SizedBox(height: isMobile ? 8 : 10),
              Text(
                'Upload GL Photos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF121A2F),
                  fontSize: isMobile ? 17 : 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                'Photos with GPS location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isMobile ? 10 : 14),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _isPicking ? null : _pickPhotos,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 18 : 22,
                    ),
                    backgroundColor: const Color(0xFF2F5FD2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(_isPicking ? 'Checking...' : 'Choose Photos'),
                ),
              ),
              if (_selectedPhotos.isNotEmpty) ...[
                SizedBox(height: isMobile ? 12 : 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selected (${_selectedPhotos.length})',
                    style: TextStyle(
                      color: const Color(0xFF121A2F),
                      fontSize: isMobile ? 13 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedPhotos.map((photo) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? 280 : 330,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFD0DAF6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            photo.hasGps
                                ? Icons.check_circle
                                : Icons.error_rounded,
                            size: 18,
                            color: photo.hasGps
                                ? const Color(0xFF15803D)
                                : const Color(0xFFB42318),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${photo.name} (${_formatFileSize(photo.sizeBytes)})',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF121A2F),
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (_validationMessage != null) ...[
                SizedBox(height: isMobile ? 12 : 14),
                Text(
                  _validationMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedPhotos.any((e) => !e.hasGps)
                        ? const Color(0xFFB42318)
                        : const Color(0xFF15803D),
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlPhotoProof {
  const _GlPhotoProof({
    required this.name,
    required this.sizeBytes,
    required this.hasGps,
  });

  final String name;
  final int sizeBytes;
  final bool hasGps;
}

class _TwoColumnRow extends StatelessWidget {
  const _TwoColumnRow({
    required this.isMobile,
    required this.left,
    required this.right,
  });

  final bool isMobile;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(children: [left, const SizedBox(height: 10), right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF121A2F),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(
            color: Color(0xFF121A2F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon == null
                ? null
                : Icon(
                    suffixIcon,
                    color: const Color(0xFF121A2F),
                    size: 18,
                  ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xBCC7D1E8),
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF91A4D5),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF121A2F),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF121A2F),
            size: 24,
          ),
          style: const TextStyle(
            color: Color(0xFF121A2F),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: const Color(0xFFF5F7FA),
          items: options
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xBCC7D1E8),
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Color(0xFF91A4D5),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyLectureState extends StatelessWidget {
  const _EmptyLectureState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 980;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isMobile ? 340 : 420),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE1E7F3), width: 1.2),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.present_to_all_outlined,
                    color: Color(0xFF6B7280),
                    size: 58,
                  ),
                  SizedBox(height: 14),
                  Text(
                    "No guest lecture reports yet. Click 'Add Report' to start.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
