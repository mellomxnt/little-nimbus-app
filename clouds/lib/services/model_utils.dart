import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> copyModelToStorage() async {
  try {
    // โหลดไฟล์โมเดลจาก assets
    final byteData = await rootBundle.load('assets/cloud_model.tflite');

    // รับ path โฟลเดอร์เอกสารของแอป
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/cloud_model.tflite');

    // เช็คว่าไฟล์มีอยู่หรือยัง ถ้าไม่มีให้เขียนไฟล์ใหม่
    final exists = await file.exists();
    if (!exists) {
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }

    return file.path;
  } catch (e) {
    // กรณี error ให้พิมพ์ log แล้วโยน error ต่อ
    print('Error copying model file: $e');
    rethrow;
  }
}
