// lib/widgets/map/bus_marker.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusMarker {
  static Future<BitmapDescriptor> getBusMarker({
    required BuildContext context,
    required Color color,
    required String label,
    double size = 40.0,
  }) async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw bus icon
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Bus body
    final RRect busRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size, size * 0.6),
      Radius.circular(size * 0.15),
    );
    canvas.drawRRect(busRRect, paint);

    // Bus windows
    final Paint windowPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Front windshield
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size * 0.05, size * 0.05, size * 0.2, size * 0.15),
        Radius.circular(size * 0.05),
      ),
      windowPaint,
    );

    // Side windows
    for (int i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size * 0.35 + (i * size * 0.2),
            size * 0.05,
            size * 0.15,
            size * 0.15,
          ),
          Radius.circular(size * 0.05),
        ),
        windowPaint,
      );
    }

    // Wheels
    final Paint wheelPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size * 0.25, size * 0.6), size * 0.1, wheelPaint);
    canvas.drawCircle(Offset(size * 0.75, size * 0.6), size * 0.1, wheelPaint);

    // Label
    textPainter.text = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.3,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        size * 0.7,
      ),
    );

    // Convert to image
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), (size * 1.0).toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  static Future<BitmapDescriptor> createMarkerFromAsset(String path) async {
    return BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      path,
    );
  }
}