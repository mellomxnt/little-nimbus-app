import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'Little Nimbus คืออะไร?',
      'answer': 'Little Nimbus เป็นแอปพลิเคชันที่ช่วยให้คุณเรียนรู้และระบุชนิดของเมฆต่างๆ ผ่านการถ่ายภาพและการตรวจจับแบบเรียลไทม์ พร้อมความรู้เกี่ยวกับเมฆ 10 ชนิดหลัก',
      'isExpanded': false,
    },
    {
      'question': 'วิธีใช้งานการตรวจจับเมฆ',
      'answer': 'คุณสามารถตรวจจับเมฆได้ 2 วิธี:\n\n1. ถ่ายรูปเมฆ - กดปุ่มกล้องเพื่อถ่ายภาพเมฆ แอปจะวิเคราะห์และบอกชนิดของเมฆ\n\n2. ดูแบบสด - เปิดกล้องแบบเรียลไทม์เพื่อตรวจจับเมฆทันที',
      'isExpanded': false,
    },
    {
      'question': 'ความแม่นยำในการตรวจจับ',
      'answer': 'แอปใช้ระบบ AI ที่ผ่านการฝึกสอนมาเป็นอย่างดี แต่ความแม่นยำอาจขึ้นอยู่กับ:\n• คุณภาพของภาพ\n• แสงสว่าง\n• มุมมองการถ่าย\n• สภาพอากาศ\n\nแนะนำให้ถ่ายภาพในที่ที่มีแสงสว่างเพียงพอ',
      'isExpanded': false,
    },
    {
      'question': 'ประวัติการตรวจจับหายไปไหน?',
      'answer': 'ประวัติการตรวจจับจะถูกเก็บไว้ในเครื่องของคุณ หากต้องการดูประวัติ ให้ไปที่หน้า "ประวัติ" จากเมนูหลัก\n\nหากยังไม่เห็น ตรวจสอบว่า:\n• เปิดการบันทึกในตั้งค่า\n• มีพื้นที่เก็บข้อมูลเพียงพอ',
      'isExpanded': false,
    },
    {
      'question': 'แอปต้องใช้อินเทอร์เน็ตไหม?',
      'answer': 'ฟีเจอร์ส่วนใหญ่สามารถใช้งานแบบออฟไลน์ได้ ยกเว้น:\n• ข้อมูลสภาพอากาศ\n• ข่าวสารเกี่ยวกับเมฆ\n• การซิงค์ข้อมูล\n\nการตรวจจับเมฆสามารถทำงานได้โดยไม่ต้องใช้อินเทอร์เน็ต',
      'isExpanded': false,
    },
    {
      'question': 'วิธีการเปลี่ยนภาษา',
      'answer': 'ไปที่หน้าตั้งค่า > การแสดงผล > ภาษา แล้วเลือกภาษาที่ต้องการ\n\nปัจจุบันรองรับ:\n• ภาษาไทย\n• English',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่าเป็น Dark Mode หรือไม่
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded, 
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ช่วยเหลือ',
          style: GoogleFonts.notoSansThai(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDarkMode 
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkPrimary,
                          AppColors.darkPrimary.withOpacity(0.8),
                        ],
                      )
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ต้องการความช่วยเหลือ?',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เรารวบรวมคำถามที่พบบ่อยไว้ให้คุณแล้ว',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'ความช่วยเหลือด่วน',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.book_rounded,
                      title: 'คู่มือการใช้งาน',
                      color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                      isDarkMode: isDarkMode,
                      onTap: () => _showUserGuide(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.video_library_rounded,
                      title: 'วิดีโอสอนใช้',
                      color: isDarkMode ? AppColors.darkAccent : AppColors.accent,
                      isDarkMode: isDarkMode,
                      onTap: () => _showVideoTutorials(),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.tips_and_updates_rounded,
                      title: 'เคล็ดลับ',
                      color: isDarkMode ? AppColors.darkSunYellow : AppColors.sunYellow,
                      isDarkMode: isDarkMode,
                      onTap: () => _showTips(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.contact_support_rounded,
                      title: 'ติดต่อเรา',
                      color: isDarkMode ? AppColors.darkMintGreen : AppColors.mintGreen,
                      isDarkMode: isDarkMode,
                      onTap: () => _showContactInfo(),
                    ),
                  ),
                ],
              ),
            ),
            
            // FAQ Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
              child: Text(
                'คำถามที่พบบ่อย',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            
            // FAQ List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _faqItems.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(index, isDarkMode);
              },
            ),
            
            // Contact Support
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.headset_mic_rounded,
                    color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ยังต้องการความช่วยเหลือ?',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ติดต่อทีมสนับสนุนของเรา',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white70 : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showContactSupport(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(Icons.email_rounded, size: 20),
                    label: Text(
                      'ส่งอีเมล',
                      style: GoogleFonts.notoSansThai(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.white10 : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.notoSansThai(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index, bool isDarkMode) {
    final item = _faqItems[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            item['question'],
            style: GoogleFonts.notoSansThai(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          trailing: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item['isExpanded'] ? Icons.remove : Icons.add,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
              size: 18,
            ),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              item['isExpanded'] = expanded;
            });
          },
          children: [
            Text(
              item['answer'],
              style: GoogleFonts.notoSansThai(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserGuide() {
    // Navigate to user guide or show modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('กำลังเปิดคู่มือการใช้งาน'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkPrimary 
            : AppColors.primary,
      ),
    );
  }

  void _showVideoTutorials() {
    // Navigate to video tutorials
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('กำลังเปิดวิดีโอสอนใช้'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkAccent 
            : AppColors.accent,
      ),
    );
  }

  void _showTips() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Show tips modal
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'เคล็ดลับการใช้งาน',
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildTipItem('💡', 'ถ่ายรูปเมฆในเวลาที่มีแสงสว่างเพียงพอ', isDarkMode),
            _buildTipItem('📸', 'หลีกเลี่ยงการถ่ายย้อนแสง', isDarkMode),
            _buildTipItem('☁️', 'ถ่ายให้เห็นลักษณะเมฆชัดเจน', isDarkMode),
            _buildTipItem('📱', 'ถือโทรศัพท์ให้นิ่งขณะถ่าย', isDarkMode),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String tip, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactInfo() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ติดต่อเรา',
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildContactItem(Icons.email_rounded, 'support@littlenimbus.com', isDarkMode),
            _buildContactItem(Icons.language_rounded, 'www.littlenimbus.com', isDarkMode),
            _buildContactItem(Icons.phone_rounded, '02-123-4567', isDarkMode),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String info, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            info,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupport() {
    // Open email client or contact form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('กำลังเปิดอีเมล...'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkPrimary 
            : AppColors.primary,
      ),
    );
  }
}