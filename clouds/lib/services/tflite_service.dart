import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:math' as math;

class TFLiteService {
  Interpreter? _interpreter;
  bool _modelLoaded = false;

  final String modelPath = 'assets/cloud_model.tflite';
  final int inputSize = 416;

  final List<String> labels = [
    'altocumulus',
    'altostratus',
    'cirrocumulus',
    'cirrostratus',
    'cirrus',
    'cumulonimbus',
    'cumulus',
    'nimbostratus',
    'stratocumulus',
    'stratus',
  ];

  Future<void> loadModel() async {
    if (_modelLoaded) return;

    final stopwatch = Stopwatch()..start();

    try {
      _interpreter = await Interpreter.fromAsset(modelPath);
      _modelLoaded = true;

      print('✅ โหลดโมเดลสำเร็จ (เวลา: ${stopwatch.elapsedMilliseconds} ms)');

      var inputTensors = _interpreter!.getInputTensors();
      var outputTensors = _interpreter!.getOutputTensors();

      print('Input tensor shape: ${inputTensors[0].shape}');
      print('Output tensor shape: ${outputTensors[0].shape}');
      
      var expectedOutputShape = [1, 14, 3549];
      if (outputTensors[0].shape.toString() == expectedOutputShape.toString()) {
        print('✅ Output shape ถูกต้อง: ${outputTensors[0].shape}');
      } else {
        print('⚠️ Output shape ไม่ตรงตามที่คาดหวัง');
        print('คาดหวัง: $expectedOutputShape');
        print('ได้จริง: ${outputTensors[0].shape}');
      }
    } catch (e) {
      print('❌ โหลดโมเดลล้มเหลว: $e (เวลา: ${stopwatch.elapsedMilliseconds} ms)');
      rethrow;
    }
    
    stopwatch.stop();
  }

  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    if (!_modelLoaded || _interpreter == null) {
      print('⚠️ โมเดลยังไม่ถูกโหลด');
      return [];
    }

    final totalStopwatch = Stopwatch()..start();
    final stepStopwatch = Stopwatch();

    // Step 1: อ่านไฟล์ภาพ
    stepStopwatch.start();
    final imageBytes = await imageFile.readAsBytes();
    stepStopwatch.stop();
    print('⏱️ อ่านไฟล์: ${stepStopwatch.elapsedMilliseconds} ms');

    // Step 2: Decode ภาพ
    stepStopwatch.reset();
    stepStopwatch.start();
    img.Image? oriImage = img.decodeImage(imageBytes);
    stepStopwatch.stop();
    print('⏱️ Decode ภาพ: ${stepStopwatch.elapsedMilliseconds} ms');

    if (oriImage == null) {
      print('❌ ไม่สามารถ decode รูปได้');
      return [];
    }

    print('📸 ภาพต้นฉบับ: ${oriImage.width}x${oriImage.height}');

    // Step 3: ปรับขนาดภาพ
    stepStopwatch.reset();
    stepStopwatch.start();
    img.Image resizedImage = img.copyResize(oriImage, width: inputSize, height: inputSize);
    stepStopwatch.stop();
    print('⏱️ ปรับขนาดภาพ: ${stepStopwatch.elapsedMilliseconds} ms');

    // Step 4: แปลงเป็น Float32List
    stepStopwatch.reset();
    stepStopwatch.start();
    Float32List inputFlat = _imageToFloat32List(resizedImage);
    var input = inputFlat.reshape([1, inputSize, inputSize, 3]);
    stepStopwatch.stop();
    print('⏱️ แปลงข้อมูลภาพ: ${stepStopwatch.elapsedMilliseconds} ms');

    var outputShape = _interpreter!.getOutputTensors()[0].shape;
    print('📊 Output tensor shape: $outputShape');

    var outputBuffer = List.generate(
      outputShape[0],
      (_) => List.generate(
        outputShape[1],
        (_) => List.filled(outputShape[2], 0.0),
      ),
    );

    // Step 5: ประมวลผลด้วยโมเดล
    stepStopwatch.reset();
    stepStopwatch.start();
    try {
      _interpreter!.run(input, outputBuffer);
      stepStopwatch.stop();
      print('⏱️ ประมวลผลโมเดล: ${stepStopwatch.elapsedMilliseconds} ms');
      print('✅ ประมวลผลสำเร็จ');
    } catch (e) {
      stepStopwatch.stop();
      print('❌ ประมวลผลล้มเหลว: $e (เวลา: ${stepStopwatch.elapsedMilliseconds} ms)');
      return [];
    }

    // Step 6: ประมวลผลการตรวจจับ
    stepStopwatch.reset();
    stepStopwatch.start();
    List<DetectionResult> detections = _processDetections(outputBuffer[0], oriImage);
    stepStopwatch.stop();
    print('⏱️ ประมวลผลการตรวจจับ: ${stepStopwatch.elapsedMilliseconds} ms');
    
    // Step 7: NMS
    stepStopwatch.reset();
    stepStopwatch.start();
    List<DetectionResult> finalResults = _applyNMS(detections, 0.4);
    stepStopwatch.stop();
    print('⏱️ NMS: ${stepStopwatch.elapsedMilliseconds} ms');
    
    totalStopwatch.stop();
    
    print('🧪 ตรวจพบก่อน NMS: ${detections.length} รายการ');
    print('🎯 ผลลัพธ์สุดท้าย: ${finalResults.length} รายการ');
    print('⏱️ เวลารวมทั้งหมด: ${totalStopwatch.elapsedMilliseconds} ms');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    return finalResults;
  }

  List<DetectionResult> _processDetections(List<List<double>> output, img.Image originalImage) {
    final processStopwatch = Stopwatch()..start();
    List<DetectionResult> detections = [];
    
    double scaleX = originalImage.width / inputSize;
    double scaleY = originalImage.height / inputSize;
    
    int numPredictions = output[0].length;
    print('🔢 จำนวน predictions: $numPredictions');
    
    // วัดเวลาการหา scores
    final scoreStopwatch = Stopwatch()..start();
    List<double> allScores = [];
    for (int pred = 0; pred < math.min(100, numPredictions); pred++) {
      for (int cls = 0; cls < 10; cls++) {
        allScores.add(output[4 + cls][pred]);
      }
    }
    allScores.sort((a, b) => b.compareTo(a));
    scoreStopwatch.stop();
    print('  ⏱️ คำนวณ scores: ${scoreStopwatch.elapsedMilliseconds} ms');
    
    print('🎯 Top 10 scores: ${allScores.take(10).map((s) => s.toStringAsFixed(4)).toList()}');
    
    double confidenceThreshold = 0.25;
    if (allScores.isNotEmpty && allScores.first < 0.5) {
      confidenceThreshold = math.max(0.1, allScores.first * 0.5);
      print('⚠️ ปรับ confidence threshold เป็น: ${confidenceThreshold.toStringAsFixed(3)}');
    }
    
    // วัดเวลาการประมวลผล detections
    final detectionStopwatch = Stopwatch()..start();
    for (int i = 0; i < numPredictions; i++) {
      double x = output[0][i];
      double y = output[1][i];
      double w = output[2][i];
      double h = output[3][i];
      
      int bestClassId = -1;
      double maxClassProb = 0.0;
      
      for (int classIdx = 0; classIdx < 10; classIdx++) {
        double classProb = output[4 + classIdx][i];
        if (classProb > maxClassProb) {
          maxClassProb = classProb;
          bestClassId = classIdx;
        }
      }
      
      if (maxClassProb > confidenceThreshold && bestClassId >= 0) {
        double centerX = x * inputSize;
        double centerY = y * inputSize;
        double width = w * inputSize;
        double height = h * inputSize;
        
        if (x > 1.0 || y > 1.0 || w > 1.0 || h > 1.0) {
          centerX = x;
          centerY = y;
          width = w;
          height = h;
        }
        
        double left = centerX - width / 2;
        double top = centerY - height / 2;
        
        left *= scaleX;
        top *= scaleY;
        width *= scaleX;
        height *= scaleY;
        
        if (left < originalImage.width && top < originalImage.height &&
            width > 0 && height > 0 && width < originalImage.width && height < originalImage.height) {
          
          left = math.max(0, left);
          top = math.max(0, top);
          double right = math.min(originalImage.width.toDouble(), left + width);
          double bottom = math.min(originalImage.height.toDouble(), top + height);
          width = right - left;
          height = bottom - top;
          
          if (width > 5 && height > 5) {
            final result = DetectionResult(
              label: labels[bestClassId],
              confidence: maxClassProb,
              rect: Rect.fromLTWH(left, top, width, height),
              classId: bestClassId,
              imageWidth: originalImage.width,
              imageHeight: originalImage.height,
            );
            
            detections.add(result);
            
            if (detections.length <= 5) {
              print('\n🎯 Detection #${detections.length}:');
              print('  🏷️  ${result.label} (${(maxClassProb * 100).toStringAsFixed(1)}%)');
              print('  📍 Raw: x=$x, y=$y, w=$w, h=$h');
              print('  📐 BBox: ${result.rect}');
            }
          }
        }
      }
    }
    detectionStopwatch.stop();
    print('  ⏱️ ประมวลผล detections: ${detectionStopwatch.elapsedMilliseconds} ms');
    
    processStopwatch.stop();
    print('  ⏱️ รวม _processDetections: ${processStopwatch.elapsedMilliseconds} ms');
    print('\n📊 สรุป: พบ ${detections.length} detections ที่ผ่านเกณฑ์');
    
    return detections;
  }

  List<DetectionResult> _applyNMS(List<DetectionResult> detections, double iouThreshold) {
    if (detections.isEmpty) return [];
    
    final nmsStopwatch = Stopwatch()..start();
    
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    List<DetectionResult> result = [];
    List<bool> suppressed = List.filled(detections.length, false);
    
    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      
      result.add(detections[i]);
      
      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        
        if (detections[i].classId == detections[j].classId) {
          double iou = _calculateIoU(detections[i].rect, detections[j].rect);
          if (iou > iouThreshold) {
            suppressed[j] = true;
          }
        }
      }
    }
    
    nmsStopwatch.stop();
    print('  ⏱️ NMS computation: ${nmsStopwatch.elapsedMilliseconds} ms');
    
    return result;
  }

  double _calculateIoU(Rect box1, Rect box2) {
    double left = math.max(box1.left, box2.left);
    double top = math.max(box1.top, box2.top);
    double right = math.min(box1.right, box2.right);
    double bottom = math.min(box1.bottom, box2.bottom);
    
    if (right <= left || bottom <= top) return 0.0;
    
    double intersection = (right - left) * (bottom - top);
    double area1 = box1.width * box1.height;
    double area2 = box2.width * box2.height;
    double union = area1 + area2 - intersection;
    
    return intersection / union;
  }

  Float32List _imageToFloat32List(img.Image image) {
    var buffer = Float32List(inputSize * inputSize * 3);
    int index = 0;
    
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        int pixel = image.getPixel(x, y);
        
        buffer[index++] = img.getRed(pixel) / 255.0;
        buffer[index++] = img.getGreen(pixel) / 255.0;
        buffer[index++] = img.getBlue(pixel) / 255.0;
      }
    }
    
    return buffer;
  }
  
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _modelLoaded = false;
  }
}

class DetectionResult {
  final String label;
  final double confidence;
  final Rect rect;
  final int classId;
  final int imageWidth;
  final int imageHeight;

  DetectionResult({
    required this.label,
    required this.confidence,
    required this.rect,
    required this.classId,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  String toString() {
    return 'DetectionResult(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, rect: $rect)';
  }
}

extension Float32ListReshape on Float32List {
  List<List<List<List<double>>>> reshape(List<int> shape) {
    assert(shape.length == 4);
    var result = List.generate(
      shape[0],
      (_) => List.generate(
        shape[1],
        (_) => List.generate(
          shape[2],
          (_) => List.filled(shape[3], 0.0),
        ),
      ),
    );
    
    int index = 0;
    for (int i = 0; i < shape[0]; i++) {
      for (int j = 0; j < shape[1]; j++) {
        for (int k = 0; k < shape[2]; k++) {
          for (int l = 0; l < shape[3]; l++) {
            result[i][j][k][l] = this[index++];
          }
        }
      }
    }
    
    return result;
  }
}