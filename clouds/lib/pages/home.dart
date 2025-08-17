import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth/login_page.dart';
import 'cloud_learning/cloud_learning_page.dart';
import 'weather/weather_page.dart';
import 'detection/detect_cloud_tflite_page.dart';
import 'detection/realtime_detect_tflite_page.dart';
import 'detection/detection_history_page.dart';
import 'settings/credits_page.dart';
import 'settings/settings_page.dart';
import 'settings/help_page.dart';
import 'settings/profile_page.dart';

import '../widgets/cloud/cloud_carousel.dart';
import 'news/cloud_news_page.dart';

import '../theme/app_colors.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomePage({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      drawer: _buildDrawer(user, isDarkMode),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(user, isDarkMode),
                ),
                
                // Welcome Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _buildWelcomeCard(isDarkMode),
                  ),
                ),
                
                // Cloud Carousel Section
                SliverToBoxAdapter(
                  child: _buildCloudCarouselSection(isDarkMode),
                ),
                
                // Today's Weather
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _buildWeatherCard(isDarkMode),
                  ),
                ),
                
                // Features Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      'สำรวจฟีเจอร์',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                
                // Feature Grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: _buildFeatureGrid(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildMainFAB(isDarkMode),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(User? user, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Menu Button
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.menu_rounded,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('☁️', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'Little Nimbus',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Theme Toggle
          GestureDetector(
            onTap: widget.toggleTheme,
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDarkMode) {
    final hour = DateTime.now().hour;
    String greeting = 'สวัสดี';
    String emoji = '👋';
    
    if (hour < 12) {
      greeting = 'อรุณสวัสดิ์';
      emoji = '🌅';
    } else if (hour < 17) {
      greeting = 'สวัสดีตอนบ่าย';
      emoji = '☀️';
    } else {
      greeting = 'สวัสดีตอนเย็น';
      emoji = '🌙';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  AppColors.darkPrimary.withOpacity(0.8),
                  AppColors.darkAccent.withOpacity(0.6),
                ]
              : [
                  AppColors.primary.withOpacity(0.8),
                  AppColors.accent.withOpacity(0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? AppColors.darkPrimary.withOpacity(0.3) 
                : AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'มาเรียนรู้เกี่ยวกับเมฆกันเถอะ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloudCarouselSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เมฆในธรรมชาติ',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'สำรวจเมฆ 10 ชนิด',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CloudLearningPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isDarkMode ? null : AppColors.primaryGradient,
                    color: isDarkMode ? AppColors.darkPrimary.withOpacity(0.2) : null,
                    border: isDarkMode
                        ? Border.all(color: AppColors.darkPrimary, width: 1)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ดูทั้งหมด',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          color: isDarkMode ? AppColors.darkPrimary : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: isDarkMode ? AppColors.darkPrimary : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: CloudCarousel(),
        ),
      ],
    );
  }

  Widget _buildWeatherCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.sunYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Colors.orange,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'อากาศวันนี้',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'แดดจัด 32°C',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'เมฆน้อย โอกาสฝน 10%',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WeatherPage()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? AppColors.darkPrimary.withOpacity(0.2) 
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'ดูเพิ่ม',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(bool isDarkMode) {
    final features = [
      {
        'icon': Icons.school_rounded,
        'title': 'เรียนรู้เมฆ',
        'subtitle': 'ความรู้เกี่ยวกับเมฆ 10 ชนิด',
        'color': isDarkMode ? AppColors.darkPrimary : AppColors.primary,
        'page': CloudLearningPage(),
      },
      {
        'icon': Icons.camera_alt_rounded,
        'title': 'ถ่ายรูปเมฆ',
        'subtitle': 'ระบุชนิดเมฆจากภาพถ่าย',
        'color': isDarkMode ? AppColors.darkAccent : AppColors.accent,
        'page': const DetectCloudTFLitePage(),
      },
      {
        'icon': Icons.videocam_rounded,
        'title': 'ดูแบบสด',
        'subtitle': 'ตรวจจับเมฆแบบเรียลไทม์',
        'color': AppColors.mintGreen,
        'page': DetectRealtimePage(),
      },
      {
        'icon': Icons.history_rounded,
        'title': 'ประวัติ',
        'subtitle': 'ดูรูปเมฆที่เคยบันทึก',
        'color': AppColors.lavender,
        'page': const DetectionHistoryPage(),
      },
      {
        'icon': Icons.cloud_queue_rounded,
        'title': 'สภาพอากาศ',
        'subtitle': 'ดูสภาพอากาศรายวัน',
        'color': AppColors.sunYellow,
        'page': WeatherPage(),
      },
      {
        'icon': Icons.newspaper_rounded,
        'title': 'ข่าว',
        'subtitle': 'ข้อมูลข่าวเกี่ยวกับเมฆ ท้องฟ้า ',
        'color': AppColors.peach,
        'page': const CloudNewsPage(),
      },
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final feature = features[index];
          return _buildFeatureCard(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            subtitle: feature['subtitle'] as String,
            color: feature['color'] as Color,
            isDarkMode: isDarkMode,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => feature['page'] as Widget),
            ),
          );
        },
        childCount: features.length,
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: isDarkMode ? Colors.white70 : AppColors.textMuted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainFAB(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? AppColors.darkPrimary.withOpacity(0.4) 
                : AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DetectCloudTFLitePage()),
        ),
        backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
        elevation: 0,
        child: const Icon(
          Icons.camera_alt_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildDrawer(User? user, bool isDarkMode) {
    return Drawer(
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.darkPrimary, AppColors.darkAccent]
                    : [AppColors.primary, AppColors.accent],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkBg : AppColors.bgWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? '😊',
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'ผู้ใช้ทั่วไป',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: GoogleFonts.notoSansThai(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'โปรไฟล์',
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'ตั้งค่า',
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(toggleTheme: widget.toggleTheme),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'เกี่ยวกับ',
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreditsPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'ช่วยเหลือ',
                  isDarkMode: isDarkMode,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpPage(),
                      ),
                    );
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Divider(
                    color: isDarkMode ? Colors.white12 : AppColors.divider,
                  ),
                ),
                _buildDrawerItem(
                  icon: user != null ? Icons.logout_rounded : Icons.login_rounded,
                  title: user != null ? 'ออกจากระบบ' : 'เข้าสู่ระบบ',
                  textColor: user != null ? AppColors.error : (isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                  isDarkMode: isDarkMode,
                  onTap: () async {
                    Navigator.pop(context);
                    if (user != null) {
                      await FirebaseAuth.instance.signOut();
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => LoginPage(toggleTheme: widget.toggleTheme),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Little Nimbus v1.0',
              style: GoogleFonts.notoSansThai(
                fontSize: 12,
                color: isDarkMode ? Colors.white38 : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Color? textColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: textColor ?? (isDarkMode ? Colors.white70 : AppColors.textSecondary),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    color: textColor ?? (isDarkMode ? Colors.white : AppColors.textPrimary),
                    fontWeight: FontWeight.w400,
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