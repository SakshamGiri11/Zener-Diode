import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../physics/circuit_physics_engine.dart';

class CustomChartPainter extends CustomPainter {
  final List<GraphPoint> dataPoints;
  final String title;
  final String xLabel;
  final String yLabel;
  final double? activePointX;
  final double? activePointY;
  final String activePointLabel;
  final double? referenceY; // e.g. horizontal line at Vz
  final String? referenceYLabel;
  final double? thresholdX; // e.g. vertical line at V_knee
  final String? thresholdXLabel;
  final List<Offset>? experimentalPoints; // (x, y) observations
  final bool isDark;
  final Color curveColor;
  final bool showZones;
  final String? zoneLeftLabel;
  final String? zoneRightLabel;

  CustomChartPainter({
    required this.dataPoints,
    required this.title,
    required this.xLabel,
    required this.yLabel,
    this.activePointX,
    this.activePointY,
    this.activePointLabel = '',
    this.referenceY,
    this.referenceYLabel,
    this.thresholdX,
    this.thresholdXLabel,
    this.experimentalPoints,
    required this.isDark,
    this.curveColor = const Color(0xFF38BDF8),
    this.showZones = false,
    this.zoneLeftLabel,
    this.zoneRightLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    // Margins for axes and labels
    final double padLeft = 60.0;
    final double padBottom = 45.0;
    final double padTop = 30.0;
    final double padRight = 30.0;

    final plotWidth = size.width - padLeft - padRight;
    final plotHeight = size.height - padTop - padBottom;

    if (plotWidth <= 0 || plotHeight <= 0) return;

    // Calculate domain & range
    double minX = dataPoints.first.x;
    double maxX = dataPoints.first.x;
    double minY = dataPoints.first.y;
    double maxY = dataPoints.first.y;

    for (final p in dataPoints) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    if (activePointX != null) {
      if (activePointX! < minX) minX = activePointX!;
      if (activePointX! > maxX) maxX = activePointX!;
    }
    if (activePointY != null) {
      if (activePointY! < minY) minY = activePointY!;
      if (activePointY! > maxY) maxY = activePointY!;
    }
    if (referenceY != null) {
      if (referenceY! < minY) minY = referenceY!;
      if (referenceY! > maxY) maxY = referenceY!;
    }

    // Add 8% padding to range
    final xSpan = (maxX - minX).abs() < 0.001 ? 1.0 : (maxX - minX);
    final ySpan = (maxY - minY).abs() < 0.001 ? 1.0 : (maxY - minY);

    final domainMin = minX >= 0 && minX < 0.1 ? 0.0 : minX - (xSpan * 0.05);
    final domainMax = maxX + (xSpan * 0.05);
    final rangeMin = minY >= 0 && minY < 0.1 ? 0.0 : minY - (ySpan * 0.08);
    final rangeMax = maxY + (ySpan * 0.08);

    double toScreenX(double x) {
      return padLeft + ((x - domainMin) / (domainMax - domainMin)) * plotWidth;
    }

    double toScreenY(double y) {
      return padTop + (1.0 - ((y - rangeMin) / (rangeMax - rangeMin))) * plotHeight;
    }

    // 1. Background Plot Area
    final plotRect = Rect.fromLTWH(padLeft, padTop, plotWidth, plotHeight);
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    canvas.drawRect(plotRect, bgPaint);

    // Shaded Zones (e.g. Dropout vs Regulation)
    if (showZones && thresholdX != null) {
      final threshScreenX = toScreenX(thresholdX!).clamp(padLeft, padLeft + plotWidth);

      // Left Zone (Dropout / Unregulated)
      final leftRect = Rect.fromLTRB(padLeft, padTop, threshScreenX, padTop + plotHeight);
      final leftPaint = Paint()..color = const Color(0xFFF59E0B).withOpacity(0.08);
      canvas.drawRect(leftRect, leftPaint);

      // Right Zone (Regulated)
      final rightRect = Rect.fromLTRB(threshScreenX, padTop, padLeft + plotWidth, padTop + plotHeight);
      final rightPaint = Paint()..color = const Color(0xFF10B981).withOpacity(0.08);
      canvas.drawRect(rightRect, rightPaint);

      if (zoneLeftLabel != null) {
        _drawText(
          canvas,
          zoneLeftLabel!,
          Offset((padLeft + threshScreenX) / 2, padTop + 14),
          color: const Color(0xFFF59E0B).withOpacity(0.7),
          fontSize: 10.5,
          bold: true,
          alignCenter: true,
        );
      }
      if (zoneRightLabel != null) {
        _drawText(
          canvas,
          zoneRightLabel!,
          Offset((threshScreenX + padLeft + plotWidth) / 2, padTop + 14),
          color: const Color(0xFF10B981).withOpacity(0.7),
          fontSize: 10.5,
          bold: true,
          alignCenter: true,
        );
      }
    }

    // 2. Gridlines and Axis Ticks
    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final axisPaint = Paint()
      ..color = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)
      ..strokeWidth = 1.5;

    // Horizontal gridlines & Y ticks (5 ticks)
    const int yDivisions = 5;
    for (int i = 0; i <= yDivisions; i++) {
      final yVal = rangeMin + (i / yDivisions) * (rangeMax - rangeMin);
      final sy = toScreenY(yVal);

      canvas.drawLine(Offset(padLeft, sy), Offset(padLeft + plotWidth, sy), gridPaint);
      _drawText(
        canvas,
        _formatTick(yVal),
        Offset(padLeft - 8, sy),
        color: isDark ? Colors.white60 : Colors.black54,
        fontSize: 10,
        alignRight: true,
      );
    }

    // Vertical gridlines & X ticks (6 ticks)
    const int xDivisions = 6;
    for (int i = 0; i <= xDivisions; i++) {
      final xVal = domainMin + (i / xDivisions) * (domainMax - domainMin);
      final sx = toScreenX(xVal);

      canvas.drawLine(Offset(sx, padTop), Offset(sx, padTop + plotHeight), gridPaint);
      _drawText(
        canvas,
        _formatTick(xVal),
        Offset(sx, padTop + plotHeight + 6),
        color: isDark ? Colors.white60 : Colors.black54,
        fontSize: 10,
        alignCenter: true,
      );
    }

    // Zero axes if applicable (especially for I-V curve)
    if (domainMin < 0 && domainMax > 0) {
      final zeroX = toScreenX(0);
      canvas.drawLine(
        Offset(zeroX, padTop),
        Offset(zeroX, padTop + plotHeight),
        axisPaint..color = (isDark ? Colors.white54 : Colors.black45),
      );
    }
    if (rangeMin < 0 && rangeMax > 0) {
      final zeroY = toScreenY(0);
      canvas.drawLine(
        Offset(padLeft, zeroY),
        Offset(padLeft + plotWidth, zeroY),
        axisPaint..color = (isDark ? Colors.white54 : Colors.black45),
      );
    }

    // Outer plot border
    canvas.drawRect(
      plotRect,
      Paint()
        ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 3. Reference Horizontal Line (e.g. Vz target)
    if (referenceY != null) {
      final refSy = toScreenY(referenceY!);
      if (refSy >= padTop && refSy <= padTop + plotHeight) {
        final refPaint = Paint()
          ..color = const Color(0xFF10B981)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        _drawDashedLine(
            canvas, Offset(padLeft, refSy), Offset(padLeft + plotWidth, refSy), refPaint);

        if (referenceYLabel != null) {
          _drawText(
            canvas,
            referenceYLabel!,
            Offset(padLeft + plotWidth - 6, refSy - 12),
            color: const Color(0xFF10B981),
            fontSize: 10,
            bold: true,
            alignRight: true,
          );
        }
      }
    }

    // 4. Threshold Vertical Line (e.g. Breakdown point)
    if (thresholdX != null) {
      final threshSx = toScreenX(thresholdX!);
      if (threshSx >= padLeft && threshSx <= padLeft + plotWidth) {
        final tPaint = Paint()
          ..color = const Color(0xFFF59E0B)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        _drawDashedLine(
            canvas, Offset(threshSx, padTop), Offset(threshSx, padTop + plotHeight), tPaint);

        if (thresholdXLabel != null) {
          _drawText(
            canvas,
            thresholdXLabel!,
            Offset(threshSx + 4, padTop + plotHeight - 16),
            color: const Color(0xFFF59E0B),
            fontSize: 10,
            bold: true,
          );
        }
      }
    }

    // 5. Draw Theoretical Data Curve
    final curvePath = Path();
    for (int i = 0; i < dataPoints.length; i++) {
      final pt = dataPoints[i];
      final sx = toScreenX(pt.x);
      final sy = toScreenY(pt.y);

      if (i == 0) {
        curvePath.moveTo(sx, sy);
      } else {
        curvePath.lineTo(sx, sy);
      }
    }

    final cPaint = Paint()
      ..color = curveColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(curvePath, cPaint);

    // 6. Draw Logged Student Observations (Experimental Dots)
    if (experimentalPoints != null && experimentalPoints!.isNotEmpty) {
      final expPaint = Paint()
        ..color = const Color(0xFFEC4899)
        ..style = PaintingStyle.fill;
      final expBorder = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      for (final exp in experimentalPoints!) {
        final sx = toScreenX(exp.dx);
        final sy = toScreenY(exp.dy);
        if (sx >= padLeft &&
            sx <= padLeft + plotWidth &&
            sy >= padTop &&
            sy <= padTop + plotHeight) {
          canvas.drawCircle(Offset(sx, sy), 5, expPaint);
          canvas.drawCircle(Offset(sx, sy), 5, expBorder);
        }
      }
    }

    // 7. Active Operating Point Dot & Coordinate Tag
    if (activePointX != null && activePointY != null) {
      final dotSx = toScreenX(activePointX!);
      final dotSy = toScreenY(activePointY!);

      if (dotSx >= padLeft &&
          dotSx <= padLeft + plotWidth &&
          dotSy >= padTop &&
          dotSy <= padTop + plotHeight) {
        // Crosshair dashed guides
        final guidePaint = Paint()
          ..color = (isDark ? Colors.white38 : Colors.black26)
          ..strokeWidth = 1.0;
        _drawDashedLine(canvas, Offset(padLeft, dotSy), Offset(dotSx, dotSy), guidePaint);
        _drawDashedLine(
            canvas, Offset(dotSx, padTop + plotHeight), Offset(dotSx, dotSy), guidePaint);

        // Glow ring
        final glowPaint = Paint()
          ..color = const Color(0xFFF43F5E).withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(Offset(dotSx, dotSy), 10, glowPaint);

        // Solid marker
        canvas.drawCircle(
            Offset(dotSx, dotSy), 6, Paint()..color = const Color(0xFFF43F5E));
        canvas.drawCircle(
            Offset(dotSx, dotSy),
            6,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);

        // Tooltip badge
        final tagText = activePointLabel.isNotEmpty
            ? activePointLabel
            : '(${activePointX!.toStringAsFixed(2)}, ${activePointY!.toStringAsFixed(2)})';

        _drawCoordinateBadge(canvas, tagText, Offset(dotSx, dotSy - 18), size);
      }
    }

    // 8. Axis Titles
    // X Axis Label
    _drawText(
      canvas,
      xLabel,
      Offset(padLeft + (plotWidth / 2), size.height - 12),
      color: isDark ? Colors.white70 : Colors.black87,
      fontSize: 12,
      bold: true,
      alignCenter: true,
    );

    // Y Axis Label (at top left above axis)
    _drawText(
      canvas,
      yLabel,
      Offset(padLeft - 10, padTop - 14),
      color: isDark ? Colors.white70 : Colors.black87,
      fontSize: 12,
      bold: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const double dashWidth = 4.0;
    const double dashSpace = 3.0;
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double distance = math.sqrt(dx * dx + dy * dy);
    final double unitDx = dx / distance;
    final double unitDy = dy / distance;

    double currentDist = 0.0;
    while (currentDist < distance) {
      final double nextDist = math.min(currentDist + dashWidth, distance);
      canvas.drawLine(
        Offset(p1.dx + unitDx * currentDist, p1.dy + unitDy * currentDist),
        Offset(p1.dx + unitDx * nextDist, p1.dy + unitDy * nextDist),
        paint,
      );
      currentDist += dashWidth + dashSpace;
    }
  }

  void _drawCoordinateBadge(
      Canvas canvas, String text, Offset position, Size size) {
    final span = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();

    final badgeWidth = tp.width + 12;
    final badgeHeight = tp.height + 6;

    double bx = position.dx - (badgeWidth / 2);
    double by = position.dy - (badgeHeight / 2);

    bx = bx.clamp(8.0, size.width - badgeWidth - 8.0);
    by = by.clamp(8.0, size.height - badgeHeight - 8.0);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bx, by, badgeWidth, badgeHeight),
      const Radius.circular(5),
    );

    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF0F172A).withOpacity(0.92));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFFF43F5E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    tp.paint(canvas, Offset(bx + 6, by + 3));
  }

  String _formatTick(double v) {
    if (v.abs() >= 100) return v.toStringAsFixed(0);
    if (v.abs() >= 10) return v.toStringAsFixed(1);
    return v.toStringAsFixed(2);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    Color color = Colors.black87,
    double fontSize = 11,
    bool bold = false,
    bool alignCenter = false,
    bool alignRight = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'sans-serif',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    double dx = position.dx;
    double dy = position.dy;

    if (alignCenter) {
      dx -= textPainter.width / 2;
    } else if (alignRight) {
      dx -= textPainter.width;
      dy -= textPainter.height / 2;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant CustomChartPainter oldDelegate) {
    return true;
  }
}
