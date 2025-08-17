import 'package:flutter/material.dart';
import 'dart:typed_data';

// Simple overlay widget for bounding boxes
class SimpleBoundingBoxOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> detections;
  
  const SimpleBoundingBoxOverlay({
    super.key,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        debugPrint("🎯 SimpleBoundingBoxOverlay:");
        debugPrint("   - Container size: $width x $height");
        debugPrint("   - Detections: ${detections.length}");
        
        return Stack(
          children: detections.map((detection) {
            final bbox = detection['bbox'];
            if (bbox == null || bbox.length < 4) {
              debugPrint("   ❌ Invalid bbox for detection: $detection");
              return const SizedBox.shrink();
            }
            
            // bbox format: [x_center, y_center, width, height] (normalized 0-1)
            final xCenter = bbox[0] * width;
            final yCenter = bbox[1] * height;
            final boxWidth = bbox[2] * width;
            final boxHeight = bbox[3] * height;
            
            final left = xCenter - boxWidth / 2;
            final top = yCenter - boxHeight / 2;
            
            debugPrint("   📦 Drawing box at: left=$left, top=$top, width=$boxWidth, height=$boxHeight");
            
            final className = detection['class']?.toString() ?? 'Unknown';
            final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;
            
            // Colors for different cloud types
            final Map<String, Color> cloudColors = {
              'altocumulus': const Color(0xFF9B7EDE),
              'altostratus': const Color(0xFF6B4EDE),
              'cirrocumulus': const Color(0xFF00D4AA),
              'cirrostratus': const Color(0xFFFFD93D),
              'cirrus': const Color(0xFFFF7B54),
              'cumulonimbus': const Color(0xFFFF4757),
              'cumulus': const Color(0xFF5B8DEE),
              'nimbostratus': const Color(0xFF636E72),
              'stratocumulus': const Color(0xFFFFB8B8),
              'stratus': const Color(0xFFEE5A6F),
            };
            
            final color = cloudColors[className.toLowerCase()] ?? const Color(0xFF5B8DEE);
            
            return Positioned(
              left: left,
              top: top,
              width: boxWidth,
              height: boxHeight,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Label - positioned above the box
                    Positioned(
                      left: 0,
                      top: -30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$className ${(confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class DetectResultImage extends StatelessWidget {
  final Uint8List imageBytes;
  final List<Map<String, dynamic>> detections;

  const DetectResultImage({
    super.key,
    required this.imageBytes,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    // Debug log
    debugPrint("🖼️ DetectResultImage build:");
    debugPrint("   - Image bytes: ${imageBytes != null ? 'Available (${imageBytes.length} bytes)' : 'NULL'}");
    debugPrint("   - Detections count: ${detections.length}");
    for (var i = 0; i < detections.length; i++) {
      debugPrint("   - Detection $i: ${detections[i]}");
    }
    
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Hero(
        tag: 'result_image',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0), // Remove if causing issues
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Original Image
              Image.memory(
                imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("❌ Error loading image: $error");
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              // Bounding Boxes Overlay
              if (detections.isNotEmpty)
                Positioned.fill(
                  child: SimpleBoundingBoxOverlay(
                    detections: detections,
                  ),
                ),
              // Tap hint
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.zoom_in,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'แตะเพื่อขยาย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageBytes: imageBytes,
          detections: detections,
        ),
      ),
    );
  }
}

// Full screen view
class FullScreenImageView extends StatelessWidget {
  final Uint8List imageBytes;
  final List<Map<String, dynamic>> detections;

  const FullScreenImageView({
    super.key,
    required this.imageBytes,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Image with pinch to zoom
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: 'result_image',
                  child: Stack(
                    children: [
                      Image.memory(
                        imageBytes,
                        fit: BoxFit.contain,
                      ),
                      if (detections.isNotEmpty)
                        Positioned.fill(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return SimpleBoundingBoxOverlay(
                                detections: detections,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Info
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'พบเมฆ ${detections.length} จุด • บีบนิ้วเพื่อซูม',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}