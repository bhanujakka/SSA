import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'appbar.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class ExirSurveyPage extends StatelessWidget {
  const ExirSurveyPage({super.key});

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
                    activeItem: 'Exit Survey',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Exit Survey'),
                const Expanded(child: _ExitSurveyBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExitSurveyBody extends StatefulWidget {
  const _ExitSurveyBody();

  @override
  State<_ExitSurveyBody> createState() => _ExitSurveyBodyState();
}

class _ExitSurveyBodyState extends State<_ExitSurveyBody> {
  final _surveyFormKey = GlobalKey<FormState>();
  final _studentFormKey = GlobalKey<FormState>();

  final _district = TextEditingController(text: 'MEDAK');
  final _vtp = TextEditingController();
  final _schoolName = TextEditingController();
  final _udise = TextEditingController();
  final _classOfVt = TextEditingController();
  final _sector = TextEditingController();
  final _jobRole = TextEditingController();
  final _vtName = TextEditingController();
  final _vtMobile = TextEditingController();

  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _lastName = TextEditingController();
  final _dob = TextEditingController();
  final _age = TextEditingController();
  final _mobile = TextEditingController();
  final _socialCategory = TextEditingController();
  final _father = TextEditingController();
  final _mother = TextEditingController();
  final _contact = TextEditingController();

  String _schoolType = 'SS';
  String _locationType = 'Urban';
  String _gender = 'Male';
  bool _higherEducation = false;
  bool _upskilling = false;
  bool _apprenticeship = false;
  bool _careerCounselling = false;
  bool _showForm = false;
  bool _showStudentInfo = false;

  final List<_ExitSurvey> _surveys = [];

  @override
  void dispose() {
    _district.dispose();
    _vtp.dispose();
    _schoolName.dispose();
    _udise.dispose();
    _classOfVt.dispose();
    _sector.dispose();
    _jobRole.dispose();
    _vtName.dispose();
    _vtMobile.dispose();
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _dob.dispose();
    _age.dispose();
    _mobile.dispose();
    _socialCategory.dispose();
    _father.dispose();
    _mother.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return Stack(
          children: [
            Column(
              children: [
                DashboardTopBar(isMobile: constraints.maxWidth < 980),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 16 : 32,
                      isCompact ? 28 : 34,
                      isCompact ? 16 : 32,
                      108,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight -
                            (constraints.maxWidth < 980 ? 96 : 92) -
                            (isCompact ? 56 : 68),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PageHeader(
                            isCompact: isCompact,
                            isAdding: _showForm,
                            onAddTap: _toggleForm,
                          ),
                          if (_showForm) ...[
                            const SizedBox(height: 24),
                            _ExitSurveyForm(
                              formKey: _surveyFormKey,
                              schoolType: _schoolType,
                              district: _district,
                              vtp: _vtp,
                              schoolName: _schoolName,
                              udise: _udise,
                              locationType: _locationType,
                              classOfVt: _classOfVt,
                              sector: _sector,
                              jobRole: _jobRole,
                              vtName: _vtName,
                              vtMobile: _vtMobile,
                              onSchoolTypeChanged: (value) {
                                if (value == null) return;
                                setState(() => _schoolType = value);
                              },
                              onLocationTypeChanged: (value) {
                                if (value == null) return;
                                setState(() => _locationType = value);
                              },
                              onAddStudent: _showStudentInformationPanel,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: _showStudentInfo
                                  ? Padding(
                                      key: const ValueKey('student-info-panel'),
                                      padding: const EdgeInsets.only(top: 24),
                                      child: Form(
                                        key: _studentFormKey,
                                        child: _FormPanel(
                                          borderColor:
                                              const Color(0xFFBEEFD0),
                                          child: _StudentInformationSection(
                                            firstName: _firstName,
                                            middleName: _middleName,
                                            lastName: _lastName,
                                            dob: _dob,
                                            age: _age,
                                            gender: _gender,
                                            mobile: _mobile,
                                            socialCategory: _socialCategory,
                                            father: _father,
                                            mother: _mother,
                                            contact: _contact,
                                            higherEducation: _higherEducation,
                                            upskilling: _upskilling,
                                            apprenticeship: _apprenticeship,
                                            careerCounselling:
                                                _careerCounselling,
                                            onGenderChanged: (value) {
                                              if (value == null) return;
                                              setState(() => _gender = value);
                                            },
                                            onHigherEducationChanged: (value) {
                                              setState(
                                                () => _higherEducation = value,
                                              );
                                            },
                                            onUpskillingChanged: (value) {
                                              setState(
                                                () => _upskilling = value,
                                              );
                                            },
                                            onApprenticeshipChanged: (value) {
                                              setState(
                                                () => _apprenticeship = value,
                                              );
                                            },
                                            onCareerCounsellingChanged:
                                                (value) {
                                              setState(
                                                () => _careerCounselling =
                                                    value,
                                              );
                                            },
                                            onPickDob: _pickDob,
                                            onSubmit: _submitSurvey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('student-info-empty'),
                                    ),
                            ),
                          ],
                          if (_surveys.isEmpty && !_showForm)
                            _EmptyState(onAddTap: _toggleForm)
                          else if (_surveys.isNotEmpty) ...[
                            SizedBox(height: _showForm ? 26 : 22),
                            ..._surveys.map(
                              (survey) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _SurveyCard(
                                  survey: survey,
                                  onDelete: () => _deleteSurvey(survey),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: isCompact ? 16 : 32,
              bottom: 28,
              child: const DashboardQuickActionsFab(),
            ),
          ],
        );
      },
    );
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
      if (!_showForm) _showStudentInfo = false;
    });
  }

  void _showStudentInformationPanel() {
    if (!(_surveyFormKey.currentState?.validate() ?? false)) return;
    setState(() => _showStudentInfo = true);
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008, 1, 1),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    _dob.text =
        '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year.toString().padLeft(4, '0')}';
  }

  void _submitSurvey() {
    final isSurveyValid = _surveyFormKey.currentState?.validate() ?? false;
    final isStudentValid = _studentFormKey.currentState?.validate() ?? false;
    if (!isSurveyValid || !isStudentValid) return;

    final middle = _middleName.text.trim();
    final fullName = [
      _firstName.text.trim(),
      if (middle.isNotEmpty) middle,
      _lastName.text.trim(),
    ].join(' ');

    final survey = _ExitSurvey(
      studentName: fullName,
      schoolType: _schoolType,
      district: _district.text.trim(),
      vtp: _vtp.text.trim(),
      schoolName: _schoolName.text.trim(),
      udise: _udise.text.trim(),
      locationType: _locationType,
      classOfVt: _classOfVt.text.trim(),
      sector: _sector.text.trim(),
      jobRole: _jobRole.text.trim(),
      vtName: _vtName.text.trim(),
      vtMobile: _vtMobile.text.trim(),
      dob: _dob.text.trim(),
      age: _age.text.trim(),
      gender: _gender,
      mobile: _mobile.text.trim(),
      socialCategory: _socialCategory.text.trim(),
      father: _father.text.trim(),
      mother: _mother.text.trim(),
      contact: _contact.text.trim(),
      higherEducation: _higherEducation,
      upskilling: _upskilling,
      apprenticeship: _apprenticeship,
      careerCounselling: _careerCounselling,
    );

    setState(() {
      _surveys.insert(0, survey);
      _showForm = false;
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$fullName exit survey submitted.')),
    );
  }

  void _deleteSurvey(_ExitSurvey survey) {
    setState(() => _surveys.remove(survey));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${survey.studentName} survey deleted.')),
    );
  }

  void _clearForm() {
    _vtp.clear();
    _schoolName.clear();
    _udise.clear();
    _classOfVt.clear();
    _sector.clear();
    _jobRole.clear();
    _vtName.clear();
    _vtMobile.clear();
    _firstName.clear();
    _middleName.clear();
    _lastName.clear();
    _dob.clear();
    _age.clear();
    _mobile.clear();
    _socialCategory.clear();
    _father.clear();
    _mother.clear();
    _contact.clear();
    _schoolType = 'SS';
    _locationType = 'Urban';
    _gender = 'Male';
    _showStudentInfo = false;
    _higherEducation = false;
    _upskilling = false;
    _apprenticeship = false;
    _careerCounselling = false;
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.isCompact,
    required this.isAdding,
    required this.onAddTap,
  });

  final bool isCompact;
  final bool isAdding;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    const titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Exit Survey',
          style: TextStyle(
            color: Color(0xFF020817),
            fontSize: 29,
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Track student exit survey data',
          style: TextStyle(
            color: Color(0xFF667085),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final button = _HeaderButton(
      label: isAdding ? 'Cancel' : 'Add Survey',
      icon: Icons.add_rounded,
      onTap: onAddTap,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 18),
          button,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: titleBlock),
        button,
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3475E6),
      borderRadius: BorderRadius.circular(14),
      elevation: 9,
      shadowColor: const Color(0x553475E6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 340,
      child: Center(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onAddTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: const Color(0xFF6B7280),
                  size: MediaQuery.of(context).size.width < 480 ? 54 : 72,
                ),
                const SizedBox(height: 18),
                const Text(
                  'No exit surveys yet. Click "Add Survey" to start.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

class _ExitSurveyForm extends StatelessWidget {
  const _ExitSurveyForm({
    required this.formKey,
    required this.schoolType,
    required this.district,
    required this.vtp,
    required this.schoolName,
    required this.udise,
    required this.locationType,
    required this.classOfVt,
    required this.sector,
    required this.jobRole,
    required this.vtName,
    required this.vtMobile,
    required this.onSchoolTypeChanged,
    required this.onLocationTypeChanged,
    required this.onAddStudent,
  });

  final GlobalKey<FormState> formKey;
  final String schoolType;
  final TextEditingController district;
  final TextEditingController vtp;
  final TextEditingController schoolName;
  final TextEditingController udise;
  final String locationType;
  final TextEditingController classOfVt;
  final TextEditingController sector;
  final TextEditingController jobRole;
  final TextEditingController vtName;
  final TextEditingController vtMobile;
  final ValueChanged<String?> onSchoolTypeChanged;
  final ValueChanged<String?> onLocationTypeChanged;
  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _FormPanel(
            borderColor: const Color(0xFFCCD8F8),
            child: _SurveyInformationSection(
              schoolType: schoolType,
              district: district,
              vtp: vtp,
              schoolName: schoolName,
              udise: udise,
              locationType: locationType,
              classOfVt: classOfVt,
              sector: sector,
              jobRole: jobRole,
              vtName: vtName,
              vtMobile: vtMobile,
              onSchoolTypeChanged: onSchoolTypeChanged,
              onLocationTypeChanged: onLocationTypeChanged,
              onAddStudent: onAddStudent,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyInformationSection extends StatelessWidget {
  const _SurveyInformationSection({
    required this.schoolType,
    required this.district,
    required this.vtp,
    required this.schoolName,
    required this.udise,
    required this.locationType,
    required this.classOfVt,
    required this.sector,
    required this.jobRole,
    required this.vtName,
    required this.vtMobile,
    required this.onSchoolTypeChanged,
    required this.onLocationTypeChanged,
    required this.onAddStudent,
  });

  final String schoolType;
  final TextEditingController district;
  final TextEditingController vtp;
  final TextEditingController schoolName;
  final TextEditingController udise;
  final String locationType;
  final TextEditingController classOfVt;
  final TextEditingController sector;
  final TextEditingController jobRole;
  final TextEditingController vtName;
  final TextEditingController vtMobile;
  final ValueChanged<String?> onSchoolTypeChanged;
  final ValueChanged<String?> onLocationTypeChanged;
  final VoidCallback onAddStudent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Survey Information'),
            const SizedBox(height: 18),
            _ResponsiveFields(
              maxWidth: constraints.maxWidth,
              children: [
                _DropdownBox(
                  label: 'SS/PM Shri *',
                  value: schoolType,
                  values: const ['SS', 'PM Shri'],
                  onChanged: onSchoolTypeChanged,
                ),
                _TextFieldBox(
                  label: 'District *',
                  controller: district,
                  readOnly: true,
                  filled: true,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'VTP *',
                  controller: vtp,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'School Name *',
                  controller: schoolName,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'UDISE Code *',
                  controller: udise,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(11)],
                  filled: true,
                  validator: _validateUdise,
                ),
                _DropdownBox(
                  label: 'Location Type *',
                  value: locationType,
                  values: const ['Urban', 'Rural'],
                  onChanged: onLocationTypeChanged,
                ),
                _TextFieldBox(
                  label: 'Class of VT *',
                  controller: classOfVt,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(2)],
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'Sector *',
                  controller: sector,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'Job Role *',
                  controller: jobRole,
                  filled: true,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'VT Name *',
                  controller: vtName,
                  filled: true,
                  inputFormatters: [_nameFormatter],
                  validator: _validateName,
                ),
                _TextFieldBox(
                  label: 'VT Mobile Number *',
                  controller: vtMobile,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(10)],
                  filled: true,
                  validator: _validateMobile,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FullWidthButton(
              label: 'Add Student',
              onTap: onAddStudent,
            ),
          ],
        );
      },
    );
  }
}

class _StudentInformationSection extends StatelessWidget {
  const _StudentInformationSection({
    // ignore: unused_element_parameter
    this.showTitle = true,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dob,
    required this.age,
    required this.gender,
    required this.mobile,
    required this.socialCategory,
    required this.father,
    required this.mother,
    required this.contact,
    required this.higherEducation,
    required this.upskilling,
    required this.apprenticeship,
    required this.careerCounselling,
    required this.onGenderChanged,
    required this.onHigherEducationChanged,
    required this.onUpskillingChanged,
    required this.onApprenticeshipChanged,
    required this.onCareerCounsellingChanged,
    required this.onPickDob,
    required this.onSubmit,
  });

  final bool showTitle;
  final TextEditingController firstName;
  final TextEditingController middleName;
  final TextEditingController lastName;
  final TextEditingController dob;
  final TextEditingController age;
  final String gender;
  final TextEditingController mobile;
  final TextEditingController socialCategory;
  final TextEditingController father;
  final TextEditingController mother;
  final TextEditingController contact;
  final bool higherEducation;
  final bool upskilling;
  final bool apprenticeship;
  final bool careerCounselling;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<bool> onHigherEducationChanged;
  final ValueChanged<bool> onUpskillingChanged;
  final ValueChanged<bool> onApprenticeshipChanged;
  final ValueChanged<bool> onCareerCounsellingChanged;
  final VoidCallback onPickDob;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              const _SectionTitle('Student Information'),
              const SizedBox(height: 18),
            ],
            _ResponsiveFields(
              maxWidth: constraints.maxWidth,
              children: [
                _TextFieldBox(
                  label: 'First Name *',
                  controller: firstName,
                  inputFormatters: [_nameFormatter],
                  validator: _validateName,
                ),
                _TextFieldBox(
                  label: 'Middle Name',
                  controller: middleName,
                  isRequired: false,
                  inputFormatters: [_nameFormatter],
                  validator: _validateOptionalName,
                ),
                _TextFieldBox(
                  label: 'Last Name *',
                  controller: lastName,
                  inputFormatters: [_nameFormatter],
                  validator: _validateName,
                ),
                _TextFieldBox(
                  label: 'DOB *',
                  controller: dob,
                  hint: 'dd-mm-yyyy',
                  readOnly: true,
                  suffixIcon: Icons.calendar_today_outlined,
                  onTap: onPickDob,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'Age *',
                  controller: age,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(2)],
                  validator: _validateAge,
                ),
                _DropdownBox(
                  label: 'Gender *',
                  value: gender,
                  values: const ['Male', 'Female', 'Other'],
                  onChanged: onGenderChanged,
                ),
                _TextFieldBox(
                  label: 'Mobile Number *',
                  controller: mobile,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(10)],
                  validator: _validateMobile,
                ),
                _TextFieldBox(
                  label: 'Social Category *',
                  controller: socialCategory,
                  validator: _requiredValidator,
                ),
                _TextFieldBox(
                  label: 'Father Name *',
                  controller: father,
                  inputFormatters: [_nameFormatter],
                  validator: _validateName,
                ),
                _TextFieldBox(
                  label: 'Mother Name *',
                  controller: mother,
                  inputFormatters: [_nameFormatter],
                  validator: _validateName,
                ),
                _TextFieldBox(
                  label: 'Contact Number *',
                  controller: contact,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_digitsOnly, LengthLimitingTextInputFormatter(10)],
                  validator: _validateMobile,
                ),
              ],
            ),
            const SizedBox(height: 32),
            _QuestionPanel(
              higherEducation: higherEducation,
              upskilling: upskilling,
              apprenticeship: apprenticeship,
              careerCounselling: careerCounselling,
              onHigherEducationChanged: onHigherEducationChanged,
              onUpskillingChanged: onUpskillingChanged,
              onApprenticeshipChanged: onApprenticeshipChanged,
              onCareerCounsellingChanged: onCareerCounsellingChanged,
            ),
            const SizedBox(height: 16),
            _FullWidthButton(
              label: 'Submit Exit Survey',
              onTap: onSubmit,
            ),
          ],
        );
      },
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.borderColor,
    required this.child,
  });

  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            isNarrow ? 16 : 24,
            isNarrow ? 20 : 26,
            isNarrow ? 16 : 24,
            isNarrow ? 22 : 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x170F172A),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({
    required this.maxWidth,
    required this.children,
  });

  final double maxWidth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isSingle = maxWidth < 760;
    final spacing = isSingle ? 0.0 : 16.0;
    final itemWidth = isSingle ? maxWidth : (maxWidth - spacing) / 2;

    return Wrap(
      spacing: spacing,
      runSpacing: 14,
      children: children
          .map(
            (child) => SizedBox(
              width: itemWidth,
              child: child,
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF020817),
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  const _TextFieldBox({
    required this.label,
    required this.controller,
    this.isRequired = true,
    this.hint,
    this.readOnly = false,
    this.filled = false,
    this.suffixIcon,
    this.onTap,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final String? hint;
  final bool readOnly;
  final bool filled;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          validator: validator ?? (isRequired ? _requiredValidator : (_) => null),
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, size: 18),
            isDense: true,
            filled: true,
            fillColor: filled ? const Color(0xFFE8F0FE) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            border: _fieldBorder(),
            enabledBorder: _fieldBorder(),
            focusedBorder: _fieldBorder(color: const Color(0xFF3475E6)),
            errorBorder: _fieldBorder(color: const Color(0xFFEF4444)),
            focusedErrorBorder: _fieldBorder(color: const Color(0xFFEF4444)),
          ),
        ),
      ],
    );
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: values
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            border: _fieldBorder(),
            enabledBorder: _fieldBorder(),
            focusedBorder: _fieldBorder(color: const Color(0xFF3475E6)),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF020817),
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    required this.higherEducation,
    required this.upskilling,
    required this.apprenticeship,
    required this.careerCounselling,
    required this.onHigherEducationChanged,
    required this.onUpskillingChanged,
    required this.onApprenticeshipChanged,
    required this.onCareerCounsellingChanged,
  });

  final bool higherEducation;
  final bool upskilling;
  final bool apprenticeship;
  final bool careerCounselling;
  final ValueChanged<bool> onHigherEducationChanged;
  final ValueChanged<bool> onUpskillingChanged;
  final ValueChanged<bool> onApprenticeshipChanged;
  final ValueChanged<bool> onCareerCounsellingChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSingle = constraints.maxWidth < 720;
        final itemWidth = isSingle
            ? constraints.maxWidth
            : (constraints.maxWidth - 20) / 2;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E7F2), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exit Survey Questions',
                style: TextStyle(
                  color: Color(0xFF020817),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _QuestionCheckbox(
                      label: 'Pursuing Higher Education?',
                      value: higherEducation,
                      onChanged: onHigherEducationChanged,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuestionCheckbox(
                      label: 'Pursuing Upskilling?',
                      value: upskilling,
                      onChanged: onUpskillingChanged,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuestionCheckbox(
                      label: 'Pursuing Apprenticeship?',
                      value: apprenticeship,
                      onChanged: onApprenticeshipChanged,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _QuestionCheckbox(
                      label: 'Received Career Counselling?',
                      value: careerCounselling,
                      onChanged: onCareerCounsellingChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionCheckbox extends StatelessWidget {
  const _QuestionCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (value) => onChanged(value ?? false),
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      title: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF020817),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3475E6),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0x553475E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({
    required this.survey,
    required this.onDelete,
  });

  final _ExitSurvey survey;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 760;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 18 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD7DFF2), width: 1),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SurveyIdentity(survey: survey, onDelete: onDelete),
                    const SizedBox(height: 16),
                    _SurveyDetails(survey: survey, columns: 1),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _SurveyIdentity(
                        survey: survey,
                        onDelete: onDelete,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      flex: 7,
                      child: _SurveyDetails(survey: survey, columns: 2),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SurveyIdentity extends StatelessWidget {
  const _SurveyIdentity({
    required this.survey,
    required this.onDelete,
  });

  final _ExitSurvey survey;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF3367D8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.assignment_turned_in_outlined,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                survey.studentName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF020817),
                  fontSize: 20,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _StatusChip(label: survey.locationType),
              const SizedBox(height: 10),
              _InfoLine(label: 'School', value: survey.schoolName),
              const SizedBox(height: 8),
              _InfoLine(label: 'Mobile', value: survey.mobile),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Delete survey',
          onPressed: onDelete,
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }
}

class _SurveyDetails extends StatelessWidget {
  const _SurveyDetails({
    required this.survey,
    required this.columns,
  });

  final _ExitSurvey survey;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('SS/PM Shri', survey.schoolType),
      ('District', survey.district),
      ('VTP', survey.vtp),
      ('UDISE', survey.udise),
      ('Class of VT', survey.classOfVt),
      ('Sector', survey.sector),
      ('VT Name', survey.vtName),
      ('Questions', survey.questionSummary),
    ];

    if (columns == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InfoLine(label: item.$1, value: item.$2),
              ),
            )
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _DetailsColumn(items: items.take(4).toList())),
        const SizedBox(width: 24),
        Expanded(child: _DetailsColumn(items: items.skip(4).toList())),
      ],
    );
  }
}

class _DetailsColumn extends StatelessWidget {
  const _DetailsColumn({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _InfoLine(label: item.$1, value: item.$2),
            ),
          )
          .toList(),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF667085),
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Color(0xFF020817),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = label == 'Urban'
        ? const Color(0xFF2D65D7)
        : const Color(0xFF0EA779);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String? _requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Required';
  return null;
}

String? _validateName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Required';
  if (text.length < 2) return 'At least 2 letters';
  if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(text)) {
    return 'Use letters only';
  }
  return null;
}

String? _validateOptionalName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  return _validateName(text);
}

String? _validateAge(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Required';
  final age = int.tryParse(text);
  if (age == null) return 'Numbers only';
  if (age < 10 || age > 30) return 'Age must be 10-30';
  return null;
}

String? _validateMobile(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Required';
  if (digits.length != 10) return 'Enter 10 digits';
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
    return 'Invalid mobile';
  }
  return null;
}

String? _validateUdise(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return 'Required';
  if (digits.length < 2) return 'Invalid UDISE';
  return null;
}

final _digitsOnly = FilteringTextInputFormatter.digitsOnly;
final _nameFormatter = FilteringTextInputFormatter.allow(
  RegExp(r"[A-Za-z .'-]"),
);

OutlineInputBorder _fieldBorder({Color color = const Color(0xFFC7D4F5)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: 1),
  );
}

class _ExitSurvey {
  const _ExitSurvey({
    required this.studentName,
    required this.schoolType,
    required this.district,
    required this.vtp,
    required this.schoolName,
    required this.udise,
    required this.locationType,
    required this.classOfVt,
    required this.sector,
    required this.jobRole,
    required this.vtName,
    required this.vtMobile,
    required this.dob,
    required this.age,
    required this.gender,
    required this.mobile,
    required this.socialCategory,
    required this.father,
    required this.mother,
    required this.contact,
    required this.higherEducation,
    required this.upskilling,
    required this.apprenticeship,
    required this.careerCounselling,
  });

  final String studentName;
  final String schoolType;
  final String district;
  final String vtp;
  final String schoolName;
  final String udise;
  final String locationType;
  final String classOfVt;
  final String sector;
  final String jobRole;
  final String vtName;
  final String vtMobile;
  final String dob;
  final String age;
  final String gender;
  final String mobile;
  final String socialCategory;
  final String father;
  final String mother;
  final String contact;
  final bool higherEducation;
  final bool upskilling;
  final bool apprenticeship;
  final bool careerCounselling;

  String get questionSummary {
    final selected = [
      if (higherEducation) 'Higher education',
      if (upskilling) 'Upskilling',
      if (apprenticeship) 'Apprenticeship',
      if (careerCounselling) 'Career counselling',
    ];
    return selected.isEmpty ? 'None selected' : selected.join(', ');
  }
}
