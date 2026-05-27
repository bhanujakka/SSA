import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class VTInstructorMyProfilePage extends StatelessWidget {
  const VTInstructorMyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileShell = constraints.maxWidth < 980;
        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobileShell ? const Drawer(child: DashboardSidebar(activeItem: 'My Profile', showCollapseButton: false)) : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobileShell)
                  const DashboardSidebarHost(activeItem: 'My Profile'),
                const Expanded(child: _MyProfileBody()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MyProfileBody extends StatefulWidget {
  const _MyProfileBody();

  static const docs = [
    ('SSC Certificate', 'Educational'),
    ('Intermediate Certificate', 'Educational'),
    ('Graduation Certificate', 'Educational'),
    ('Post Graduation Certificate', 'Educational'),
    ('Aadhaar Card', 'Identity'),
    ('PAN Card', 'Identity'),
    ('Passport Size Photograph', 'Personal'),
  ];

  @override
  State<_MyProfileBody> createState() => _MyProfileBodyState();
}

class _MyProfileBodyState extends State<_MyProfileBody> {
  final Map<String, String> _uploadedFiles = {};
  final Map<String, String> _fieldErrors = {};
  bool _isEditing = false;
  late Map<String, String> _savedProfile;
  late Map<String, String> _draftProfile;

  @override
  void initState() {
    super.initState();
    _savedProfile = {
      'firstName': 'John',
      'middleName': '',
      'lastName': 'Doe',
      'dob': '15-05-1990',
      'gender': 'Male',
      'qualification': 'B.Tech in Computer Science',
      'email': 'john.doe@example.com',
      'phone': '+91 98765 43210',
      'alternatePhone': '',
      'organization': 'Govt High School Delhi',
      'designation': 'Vocational Trainer',
      'address': '123 Main Street',
      'city': 'New Delhi',
      'state': 'Delhi',
      'pinCode': '110001',
      'aadhaar': '1234-5678-9012',
      'pan': 'ABCDE1234F',
    };
    _draftProfile = Map<String, String>.from(_savedProfile);
  }

  void _onEditButtonTap() {
    if (_isEditing) {
      final validationErrors = _validateDraftProfile();
      if (validationErrors.isNotEmpty) {
        setState(() {
          _fieldErrors
            ..clear()
            ..addAll(validationErrors);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationErrors.values.first),
            backgroundColor: const Color(0xFFB91C1C),
          ),
        );
        return;
      }

      setState(() {
        _fieldErrors.clear();
        _draftProfile['pan'] = (_draftProfile['pan'] ?? '').trim().toUpperCase();
        _draftProfile['phone'] = (_draftProfile['phone'] ?? '').trim();
        _draftProfile['alternatePhone'] = (_draftProfile['alternatePhone'] ?? '').trim();
        _draftProfile['aadhaar'] = (_draftProfile['aadhaar'] ?? '').trim();
        _savedProfile = Map<String, String>.from(_draftProfile);
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully'),
          backgroundColor: Color(0xFF0F9F6E),
        ),
      );
      return;
    }

    setState(() {
      _draftProfile = Map<String, String>.from(_savedProfile);
      _fieldErrors.clear();
      _isEditing = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit mode enabled'),
        backgroundColor: Color(0xFF0F9F6E),
      ),
    );
  }

  void _onCancelEditTap() {
    setState(() {
      _draftProfile = Map<String, String>.from(_savedProfile);
      _fieldErrors.clear();
      _isEditing = false;
    });
  }

  void _updateDraftField(String key, String value) {
    setState(() {
      _draftProfile[key] = value;
      _fieldErrors.remove(key);
    });
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _parseDob(_draftProfile['dob']) ?? DateTime(now.year - 25, 1, 1);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (selected == null) return;
    final formatted =
        '${selected.day.toString().padLeft(2, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.year}';
    _updateDraftField('dob', formatted);
  }

  DateTime? _parseDob(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime.tryParse(
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
    );
  }

  Map<String, String> _validateDraftProfile() {
    final errors = <String, String>{};
    bool isBlank(String key) => (_draftProfile[key] ?? '').trim().isEmpty;
    String digitsOnly(String key) => (_draftProfile[key] ?? '').replaceAll(RegExp(r'\D'), '');

    if (isBlank('firstName')) errors['firstName'] = 'First Name is required.';
    if (isBlank('lastName')) errors['lastName'] = 'Last Name is required.';
    if (isBlank('dob')) errors['dob'] = 'Date of Birth is required.';
    if (isBlank('gender')) errors['gender'] = 'Gender is required.';
    if (isBlank('email')) errors['email'] = 'Email Address is required.';
    if (isBlank('phone')) errors['phone'] = 'Phone Number is required.';
    if (isBlank('organization')) errors['organization'] = 'Organization is required.';
    if (isBlank('designation')) errors['designation'] = 'Designation is required.';
    if (isBlank('address')) errors['address'] = 'Address is required.';
    if (isBlank('city')) errors['city'] = 'City is required.';
    if (isBlank('state')) errors['state'] = 'State is required.';
    if (isBlank('pinCode')) errors['pinCode'] = 'PIN Code is required.';

    final email = (_draftProfile['email'] ?? '').trim();
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isNotEmpty && !emailPattern.hasMatch(email)) {
      errors['email'] = 'Enter a valid Email Address.';
    }

    final phone = digitsOnly('phone');
    if (phone.isNotEmpty && (phone.length < 10 || phone.length > 12)) {
      errors['phone'] = 'Phone Number should have 10 to 12 digits.';
    }

    final alternatePhone = digitsOnly('alternatePhone');
    if (alternatePhone.isNotEmpty && (alternatePhone.length < 10 || alternatePhone.length > 12)) {
      errors['alternatePhone'] = 'Alternate Phone should have 10 to 12 digits.';
    }

    final pinCode = digitsOnly('pinCode');
    if (pinCode.isNotEmpty && pinCode.length != 6) {
      errors['pinCode'] = 'PIN Code must be 6 digits.';
    }

    final pan = (_draftProfile['pan'] ?? '').trim();
    if (pan.isNotEmpty && !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan.toUpperCase())) {
      errors['pan'] = 'Enter a valid PAN Number (e.g., ABCDE1234F).';
    }

    final aadhaar = digitsOnly('aadhaar');
    if (aadhaar.isNotEmpty && aadhaar.length != 12) {
      errors['aadhaar'] = 'Aadhaar Number must be 12 digits.';
    }

    return errors;
  }

  Future<void> _pickAndUpload(String documentTitle) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final extension = (file.extension ?? '').toLowerCase();
      const allowed = {'pdf', 'jpg', 'jpeg', 'png'};
      if (!allowed.contains(extension)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file format. Use PDF, JPG, JPEG, or PNG.'),
            backgroundColor: Color(0xFFB91C1C),
          ),
        );
        return;
      }

      const maxBytes = 5 * 1024 * 1024;
      if (file.size > maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File is too large. Maximum allowed size is 5MB.'),
            backgroundColor: Color(0xFFB91C1C),
          ),
        );
        return;
      }

      setState(() {
        _uploadedFiles[documentTitle] = file.name;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$documentTitle uploaded: ${file.name}'),
          backgroundColor: const Color(0xFF0F9F6E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isMobile = maxWidth < 980;
        final useTwoColumns = maxWidth >= 900;
        final profileData = _isEditing ? _draftProfile : _savedProfile;

        return Stack(
          children: [
            Column(
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
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'My Profile',
                                style: TextStyle(
                                  color: DashboardColors.text,
                                  fontSize: 46 / 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _EditProfileButton(
                              label: _isEditing ? 'Save Profile' : 'Edit Profile',
                              onTap: _onEditButtonTap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your personal information and documents',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: 31 / 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _CancelEditButton(onTap: _onCancelEditTap),
                          ),
                        ],
                        const SizedBox(height: 20),
                        if (useTwoColumns)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 65,
                                child: _LeftProfileColumn(
                                  isEditing: _isEditing,
                                  profileData: profileData,
                                  fieldErrors: _fieldErrors,
                                  onChanged: _updateDraftField,
                                  onDobTap: _pickDob,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 35,
                                child: _DocumentsCard(
                                  isMobile: isMobile,
                                  uploadedFiles: _uploadedFiles,
                                  onUploadTap: _pickAndUpload,
                                ),
                              ),
                            ],
                          ),
                        if (!useTwoColumns)
                          Column(
                            children: [
                              _LeftProfileColumn(
                                isEditing: _isEditing,
                                profileData: profileData,
                                fieldErrors: _fieldErrors,
                                onChanged: _updateDraftField,
                                onDobTap: _pickDob,
                              ),
                              const SizedBox(height: 18),
                              _DocumentsCard(
                                isMobile: isMobile,
                                uploadedFiles: _uploadedFiles,
                                onUploadTap: _pickAndUpload,
                              ),
                            ],
                          ),
                        const SizedBox(height: 110),
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

class _LeftProfileColumn extends StatelessWidget {
  const _LeftProfileColumn({
    required this.isEditing,
    required this.profileData,
    required this.fieldErrors,
    required this.onChanged,
    required this.onDobTap,
  });

  final bool isEditing;
  final Map<String, String> profileData;
  final Map<String, String> fieldErrors;
  final void Function(String key, String value) onChanged;
  final VoidCallback onDobTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileInfoCard(
          isEditing: isEditing,
          profileData: profileData,
          fieldErrors: fieldErrors,
          onChanged: onChanged,
          onDobTap: onDobTap,
        ),
        const SizedBox(height: 18),
        _ContactInfoCard(
          isEditing: isEditing,
          profileData: profileData,
          fieldErrors: fieldErrors,
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
        _OrganizationCard(
          isEditing: isEditing,
          profileData: profileData,
          fieldErrors: fieldErrors,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x55EA4A65), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12A3BCB0),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DashboardColors.red, Color(0xFF2D65D7)],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 38 / 2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.isEditing,
    required this.profileData,
    required this.fieldErrors,
    required this.onChanged,
    required this.onDobTap,
  });

  final bool isEditing;
  final Map<String, String> profileData;
  final Map<String, String> fieldErrors;
  final void Function(String key, String value) onChanged;
  final VoidCallback onDobTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Personal Information', icon: Icons.person_outline_rounded),
          const SizedBox(height: 18),
          _TwoFields(
            left: _Field(
              label: 'First Name *',
              value: profileData['firstName'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['firstName'],
              onChanged: (value) => onChanged('firstName', value),
            ),
            right: _Field(
              label: 'Middle Name',
              value: profileData['middleName'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['middleName'],
              onChanged: (value) => onChanged('middleName', value),
            ),
          ),
          const SizedBox(height: 12),
          _TwoFields(
            left: _Field(
              label: 'Last Name *',
              value: profileData['lastName'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['lastName'],
              onChanged: (value) => onChanged('lastName', value),
            ),
            right: _Field(
              label: 'Date of Birth *',
              value: profileData['dob'] ?? '',
              enabled: isEditing,
              readOnly: true,
              onTap: isEditing ? onDobTap : null,
              errorText: fieldErrors['dob'],
              onChanged: (value) => onChanged('dob', value),
            ),
          ),
          const SizedBox(height: 12),
          _TwoFields(
            left: _Field(
              label: 'Gender *',
              value: profileData['gender'] ?? '',
              enabled: isEditing,
              isDropdown: true,
              errorText: fieldErrors['gender'],
              onChanged: (value) => onChanged('gender', value),
            ),
            right: _Field(
              label: 'Qualification',
              value: profileData['qualification'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['qualification'],
              onChanged: (value) => onChanged('qualification', value),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactInfoCard extends StatelessWidget {
  const _ContactInfoCard({
    required this.isEditing,
    required this.profileData,
    required this.fieldErrors,
    required this.onChanged,
  });

  final bool isEditing;
  final Map<String, String> profileData;
  final Map<String, String> fieldErrors;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Contact Information', icon: Icons.call_outlined),
          const SizedBox(height: 18),
          _TwoFields(
            left: _Field(
              label: 'Email Address *',
              value: profileData['email'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['email'],
              onChanged: (value) => onChanged('email', value),
            ),
            right: _Field(
              label: 'Phone Number *',
              value: profileData['phone'] ?? '',
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
              ],
              errorText: fieldErrors['phone'],
              onChanged: (value) => onChanged('phone', value),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Alternate Phone',
            value: profileData['alternatePhone'] ?? '',
            enabled: isEditing,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
            ],
            errorText: fieldErrors['alternatePhone'],
            onChanged: (value) => onChanged('alternatePhone', value),
          ),
        ],
      ),
    );
  }
}

class _OrganizationCard extends StatelessWidget {
  const _OrganizationCard({
    required this.isEditing,
    required this.profileData,
    required this.fieldErrors,
    required this.onChanged,
  });

  final bool isEditing;
  final Map<String, String> profileData;
  final Map<String, String> fieldErrors;
  final void Function(String key, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Organization & Address', icon: Icons.business_outlined),
          const SizedBox(height: 18),
          _TwoFields(
            left: _Field(
              label: 'Organization *',
              value: profileData['organization'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['organization'],
              onChanged: (value) => onChanged('organization', value),
            ),
            right: _Field(
              label: 'Designation *',
              value: profileData['designation'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['designation'],
              onChanged: (value) => onChanged('designation', value),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Address *',
            value: profileData['address'] ?? '',
            enabled: isEditing,
            errorText: fieldErrors['address'],
            onChanged: (value) => onChanged('address', value),
          ),
          const SizedBox(height: 12),
          _TwoFields(
            left: _Field(
              label: 'City *',
              value: profileData['city'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['city'],
              onChanged: (value) => onChanged('city', value),
            ),
            right: _Field(
              label: 'State *',
              value: profileData['state'] ?? '',
              enabled: isEditing,
              errorText: fieldErrors['state'],
              onChanged: (value) => onChanged('state', value),
            ),
          ),
          const SizedBox(height: 12),
          _TwoFields(
            left: _Field(
              label: 'PIN Code *',
              value: profileData['pinCode'] ?? '',
              enabled: isEditing,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              errorText: fieldErrors['pinCode'],
              onChanged: (value) => onChanged('pinCode', value),
            ),
            right: _Field(
              label: 'Aadhaar Number',
              value: profileData['aadhaar'] ?? '',
              enabled: isEditing,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              errorText: fieldErrors['aadhaar'],
              onChanged: (value) => onChanged('aadhaar', value),
            ),
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'PAN Number',
            value: profileData['pan'] ?? '',
            enabled: isEditing,
            fixedWidthFraction: 0.5,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(10),
              UpperCaseTextFormatter(),
            ],
            errorText: fieldErrors['pan'],
            onChanged: (value) => onChanged('pan', value),
          ),
        ],
      ),
    );
  }
}

class _TwoFields extends StatelessWidget {
  const _TwoFields({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        if (isCompact) {
          return Column(
            children: [
              left,
              const SizedBox(height: 12),
              right,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.errorText,
    this.isDropdown = false,
    this.fixedWidthFraction,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isDropdown;
  final double? fixedWidthFraction;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: DashboardColors.text,
            fontSize: 34 / 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: errorText == null ? const Color(0x66E8A9B3) : const Color(0xFFB91C1C),
              width: 1.7,
            ),
          ),
          child: isDropdown
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.isEmpty ? null : value,
                    isExpanded: true,
                    hint: const Text(
                      'Select',
                      style: TextStyle(
                        color: Color(0xFF7C8CA3),
                        fontSize: 31 / 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    items: const ['Male', 'Female', 'Other']
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: enabled
                        ? (newValue) {
                            if (newValue != null) onChanged(newValue);
                          }
                        : null,
                  ),
                )
              : TextFormField(
                  initialValue: value,
                  enabled: enabled,
                  readOnly: readOnly,
                  onTap: onTap,
                  onChanged: onChanged,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '',
                  ),
                  style: const TextStyle(
                    color: Color(0xFF7C8CA3),
                    fontSize: 31 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB91C1C),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (fixedWidthFraction == null) return field;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        if (isCompact) return field;
        return SizedBox(
          width: constraints.maxWidth * fixedWidthFraction!,
          child: field,
        );
      },
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({
    required this.isMobile,
    required this.uploadedFiles,
    required this.onUploadTap,
  });

  final bool isMobile;
  final Map<String, String> uploadedFiles;
  final void Function(String documentTitle) onUploadTap;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Documents', icon: Icons.description_outlined),
          const SizedBox(height: 2),
          const Text(
            'Upload required documents',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 28 / 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ..._MyProfileBody.docs.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DocumentItem(
                title: doc.$1,
                kind: doc.$2,
                uploadedFileName: uploadedFiles[doc.$1],
                onUploadTap: () => onUploadTap(doc.$1),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x66E8A9B3), width: 1.6),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Guidelines',
                  style: TextStyle(
                    color: DashboardColors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '- File format: PDF, JPG, PNG\n- Max size: 5MB per file\n- Ensure documents are clear and readable',
                  style: TextStyle(
                    color: DashboardColors.text,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (isMobile) const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  const _DocumentItem({
    required this.title,
    required this.kind,
    required this.onUploadTap,
    this.uploadedFileName,
  });

  final String title;
  final String kind;
  final VoidCallback onUploadTap;
  final String? uploadedFileName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x66E8A9B3), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 18 / 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            kind,
            style: const TextStyle(
              color: DashboardColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (uploadedFileName != null) ...[
            const SizedBox(height: 6),
            Text(
              'Uploaded: $uploadedFileName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0F9F6E),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onUploadTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x66E8A9B3), width: 1.5),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        uploadedFileName == null ? Icons.upload_outlined : Icons.check_circle_outline_rounded,
                        color: DashboardColors.text,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        uploadedFileName == null ? 'Upload' : 'Replace File',
                        style: const TextStyle(
                          color: DashboardColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 17 / 1.2,
                        ),
                      ),
                    ],
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

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 120,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2552C2), Color(0xFF2D65D7)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A4A81A6),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CancelEditButton extends StatelessWidget {
  const _CancelEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        'Cancel',
        style: TextStyle(
          color: DashboardColors.red,
          fontWeight: FontWeight.w700,
        ),
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

