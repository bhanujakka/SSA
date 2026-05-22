import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class TeachingRegisterPage extends StatefulWidget {
  const TeachingRegisterPage({super.key});

  @override
  State<TeachingRegisterPage> createState() => _TeachingRegisterPageState();
}

class _TeachingRegisterPageState extends State<TeachingRegisterPage> {
  DateTime _selectedDate = DateTime.now();
  List<PlatformFile> _files = [];

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

  Future<void> _pickPhotos() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      setState(() => _files = result.files);
    }
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
                    activeItem: 'Teaching Register',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(
                    activeItem: 'Teaching Register',
                  ),
                Expanded(
                  child: _TeachingRegisterBody(
                    isMobile: isMobile,
                    selectedDate: _dateLabel(_selectedDate),
                    files: _files,
                    onPickDate: _pickDate,
                    onPickPhotos: _pickPhotos,
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

class _TeachingRegisterBody extends StatelessWidget {
  const _TeachingRegisterBody({
    required this.isMobile,
    required this.selectedDate,
    required this.files,
    required this.onPickDate,
    required this.onPickPhotos,
  });

  final bool isMobile;
  final String selectedDate;
  final List<PlatformFile> files;
  final VoidCallback onPickDate;
  final VoidCallback onPickPhotos;

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
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teaching Daily Register',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: isMobile ? 28 : 32,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload daily teaching register photos',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isMobile ? 16 : 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 30),
                        _RegisterUploadCard(
                          isMobile: isMobile,
                          selectedDate: selectedDate,
                          files: files,
                          onPickDate: onPickDate,
                          onPickPhotos: onPickPhotos,
                        ),
                        const SizedBox(height: 26),
                        const _GuidelinesCard(),
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

class _RegisterUploadCard extends StatelessWidget {
  const _RegisterUploadCard({
    required this.isMobile,
    required this.selectedDate,
    required this.files,
    required this.onPickDate,
    required this.onPickPhotos,
  });

  final bool isMobile;
  final String selectedDate;
  final List<PlatformFile> files;
  final VoidCallback onPickDate;
  final VoidCallback onPickPhotos;

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
          _CardHeader(isMobile: isMobile),
          SizedBox(height: isMobile ? 26 : 30),
          const Text(
            'Select Date',
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
          _DashedUploadBox(
            isMobile: isMobile,
            files: files,
            onPickPhotos: onPickPhotos,
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.isMobile});

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
            Icons.fact_check_outlined,
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
                'Daily Register Upload',
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: isMobile ? 20 : 23,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Upload photos of teaching register',
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

class _DashedUploadBox extends StatelessWidget {
  const _DashedUploadBox({
    required this.isMobile,
    required this.files,
    required this.onPickPhotos,
  });

  final bool isMobile;
  final List<PlatformFile> files;
  final VoidCallback onPickPhotos;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFB9C7EF),
        radius: 18,
      ),
      child: InkWell(
        onTap: onPickPhotos,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isMobile ? 300 : 360),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 30,
            vertical: isMobile ? 34 : 56,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.upload_rounded,
                color: Color(0xFF244CC8),
                size: 82,
              ),
              const SizedBox(height: 22),
              Text(
                'Upload Register Photos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: isMobile ? 22 : 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                files.isEmpty
                    ? 'Click to select multiple photos'
                    : '${files.length} photo${files.length == 1 ? '' : 's'} selected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (files.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  files.take(3).map((file) => file.name).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onPickPhotos,
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
                child: const Text(
                  'Choose Photos',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuidelinesCard extends StatelessWidget {
  const _GuidelinesCard();

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
            'Upload Guidelines',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 20),
          _GuidelineText(
            'Upload clear, readable photos of your daily teaching register',
          ),
          SizedBox(height: 12),
          _GuidelineText(
            'Ensure all entries for the day are visible in the photos',
          ),
          SizedBox(height: 12),
          _GuidelineText(
            'You can upload multiple photos if the register has multiple pages',
          ),
        ],
      ),
    );
  }
}

class _GuidelineText extends StatelessWidget {
  const _GuidelineText(this.text);

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

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
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
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
