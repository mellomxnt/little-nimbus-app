import 'package:flutter/material.dart';

class AppColors {
  // ====================================
  // 🎨 DAILYBEAN STYLE PALETTE
  // ====================================

  // 🌱 Primary Colors (Main UI Elements)
  static const Color primary = Color(0xFFB8D4E3); // Soft Blue
  static const Color primaryLight = Color(0xFFE3F2FD); // Light Blue
  static const Color primaryDark = Color(0xFF7BA7C0); // Darker Blue

  // 🍑 Accent Colors (Buttons, Highlights)
  static const Color accent = Color(0xFFFFD6E8); // Pastel Pink
  static const Color accentLight = Color(0xFFFFE5CC); // Peach
  static const Color accentDark = Color(0xFFF5CFCF); // Soft Pink

  // 🤍 Background Colors
  static const Color bgCream = Color(0xFFFFFBF5); // Main Background
  static const Color bgWhite = Color(0xFFFFFFFF); // Cards/Containers
  static const Color bgGray = Color(0xFFF5F5F5); // Secondary Background

  // 📝 Text Colors
  static const Color textPrimary = Color(0xFF3E3E60); // Main Text
  static const Color textSecondary = Color(0xFF6B6B6B); // Secondary Text
  static const Color textMuted = Color(0xFF9E9E9E); // Muted/Hint Text
  static const Color textLight = Color(0xFFBDBDBD); // Very Light Text

  // 🌿 Supporting Colors
  static const Color mintGreen = Color(0xFFD4E8DB); // Success/Positive
  static const Color lavender = Color(0xFFE8E3F5); // Info/Alternative
  static const Color sunYellow = Color(0xFFFFF9C4); // Warning/Highlight

  // 🔲 Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0); // Default Border
  static const Color borderLight = Color(0xFFF0F0F0); // Light Border
  static const Color divider = Color(0xFFEEEEEE); // Divider Lines

  // ⚡ System Colors
  static const Color error = Color(0xFFFFB4AB); // Error (Soft Red)
  static const Color errorDark = Color(0xFFCF6679); // Error Text
  static const Color success = Color(0xFFB9F6CA); // Success (Soft Green)
  static const Color successDark = Color(0xFF00C853); // Success Text
  static const Color warning = Color(0xFFFFE082); // Warning (Soft Yellow)
  static const Color warningDark = Color(0xFFF57C00); // Warning Text
  static const Color info = Color(0xFFB3E5FC); // Info (Soft Blue)

  // 🌙 Dark Mode Colors (Optional)
  static const Color darkBg = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkPrimary = Color(0xFF90CAF9);
  static const Color darkAccent = Color(0xFFFFAB91);
  static const Color darkSunYellow = Color(0xFFFDD835);
  static const Color darkMintGreen= Color(0xFF4CAF50);
  // ====================================
  // 🎯 SEMANTIC GROUPINGS
  // ====================================

  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = bgWhite;
  static const Color buttonDisabled = borderLight;
  static const Color buttonText = textPrimary;
  static const Color buttonTextLight = Colors.white;

  // Input Field Colors
  static const Color inputBg = bgWhite;
  static const Color inputBorder = border;
  static const Color inputFocusBorder = primary;
  static const Color inputHintText = textMuted;
  static const Color inputText = textPrimary;

  // Card Colors
  static const Color cardBg = bgWhite;
  static const Color cardBorder = borderLight;
  static const Color cardShadow = Color(0x0A000000);

  // Navigation Colors
  static const Color navBg = bgWhite;
  static const Color navIcon = textSecondary;
  static const Color navIconActive = primary;
  static const Color navText = textSecondary;
  static const Color navTextActive = primary;
  // DailyBean-style pastel colors
  static const Color softBlue = Color(0xFFB8D4E3);
  static const Color pastelPink = Color(0xFFFFD6E8);
  static const Color peach = Color(0xFFFFE5CC);
  static const Color grayText = Color(0xFF6B6B6B);
  static const Color lightGray = Color(0xFFF5F5F5);
  // ====================================
  // 🌈 GRADIENT DEFINITIONS
  // ====================================



  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgCream, bgWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ====================================
  // 🛠 UTILITY METHODS
  // ====================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Darken a color by percentage (0.0 - 1.0)
  static Color darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Lighten a color by percentage (0.0 - 1.0)
  static Color lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
