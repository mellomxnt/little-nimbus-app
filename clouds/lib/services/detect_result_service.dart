import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetectResultService {
  // ฟังก์ชันบีบอัดภาพ
  static Future<Uint8List?> compressImage(Uint8List imageBytes, {int maxWidth = 1024}) async {
    try {
      debugPrint('🗜️ Compressing image...');
      debugPrint('   - Original size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // Decode image
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      debugPrint('   - Original dimensions: ${image.width}x${image.height}');
      
      // คำนวณขนาดใหม่
      double scale = 1.0;
      if (image.width > maxWidth || image.height > maxWidth) {
        scale = maxWidth / (image.width > image.height ? image.width : image.height);
      }
      
      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();
      
      debugPrint('   - New dimensions: ${newWidth}x${newHeight}');
      
      // สร้างภาพใหม่
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..filterQuality = FilterQuality.medium;
      
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble()),
        paint,
      );
      
      final picture = recorder.endRecording();
      final resizedImage = await picture.toImage(newWidth, newHeight);
      
      // Convert to JPEG with quality
      final byteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      
      final compressedBytes = byteData.buffer.asUint8List();
      debugPrint('   - Compressed size: ${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // ถ้ายังใหญ่เกินไป ลองลดขนาดอีก
      if (compressedBytes.length > 900000 && maxWidth > 512) { // 900KB
        debugPrint('   - Still too large, compressing again...');
        return await compressImage(imageBytes, maxWidth: maxWidth ~/ 2);
      }
      
      return compressedBytes;
    } catch (e) {
      debugPrint('❌ Error compressing image: $e');
      return null;
    }
  }
  static Uint8List? decodeImage(Map<String, dynamic> resultData, bool isFromTFLite) {
    try {
      final imageData = resultData['image'];
      debugPrint('🖼️ Decoding image:');
      debugPrint('   - isFromTFLite: $isFromTFLite');
      debugPrint('   - imageData type: ${imageData.runtimeType}');
      
      if (imageData == null) {
        debugPrint('   ❌ imageData is null');
        return null;
      }
      
      // Handle Uint8List (direct bytes)
      if (imageData is Uint8List) {
        debugPrint('   ✅ Image is already Uint8List (${imageData.length} bytes)');
        return imageData;
      }
      
      // Handle List<int>
      if (imageData is List<int>) {
        debugPrint('   ✅ Converting List<int> to Uint8List (${imageData.length} bytes)');
        return Uint8List.fromList(imageData);
      }
      
      // Handle List<dynamic> - เพิ่มกรณีนี้
      if (imageData is List<dynamic>) {
        debugPrint('   ✅ Converting List<dynamic> to Uint8List (${imageData.length} items)');
        return Uint8List.fromList(imageData.cast<int>());
      }
      
      // Handle base64 String
      if (imageData is String) {
        debugPrint('   ✅ Decoding base64 string (${imageData.length} chars)');
        return base64Decode(imageData);
      }
      
      debugPrint('   ❌ Unknown image data type: ${imageData.runtimeType}');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error decoding image: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  static List<Map<String, dynamic>> getDetections(Map<String, dynamic> resultData) {
    debugPrint('📊 Getting detections from resultData');
    debugPrint('   - ResultData keys: ${resultData.keys}');
    
    final raw = resultData['detections'];
    debugPrint('   - Raw detections type: ${raw.runtimeType}');
    
    if (raw is List) {
      final detections = raw.map((e) {
        if (e is Map<String, dynamic>) {
          debugPrint('   - Detection: $e');
          return e;
        }
        if (e is Map) {
          final converted = Map<String, dynamic>.from(e);
          debugPrint('   - Converted detection: $converted');
          return converted;
        }
        debugPrint('   - Invalid detection type: ${e.runtimeType}');
        return <String, dynamic>{};
      }).where((d) => d.isNotEmpty).toList(); // กรองค่าว่างออก
      
      debugPrint('   - Total valid detections: ${detections.length}');
      return detections;
    }
    
    debugPrint('   - No detections found');
    return [];
  }

  static Future<void> saveToHistory(
    BuildContext context,
    Map<String, dynamic> resultData,
    bool isFromTFLite,
  ) async {
    try {
      debugPrint('💾 Starting saveToHistory...');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('   ❌ User not logged in');
        throw Exception('กรุณาล็อกอินเพื่อบันทึกประวัติ');
      }
      
      debugPrint('   ✅ User: ${user.uid}');

      // ถอดรหัสภาพ
      var imageBytes = decodeImage(resultData, isFromTFLite);
      if (imageBytes == null) {
        debugPrint('   ❌ Failed to decode image');
        throw Exception('ไม่สามารถถอดรหัสภาพได้');
      }
      debugPrint('   ✅ Image decoded: ${imageBytes.length} bytes');

      // ตรวจสอบขนาดภาพก่อนบันทึก
      final imageSizeMB = imageBytes.length / (1024 * 1024);
      debugPrint('   📏 Image size: ${imageSizeMB.toStringAsFixed(2)} MB');
      
      // ถ้าภาพใหญ่เกินไป ให้บีบอัด
      if (imageSizeMB > 0.5) { // ใช้ 0.5 MB เพื่อความปลอดภัย
        debugPrint('   ⚠️ Image too large, compressing...');
        final compressedBytes = await compressImage(imageBytes);
        if (compressedBytes != null) {
          imageBytes = compressedBytes;
          debugPrint('   ✅ Image compressed successfully');
        } else {
          throw Exception('ไม่สามารถบีบอัดภาพได้ กรุณาใช้ภาพที่มีขนาดเล็กลง');
        }
      }

      // ดึงข้อมูลการตรวจจับ
      final detections = getDetections(resultData);
      if (detections.isEmpty) {
        debugPrint('   ⚠️ No detections found, but continuing to save...');
      }

      // เตรียมข้อมูลสำหรับบันทึก
      final dataToSave = {
        'image': base64Encode(imageBytes),
        'detections': detections,
        'timestamp': FieldValue.serverTimestamp(),
        'source': isFromTFLite ? 'tflite' : 'api',
        'imageSize': imageBytes.length,
        'compressed': imageSizeMB > 0.5, // บันทึกว่าภาพถูกบีบอัดหรือไม่
      };
      
      debugPrint('   📝 Preparing to save data...');
      debugPrint('   - Detections count: ${detections.length}');
      debugPrint('   - Final image size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');

      // บันทึกลง Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .add(dataToSave);

      debugPrint('   ✅ Saved successfully with ID: ${docRef.id}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving history: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow; // ส่ง error กลับไปให้ UI จัดการ
    }
  }

  static Future<void> sendFeedback(
    BuildContext context,
    Map<String, dynamic> resultData,
    bool isFromTFLite,
    String reason,
  ) async {
    try {
      debugPrint('📤 Starting sendFeedback...');
      debugPrint('   - Reason: $reason');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('   ❌ User not logged in');
        throw Exception('กรุณาล็อกอินเพื่อส่งรายงาน');
      }
      
      debugPrint('   ✅ User: ${user.uid}');

      // ถอดรหัสภาพ
      var imageBytes = decodeImage(resultData, isFromTFLite);
      if (imageBytes == null) {
        debugPrint('   ❌ Failed to decode image');
        throw Exception('ไม่สามารถถอดรหัสภาพได้');
      }
      debugPrint('   ✅ Image decoded: ${imageBytes.length} bytes');

      // ตรวจสอบขนาดภาพ
      final imageSizeMB = imageBytes.length / (1024 * 1024);
      debugPrint('   📏 Image size: ${imageSizeMB.toStringAsFixed(2)} MB');
      
      // ถ้าภาพใหญ่เกินไป ให้บีบอัด
      if (imageSizeMB > 0.5) {
        debugPrint('   ⚠️ Image too large for feedback, compressing...');
        final compressedBytes = await compressImage(imageBytes);
        if (compressedBytes != null) {
          imageBytes = compressedBytes;
          debugPrint('   ✅ Image compressed successfully');
        } else {
          throw Exception('ไม่สามารถบีบอัดภาพได้ กรุณาใช้ภาพที่มีขนาดเล็กลง');
        }
      }

      // ดึงข้อมูลการตรวจจับ
      final detections = getDetections(resultData);
      debugPrint('   - Detections count: ${detections.length}');

      // เตรียมข้อมูลสำหรับส่ง feedback
      final feedbackData = {
        'uid': user.uid,
        'userEmail': user.email ?? 'anonymous',
        'image': base64Encode(imageBytes),
        'detections': detections,
        'reason': reason.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'source': isFromTFLite ? 'tflite' : 'api',
        'imageSize': imageBytes.length,
        'compressed': imageSizeMB > 0.5,
        'status': 'pending', // สำหรับ admin ตรวจสอบ
      };

      debugPrint('   📝 Preparing to send feedback...');
      debugPrint('   - Final image size: ${(imageBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');

      // บันทึกลง Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('feedbacks')
          .add(feedbackData);

      debugPrint('   ✅ Feedback sent successfully with ID: ${docRef.id}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error sending feedback: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow; // ส่ง error กลับไปให้ UI จัดการ
    }
  }
}