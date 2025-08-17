import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class DetectionHistoryPage extends StatefulWidget {
  const DetectionHistoryPage({super.key});

  @override
  State<DetectionHistoryPage> createState() => _DetectionHistoryPageState();
}

class _DetectionHistoryPageState extends State<DetectionHistoryPage>
    with TickerProviderStateMixin {
  final selectedIds = <String>{};
  bool _isEditing = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String translateLabel(String label) {
    const translations = {
      'Cumulus': 'คิวมูลัส',
      'Cirrus': 'เซอร์รัส',
      'Stratus': 'สเตรตัส',
      'Nimbus': 'นิมบัส',
      'Altocumulus': 'แอลโตคิวมูลัส',
      'Altostratus': 'แอลโตสเตรตัส',
      'Cirrostratus': 'เซอร์โรสเตรตัส',
      'Cirrocumulus': 'เซอร์โรคิวมูลัส',
      'Nimbostratus': 'นิมโบสเตรตัส',
      'Cumulonimbus': 'คิวมูโลนิมบัส',
    };
    return translations[label] ?? label;
  }
  
  Color getCloudColor(String label) {
    const colors = {
      'Cumulus': Color(0xFF4CAF50),
      'Cirrus': Color(0xFF2196F3),
      'Stratus': Color(0xFF757575),
      'Nimbus': Color(0xFF424242),
      'Altocumulus': Color(0xFF9C27B0),
      'Altostratus': Color(0xFF673AB7),
      'Cirrostratus': Color(0xFF3F51B5),
      'Cirrocumulus': Color(0xFF00BCD4),
      'Nimbostratus': Color(0xFF607D8B),
      'Cumulonimbus': Color(0xFFFF5722),
    };
    return colors[label] ?? AppColors.primary;
  }

  IconData getCloudIcon(String label) {
    const icons = {
      'Cumulus': Icons.cloud_outlined,
      'Cirrus': Icons.air,
      'Stratus': Icons.layers,
      'Nimbus': Icons.water_drop,
      'Altocumulus': Icons.filter_drama,
      'Altostratus': Icons.blur_on,
      'Cirrostratus': Icons.gradient,
      'Cirrocumulus': Icons.grain,
      'Nimbostratus': Icons.opacity,
      'Cumulonimbus': Icons.bolt,
    };
    return icons[label] ?? Icons.cloud_queue;
  }

  Map<String, dynamic> getUniqueDetections(List<dynamic> detections) {
    final uniqueClasses = <String>{};
    final classConfidenceMap = <String, double>{};
    final uniqueDetections = <Map<String, dynamic>>[];
    
    for (var detection in detections) {
      if (detection is Map<String, dynamic>) {
        final cloudClass = detection['class'] as String?;
        final confidence = detection['confidence'] as double?;
        
        if (cloudClass != null && !uniqueClasses.contains(cloudClass)) {
          uniqueClasses.add(cloudClass);
          uniqueDetections.add(detection);
          
          if (confidence != null) {
            // Keep the highest confidence for each class
            final currentConfidence = classConfidenceMap[cloudClass] ?? 0.0;
            if (confidence > currentConfidence) {
              classConfidenceMap[cloudClass] = confidence;
            }
          }
        }
      }
    }
    
    return {
      'detections': uniqueDetections,
      'confidenceMap': classConfidenceMap,
    };
  }

  Future<void> _deleteSelectedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || selectedIds.isEmpty) return;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'ยืนยันการลบ',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Text(
          'คุณต้องการลบ ${selectedIds.length} รายการที่เลือกหรือไม่?',
          style: GoogleFonts.notoSansThai(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.notoSansThai(
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'ลบ',
              style: GoogleFonts.notoSansThai(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (var id in selectedIds) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('history')
              .doc(id)
              .delete();
        }

        setState(() {
          selectedIds.clear();
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ลบรายการที่เลือกเรียบร้อยแล้ว',
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เกิดข้อผิดพลาดในการลบ',
              style: GoogleFonts.notoSansThai(),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _toggleSelection(String docId) {
    setState(() {
      if (selectedIds.contains(docId)) {
        selectedIds.remove(docId);
      } else {
        selectedIds.add(docId);
      }
    });
  }

  void _showDetailsDialog(BuildContext context, List<dynamic> detections,
      String formattedDate, Uint8List? imageBytes) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get unique detections for dialog
    final uniqueData = getUniqueDetections(detections);
    final uniqueDetections = uniqueData['detections'] as List<Map<String, dynamic>>;
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDarkMode 
                      ? LinearGradient(
                          colors: [AppColors.darkPrimary, AppColors.darkAccent],
                        )
                      : AppColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cloud_queue_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รายละเอียดผลตรวจจับ',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'วันที่: $formattedDate',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Preview
                      if (imageBytes != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              imageBytes,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Detections
                      Text(
                        'ผลการตรวจจับ',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (uniqueDetections.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.white.withOpacity(0.05) 
                                : AppColors.bgGray,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ไม่มีข้อมูลผลการตรวจจับ',
                                style: GoogleFonts.notoSansThai(
                                  color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...uniqueDetections.map((d) {
                          final label = translateLabel(d['class'] ?? 'ไม่ระบุ');
                          final confidence = d['confidence'];
                          final confText = confidence != null
                              ? '${(confidence * 100).toStringAsFixed(1)}%'
                              : 'ไม่ระบุ';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? AppColors.darkPrimary.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode 
                                    ? AppColors.darkPrimary.withOpacity(0.3)
                                    : AppColors.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    label,
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    confText,
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? AppColors.darkPrimary.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 60,
                  color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'กรุณาเข้าสู่ระบบ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'เพื่อดูประวัติการตรวจจับเมฆ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final historyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
        foregroundColor: isDarkMode ? Colors.white : AppColors.textPrimary,
        title: Text(
          'ประวัติการตรวจจับเมฆ',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [
          if (_isEditing && selectedIds.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                onPressed: _deleteSelectedItems,
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isEditing
                      ? AppColors.success.withOpacity(0.1)
                      : (isDarkMode 
                          ? AppColors.darkPrimary.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  color: _isEditing 
                      ? AppColors.success 
                      : (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                  size: 20,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    selectedIds.clear();
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: StreamBuilder<QuerySnapshot>(
          stream: historyRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'เกิดข้อผิดพลาดในการโหลดข้อมูล',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                            isDarkMode ? AppColors.darkPrimary : AppColors.primary
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'กำลังโหลดข้อมูล...',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? AppColors.darkPrimary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        size: 60,
                        color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'ยังไม่มีประวัติการตรวจจับ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'เริ่มถ่ายรูปเมฆเพื่อสร้างประวัติ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group by date
            final Map<String, List<QueryDocumentSnapshot>> grouped = {};
            for (var doc in docs) {
              final timestamp = (doc['timestamp'] as Timestamp).toDate();
              final key =
                  '${timestamp.day}/${timestamp.month}/${timestamp.year}';
              grouped.putIfAbsent(key, () => []).add(doc);
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? AppColors.darkPrimary.withOpacity(0.2)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${docs.length} รายการ',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 12,
                              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (_isEditing && selectedIds.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? AppColors.darkAccent.withOpacity(0.2)
                                  : AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'เลือก ${selectedIds.length} รายการ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 12,
                                color: isDarkMode ? AppColors.darkAccent : AppColors.accent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = grouped.entries.elementAt(index);
                      final date = entry.key;
                      final entries = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'วันที่ $date',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode 
                                        ? AppColors.darkPrimary.withOpacity(0.2)
                                        : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${entries.length}',
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 12,
                                      color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // History Items
                          ...entries.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final docId = doc.id;

                            Uint8List? imageBytes;
                            try {
                              final base64Str =
                                  data['image'] ?? data['image_base64'];
                              if (base64Str != null) {
                                imageBytes = base64Decode(base64Str);
                              }
                            } catch (_) {}

                            final detections =
                                (data['detections'] as List?) ?? [];

                            // Get unique detections using the helper method
                            final uniqueData = getUniqueDetections(detections);
                            final uniqueDetections = uniqueData['detections'] as List<Map<String, dynamic>>;
                            
                            // Create label text from unique classes only
                            final labelText = uniqueDetections.isNotEmpty
                                ? uniqueDetections
                                    .map((d) => translateLabel(d['class'] ?? ''))
                                    .join(', ')
                                : 'ไม่พบคลาสของเมฆ';

                            // Create confidence text from unique classes only
                            final confidenceText = uniqueDetections.isNotEmpty
                                ? uniqueDetections
                                    .where((d) => d['confidence'] != null)
                                    .map((d) => '${(d['confidence'] * 100).toStringAsFixed(1)}%')
                                    .join(', ')
                                : 'ไม่มีข้อมูล';

                            return Container(
                              margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      _isEditing && selectedIds.contains(docId)
                                          ? (isDarkMode ? AppColors.darkPrimary : AppColors.primary)
                                          : (isDarkMode ? Colors.white10 : AppColors.borderLight),
                                  width:
                                      _isEditing && selectedIds.contains(docId)
                                          ? 2
                                          : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode 
                                        ? Colors.black.withOpacity(0.2)
                                        : AppColors.primary.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _showDetailsDialog(
                                      context, detections, date, imageBytes),
                                  onLongPress: () {
                                    if (!_isEditing) {
                                      setState(() {
                                        _isEditing = true;
                                        selectedIds.add(docId);
                                      });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Image
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: imageBytes != null
                                                ? Image.memory(
                                                    imageBytes,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    color: isDarkMode 
                                                        ? Colors.white.withOpacity(0.05)
                                                        : AppColors.bgGray,
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_rounded,
                                                      color: isDarkMode 
                                                          ? Colors.white38
                                                          : AppColors.textMuted,
                                                      size: 24,
                                                    ),
                                                  ),
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                labelText,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.notoSansThai(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.show_chart_rounded,
                                                    size: 14,
                                                    color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'ความมั่นใจ: $confidenceText',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .notoSansThai(
                                                        fontSize: 12,
                                                        color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Selection checkbox or arrow
                                        if (_isEditing)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            child: Checkbox(
                                              value:
                                                  selectedIds.contains(docId),
                                              onChanged: (_) =>
                                                  _toggleSelection(docId),
                                              activeColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isDarkMode 
                                                  ? AppColors.darkPrimary.withOpacity(0.2)
                                                  : AppColors.primary.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 12,
                                              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}