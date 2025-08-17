import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/splash_screen.dart';
import 'pages/auth/login_page.dart';
import 'pages/home.dart';
import 'services/tflite_service.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Firebase init
  await TFLiteService().loadModel(); // ✅ โหลดโมเดล TFLite
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isThemeLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // โหลดค่า Theme จาก SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isThemeLoaded = true;
    });
  }

  // สลับ Theme และบันทึกลง SharedPreferences
  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    // รอให้โหลด Theme preference เสร็จก่อน
    if (!_isThemeLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.bgCream,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Little Nimbus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(
        toggleTheme: _toggleTheme,
        getNextPage: _getInitialPage,
      ),
    );
  }

  /// ตรวจสอบว่า user login อยู่หรือไม่ แล้วเลือกหน้าให้แสดง
  Widget _getInitialPage() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return HomePage(
          toggleTheme: _toggleTheme); // ✅ ต้องส่ง toggleTheme เข้าไป
    } else {
      return LoginPage(toggleTheme: _toggleTheme); // ✅ เช่นกัน
    }
  }
}
