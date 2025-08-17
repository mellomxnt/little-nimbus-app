import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:google_fonts/google_fonts.dart';

import '../../services/tflite_service.dart';
import '../../theme/app_colors.dart';

class DetectRealtimePage extends StatefulWidget {
  @override
  _DetectRealtimePageState createState() => _DetectRealtimePageState();
}

class _DetectRealtimePageState extends State<DetectRealtimePage> {
  CameraController? _cameraController;
  late TFLiteService _tfliteService;
  List<DetectionResult> _results = [];
  bool _isDetecting = false;
  bool _isModelLoaded = false;
  bool _isCameraInitialized = false;
  
  // สำหรับคำนวณขนาดการแสดงผล
  Size? _imageSize;
  Size? _screenSize;

  @override
  void initState() {
    super.initState();
    _tfliteService = TFLiteService();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _tfliteService.loadModel();
      setState(() => _isModelLoaded = true);
      await _initCamera();
    } catch (e) {
      debugPrint('❌ Error initializing services: $e');
      _showErrorSnackBar('ไม่สามารถโหลดโมเดลได้');
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorSnackBar('ไม่พบกล้องในอุปกรณ์');
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera, 
        ResolutionPreset.medium,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      
      setState(() => _isCameraInitialized = true);

      // เริ่มประมวลผลภาพ
      _startImageStream();
    } catch (e) {
      debugPrint('❌ Camera initialization error: $e');
      _showErrorSnackBar('ไม่สามารถเปิดกล้องได้');
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting || !_isModelLoaded) return;
      
      _isDetecting = true;

      try {
        // แปลงเป็น img.Image
        final convertedImage = await _convertCameraImage(image);
        if (convertedImage == null) {
          _isDetecting = false;
          return;
        }

        // บันทึกเป็นไฟล์ชั่วคราว
        final tempDir = await Directory.systemTemp.createTemp();
        final file = File('${tempDir.path}/frame.jpg');
        await file.writeAsBytes(img.encodeJpg(convertedImage, quality: 85));

        // ประมวลผลด้วย TFLite
        final results = await _tfliteService.detectObjects(file);

        // ลบไฟล์ชั่วคราว
        await file.delete();
        await tempDir.delete();

        if (mounted) {
          setState(() {
            _results = results;
            _imageSize = Size(
              convertedImage.width.toDouble(), 
              convertedImage.height.toDouble()
            );
          });
        }
      } catch (e) {
        debugPrint('❌ Detection error: $e');
      }

      _isDetecting = false;
    });
  }

  Future<img.Image?> _convertCameraImage(CameraImage cameraImage) async {
    try {
      if (Platform.isAndroid) {
        // สำหรับ Android (YUV420)
        return _convertYUV420ToImage(cameraImage);
      } else if (Platform.isIOS) {
        // สำหรับ iOS (BGRA8888)
        return _convertBGRA8888ToImage(cameraImage);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Image conversion error: $e');
      return null;
    }
  }

  img.Image? _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final img.Image image = img.Image(width, height);

    final plane = cameraImage.planes[0];
    final yBuffer = cameraImage.planes[0].bytes;
    final uBuffer = cameraImage.planes[1].bytes;
    final vBuffer = cameraImage.planes[2].bytes;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 1;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);

        final yValue = yBuffer[yIndex];
        final uValue = uBuffer[uvIndex];
        final vValue = vBuffer[uvIndex];

        // YUV to RGB conversion
        final r = (yValue + 1.370705 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128)).clamp(0, 255).toInt();
        final b = (yValue + 1.732446 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    // หมุนภาพถ้าจำเป็น (Android มักต้องหมุน 90 องศา)
    return img.copyRotate(image, 90);
  }

  img.Image? _convertBGRA8888ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;
    
    final img.Image image = img.Image(width, height);
    final buffer = cameraImage.planes[0].bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = (y * width + x) * 4;
        final b = buffer[index];
        final g = buffer[index + 1];
        final r = buffer[index + 2];
        final a = buffer[index + 3];
        
        image.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return image;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'ตรวจจับเมฆแบบเรียลไทม์',
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isModelLoaded ? AppColors.mintGreen : AppColors.sunYellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isModelLoaded ? Icons.check_circle : Icons.hourglass_empty,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 4),
                Text(
                  _isModelLoaded ? 'พร้อม' : 'กำลังโหลด',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isModelLoaded) {
      return _buildLoadingScreen();
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'กำลังเปิดกล้อง...',
              style: GoogleFonts.notoSansThai(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        _buildCameraPreview(),
        
        // Detection Overlay
        if (_imageSize != null && _screenSize != null)
          ..._buildDetectionOverlay(),
        
        // Stats Overlay
        _buildStatsOverlay(),
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'กำลังโหลดโมเดล AI...',
              style: GoogleFonts.notoSansThai(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Center(
      child: AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  List<Widget> _buildDetectionOverlay() {
    final previewSize = _getPreviewSize();
    if (previewSize == null) return [];

    final scaleX = previewSize.width / _imageSize!.width;
    final scaleY = previewSize.height / _imageSize!.height;

    // คำนวณ offset สำหรับจัดกึ่งกลาง
    final offsetX = (_screenSize!.width - previewSize.width) / 2;
    final offsetY = (_screenSize!.height - previewSize.height) / 2;

    return _results.map((detection) {
      final left = detection.rect.left * scaleX + offsetX;
      final top = detection.rect.top * scaleY + offsetY;
      final width = detection.rect.width * scaleX;
      final height = detection.rect.height * scaleY;

      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(
              color: _getColorForCloud(detection.label),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Label background
              Positioned(
                top: -2,
                left: -2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorForCloud(detection.label),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud,
                        size: 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${detection.label} ${(detection.confidence * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.notoSansThai(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Size? _getPreviewSize() {
    if (_screenSize == null || _cameraController == null) return null;

    final aspectRatio = _cameraController!.value.aspectRatio;
    final screenWidth = _screenSize!.width;
    final screenHeight = _screenSize!.height;

    // คำนวณขนาดที่เหมาะสมโดยรักษา aspect ratio
    double previewWidth = screenWidth;
    double previewHeight = screenWidth / aspectRatio;

    if (previewHeight > screenHeight) {
      previewHeight = screenHeight;
      previewWidth = screenHeight * aspectRatio;
    }

    return Size(previewWidth, previewHeight);
  }

  Widget _buildStatsOverlay() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'สถานะ:',
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _isDetecting ? 'กำลังประมวลผล...' : 'พร้อมตรวจจับ',
                  style: GoogleFonts.notoSansThai(
                    color: _isDetecting ? AppColors.sunYellow : AppColors.mintGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'พบเมฆ:',
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_results.length} ชนิด',
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (_results.isNotEmpty) ...[
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _results.map((r) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorForCloud(r.label).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getColorForCloud(r.label),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    r.label,
                    style: GoogleFonts.notoSansThai(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorForCloud(String cloudType) {
    final colors = {
      'altocumulus': Colors.blue,
      'altostratus': Colors.indigo,
      'cirrocumulus': Colors.cyan,
      'cirrostratus': Colors.lightBlue,
      'cirrus': Colors.teal,
      'cumulonimbus': Colors.deepPurple,
      'cumulus': Colors.orange,
      'nimbostratus': Colors.blueGrey,
      'stratocumulus': Colors.purple,
      'stratus': Colors.grey,
    };
    return colors[cloudType.toLowerCase()] ?? Colors.pinkAccent;
  }
}