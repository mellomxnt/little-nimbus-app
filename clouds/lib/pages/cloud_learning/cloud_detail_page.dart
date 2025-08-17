import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/cloud_database.dart';
import '../../models/cloud_info.dart';
import '../../theme/app_colors.dart';

class CloudDetailPage extends StatefulWidget {
  final String cloudName;

  const CloudDetailPage({Key? key, required this.cloudName}) : super(key: key);

  @override
  _CloudDetailPageState createState() => _CloudDetailPageState();
}

class _CloudDetailPageState extends State<CloudDetailPage> with TickerProviderStateMixin {
  String description = '';
  String formation = '';
  String atmosphericLayer = '';
  String cause = '';
  String weatherImpact = '';
  String imageUrl = '';
  bool isLoading = true;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
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
    
    fetchCloudDetails(widget.cloudName);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> fetchCloudDetails(String cloudName) async {
    try {
      final cloud = await CloudDatabase.instance.getCloudByName(cloudName);
      if (cloud == null) {
        setState(() {
          description = 'ไม่พบข้อมูลเมฆชนิดนี้';
          isLoading = false;
        });
      } else {
        setState(() {
          description = cloud.description ?? 'ไม่มีคำอธิบาย';
          formation = cloud.formation ?? 'ไม่มีข้อมูล';
          atmosphericLayer = cloud.atmosphericLayer ?? 'ไม่มีข้อมูล';
          cause = cloud.cause ?? 'ไม่มีข้อมูล';
          weatherImpact = cloud.weatherImpact ?? 'ไม่มีข้อมูล';
          imageUrl = cloud.imageUrl ?? '';
          isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      setState(() {
        description = 'เกิดข้อผิดพลาดในการดึงข้อมูล';
        isLoading = false;
      });
    }
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
    required bool isDarkMode,
    int index = 0,
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDarkMode ? Colors.white10 : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            content,
                            style: GoogleFonts.notoSansThai(
                              fontSize: 13,
                              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFullImage(BuildContext context) {
    if (imageUrl.isEmpty) return;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FullImageView(
          imageUrl: imageUrl,
          cloudName: widget.cloudName,
        ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      body: isLoading
          ? _buildLoadingState(isDarkMode)
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(isDarkMode),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          icon: Icons.info_outline_rounded,
                          title: 'รายละเอียด',
                          content: description,
                          iconColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                          isDarkMode: isDarkMode,
                          index: 0,
                        ),
                        _buildInfoCard(
                          icon: Icons.cloud_queue_rounded,
                          title: 'การก่อตัว',
                          content: formation,
                          iconColor: isDarkMode ? AppColors.darkAccent : AppColors.accent,
                          isDarkMode: isDarkMode,
                          index: 1,
                        ),
                        _buildInfoCard(
                          icon: Icons.layers_rounded,
                          title: 'ชั้นบรรยากาศ',
                          content: atmosphericLayer,
                          iconColor: AppColors.mintGreen,
                          isDarkMode: isDarkMode,
                          index: 2,
                        ),
                        _buildInfoCard(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'สาเหตุการเกิด',
                          content: cause,
                          iconColor: AppColors.sunYellow,
                          isDarkMode: isDarkMode,
                          index: 3,
                        ),
                        _buildInfoCard(
                          icon: Icons.umbrella_rounded,
                          title: 'ผลต่อสภาพอากาศ',
                          content: weatherImpact,
                          iconColor: AppColors.lavender,
                          isDarkMode: isDarkMode,
                          index: 4,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(bool isDarkMode) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? AppColors.darkSurface.withOpacity(0.9)
              : AppColors.bgWhite.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? AppColors.darkSurface.withOpacity(0.9)
                : AppColors.bgWhite.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? Colors.white10 : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Text(
            widget.cloudName.toUpperCase(),
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _openFullImage(context),
              child: Hero(
                tag: 'cloud_${widget.cloudName}',
                child: imageUrl.isNotEmpty
                    ? Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDarkMode ? AppColors.darkSurface : AppColors.bgGray,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 64,
                                  color: isDarkMode ? Colors.white38 : AppColors.textMuted,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ไม่สามารถโหลดรูปได้',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.white38 : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        color: isDarkMode ? AppColors.darkSurface : AppColors.bgGray,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_outlined,
                              size: 64,
                              color: isDarkMode ? Colors.white38 : AppColors.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ไม่มีภาพประกอบ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 14,
                                color: isDarkMode ? Colors.white38 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
            // Tap to view indicator
            if (imageUrl.isNotEmpty)
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? AppColors.darkSurface.withOpacity(0.9)
                        : AppColors.bgWhite.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode ? Colors.white10 : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in_rounded,
                        size: 16,
                        color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                      const SizedBox(width: 4),
                      
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary)
                      .withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'กำลังโหลดข้อมูล...',
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Full Image View
class _FullImageView extends StatelessWidget {
  final String imageUrl;
  final String cloudName;

  const _FullImageView({
    required this.imageUrl,
    required this.cloudName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Image
            Center(
              child: Hero(
                tag: 'cloud_$cloudName',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // Cloud name
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cloudName.toUpperCase(),
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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