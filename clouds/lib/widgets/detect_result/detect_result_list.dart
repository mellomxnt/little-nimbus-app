import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/cloud_learning/cloud_detail_page.dart';
import '../../theme/app_colors.dart';

class DetectResultList extends StatelessWidget {
  final List<Map<String, dynamic>> detections;

  const DetectResultList({super.key, required this.detections});

  // DailyBean color palette for cloud types
  final Map<String, Color> cloudColors = const {
    'altocumulus': AppColors.lavender,
    'altostratus': AppColors.primaryDark,
    'cirrocumulus': AppColors.mintGreen,
    'cirrostratus': AppColors.sunYellow,
    'cirrus': AppColors.accent,
    'cumulonimbus': AppColors.error,
    'cumulus': AppColors.primary,
    'nimbostratus': AppColors.textSecondary,
    'stratocumulus': AppColors.peach,
    'stratus': AppColors.accentDark,
  };

  final Map<String, IconData> cloudIcons = const {
    'altocumulus': Icons.filter_drama,
    'altostratus': Icons.horizontal_split,
    'cirrocumulus': Icons.grain,
    'cirrostratus': Icons.blur_on,
    'cirrus': Icons.air,
    'cumulonimbus': Icons.thunderstorm,
    'cumulus': Icons.cloud,
    'nimbostratus': Icons.water_drop,
    'stratocumulus': Icons.dashboard,
    'stratus': Icons.layers,
  };


  void _navigateToDetail(BuildContext context, String cloudName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CloudDetailPage(cloudName: cloudName.toLowerCase()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (detections.isEmpty) {
      return _buildEmptyState();
    }

    // Group and calculate average confidence
    final Map<String, List<double>> grouped = {};
    for (var d in detections) {
      final name = d['class']?.toString() ?? 'Unknown';
      final confidence = (d['confidence'] as num?)?.toDouble() ?? 0.0;
      grouped.putIfAbsent(name, () => []).add(confidence);
    }

    final List<Map<String, dynamic>> uniqueDetections = grouped.entries.map((entry) {
      final avgConfidence = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final count = entry.value.length;
      return {
        'class': entry.key,
        'confidence': avgConfidence,
        'count': count,
      };
    }).toList()
      ..sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats summary
        _buildStatsSummary(uniqueDetections),
        const SizedBox(height: 20),
        
        // Detection cards
        ...uniqueDetections.asMap().entries.map((entry) {
          final index = entry.key;
          final detection = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < uniqueDetections.length - 1 ? 12 : 0,
            ),
            child: _buildDetectionCard(
              context,
              detection,
              index,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบเมฆในภาพ',
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองถ่ายภาพใหม่อีกครั้ง',
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(List<Map<String, dynamic>> detections) {
    final totalCount = detections.fold<int>(
      0,
      (sum, d) => sum + (d['count'] as int),
    );
    
    final highestConfidence = detections.isNotEmpty
        ? detections.first['confidence'] as double
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.3),
            AppColors.accent.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Total detections
          Expanded(
            child: _buildStatItem(
              icon: Icons.cloud,
              label: 'ตรวจพบ',
              value: '$totalCount',
              unit: 'จุด',
              color: AppColors.primary,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderLight,
          ),
          
          // Cloud types
          Expanded(
            child: _buildStatItem(
              icon: Icons.category_rounded,
              label: 'ประเภท',
              value: '${detections.length}',
              unit: 'ชนิด',
              color: AppColors.accent,
            ),
          ),
          
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderLight,
          ),
          
          // Highest confidence
          Expanded(
            child: _buildStatItem(
              icon: Icons.analytics_rounded,
              label: 'ความมั่นใจ',
              value: '${(highestConfidence * 100).toStringAsFixed(0)}',
              unit: '%',
              color: AppColors.mintGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.notoSansThai(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: GoogleFonts.notoSansThai(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetectionCard(
    BuildContext context,
    Map<String, dynamic> detection,
    int index,
  ) {
    final name = detection['class'] ?? 'Unknown';
    final confidence = (detection['confidence'] as double?) ?? 0.0;
    final count = detection['count'] ?? 1;
    
    final color = cloudColors[name.toLowerCase()] ?? AppColors.primary;
    final icon = cloudIcons[name.toLowerCase()] ?? Icons.cloud_outlined;

    // Confidence level
    String confidenceLevel;
    Color confidenceColor;
    IconData confidenceIcon;
    
    if (confidence > 0.8) {
      confidenceLevel = 'สูงมาก';
      confidenceColor = AppColors.mintGreen;
      confidenceIcon = Icons.verified_rounded;
    } else if (confidence > 0.6) {
      confidenceLevel = 'สูง';
      confidenceColor = AppColors.success;
      confidenceIcon = Icons.check_circle_outline_rounded;
    } else if (confidence > 0.4) {
      confidenceLevel = 'ปานกลาง';
      confidenceColor = AppColors.sunYellow;
      confidenceIcon = Icons.info_outline_rounded;
    } else {
      confidenceLevel = 'ต่ำ';
      confidenceColor = AppColors.textMuted;
      confidenceIcon = Icons.help_outline_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: name != 'Unknown' ? () => _navigateToDetail(context, name) : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (count > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x$count',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          confidenceIcon,
                          size: 14,
                          color: confidenceColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ความมั่นใจ: ',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(confidence * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: confidenceColor,
                          ),
                        ),
                       /* Text(
                          ' ($confidenceLevel)',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action
              if (name != 'Unknown')
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}