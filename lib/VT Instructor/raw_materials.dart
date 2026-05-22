import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'appbar.dart';
import 'dashboard_colors.dart';
import 'floating_quick_actions.dart';
import 'sidebar.dart';

class RawMaterialsPage extends StatefulWidget {
  const RawMaterialsPage({super.key});

  @override
  State<RawMaterialsPage> createState() => _RawMaterialsPageState();
}

class _RawMaterialsPageState extends State<RawMaterialsPage> {
  List<PlatformFile> _billFiles = const [];
  PlatformFile? _stockFile;
  DateTime _selectedMonth = DateTime.now();
  bool _isUploadingBills = false;
  bool _isUploadingStock = false;

  Future<void> _pickBillFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      withData: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _billFiles = result.files);
    }
  }

  Future<void> _pickStockFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls', 'csv'],
      withData: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _stockFile = result.files.single);
    }
  }

  Future<void> _pickMonth() async {
    final pickedYear = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(_selectedMonth.year - 3, 1),
      lastDate: DateTime(_selectedMonth.year + 3, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select stock month',
    );

    if (pickedYear != null) {
      setState(() {
        _selectedMonth = DateTime(pickedYear.year, pickedYear.month);
      });
    }
  }

  Future<void> _submitBills() async {
    if (_billFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose at least one bill, photo, or PDF file.'),
        ),
      );
      return;
    }

    setState(() => _isUploadingBills = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() => _isUploadingBills = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_billFiles.length} raw material file${_billFiles.length == 1 ? '' : 's'} prepared for upload.',
        ),
        backgroundColor: const Color(0xFF1E4ED8),
      ),
    );
  }

  Future<void> _submitStock() async {
    if (_stockFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a stock Excel sheet before uploading.'),
        ),
      );
      return;
    }

    setState(() => _isUploadingStock = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    setState(() => _isUploadingStock = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Stock update ready: ${_stockFile!.name} for ${_monthLabel(_selectedMonth)}.',
        ),
        backgroundColor: const Color(0xFF1E4ED8),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]}, ${date.year}';
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
                    activeItem: 'Raw Materials',
                    showCollapseButton: false,
                  ),
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  const DashboardSidebarHost(activeItem: 'Raw Materials'),
                Expanded(
                  child: _RawMaterialsBody(
                    isMobile: isMobile,
                    billFiles: _billFiles,
                    stockFile: _stockFile,
                    selectedMonth: _monthLabel(_selectedMonth),
                    isUploadingBills: _isUploadingBills,
                    isUploadingStock: _isUploadingStock,
                    onPickBillFiles: _pickBillFiles,
                    onPickStockFile: _pickStockFile,
                    onPickMonth: _pickMonth,
                    onSubmitBills: _submitBills,
                    onSubmitStock: _submitStock,
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

class _RawMaterialsBody extends StatelessWidget {
  const _RawMaterialsBody({
    required this.isMobile,
    required this.billFiles,
    required this.stockFile,
    required this.selectedMonth,
    required this.isUploadingBills,
    required this.isUploadingStock,
    required this.onPickBillFiles,
    required this.onPickStockFile,
    required this.onPickMonth,
    required this.onSubmitBills,
    required this.onSubmitStock,
  });

  final bool isMobile;
  final List<PlatformFile> billFiles;
  final PlatformFile? stockFile;
  final String selectedMonth;
  final bool isUploadingBills;
  final bool isUploadingStock;
  final VoidCallback onPickBillFiles;
  final VoidCallback onPickStockFile;
  final VoidCallback onPickMonth;
  final VoidCallback onSubmitBills;
  final VoidCallback onSubmitStock;

  @override
  Widget build(BuildContext context) {
    final shouldStackCards = MediaQuery.of(context).size.width < 1280;

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
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Raw Materials',
                          style: TextStyle(
                            color: DashboardColors.text,
                            fontSize: isMobile ? 28 : 32,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Upload bills, photos, and stock updates',
                          style: TextStyle(
                            color: const Color(0xFF6B7280),
                            fontSize: isMobile ? 16 : 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 30),
                        if (shouldStackCards)
                          Column(
                            children: [
                              _BillsUploadCard(
                                isMobile: isMobile,
                                billFiles: billFiles,
                                isUploading: isUploadingBills,
                                onPickFiles: onPickBillFiles,
                                onSubmit: onSubmitBills,
                              ),
                              const SizedBox(height: 22),
                              _StockUpdateCard(
                                isMobile: isMobile,
                                selectedMonth: selectedMonth,
                                stockFile: stockFile,
                                isUploading: isUploadingStock,
                                onPickMonth: onPickMonth,
                                onPickStockFile: onPickStockFile,
                                onSubmit: onSubmitStock,
                              ),
                            ],
                          )
                        else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _BillsUploadCard(
                                  isMobile: isMobile,
                                  billFiles: billFiles,
                                  isUploading: isUploadingBills,
                                  onPickFiles: onPickBillFiles,
                                  onSubmit: onSubmitBills,
                                ),
                              ),
                              const SizedBox(width: 28),
                              Expanded(
                                child: _StockUpdateCard(
                                  isMobile: isMobile,
                                  selectedMonth: selectedMonth,
                                  stockFile: stockFile,
                                  isUploading: isUploadingStock,
                                  onPickMonth: onPickMonth,
                                  onPickStockFile: onPickStockFile,
                                  onSubmit: onSubmitStock,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 26),
                        const _RawMaterialsInstructionsCard(),
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

class _BillsUploadCard extends StatelessWidget {
  const _BillsUploadCard({
    required this.isMobile,
    required this.billFiles,
    required this.isUploading,
    required this.onPickFiles,
    required this.onSubmit,
  });

  final bool isMobile;
  final List<PlatformFile> billFiles;
  final bool isUploading;
  final VoidCallback onPickFiles;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _RawCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RawCardHeader(
            isMobile: isMobile,
            icon: Icons.file_upload_outlined,
            title: 'Upload Bills & Photos',
            subtitle: 'Upload purchase bills and material photos',
          ),
          SizedBox(height: isMobile ? 24 : 28),
          _DashedUploadPanel(
            isMobile: isMobile,
            icon: Icons.upload_outlined,
            title: billFiles.isEmpty ? 'Click to upload files' : 'Files selected',
            subtitle: billFiles.isEmpty
                ? 'Support for multiple files (images, PDF)'
                : '${billFiles.length} file${billFiles.length == 1 ? '' : 's'} selected',
            buttonLabel: billFiles.isEmpty ? 'Choose Files' : 'Choose More Files',
            details: billFiles.take(3).map((file) => file.name).join(', '),
            onTap: onPickFiles,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isUploading ? null : onSubmit,
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
              icon: isUploading
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
                isUploading ? 'Uploading...' : 'Upload Bills',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StockUpdateCard extends StatelessWidget {
  const _StockUpdateCard({
    required this.isMobile,
    required this.selectedMonth,
    required this.stockFile,
    required this.isUploading,
    required this.onPickMonth,
    required this.onPickStockFile,
    required this.onSubmit,
  });

  final bool isMobile;
  final String selectedMonth;
  final PlatformFile? stockFile;
  final bool isUploading;
  final VoidCallback onPickMonth;
  final VoidCallback onPickStockFile;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return _RawCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RawCardHeader(
            isMobile: isMobile,
            icon: Icons.inventory_2_outlined,
            title: 'Monthly Stock Update',
            subtitle: 'Upload Excel sheet with stock details',
          ),
          SizedBox(height: isMobile ? 24 : 28),
          const Text(
            'Select Month',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onPickMonth,
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
                      selectedMonth,
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
          const SizedBox(height: 20),
          _DashedUploadPanel(
            isMobile: isMobile,
            icon: Icons.inventory_2_outlined,
            title: stockFile == null ? 'Upload Excel Sheet' : 'Stock file selected',
            subtitle: stockFile == null
                ? 'Present stock and last month stock details'
                : stockFile!.name,
            buttonLabel: stockFile == null ? 'Choose File' : 'Choose Another File',
            details: stockFile == null ? null : _formatFileSize(stockFile!.size),
            onTap: onPickStockFile,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isUploading ? null : onSubmit,
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
              icon: isUploading
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
                isUploading ? 'Uploading...' : 'Upload Stock',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _RawCardFrame extends StatelessWidget {
  const _RawCardFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
      child: child,
    );
  }
}

class _RawCardHeader extends StatelessWidget {
  const _RawCardHeader({
    required this.isMobile,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final bool isMobile;
  final IconData icon;
  final String title;
  final String subtitle;

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
          child: Icon(icon, color: Colors.white, size: 36),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: isMobile ? 20 : 23,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
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

class _DashedUploadPanel extends StatelessWidget {
  const _DashedUploadPanel({
    required this.isMobile,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    this.details,
  });

  final bool isMobile;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String? details;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RawDashedBorderPainter(
        color: const Color(0xFFB9C7EF),
        radius: 18,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: isMobile ? 250 : 300),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 30,
            vertical: isMobile ? 30 : 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF244CC8), size: 74),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: DashboardColors.text,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (details != null && details!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  details!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFE8EDFF),
                  foregroundColor: const Color(0xFF244CC8),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonLabel,
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
}

class _RawMaterialsInstructionsCard extends StatelessWidget {
  const _RawMaterialsInstructionsCard();

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
            'Upload Instructions',
            style: TextStyle(
              color: DashboardColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 20),
          _InstructionLine(
            'Upload all bills and photos related to raw material purchases',
          ),
          SizedBox(height: 12),
          _InstructionLine(
            'Excel sheet should contain: Material name, Present stock quantity, Last month stock quantity',
          ),
          SizedBox(height: 12),
          _InstructionLine(
            'Supported formats: Images (JPG, PNG), PDF for bills, Excel (.xlsx, .xls, .csv) for stock',
          ),
        ],
      ),
    );
  }
}

class _InstructionLine extends StatelessWidget {
  const _InstructionLine(this.text);

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

class _RawDashedBorderPainter extends CustomPainter {
  const _RawDashedBorderPainter({
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
  bool shouldRepaint(covariant _RawDashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
