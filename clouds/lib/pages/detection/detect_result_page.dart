import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clouds/widgets/detect_result/detect_result_image.dart';
import 'package:clouds/widgets/detect_result/detect_result_list.dart';
import '../../services/detect_result_service.dart';
import '../../theme/app_colors.dart';

class DetectResultPage extends StatefulWidget {
  final Map<String, dynamic> resultData;
  final bool isFromTFLite;

  const DetectResultPage({
    super.key,
    required this.resultData,
    this.isFromTFLite = false,
  });

  @override
  State<DetectResultPage> createState() => _DetectResultPageState();
}

class _DetectResultPageState extends State<DetectResultPage>
    with TickerProviderStateMixin {
  final TextEditingController _reportController = TextEditingController();
  bool _isSaving = false;
  bool _isReporting = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _reportController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _showReportDialog() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _reportController.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.report_problem_rounded,
                            color: AppColors.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รายงานปัญหา',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'ช่วยเราปรับปรุงระบบให้ดีขึ้น',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 12,
                                  color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                        ),
                      ),
                      child: TextField(
                        controller: _reportController,
                        maxLines: 4,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'กรุณาอธิบายปัญหาที่พบ เช่น ผลการตรวจจับไม่ถูกต้อง หรือ มีข้อผิดพลาดอื่นๆ',
                          hintStyle: GoogleFonts.notoSansThai(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white38 : AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _isReporting
                                ? null
                                : () => Navigator.pop(dialogContext),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'ยกเลิก',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _isReporting
                                ? null
                                : () async {
                                    final reportText =
                                        _reportController.text.trim();
                                    if (reportText.isEmpty) {
                                      ScaffoldMessenger.of(dialogContext)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'กรุณากรอกรายละเอียดก่อนส่ง',
                                            style: GoogleFonts.notoSansThai(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: AppColors.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => _isReporting = true);

                                    try {
                                      await DetectResultService.sendFeedback(
                                        dialogContext,
                                        widget.resultData,
                                        widget.isFromTFLite,
                                        reportText,
                                      );

                                      setState(() => _isReporting = false);
                                      if (!mounted) return;

                                      Navigator.pop(dialogContext);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                'ส่งรายงานปัญหาสำเร็จ',
                                                style: GoogleFonts.notoSansThai(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: AppColors.mintGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() => _isReporting = false);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'เกิดข้อผิดพลาดในการส่งรายงาน: $e',
                                              style: GoogleFonts.notoSansThai(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: AppColors.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: isDarkMode 
                                  ? LinearGradient(
                                      colors: [AppColors.darkPrimary, AppColors.darkAccent],
                                    )
                                  : AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isReporting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'ส่งรายงาน',
                                        style: GoogleFonts.notoSansThai(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveToHistory() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      await DetectResultService.saveToHistory(
        context,
        widget.resultData,
        widget.isFromTFLite,
      );

      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'บันทึกลงในประวัติเรียบร้อย',
                  style: GoogleFonts.notoSansThai(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.mintGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาดในการบันทึก: $e',
              style: GoogleFonts.notoSansThai(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final imageBytes = DetectResultService.decodeImage(
      widget.resultData,
      widget.isFromTFLite,
    );
    final detections = DetectResultService.getDetections(widget.resultData);
    
    // เพิ่ม debug log ตรงนี้
    debugPrint("🔍 DetectResultPage build:");
    debugPrint("   - isFromTFLite: ${widget.isFromTFLite}");
    debugPrint("   - imageBytes: ${imageBytes != null ? 'Available (${imageBytes.length} bytes)' : 'NULL'}");
    debugPrint("   - detections count: ${detections.length}");
    for (var i = 0; i < detections.length; i++) {
      debugPrint("   - Detection $i: ${detections[i]}");
    }
    
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : AppColors.borderLight,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'ผลการตรวจจับเมฆ',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Image Section
                if (imageBytes != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDarkMode
                                    ? [
                                        AppColors.darkPrimary.withOpacity(0.3),
                                        AppColors.darkAccent.withOpacity(0.2),
                                      ]
                                    : [
                                        AppColors.primary.withOpacity(0.1),
                                        AppColors.accent.withOpacity(0.05),
                                      ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ภาพที่ถ่าย',
                                          style: GoogleFonts.notoSansThai(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'แตะเพื่อดูรายละเอียด',
                                          style: GoogleFonts.notoSansThai(
                                            fontSize: 12,
                                            color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Image
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: DetectResultImage(
                                imageBytes: imageBytes,
                                detections: detections,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Detection Results Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDarkMode
                                  ? [
                                      AppColors.mintGreen.withOpacity(0.3),
                                      AppColors.sunYellow.withOpacity(0.2),
                                    ]
                                  : [
                                      AppColors.mintGreen.withOpacity(0.1),
                                      AppColors.sunYellow.withOpacity(0.05),
                                    ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.mintGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.analytics_rounded,
                                    color: AppColors.mintGreen,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'รายละเอียดการตรวจจับ',
                                        style: GoogleFonts.notoSansThai(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'ประเภทเมฆที่ตรวจพบ',
                                        style: GoogleFonts.notoSansThai(
                                          fontSize: 12,
                                          color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.mintGreen.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${detections.length} ชนิด',
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.mintGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Results List
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: DetectResultList(detections: detections),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Action Buttons Section
                if (user != null && !user.isAnonymous)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Column(
                        children: [
                          // Save Button
                          GestureDetector(
                            onTap: _isSaving ? null : _saveToHistory,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: _isSaving
                                    ? LinearGradient(
                                        colors: [Colors.grey, Colors.grey])
                                    : isDarkMode 
                                      ? LinearGradient(
                                          colors: [AppColors.darkPrimary, AppColors.darkAccent],
                                        )
                                      : AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _isSaving
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary)
                                              .withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.bookmark_add_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'บันทึกผลการตรวจจับ',
                                            style: GoogleFonts.notoSansThai(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Report Button
                          GestureDetector(
                            onTap: _isReporting ? null : _showReportDialog,
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.report_problem_outlined,
                                      color: AppColors.error,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'รายงานปัญหาผลลัพธ์',
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              size: 48,
                              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'เข้าสู่ระบบเพื่อใช้งานเพิ่มเติม',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'บันทึกผลการตรวจจับและส่งรายงานปัญหา',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
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