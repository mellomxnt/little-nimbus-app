import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/tflite_service.dart';
import '../../theme/app_colors.dart';
import 'detect_result_page.dart';

class DetectCloudTFLitePage extends StatefulWidget {
  const DetectCloudTFLitePage({super.key});

  @override
  State<DetectCloudTFLitePage> createState() => _DetectCloudTFLitePageState();
}

class _DetectCloudTFLitePageState extends State<DetectCloudTFLitePage>
    with TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraActive = false;
  bool _isCapturing = false;
  bool _isModelLoaded = false;
  File? _imageFile;
  late TFLiteService _tfliteService;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tfliteService = TFLiteService();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _loadModel();
    _fadeController.forward();
  }

  Future<void> _loadModel() async {
    try {
      await _tfliteService.loadModel();
      setState(() => _isModelLoaded = true);
      debugPrint("✅ โหลดโมเดลสำเร็จ");
    } catch (e) {
      debugPrint("❌ โหลดโมเดลล้มเหลว: $e");
      if (mounted) {
        _showErrorSnackBar('ไม่สามารถโหลดโมเดลได้');
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorSnackBar('ไม่พบกล้องในอุปกรณ์');
        return;
      }

      _controller = CameraController(_cameras.first, ResolutionPreset.medium);
      await _controller!.initialize();

      setState(() {
        _isCameraInitialized = true;
        _isCameraActive = true;
        _imageFile = null;
      });
    } catch (e) {
      debugPrint('❌ เปิดกล้องล้มเหลว: $e');
      if (mounted) {
        _showErrorSnackBar('ไม่สามารถเปิดกล้องได้');
      }
    }
  }

  Future<void> _disposeCamera() async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller?.dispose();
      setState(() {
        _isCameraInitialized = false;
        _isCameraActive = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        _showErrorSnackBar('ไม่พบไฟล์ภาพที่เลือก');
        return;
      }
      await _disposeCamera();
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    } catch (e) {
      debugPrint('❌ เลือกรูปล้มเหลว: $e');
      _showErrorSnackBar('ไม่สามารถเลือกภาพได้');
    }
  }

  Future<void> _captureAndNavigate() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final picture = await _controller!.takePicture();
      final imageFile = File(picture.path);
      await _processAndNavigate(imageFile);
    } catch (e) {
      debugPrint('❌ ถ่ายภาพล้มเหลว: $e');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการถ่ายภาพ');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _processAndNavigate(File imageFile) async {
    if (!_isModelLoaded) {
      _showErrorSnackBar('โมเดลยังไม่ได้โหลด');
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final rawResult = await _tfliteService.detectObjects(imageFile);
      debugPrint("📸 ผลลัพธ์ดิบจากโมเดล: $rawResult");
      debugPrint("📊 จำนวน detection: ${rawResult.length}");

      List<Map<String, dynamic>> processedDetections = [];

      for (var det in rawResult) {
        double confidence = det.confidence;
        if (confidence < 0.5) continue;

        // Convert to normalized coordinates (0-1) for the UI
        double normalizedX = (det.rect.left + det.rect.width / 2) / det.imageWidth;
        double normalizedY = (det.rect.top + det.rect.height / 2) / det.imageHeight;
        double normalizedWidth = det.rect.width / det.imageWidth;
        double normalizedHeight = det.rect.height / det.imageHeight;

        final detection = {
          'class': det.label,
          'confidence': confidence,
          'bbox': [normalizedX, normalizedY, normalizedWidth, normalizedHeight],
          'image_width': det.imageWidth.toDouble(),
          'image_height': det.imageHeight.toDouble(),
        };
        
        debugPrint("🎯 Detection processed:");
        debugPrint("   - Class: ${det.label}");
        debugPrint("   - Confidence: ${(confidence * 100).toStringAsFixed(1)}%");
        debugPrint("   - Original rect: ${det.rect}");
        debugPrint("   - Normalized bbox: [${normalizedX.toStringAsFixed(3)}, ${normalizedY.toStringAsFixed(3)}, ${normalizedWidth.toStringAsFixed(3)}, ${normalizedHeight.toStringAsFixed(3)}]");
        
        processedDetections.add(detection);
      }

      if (processedDetections.isEmpty) {
        _showErrorSnackBar('ไม่พบเมฆในภาพ');
        return;
      }

      debugPrint("✅ Total processed detections: ${processedDetections.length}");

      // อ่านไฟล์ภาพเป็น bytes
      final bytes = await imageFile.readAsBytes();
      debugPrint("📷 Image bytes length: ${bytes.length}");
      
      if (!mounted) return;
      
      // ส่งภาพเป็น Uint8List โดยตรง ไม่ต้อง encode base64
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetectResultPage(
            resultData: {
              'image': bytes,  // ส่งเป็น Uint8List โดยตรง
              'detections': processedDetections,
            },
            isFromTFLite: true,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ ประมวลผลภาพล้มเหลว: $e');
      debugPrint('StackTrace: $stackTrace');
      _showErrorSnackBar('เกิดข้อผิดพลาดในการประมวลผลภาพ');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.darkSurface : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposeCamera();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBg : AppColors.bgCream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              if (!_isModelLoaded)
                _buildLoadingScreen(isDarkMode)
              else
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(isDarkMode),
                    ),
                    
                    // Preview Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: _buildPreview(isDarkMode),
                      ),
                    ),
                    
                    // Controls Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        child: _buildControls(isDarkMode),
                      ),
                    ),
                  ],
                ),
              
              // Loading Overlay
              if (_isCapturing)
                _buildLoadingOverlay(isDarkMode),
            ],
          ),
        ),
      ),
      floatingActionButton: _isCameraActive ? _buildCaptureButton(isDarkMode) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
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
          
          // Title
          Column(
            children: [
              Text(
                'ระบุชนิดเมฆ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                'ถ่ายหรือเลือกภาพเมฆ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Status Indicator
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _isModelLoaded 
                ? (isDarkMode ? AppColors.mintGreen.withOpacity(0.3) : AppColors.mintGreen.withOpacity(0.2))
                : (isDarkMode ? AppColors.sunYellow.withOpacity(0.3) : AppColors.sunYellow.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.white10 : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Icon(
              _isModelLoaded ? Icons.check_rounded : Icons.hourglass_empty_rounded,
              color: _isModelLoaded ? AppColors.mintGreen : AppColors.sunYellow,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDarkMode) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: isDarkMode 
                  ? LinearGradient(
                      colors: [AppColors.darkPrimary, AppColors.darkAccent],
                    )
                  : AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_download_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'กำลังโหลดโมเดล AI...',
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณารอสักครู่',
              style: GoogleFonts.notoSansThai(
                fontSize: 14,
                color: isDarkMode ? Colors.white54 : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: isDarkMode ? Colors.white12 : AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? AppColors.darkPrimary : AppColors.primary
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode ? Colors.white10 : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: _imageFile != null
            ? Stack(
                children: [
                  Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mintGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ภาพที่เลือก',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : _isCameraActive
                ? (_controller != null && _controller!.value.isInitialized
                    ? Stack(
                        children: [
                          CameraPreview(_controller!),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE',
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildPlaceholder('กำลังเปิดกล้อง...', Icons.camera_alt_rounded, isDarkMode))
                : _buildPlaceholder('กรุณาเลือกภาพหรือเปิดกล้อง', Icons.add_a_photo_rounded, isDarkMode),
      ),
    );
  }

  Widget _buildPlaceholder(String text, IconData icon, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'เปิดกล้อง',
                onPressed: _isCameraActive ? null : _initializeCamera,
                color: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
                isActive: _isCameraActive,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.photo_library_rounded,
                label: 'เลือกภาพ',
                onPressed: _pickImage,
                color: isDarkMode ? AppColors.darkAccent : AppColors.accent,
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        
        if (_imageFile != null) ...[
          const SizedBox(height: 16),
          _buildActionButton(
            icon: Icons.psychology_rounded,
            label: 'วิเคราะห์เมฆ',
            onPressed: () => _processAndNavigate(_imageFile!),
            color: AppColors.mintGreen,
            isFullWidth: true,
            isDarkMode: isDarkMode,
          ),
        ],
        
        const SizedBox(height: 16),
        _buildActionButton(
          icon: Icons.refresh_rounded,
          label: 'รีเซ็ต',
          onPressed: () {
            _disposeCamera();
            setState(() => _imageFile = null);
          },
          color: isDarkMode ? Colors.white54 : AppColors.textMuted,
          isOutlined: true,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required bool isDarkMode,
    bool isActive = false,
    bool isFullWidth = false,
    bool isOutlined = false,
  }) {
    return Container(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined 
            ? (isDarkMode ? AppColors.darkSurface : AppColors.bgWhite)
            : isActive 
              ? color.withOpacity(0.2) 
              : color,
          foregroundColor: isOutlined 
            ? color 
            : isActive 
              ? color 
              : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutlined 
              ? BorderSide(
                  color: isDarkMode ? Colors.white10 : AppColors.borderLight, 
                  width: 1
                )
              : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        icon: Icon(
          icon,
          size: 20,
        ),
        label: Text(
          label,
          style: GoogleFonts.notoSansThai(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _isCapturing ? null : _captureAndNavigate,
        backgroundColor: isDarkMode ? AppColors.darkPrimary : AppColors.primary,
        elevation: 0,
        icon: Icon(
          _isCapturing ? Icons.hourglass_empty_rounded : Icons.camera_rounded,
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          _isCapturing ? 'กำลังถ่าย...' : 'ถ่ายภาพ',
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isDarkMode) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkSurface : AppColors.bgWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? AppColors.darkPrimary : AppColors.primary
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'กำลังประมวลผล...',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                'กรุณารอสักครู่',
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white54 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}