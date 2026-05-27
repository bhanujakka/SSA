import 'package:flutter/material.dart';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class IndustrialVisitPage extends StatelessWidget {
  const IndustrialVisitPage({super.key, this.activeItem = 'Industrial Visit'});

  final String activeItem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? Drawer(
                  child: DashboardSidebar(
                    activeItem: activeItem,
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  DashboardSidebarHost(activeItem: activeItem),
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
  final List<_IndustrialVisitReport> _reports = [];
  bool _showAddReportForm = false;
  bool _showPaymentVoucher = false;
  String? _selectedClass = 'Class 9';
  final _schoolName = TextEditingController();
  final _tradeName = TextEditingController();
  final _vtpName = TextEditingController();
  final _vtName = TextEditingController();
  final _ivDate = TextEditingController();
  final _studentsAttended = TextEditingController();
  final _distanceFromPlace = TextEditingController();
  final _organizationVisited = TextEditingController();
  final _interactedPerson = TextEditingController();
  final _topicCovered = TextEditingController();
  final _studentFeedback = TextEditingController();
  final _learningOutcomes = TextEditingController();
  final _ivName = TextEditingController();
  final _principalName = TextEditingController();
  final _paymentDate = TextEditingController();
  final _paymentVoucherNo = TextEditingController();
  final _paymentRupees = TextEditingController();
  final _paymentPayTo = TextEditingController();
  final _paymentRupeesWords = TextEditingController();
  final _paymentParticulars = TextEditingController();
  final _paymentSchoolName = TextEditingController();
  final _preparedSchoolName = TextEditingController();
  final _trainerName = TextEditingController();
  final _billNo = TextEditingController();
  final _billDate = TextEditingController();
  final _billType = TextEditingController();
  final _expensesDoneFor = TextEditingController();
  final _billAmount = TextEditingController();
  final _totalAmount = TextEditingController();
  final _paymentVtName = TextEditingController();
  final _ivPersonAccountNo = TextEditingController();
  final _ifscCode = TextEditingController();
  final _bankName = TextEditingController();
  final _branchName = TextEditingController();

  void _toggleReportForm() {
    setState(() {
      _showAddReportForm = !_showAddReportForm;
      if (!_showAddReportForm) _showPaymentVoucher = false;
    });
  }

  void _submitIndustrialVisit() {
    final formState = _reportFormKey.currentState;
    if (formState == null) return;

    if (formState.validate()) {
      FocusScope.of(context).unfocus();
      _paymentSchoolName.text = _schoolName.text;
      _preparedSchoolName.text = _schoolName.text;
      _trainerName.text = _vtName.text;
      _paymentVtName.text = _vtName.text;
      setState(() => _showPaymentVoucher = true);
    }
  }

  void _submitPaymentVoucher() {
    final formState = _voucherFormKey.currentState;
    if (formState == null) return;

    if (formState.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        _reports.insert(
          0,
          _IndustrialVisitReport(
            schoolName: _schoolName.text.trim(),
            tradeName: _tradeName.text.trim(),
            vtpName: _vtpName.text.trim(),
            vtName: _vtName.text.trim(),
            className: _selectedClass ?? '-',
            visitDate: _ivDate.text.trim(),
            studentsAttended: _studentsAttended.text.trim(),
            distanceFromPlace: _distanceFromPlace.text.trim(),
            organizationVisited: _organizationVisited.text.trim(),
            interactedPerson: _interactedPerson.text.trim(),
            topicCovered: _topicCovered.text.trim(),
            studentFeedback: _studentFeedback.text.trim(),
            learningOutcomes: _learningOutcomes.text.trim(),
            ivName: _ivName.text.trim(),
            principalName: _principalName.text.trim(),
            paymentDate: _paymentDate.text.trim(),
            paymentVoucherNo: _paymentVoucherNo.text.trim(),
            paymentRupees: _paymentRupees.text.trim(),
            paymentPayTo: _paymentPayTo.text.trim(),
            paymentRupeesWords: _paymentRupeesWords.text.trim(),
            paymentParticulars: _paymentParticulars.text.trim(),
            paymentSchoolName: _paymentSchoolName.text.trim(),
            preparedSchoolName: _preparedSchoolName.text.trim(),
            trainerName: _trainerName.text.trim(),
            billNo: _billNo.text.trim(),
            billDate: _billDate.text.trim(),
            billType: _billType.text.trim(),
            expensesDoneFor: _expensesDoneFor.text.trim(),
            billAmount: _billAmount.text.trim(),
            totalAmount: _totalAmount.text.trim(),
            paymentVtName: _paymentVtName.text.trim(),
            ivPersonAccountNo: _ivPersonAccountNo.text.trim(),
            ifscCode: _ifscCode.text.trim().toUpperCase(),
            bankName: _bankName.text.trim(),
            branchName: _branchName.text.trim(),
          ),
        );
        _showAddReportForm = false;
        _showPaymentVoucher = false;
      });
      _clearForms();
      _showTopRightPopup('Industrial visit and payment voucher submitted');
    }
  }

  void _clearForms() {
    for (final controller in [
      _schoolName,
      _tradeName,
      _vtpName,
      _vtName,
      _ivDate,
      _studentsAttended,
      _distanceFromPlace,
      _organizationVisited,
      _interactedPerson,
      _topicCovered,
      _studentFeedback,
      _learningOutcomes,
      _ivName,
      _principalName,
      _paymentDate,
      _paymentVoucherNo,
      _paymentRupees,
      _paymentPayTo,
      _paymentRupeesWords,
      _paymentParticulars,
      _paymentSchoolName,
      _preparedSchoolName,
      _trainerName,
      _billNo,
      _billDate,
      _billType,
      _expensesDoneFor,
      _billAmount,
      _totalAmount,
      _paymentVtName,
      _ivPersonAccountNo,
      _ifscCode,
      _bankName,
      _branchName,
    ]) {
      controller.clear();
    }

    _selectedClass = 'Class 9';
    _reportFormKey.currentState?.reset();
    _voucherFormKey.currentState?.reset();
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
    _vtpName.dispose();
    _vtName.dispose();
    _ivDate.dispose();
    _studentsAttended.dispose();
    _distanceFromPlace.dispose();
    _organizationVisited.dispose();
    _interactedPerson.dispose();
    _topicCovered.dispose();
    _studentFeedback.dispose();
    _learningOutcomes.dispose();
    _ivName.dispose();
    _principalName.dispose();
    _paymentDate.dispose();
    _paymentVoucherNo.dispose();
    _paymentRupees.dispose();
    _paymentPayTo.dispose();
    _paymentRupeesWords.dispose();
    _paymentParticulars.dispose();
    _paymentSchoolName.dispose();
    _preparedSchoolName.dispose();
    _trainerName.dispose();
    _billNo.dispose();
    _billDate.dispose();
    _billType.dispose();
    _expensesDoneFor.dispose();
    _billAmount.dispose();
    _totalAmount.dispose();
    _paymentVtName.dispose();
    _ivPersonAccountNo.dispose();
    _ifscCode.dispose();
    _bankName.dispose();
    _branchName.dispose();
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
                            paymentDate: _paymentDate,
                            onPaymentDateTap: () => _pickDate(_paymentDate),
                            voucherNo: _paymentVoucherNo,
                            rupees: _paymentRupees,
                            payTo: _paymentPayTo,
                            rupeesInWords: _paymentRupeesWords,
                            particulars: _paymentParticulars,
                            paymentSchoolName: _paymentSchoolName,
                            preparedSchoolName: _preparedSchoolName,
                            trainerName: _trainerName,
                            billNo: _billNo,
                            billDate: _billDate,
                            onBillDateTap: () => _pickDate(_billDate),
                            billType: _billType,
                            expensesDoneFor: _expensesDoneFor,
                            billAmount: _billAmount,
                            totalAmount: _totalAmount,
                            vtName: _paymentVtName,
                            accountNo: _ivPersonAccountNo,
                            ifscCode: _ifscCode,
                            bankName: _bankName,
                            branchName: _branchName,
                            onSubmit: _submitPaymentVoucher,
                          )
                        else if (_showAddReportForm)
                          _IndustrialVisitReportForm(
                            formKey: _reportFormKey,
                            schoolName: _schoolName,
                            tradeName: _tradeName,
                            vtpName: _vtpName,
                            vtName: _vtName,
                            ivDate: _ivDate,
                            onIvDateTap: () => _pickDate(_ivDate),
                            studentsAttended: _studentsAttended,
                            distanceFromPlace: _distanceFromPlace,
                            organizationVisited: _organizationVisited,
                            interactedPerson: _interactedPerson,
                            topicCovered: _topicCovered,
                            studentFeedback: _studentFeedback,
                            learningOutcomes: _learningOutcomes,
                            ivName: _ivName,
                            principalName: _principalName,
                            selectedClass: _selectedClass,
                            onClassChanged: (value) =>
                                setState(() => _selectedClass = value),
                            onSubmit: _submitIndustrialVisit,
                          )
                        else if (_reports.isNotEmpty)
                          _IndustrialVisitReportsList(reports: _reports)
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
          'Industrial Visit Management',
          style: TextStyle(
            color: Color(0xFF0E1730),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Add and manage industrial visit reports',
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
                  showCancel ? 'Cancel' : 'Add Industrial Visit',
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

class _IndustrialVisitReportForm extends StatelessWidget {
  const _IndustrialVisitReportForm({
    required this.formKey,
    required this.schoolName,
    required this.tradeName,
    required this.vtpName,
    required this.vtName,
    required this.ivDate,
    required this.studentsAttended,
    required this.distanceFromPlace,
    required this.organizationVisited,
    required this.interactedPerson,
    required this.topicCovered,
    required this.studentFeedback,
    required this.learningOutcomes,
    required this.ivName,
    required this.principalName,
    required this.selectedClass,
    required this.onIvDateTap,
    required this.onClassChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController schoolName;
  final TextEditingController tradeName;
  final TextEditingController vtpName;
  final TextEditingController vtName;
  final TextEditingController ivDate;
  final TextEditingController studentsAttended;
  final TextEditingController distanceFromPlace;
  final TextEditingController organizationVisited;
  final TextEditingController interactedPerson;
  final TextEditingController topicCovered;
  final TextEditingController studentFeedback;
  final TextEditingController learningOutcomes;
  final TextEditingController ivName;
  final TextEditingController principalName;
  final String? selectedClass;
  final VoidCallback onIvDateTap;
  final ValueChanged<String?> onClassChanged;
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
              'Add Industrial Visit',
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
                label: 'Name of the School *',
                controller: schoolName,
                validator: (value) => _requiredField(value, 'Name of school'),
              ),
              right: _SelectField(
                label: 'Level (Class) *',
                value: selectedClass,
                options: const ['Class 9', 'Class 10', 'Class 11', 'Class 12'],
                onChanged: onClassChanged,
                validator: (value) => _requiredField(value, 'Level'),
              ),
            ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Trade *',
              controller: tradeName,
              validator: (value) => _requiredField(value, 'Trade'),
            ),
            right: _InputField(
              label: 'VTP Name *',
              controller: vtpName,
              validator: (value) => _requiredField(value, 'VTP name'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'VT Name *',
              controller: vtName,
              validator: (value) => _requiredField(value, 'VT name'),
            ),
            right: _InputField(
              label: 'Date *',
              controller: ivDate,
              hint: 'dd-mm-yyyy',
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: onIvDateTap,
              suffixIcon: Icons.calendar_today_outlined,
              validator: _date,
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'No. of Students Attended *',
              controller: studentsAttended,
              keyboardType: TextInputType.number,
              validator: (value) => _wholeNumber(
                value,
                'No. of students attended',
                allowZero: false,
              ),
            ),
            right: _InputField(
              label: 'Distance From the Place (KM) *',
              controller: distanceFromPlace,
              keyboardType: TextInputType.number,
              validator: (value) => _positiveNumber(value, 'Distance'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Name & Address of the Organization Visited *',
              controller: organizationVisited,
              maxLines: 3,
              validator: (value) =>
                  _requiredField(value, 'Name and address of organization'),
            ),
            right: _InputField(
              label: 'Name, Designation Who Interacted with Students *',
              controller: interactedPerson,
              maxLines: 3,
              validator: (value) =>
                  _requiredField(value, 'Interacted person details'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Topic Covered *',
              controller: topicCovered,
              maxLines: 3,
              validator: (value) =>
                  _requiredField(value, 'Topic covered'),
            ),
            right: _InputField(
              label: 'Feedback of Students from IV *',
              controller: studentFeedback,
              maxLines: 3,
              validator: (value) =>
                  _requiredField(value, 'Feedback of students from IV'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Learning Outcomes *',
              controller: learningOutcomes,
              maxLines: 4,
              validator: (value) =>
                  _requiredField(value, 'Learning outcomes'),
            ),
            right: _InputField(
              label: 'Name of the IV *',
              controller: ivName,
              validator: (value) => _requiredField(value, 'Name of the IV'),
            ),
          ),
          const SizedBox(height: 12),
          _TwoColumnRow(
            isMobile: isMobile,
            left: _InputField(
              label: 'Name of the VT *',
              controller: vtName,
              validator: (value) => _requiredField(value, 'Name of the VT'),
            ),
            right: _InputField(
              label: 'Name of the Principle *',
              controller: principalName,
              validator: (value) =>
                  _requiredField(value, 'Name of the Principle'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Proofs - IV Photos with GPS',
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
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Submit Industrial Visit'),
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
    required this.paymentDate,
    required this.onPaymentDateTap,
    required this.voucherNo,
    required this.rupees,
    required this.payTo,
    required this.rupeesInWords,
    required this.particulars,
    required this.paymentSchoolName,
    required this.preparedSchoolName,
    required this.trainerName,
    required this.billNo,
    required this.billDate,
    required this.onBillDateTap,
    required this.billType,
    required this.expensesDoneFor,
    required this.billAmount,
    required this.totalAmount,
    required this.vtName,
    required this.accountNo,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController paymentDate;
  final VoidCallback onPaymentDateTap;
  final TextEditingController voucherNo;
  final TextEditingController rupees;
  final TextEditingController payTo;
  final TextEditingController rupeesInWords;
  final TextEditingController particulars;
  final TextEditingController paymentSchoolName;
  final TextEditingController preparedSchoolName;
  final TextEditingController trainerName;
  final TextEditingController billNo;
  final TextEditingController billDate;
  final VoidCallback onBillDateTap;
  final TextEditingController billType;
  final TextEditingController expensesDoneFor;
  final TextEditingController billAmount;
  final TextEditingController totalAmount;
  final TextEditingController vtName;
  final TextEditingController accountNo;
  final TextEditingController ifscCode;
  final TextEditingController bankName;
  final TextEditingController branchName;
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

  String? _positiveAmount(String? value, String label) {
    final requiredError = _requiredField(value, label);
    if (requiredError != null) return requiredError;
    final amount = num.tryParse(value!.trim());
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }

  String? _accountNumber(String? value) {
    final requiredError = _requiredField(value, 'Account no. of IV person');
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^\d{9,18}$').hasMatch(value!.trim())) {
      return 'Enter a valid 9 to 18 digit account number';
    }
    return null;
  }

  String? _ifsc(String? value) {
    return _requiredField(value, 'IFSC code');
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
              'Payment Vocher of VT',
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
                label: 'Date *',
                controller: paymentDate,
                hint: 'dd-mm-yyyy',
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: onPaymentDateTap,
                suffixIcon: Icons.calendar_today_outlined,
                validator: _date,
              ),
              right: _InputField(
                label: 'Vocher No *',
                controller: voucherNo,
                validator: (value) => _requiredField(value, 'Vocher no'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Rupees *',
                controller: rupees,
                keyboardType: TextInputType.number,
                validator: (value) => _positiveAmount(value, 'Rupees'),
              ),
              right: _InputField(
                label: 'Pay To *',
                controller: payTo,
                validator: (value) => _requiredField(value, 'Pay to'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Rupees in Words *',
                controller: rupeesInWords,
                validator: (value) =>
                    _requiredField(value, 'Rupees in words'),
              ),
              right: _InputField(
                label: 'Particulars Who Received the Money *',
                controller: particulars,
                maxLines: 3,
                validator: (value) => _requiredField(
                  value,
                  'Particulars who received the money',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _InputField(
              label: 'School Name *',
              controller: paymentSchoolName,
              validator: (value) => _requiredField(value, 'School name'),
            ),
            const _VoucherDivider(),
            const _VoucherSectionTitle('Prepared by VT'),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'School Name *',
                controller: preparedSchoolName,
                validator: (value) => _requiredField(value, 'School name'),
              ),
              right: _InputField(
                label: 'Trainer Name *',
                controller: trainerName,
                validator: (value) => _requiredField(value, 'Trainer name'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Bill No *',
                controller: billNo,
                validator: (value) => _requiredField(value, 'Bill no'),
              ),
              right: _InputField(
                label: 'Date *',
                controller: billDate,
                hint: 'dd-mm-yyyy',
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: onBillDateTap,
                suffixIcon: Icons.calendar_today_outlined,
                validator: _date,
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Bill Type *',
                controller: billType,
                validator: (value) => _requiredField(value, 'Bill type'),
              ),
              right: _InputField(
                label: 'Expenses Done For *',
                controller: expensesDoneFor,
                validator: (value) =>
                    _requiredField(value, 'Expenses done for'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Bill Amount *',
                controller: billAmount,
                keyboardType: TextInputType.number,
                validator: (value) => _positiveAmount(value, 'Bill amount'),
              ),
              right: _InputField(
                label: 'Total Amount *',
                controller: totalAmount,
                keyboardType: TextInputType.number,
                validator: (value) => _positiveAmount(value, 'Total amount'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'VT Name *',
                controller: vtName,
                validator: (value) => _requiredField(value, 'VT name'),
              ),
              right: _InputField(
                label: 'Account No. of IV Person *',
                controller: accountNo,
                keyboardType: TextInputType.number,
                validator: _accountNumber,
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'IFSC Code *',
                controller: ifscCode,
                validator: _ifsc,
              ),
              right: _InputField(
                label: 'Bank Name *',
                controller: bankName,
                validator: (value) => _requiredField(value, 'Bank name'),
              ),
            ),
            const SizedBox(height: 12),
            _TwoColumnRow(
              isMobile: isMobile,
              left: _InputField(
                label: 'Branch Name *',
                controller: branchName,
                validator: (value) => _requiredField(value, 'Branch name'),
              ),
              right: const SizedBox.shrink(),
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
        final gpsLocation = bytes == null ? null : await _readGpsLocation(bytes);
        selected.add(
          _GlPhotoProof(
            name: file.name,
            sizeBytes: file.size,
            gpsLocation: gpsLocation,
          ),
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

  Future<_GpsLocation?> _readGpsLocation(List<int> bytes) async {
    try {
      final exif = await readExifFromBytes(bytes);
      final latitude = _coordinateFromExif(
        exif,
        'GPS GPSLatitude',
        'GPS GPSLatitudeRef',
      );
      final longitude = _coordinateFromExif(
        exif,
        'GPS GPSLongitude',
        'GPS GPSLongitudeRef',
      );
      if (latitude == null || longitude == null) return null;
      if (latitude == 0 && longitude == 0) return null;
      return _GpsLocation(latitude: latitude, longitude: longitude);
    } catch (_) {
      return null;
    }
  }

  double? _coordinateFromExif(
    Map<String, IfdTag> exif,
    String coordinateKey,
    String refKey,
  ) {
    final coordinate = exif[coordinateKey]?.printable.trim();
    if (coordinate == null || coordinate.isEmpty) return null;

    final parts = RegExp(
      r'-?\d+(?:\.\d+)?(?:/\d+(?:\.\d+)?)?',
    ).allMatches(coordinate).map((match) => match.group(0)!).toList();
    if (parts.isEmpty) return null;

    double? parsePart(String part) {
      if (!part.contains('/')) return double.tryParse(part);
      final fraction = part.split('/');
      if (fraction.length != 2) return null;
      final numerator = double.tryParse(fraction[0]);
      final denominator = double.tryParse(fraction[1]);
      if (numerator == null || denominator == null || denominator == 0) {
        return null;
      }
      return numerator / denominator;
    }

    final degrees = parsePart(parts[0]);
    if (degrees == null) return null;

    final minutes = parts.length > 1 ? parsePart(parts[1]) ?? 0 : 0;
    final seconds = parts.length > 2 ? parsePart(parts[2]) ?? 0 : 0;
    var value = degrees + (minutes / 60) + (seconds / 3600);

    final ref = exif[refKey]?.printable.trim().toUpperCase();
    if (ref == 'S' || ref == 'W') value = -value;
    return value;
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
                'Upload IV Photos',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${photo.name} (${_formatFileSize(photo.sizeBytes)})',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: const Color(0xFF121A2F),
                                    fontSize: isMobile ? 12 : 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  photo.gpsLocation == null
                                      ? 'GPS location not found'
                                      : 'GPS: ${photo.gpsLocation!.formatted}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: photo.hasGps
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB42318),
                                    fontSize: isMobile ? 11 : 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

class _GpsLocation {
  const _GpsLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  String get formatted {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}

class _GlPhotoProof {
  const _GlPhotoProof({
    required this.name,
    required this.sizeBytes,
    required this.gpsLocation,
  });

  final String name;
  final int sizeBytes;
  final _GpsLocation? gpsLocation;

  bool get hasGps => gpsLocation != null;
}

class _IndustrialVisitReport {
  const _IndustrialVisitReport({
    required this.schoolName,
    required this.tradeName,
    required this.vtpName,
    required this.vtName,
    required this.className,
    required this.visitDate,
    required this.studentsAttended,
    required this.distanceFromPlace,
    required this.organizationVisited,
    required this.interactedPerson,
    required this.topicCovered,
    required this.studentFeedback,
    required this.learningOutcomes,
    required this.ivName,
    required this.principalName,
    required this.paymentDate,
    required this.paymentVoucherNo,
    required this.paymentRupees,
    required this.paymentPayTo,
    required this.paymentRupeesWords,
    required this.paymentParticulars,
    required this.paymentSchoolName,
    required this.preparedSchoolName,
    required this.trainerName,
    required this.billNo,
    required this.billDate,
    required this.billType,
    required this.expensesDoneFor,
    required this.billAmount,
    required this.totalAmount,
    required this.paymentVtName,
    required this.ivPersonAccountNo,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
  });

  final String schoolName;
  final String tradeName;
  final String vtpName;
  final String vtName;
  final String className;
  final String visitDate;
  final String studentsAttended;
  final String distanceFromPlace;
  final String organizationVisited;
  final String interactedPerson;
  final String topicCovered;
  final String studentFeedback;
  final String learningOutcomes;
  final String ivName;
  final String principalName;
  final String paymentDate;
  final String paymentVoucherNo;
  final String paymentRupees;
  final String paymentPayTo;
  final String paymentRupeesWords;
  final String paymentParticulars;
  final String paymentSchoolName;
  final String preparedSchoolName;
  final String trainerName;
  final String billNo;
  final String billDate;
  final String billType;
  final String expensesDoneFor;
  final String billAmount;
  final String totalAmount;
  final String paymentVtName;
  final String ivPersonAccountNo;
  final String ifscCode;
  final String bankName;
  final String branchName;
}

class _IndustrialVisitReportsList extends StatelessWidget {
  const _IndustrialVisitReportsList({required this.reports});

  final List<_IndustrialVisitReport> reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Submitted Industrial Visit Reports',
          style: TextStyle(
            color: Color(0xFF0E1730),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...reports.map(
          (report) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _IndustrialVisitReportCard(report: report),
          ),
        ),
      ],
    );
  }
}

class _IndustrialVisitReportCard extends StatelessWidget {
  const _IndustrialVisitReportCard({required this.report});

  final _IndustrialVisitReport report;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E7F3), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.factory_outlined,
                  color: Color(0xFF2F5FD2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.schoolName.isEmpty ? '-' : report.schoolName,
                      style: const TextStyle(
                        color: Color(0xFF0E1730),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.className} | ${report.tradeName.isEmpty ? '-' : report.tradeName}',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Submitted',
                  style: TextStyle(
                    color: Color(0xFF15803D),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ReportInfoTile(
                label: 'IV Name',
                value: report.ivName,
              ),
              _ReportInfoTile(label: 'Date', value: report.visitDate),
              _ReportInfoTile(label: 'VTP Name', value: report.vtpName),
              _ReportInfoTile(label: 'VT Name', value: report.vtName),
              _ReportInfoTile(
                label: 'Students Attended',
                value: report.studentsAttended,
              ),
              _ReportInfoTile(
                label: 'Distance',
                value: '${report.distanceFromPlace} KM',
              ),
              _ReportInfoTile(
                label: 'Organization',
                value: report.organizationVisited,
              ),
              _ReportInfoTile(
                label: 'Interacted With',
                value: report.interactedPerson,
              ),
              _ReportInfoTile(label: 'Topic', value: report.topicCovered),
              _ReportInfoTile(label: 'Feedback', value: report.studentFeedback),
              _ReportInfoTile(
                label: 'Learning Outcomes',
                value: report.learningOutcomes,
              ),
              _ReportInfoTile(
                label: 'Principle',
                value: report.principalName,
              ),
            ],
          ),
          const _ReportCardSectionTitle('Payment Vocher of VT'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ReportInfoTile(label: 'Date', value: report.paymentDate),
              _ReportInfoTile(
                label: 'Vocher No',
                value: report.paymentVoucherNo,
              ),
              _ReportInfoTile(
                label: 'Rupees',
                value: 'Rs. ${report.paymentRupees}',
              ),
              _ReportInfoTile(label: 'Pay To', value: report.paymentPayTo),
              _ReportInfoTile(
                label: 'Rupees in Words',
                value: report.paymentRupeesWords,
              ),
              _ReportInfoTile(
                label: 'Particulars',
                value: report.paymentParticulars,
              ),
              _ReportInfoTile(
                label: 'School Name',
                value: report.paymentSchoolName,
              ),
            ],
          ),
          const _ReportCardSectionTitle('Prepared by VT'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ReportInfoTile(
                label: 'School Name',
                value: report.preparedSchoolName,
              ),
              _ReportInfoTile(label: 'Trainer Name', value: report.trainerName),
              _ReportInfoTile(label: 'Bill No', value: report.billNo),
              _ReportInfoTile(label: 'Date', value: report.billDate),
              _ReportInfoTile(label: 'Bill Type', value: report.billType),
              _ReportInfoTile(
                label: 'Expenses Done For',
                value: report.expensesDoneFor,
              ),
              _ReportInfoTile(
                label: 'Bill Amount',
                value: 'Rs. ${report.billAmount}',
              ),
              _ReportInfoTile(
                label: 'Total Amount',
                value: 'Rs. ${report.totalAmount}',
              ),
              _ReportInfoTile(label: 'VT Name', value: report.paymentVtName),
              _ReportInfoTile(
                label: 'Account No.',
                value: report.ivPersonAccountNo,
              ),
              _ReportInfoTile(label: 'IFSC Code', value: report.ifscCode),
              _ReportInfoTile(label: 'Bank Name', value: report.bankName),
              _ReportInfoTile(label: 'Branch Name', value: report.branchName),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportCardSectionTitle extends StatelessWidget {
  const _ReportCardSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0E1730),
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ReportInfoTile extends StatelessWidget {
  const _ReportInfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0E1730),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
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
                    "No industrial visit reports yet. Click 'Add Industrial Visit' to start.",
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
