import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ====================================
  // 🌞 LIGHT THEME
  // ====================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Main Colors
    scaffoldBackgroundColor: AppColors.bgCream,
    primaryColor: AppColors.primary,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.accent,
      secondaryContainer: AppColors.accentLight,
      background: AppColors.bgCream,
      surface: AppColors.bgWhite,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgCream,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: GoogleFonts.notoSansThai(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.textSecondary,
      size: 24,
    ),
    
    // Text Theme
    textTheme: GoogleFonts.notoSansThaiTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ).copyWith(
      // Headlines
      headlineLarge: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.notoSansThai(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      
      // Titles
      titleLarge: GoogleFonts.notoSansThai(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.notoSansThai(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.notoSansThai(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      
      // Body
      bodyLarge: GoogleFonts.notoSansThai(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.notoSansThai(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.notoSansThai(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      
      // Labels
      labelLarge: GoogleFonts.notoSansThai(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.notoSansThai(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.notoSansThai(
        fontSize: 11,
        color: AppColors.textMuted,
      ),
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.cardBorder, width: 1),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonTextLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.notoSansThai(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.notoSansThai(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.notoSansThai(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.inputBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.inputFocusBorder, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: GoogleFonts.notoSansThai(
        fontSize: 14,
        color: AppColors.inputHintText,
      ),
      labelStyle: GoogleFonts.notoSansThai(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.navBg,
      selectedItemColor: AppColors.navIconActive,
      unselectedItemColor: AppColors.navIcon,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.notoSansThai(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.notoSansThai(
        fontSize: 12,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.bgGray,
      selectedColor: AppColors.primaryLight,
      labelStyle: GoogleFonts.notoSansThai(
        fontSize: 12,
        color: AppColors.textPrimary,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // ====================================
  // 🌙 DARK THEME
  // ====================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Main Colors
    scaffoldBackgroundColor: AppColors.darkBg,
    primaryColor: AppColors.darkPrimary,
    
    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkAccent,
      background: AppColors.darkBg,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: AppColors.darkBg,
      onSecondary: AppColors.darkBg,
      onBackground: Colors.white70,
      onSurface: Colors.white70,
      onError: Colors.white,
    ),
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppColors.darkPrimary),
      titleTextStyle: GoogleFonts.notoSansThai(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.darkPrimary,
      size: 24,
    ),
    
    // Text Theme
    textTheme: GoogleFonts.notoSansThaiTextTheme().apply(
      bodyColor: Colors.white70,
      displayColor: Colors.white70,
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white10, width: 1),
      ),
    ),
    
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: Colors.white12,
      thickness: 1,
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.notoSansThai(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white24, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.white24, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      hintStyle: GoogleFonts.notoSansThai(
        fontSize: 14,
        color: Colors.white38,
      ),
      labelStyle: GoogleFonts.notoSansThai(
        fontSize: 14,
        color: Colors.white54,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.notoSansThai(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.notoSansThai(
        fontSize: 12,
      ),
    ),
  );
}