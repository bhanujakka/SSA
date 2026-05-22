import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class ParentTeacherMeetingPage extends StatefulWidget {
  const ParentTeacherMeetingPage({super.key});

  @override
  State<ParentTeacherMeetingPage> createState() =>
      _ParentTeacherMeetingPageState();
}

class _ParentTeacherMeetingPageState extends State<ParentTeacherMeetingPage> {
  DateTime _selectedDate = DateTime.now();
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(_selectedDate.year - 2),
      lastDate: DateTime(_selectedDate.year + 2),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls', 'csv'],
      withData: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _submitMeetingRecord() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose an Excel file before submitting.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Meeting record ready: ${_selectedFile!.name} for ${_dateLabel(_selectedDate)}.',
        ),
        backgroundColor: const Color(0xFF1E4ED8),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}-${twoDigits(date.month)}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 980;

        return Scaffold(
          backgroundColor: DashboardColors.surface,
          drawer: isMobile
              ? const Drawer(
                  child: DashboardSidebar(
                    activeItem: 'Parent Teacher Meeting',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(
                    activeItem: 'Parent Teacher Meeting',
                  ),
                Expanded(
                  child: _ParentTeacherMeetingBody(
                    isMobile: isMobile,
                    selectedDate: _dateLabel(_selectedDate),
                    selectedFile: _selectedFile,
                    isSubmitting: _isSubmitting,
                    onPickDate: _pickDate,
                    onPickExcelFile: _pickExcelFile,
                    onSubmit: _submitMeetingRecord,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParentTeacherMeetingBody extends StatelessWidget {
  const _ParentTeacherMeetingBody({
    required this.isMobile,
    required this.selectedDate,
    required this.selectedFile,
    required this.isSubmitting,
    required this.onPickDate,
    required this.onPickExcelFile,
    required this.onSubmit,
  });

  final bool isMobile;
  final String selectedDate;
  final PlatformFile? selectedFile;
  final bool isSubmitting;
  final VoidCallback onPickDate;
  final VoidCallback onPickExcelFile;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            DashboardTopBar(isMobile: isMobile),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32,
                  isMobile ? 26 : 36,
                  isMobile ? 16 : 32,
                  32,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parent Teacher Monitoring',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: isMobile ? 28 : 32,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload parent-teacher interaction records',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isMobile ? 16 : 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 30),
                        _MeetingUploadCard(
                          isMobile: isMobile,
                          selectedDate: selectedDate,
                          selectedFile: selectedFile,
                          isSubmitting: isSubmitting,
                          onPickDate: onPickDate,
                          onPickExcelFile: onPickExcelFile,
                          onSubmit: onSubmit,
                        ),
                        const SizedBox(height: 26),
                        const _ExcelFormatCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          right: isMobile ? 18 : 28,
          bottom: isMobile ? 18 : 30,
          child: DashboardQuickActionsFab(size: isMobile ? 58 : 70),
        ),
      ],
    );
  }
}

class _MeetingUploadCard extends StatelessWidget {
  const _MeetingUploadCard({
    required this.isMobile,
    required this.selectedDate,
    required this.selectedFile,
    required this.isSubmitting,
    required this.onPickDate,
    required this.onPickExcelFile,
    required this.onSubmit,
  });

  final bool isMobile;
  final String selectedDate;
  final PlatformFile? selectedFile;
  final bool isSubmitting;
  final VoidCallback onPickDate;
  final VoidCallback onPickExcelFile;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD0DAF2), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F172A),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MeetingCardHeader(isMobile: isMobile),
          SizedBox(height: isMobile ? 26 : 30),
          const Text(
            'Meeting Date',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD0DAF2), width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate,
                      style: const TextStyle(
                        color: DashboardColors.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.black,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          _ExcelUploadZone(
            isMobile: isMobile,
            selectedFile: selectedFile,
            onPickExcelFile: onPickExcelFile,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.end,
            children: [
              if (selectedFile != null)
                OutlinedButton.icon(
                  onPressed: onPickExcelFile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E40AF),
                    side: const BorderSide(color: Color(0xFFB9C7EF)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Replace File',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shadowColor: const Color(0x552552C2),
                  backgroundColor: const Color(0xFF2D65D7),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF98AEDF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  isSubmitting ? 'Uploading...' : 'Upload Records',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeetingCardHeader extends StatelessWidget {
  const _MeetingCardHeader({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isMobile ? 60 : 72,
          height: isMobile ? 60 : 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF244CC8), Color(0xFF3485F5)],
            ),
          ),
          child: const Icon(
            Icons.groups_2_outlined,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meeting Records Upload',
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: isMobile ? 20 : 23,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload Excel sheet with interaction details',
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: isMobile ? 15 : 17,
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

class _ExcelUploadZone extends StatelessWidget {
  const _ExcelUploadZone({
    required this.isMobile,
    required this.selectedFile,
    required this.onPickExcelFile,
  });

  final bool isMobile;
  final PlatformFile? selectedFile;
  final VoidCallback onPickExcelFile;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MeetingDashedBorderPainter(
        color: const Color(0xFFB9C7EF),
        radius: 18,
      ),
      child: InkWell(
        onTap: onPickExcelFile,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isMobile ? 280 : 340),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 30,
            vertical: isMobile ? 32 : 52,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.file_upload_outlined,
                color: Color(0xFF244CC8),
                size: 82,
              ),
              const SizedBox(height: 22),
              Text(
                selectedFile == null ? 'Upload Excel Sheet' : 'File Selected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: isMobile ? 22 : 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedFile == null
                    ? 'Upload parent-teacher meeting records'
                    : selectedFile!.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (selectedFile?.size != null && selectedFile!.size > 0) ...[
                const SizedBox(height: 8),
                Text(
                  _formatFileSize(selectedFile!.size),
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onPickExcelFile,
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shadowColor: const Color(0x552552C2),
                  backgroundColor: const Color(0xFF2D65D7),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 34,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  selectedFile == null ? 'Choose File' : 'Choose Another File',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _ExcelFormatCard extends StatelessWidget {
  const _ExcelFormatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E7F3), width: 1.5),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Excel Sheet Format',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'The Excel sheet should contain the following columns:',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14),
          _MeetingGuidelineText(
            'Student Name, Class, Parent Name, Meeting Date, Discussion Points, Action Items, Follow-up Required',
          ),
          SizedBox(height: 12),
          _MeetingGuidelineText(
            'Supported formats: .xlsx, .xls, .csv',
          ),
        ],
      ),
    );
  }
}

class _MeetingGuidelineText extends StatelessWidget {
  const _MeetingGuidelineText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Icon(Icons.circle, color: Color(0xFF244CC8), size: 7),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MeetingDashedBorderPainter extends CustomPainter {
  const _MeetingDashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dashWidth = 8.0;
      const dashSpace = 7.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MeetingDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
