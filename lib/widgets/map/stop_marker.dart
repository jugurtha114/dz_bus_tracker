// lib/widgets/map/stop_marker.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StopMarker {
  static Future<BitmapDescriptor> getStopMarker({
    required BuildContext context,
    required Color color,
    String? label,
    double size = 40,
  }) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw stop icon
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Outer circle
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Inner circle
    final Paint innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 3,
      innerPaint,
    );

    // Bus symbol
    final Paint busPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Simple bus icon in the center
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size / 2 - size / 6,
          size / 2 - size / 10,
          size / 3,
          size / 5,
        ),
        Radius.circular(size / 20),
      ),
      busPaint,
    );

    // Label
    if (label != null) {
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size - textPainter.width) / 2,
          size * 0,
        ),
      );
    }

    // Convert to image
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}