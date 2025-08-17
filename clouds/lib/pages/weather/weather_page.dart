import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import '../../theme/app_colors.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with TickerProviderStateMixin {
  String _city = 'กำลังค้นหาตำแหน่ง...';
  String _country = '';
  double? _latitude;
  double? _longitude;
  Map<String, dynamic> _weatherData = {};
  List<dynamic> _forecastData = [];
  bool _isLoading = true;
  bool _isLocationLoading = true;
  String _analysisResult = '';
  IconData _analysisIcon = Icons.cloud;
  Color _analysisColor = AppColors.primary;
  String _errorMessage = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _getCurrentLocation();
  }

  void _setupAnimations() {
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

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLocationLoading = true;
        _errorMessage = '';
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _useFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        await _useFallbackLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      await _getAddressFromCoordinates(position.latitude, position.longitude);
      await _fetchWeatherData();
    } catch (e) {
      print('Location error: $e');
      await _useFallbackLocation();
    }
  }

  Future<void> _useFallbackLocation() async {
    setState(() {
      _city = 'กรุงเทพมหานคร';
      _country = 'ประเทศไทย';
      _latitude = 13.7563;
      _longitude = 100.5018;
      _isLocationLoading = false;
    });

    await _fetchWeatherData();
  }

  Future<void> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _city = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'ไม่ทราบพื้นที่';
          _country = place.country ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _city = 'ไม่สามารถระบุพื้นที่ได้';
      });
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_latitude == null || _longitude == null) return;

    const apiKey = '???????????????????';
    final currentUrl = Uri.parse(
      'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$_latitude,$_longitude&lang=th',
    );
    final forecastUrl = Uri.parse(
      'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$_latitude,$_longitude&days=5&lang=th',
    );

    try {
      final currentResponse = await http.get(currentUrl);
      final forecastResponse = await http.get(forecastUrl);

      if (currentResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        final currentData = json.decode(currentResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        final current = currentData['current'];
        final location = currentData['location'];

        setState(() {
          _weatherData = current;
          _forecastData = forecastData['forecast']['forecastday'];
          _city = location['name'] ?? _city;
          _country = location['country'] ?? _country;
          _isLoading = false;
          _analyzeWeather(current);
        });
      } else {
        setState(() {
          _weatherData = {};
          _forecastData = [];
          _isLoading = false;
          _errorMessage = 'ไม่สามารถดึงข้อมูลสภาพอากาศได้';
        });
      }
    } catch (e) {
      setState(() {
        _weatherData = {};
        _forecastData = [];
        _isLoading = false;
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.toString()}';
      });
    }
  }

  void _analyzeWeather(Map<String, dynamic> data) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final humidity = data['humidity'];
    final pressure = data['pressure_mb'];
    final wind = data['wind_kph'];
    final condition = data['condition']['text'].toLowerCase();
    final temp = data['temp_c'];

    if (humidity > 85 &&
        pressure < 1005 &&
        (condition.contains('เมฆ') || condition.contains('cloud'))) {
      _analysisResult = 'มีโอกาสเกิดฝนในไม่ช้า';
      _analysisIcon = Icons.umbrella;
      _analysisColor = isDarkMode ? AppColors.darkPrimary : AppColors.primary;
    } else if (wind > 30 &&
        (condition.contains('เมฆ') || condition.contains('cloud'))) {
      _analysisResult = 'ลมแรงและมีเมฆมาก อาจเกิดพายุฝน';
      _analysisIcon = Icons.air;
      _analysisColor = isDarkMode ? AppColors.darkAccent : AppColors.accent;
    } else if (pressure > 1015 && humidity < 60) {
      _analysisResult = 'สภาพอากาศค่อนข้างแจ่มใส';
      _analysisIcon = Icons.wb_sunny;
      _analysisColor = AppColors.sunYellow;
    } else if (temp > 35) {
      _analysisResult = 'อากาศร้อนมาก ควรหลีกเลี่ยงแสงแดด';
      _analysisIcon = Icons.wb_sunny;
      _analysisColor = AppColors.peach;
    } else if (temp < 20) {
      _analysisResult = 'อากาศเย็น ควรแต่งกายให้อบอุ่น';
      _analysisIcon = Icons.ac_unit;
      _analysisColor = AppColors.mintGreen;
    } else {
      _analysisResult = 'สภาพอากาศโดยรวมปกติ';
      _analysisIcon = Icons.cloud_done;
      _analysisColor = AppColors.lavender;
    }
  }

  Future<void> _refreshWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: _buildHeader(isDarkMode),
                ),

                // Content
                SliverToBoxAdapter(
                  child: _buildContent(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
                Icons.arrow_back_ios_rounded,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'สภาพอากาศ',
            style: GoogleFonts.notoSansThai(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _refreshWeather,
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
                Icons.refresh_rounded,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDarkMode) {
    if (_isLoading || _isLocationLoading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? AppColors.darkPrimary : AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'กำลังดึงข้อมูลสภาพอากาศ...',
                style: GoogleFonts.notoSansThai(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _refreshWeather,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isDarkMode ? null : AppColors.primaryGradient,
                      color: isDarkMode ? AppColors.darkPrimary : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ลองใหม่',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_weatherData.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Text(
            'ไม่พบข้อมูลสภาพอากาศ',
            style: GoogleFonts.notoSansThai(
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshWeather,
      color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Weather Card
            _buildCurrentWeatherCard(isDarkMode),

            const SizedBox(height: 20),

            // Analysis Card
            _buildAnalysisCard(isDarkMode),

            const SizedBox(height: 20),

            // Weather Details
            _buildWeatherDetails(isDarkMode),

            const SizedBox(height: 20),

            // Forecast Section
            if (_forecastData.isNotEmpty) _buildForecastSection(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(bool isDarkMode) {
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
        children: [
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _city,
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weather Icon and Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_weatherData['condition']?['icon'] != null)
                Image.network(
                  'https:${_weatherData['condition']['icon']}',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.cloud,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_weatherData['temp_c']}°C',
                    style: GoogleFonts.nunito(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    _weatherData['condition']['text'],
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Fallback location warning
          if (_latitude == 13.7563 && _longitude == 100.5018) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'แสดงข้อมูลจากกรุงเทพฯ (ไม่สามารถเข้าถึงตำแหน่งปัจจุบัน)',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _analysisColor.withOpacity(isDarkMode ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _analysisColor.withOpacity(isDarkMode ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _analysisColor.withOpacity(isDarkMode ? 0.25 : 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _analysisIcon,
              color: _analysisColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'การวิเคราะห์อากาศ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _analysisResult,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(bool isDarkMode) {
    final details = [
      {
        'icon': Icons.opacity,
        'label': 'ความชื้น',
        'value': '${_weatherData['humidity']}%',
        'color': isDarkMode ? AppColors.darkPrimary : AppColors.primary,
      },
      {
        'icon': Icons.air,
        'label': 'ลม',
        'value': '${_weatherData['wind_kph']} กม./ชม.',
        'color': isDarkMode ? AppColors.darkAccent : AppColors.accent,
      },
      {
        'icon': Icons.speed,
        'label': 'ความกดอากาศ',
        'value': '${_weatherData['pressure_mb']} hPa',
        'color': AppColors.mintGreen,
      },
      {
        'icon': Icons.visibility,
        'label': 'ทัศนวิสัย',
        'value': '${_weatherData['vis_km']} กม.',
        'color': AppColors.lavender,
      },
      {
        'icon': Icons.thermostat,
        'label': 'ความรู้สึก',
        'value': '${_weatherData['feelslike_c']}°C',
        'color': AppColors.sunYellow,
      },
      {
        'icon': Icons.location_on,
        'label': 'พิกัด',
        'value':
            '${_latitude?.toStringAsFixed(3)}, ${_longitude?.toStringAsFixed(3)}',
        'color': AppColors.peach,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'รายละเอียด',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: details.length,
          itemBuilder: (context, index) {
            final detail = details[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: (detail['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          detail['icon'] as IconData,
                          size: 18,
                          color: detail['color'] as Color,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail['label'] as String,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 12,
                          color:
                              isDarkMode ? Colors.white54 : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail['value'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildForecastSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'พยากรณ์อากาศ 3 วัน',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecastData.length,
            itemBuilder: (context, index) {
              final forecast = _forecastData[index];
              final date = DateTime.parse(forecast['date']);
              final day = _getDayName(date);

              return Container(
                width: 100,
                margin: EdgeInsets.only(
                    right: index < _forecastData.length - 1 ? 12 : 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color:
                            isDarkMode ? Colors.white54 : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (forecast['day']['condition']?['icon'] != null)
                      Image.network(
                        'https:${forecast['day']['condition']['icon']}',
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.cloud,
                            size: 32,
                            color: isDarkMode ? Colors.white70 : Colors.grey,
                          );
                        },
                      ),
                    Column(
                      children: [
                        Text(
                          '${forecast['day']['maxtemp_c'].round()}°',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
    String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = targetDate.difference(today).inDays;
    
    if (difference == 0) return 'วันนี้';
    if (difference == 1) return 'พรุ่งนี้';
    
    const dayNames = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return dayNames[date.weekday - 1];
  }
}
