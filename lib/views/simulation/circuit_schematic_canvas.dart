import 'package:flutter/material.dart';
import '../../models/circuit_parameters.dart';
import '../../models/simulation_result.dart';

class CircuitSchematicCanvas extends StatefulWidget {
  final CircuitParameters params;
  final SimulationResult result;

  const CircuitSchematicCanvas({
    super.key,
    required this.params,
    required this.result,
  });

  @override
  State<CircuitSchematicCanvas> createState() => _CircuitSchematicCanvasState();
}

class _CircuitSchematicCanvasState extends State<CircuitSchematicCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 270,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: _SchematicPainter(
                params: widget.params,
                result: widget.result,
                animationValue: _animationController.value,
                isDark: isDark,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }
}

class _SchematicPainter extends CustomPainter {
  final CircuitParameters params;
  final SimulationResult result;
  final double animationValue;
  final bool isDark;

  _SchematicPainter({
    required this.params,
    required this.result,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background Grid
    _drawGrid(canvas, size);

    // Main circuit layout coordinates
    final double left = size.width * 0.14;
    final double midLeft = size.width * 0.40;
    final double zenerX = size.width * 0.65;
    final double loadX = size.width * 0.88;

    final double topY = size.height * 0.22;
    final double bottomY = size.height * 0.80;

    final wirePaint = Paint()
      ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final junctionPaint = Paint()
      ..color = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;

    // 1. Draw Wires
    // Left loop (DC source branch)
    canvas.drawLine(Offset(left, topY), Offset(left, size.height * 0.42), wirePaint);
    canvas.drawLine(Offset(left, size.height * 0.60), Offset(left, bottomY), wirePaint);

    // Top rail: from left to Rs, then from Rs to load
    canvas.drawLine(Offset(left, topY), Offset(midLeft - 35, topY), wirePaint);
    canvas.drawLine(Offset(midLeft + 35, topY), Offset(loadX, topY), wirePaint);

    // Bottom rail: from left to load
    canvas.drawLine(Offset(left, bottomY), Offset(loadX, bottomY), wirePaint);

    // Zener branch wires (top rail to Zener, Zener to bottom rail)
    canvas.drawLine(Offset(zenerX, topY), Offset(zenerX, size.height * 0.40), wirePaint);
    canvas.drawLine(Offset(zenerX, size.height * 0.62), Offset(zenerX, bottomY), wirePaint);

    // Load branch wires
    if (params.isOpenCircuit) {
      // Draw open switch symbol
      canvas.drawLine(Offset(loadX, topY), Offset(loadX, size.height * 0.35), wirePaint);
      canvas.drawLine(Offset(loadX, size.height * 0.65), Offset(loadX, bottomY), wirePaint);
      _drawOpenSwitch(canvas, loadX, size.height * 0.35, size.height * 0.48);
    } else {
      canvas.drawLine(Offset(loadX, topY), Offset(loadX, size.height * 0.40), wirePaint);
      canvas.drawLine(Offset(loadX, size.height * 0.62), Offset(loadX, bottomY), wirePaint);
      _drawResistorSymbol(canvas, loadX, size.height * 0.51, isVertical: true);
    }

    // Junction Dots at nodes
    canvas.drawCircle(Offset(zenerX, topY), 4, junctionPaint);
    canvas.drawCircle(Offset(zenerX, bottomY), 4, junctionPaint);
    if (!params.isOpenCircuit) {
      canvas.drawCircle(Offset(loadX, topY), 4, junctionPaint);
      canvas.drawCircle(Offset(loadX, bottomY), 4, junctionPaint);
    }

    // 2. Draw Component Symbols
    // DC Source at Left
    _drawDcSource(canvas, left, size.height * 0.51);

    // Series Resistor Rs at Top
    _drawResistorSymbol(canvas, midLeft, topY, isVertical: false);

    // Zener Diode at zenerX
    _drawZenerDiode(canvas, zenerX, size.height * 0.51);

    // Ground Symbol at bottom
    _drawGround(canvas, zenerX, bottomY);

    // 3. Draw Animated Current Particles
    _drawCurrentFlow(
      canvas: canvas,
      left: left,
      midLeft: midLeft,
      zenerX: zenerX,
      loadX: loadX,
      topY: topY,
      bottomY: bottomY,
      height: size.height,
    );

    // 4. Draw Component Text Labels & Annotations
    _drawLabels(
      canvas: canvas,
      left: left,
      midLeft: midLeft,
      zenerX: zenerX,
      loadX: loadX,
      topY: topY,
      bottomY: bottomY,
      size: size,
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
          .withOpacity(0.4)
      ..strokeWidth = 0.5;

    const double step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawDcSource(Canvas canvas, double cx, double cy) {
    final paint = Paint()
      ..color = isDark ? Colors.white : Colors.black87
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Longer plate (Positive)
    canvas.drawLine(Offset(cx - 18, cy - 10), Offset(cx + 18, cy - 10), paint);
    // Shorter plate (Negative)
    canvas.drawLine(Offset(cx - 10, cy + 10), Offset(cx + 10, cy + 10), paint);

    // Polarity labels
    _drawText(canvas, '+', Offset(cx + 22, cy - 18),
        color: const Color(0xFFEF4444), fontSize: 13, bold: true);
    _drawText(canvas, '−', Offset(cx + 22, cy + 2),
        color: const Color(0xFF38BDF8), fontSize: 15, bold: true);
  }

  void _drawResistorSymbol(Canvas canvas, double cx, double cy,
      {required bool isVertical}) {
    final rPaint = Paint()
      ..color = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (!isVertical) {
      // Horizontal zigzag (for Rs)
      final double startX = cx - 30;
      path.moveTo(startX, cy);
      path.lineTo(startX + 6, cy - 10);
      path.lineTo(startX + 18, cy + 10);
      path.lineTo(startX + 30, cy - 10);
      path.lineTo(startX + 42, cy + 10);
      path.lineTo(startX + 54, cy - 10);
      path.lineTo(startX + 60, cy);
    } else {
      // Vertical zigzag (for RL)
      final double startY = cy - 25;
      path.moveTo(cx, startY);
      path.lineTo(cx - 10, startY + 6);
      path.lineTo(cx + 10, startY + 16);
      path.lineTo(cx - 10, startY + 26);
      path.lineTo(cx + 10, startY + 36);
      path.lineTo(cx - 10, startY + 44);
      path.lineTo(cx, startY + 50);
    }
    canvas.drawPath(path, rPaint);
  }

  void _drawZenerDiode(Canvas canvas, double cx, double cy) {
    // In voltage regulator mode, Zener cathode is connected to the POSITIVE top rail (Reverse Bias)
    // Anode is connected to ground (Bottom rail)
    // So triangle points DOWNWARDS towards anode, and cathode bar is at TOP.
    final diodeColor = result.isZenerConductionActive
        ? (result.pz > params.pzMax
            ? const Color(0xFFEF4444)
            : const Color(0xFF34D399))
        : const Color(0xFF94A3B8);

    final dPaint = Paint()
      ..color = diodeColor
      ..strokeWidth = 2.2
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = diodeColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double topBarY = cy - 14;
    final double bottomPointY = cy + 14;

    // Triangle (pointing down from cathode bar to anode)
    final triPath = Path()
      ..moveTo(cx - 14, topBarY)
      ..lineTo(cx + 14, topBarY)
      ..lineTo(cx, bottomPointY)
      ..close();
    canvas.drawPath(triPath, dPaint);

    // Zener Cathode Bar with characteristic "Z" bent wings
    final zBarPath = Path()
      ..moveTo(cx - 14, topBarY + 6) // Left wing bent down
      ..lineTo(cx - 14, topBarY)
      ..lineTo(cx + 14, topBarY)
      ..lineTo(cx + 14, topBarY - 6); // Right wing bent up
    canvas.drawPath(zBarPath, linePaint);

    // Glow effect if active
    if (result.isZenerConductionActive) {
      final glowPaint = Paint()
        ..color = diodeColor.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(cx, cy), 22, glowPaint);
    }
  }

  void _drawOpenSwitch(Canvas canvas, double cx, double startY, double endY) {
    final sPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Terminal dots
    canvas.drawCircle(Offset(cx, startY), 3, sPaint);
    canvas.drawCircle(Offset(cx, endY + 12), 3, sPaint);

    // Open switch blade angled out
    canvas.drawLine(
      Offset(cx, startY),
      Offset(cx + 16, startY + 18),
      sPaint,
    );
  }

  void _drawGround(Canvas canvas, double cx, double cy) {
    final gPaint = Paint()
      ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(cx, cy), Offset(cx, cy + 12), gPaint);
    canvas.drawLine(Offset(cx - 14, cy + 12), Offset(cx + 14, cy + 12), gPaint);
    canvas.drawLine(Offset(cx - 9, cy + 17), Offset(cx + 9, cy + 17), gPaint);
    canvas.drawLine(Offset(cx - 4, cy + 22), Offset(cx + 4, cy + 22), gPaint);
  }

  void _drawCurrentFlow({
    required Canvas canvas,
    required double left,
    required double midLeft,
    required double zenerX,
    required double loadX,
    required double topY,
    required double bottomY,
    required double height,
  }) {
    // Flow speed & particle density proportional to currents
    final pPaintIs = Paint()..color = const Color(0xFFFBBF24); // Source Amber
    final pPaintIz = Paint()..color = const Color(0xFF34D399); // Zener Green
    final pPaintIl = Paint()..color = const Color(0xFFA78BFA); // Load Purple

    // 1. Source Series Branch: Left DC source -> Rs -> Top junction at zenerX
    if (result.isCurrentMA > 0.05) {
      final double progress = animationValue;
      const int numParticles = 6;
      for (int i = 0; i < numParticles; i++) {
        final double t = (progress + (i / numParticles)) % 1.0;
        // Total path length of series section: up left wire, across top rail to zenerX
        final double pathLen = (topY - bottomY).abs() + (zenerX - left);
        final double currDist = t * pathLen;

        Offset pos;
        if (currDist < (bottomY - topY)) {
          // Going UP left branch
          pos = Offset(left, bottomY - currDist);
        } else {
          // Going RIGHT along top rail
          pos = Offset(left + (currDist - (bottomY - topY)), topY);
        }
        canvas.drawCircle(pos, 2.8, pPaintIs);
      }
    }

    // 2. Zener Diode Shunt Branch: from topY down to bottomY at zenerX
    if (result.izCurrentMA > 0.05 && result.isZenerConductionActive) {
      final double progress = animationValue;
      final int numZenerParticles = (result.izCurrentMA > 5.0) ? 4 : 2;
      for (int i = 0; i < numZenerParticles; i++) {
        final double t = (progress + (i / numZenerParticles)) % 1.0;
        final double y = topY + t * (bottomY - topY);
        canvas.drawCircle(Offset(zenerX, y), 2.8, pPaintIz);
      }
    }

    // 3. Load Branch: top rail from zenerX to loadX, then down load branch
    if (!params.isOpenCircuit && result.ilCurrentMA > 0.05) {
      final double progress = animationValue;
      const int numLoadParticles = 4;
      for (int i = 0; i < numLoadParticles; i++) {
        final double t = (progress + (i / numLoadParticles)) % 1.0;
        final double topDist = loadX - zenerX;
        final double downDist = bottomY - topY;
        final double totalDist = topDist + downDist;
        final double currDist = t * totalDist;

        Offset pos;
        if (currDist < topDist) {
          pos = Offset(zenerX + currDist, topY);
        } else {
          pos = Offset(loadX, topY + (currDist - topDist));
        }
        canvas.drawCircle(pos, 2.8, pPaintIl);
      }
    }

    // 4. Return ground path: from load/zener back to left
    if (result.isCurrentMA > 0.05) {
      final double progress = animationValue;
      const int numGroundParticles = 5;
      for (int i = 0; i < numGroundParticles; i++) {
        final double t = (progress + (i / numGroundParticles)) % 1.0;
        final double x = loadX - (t * (loadX - left));
        canvas.drawCircle(Offset(x, bottomY), 2.4, pPaintIs);
      }
    }
  }

  void _drawLabels({
    required Canvas canvas,
    required double left,
    required double midLeft,
    required double zenerX,
    required double loadX,
    required double topY,
    required double bottomY,
    required Size size,
  }) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white60 : Colors.black54;

    // Vin Label
    _drawText(
      canvas,
      'Vin = ${params.vin.toStringAsFixed(1)} V',
      Offset(left - 10, size.height * 0.50 - 32),
      color: const Color(0xFF38BDF8),
      fontSize: 12.5,
      bold: true,
      alignCenter: true,
    );
    _drawText(
      canvas,
      '(Unregulated DC)',
      Offset(left - 10, size.height * 0.50 + 26),
      color: subColor,
      fontSize: 10,
      alignCenter: true,
    );

    // Rs Label & Series Current Is
    _drawText(
      canvas,
      'Rs = ${params.rs.toStringAsFixed(0)} Ω',
      Offset(midLeft, topY - 26),
      color: textColor,
      fontSize: 12.5,
      bold: true,
      alignCenter: true,
    );
    _drawText(
      canvas,
      'Is → ${result.isCurrentMA.toStringAsFixed(1)} mA',
      Offset(midLeft, topY + 16),
      color: const Color(0xFFFBBF24),
      fontSize: 11,
      bold: true,
      alignCenter: true,
    );

    // Zener Diode Label & Iz
    _drawText(
      canvas,
      'Dz (${params.vz.toStringAsFixed(1)} V)',
      Offset(zenerX, size.height * 0.50 - 34),
      color: result.isZenerConductionActive
          ? const Color(0xFF34D399)
          : const Color(0xFF94A3B8),
      fontSize: 12,
      bold: true,
      alignCenter: true,
    );
    _drawText(
      canvas,
      'Iz ↓ ${result.izCurrentMA.toStringAsFixed(1)} mA',
      Offset(zenerX + 2, size.height * 0.50 + 26),
      color: const Color(0xFF34D399),
      fontSize: 11,
      bold: true,
      alignCenter: true,
    );

    // Load Resistor Label & IL
    if (params.isOpenCircuit) {
      _drawText(
        canvas,
        'LOAD OPEN',
        Offset(loadX, size.height * 0.50 - 10),
        color: const Color(0xFFF59E0B),
        fontSize: 11.5,
        bold: true,
        alignCenter: true,
      );
      _drawText(
        canvas,
        '(IL = 0 mA)',
        Offset(loadX, size.height * 0.50 + 8),
        color: subColor,
        fontSize: 10.5,
        alignCenter: true,
      );
    } else {
      _drawText(
        canvas,
        'RL = ${params.rl >= 1000 ? '${(params.rl / 1000).toStringAsFixed(1)}k' : params.rl.toStringAsFixed(0)} Ω',
        Offset(loadX, size.height * 0.50 - 34),
        color: textColor,
        fontSize: 12,
        bold: true,
        alignCenter: true,
      );
      _drawText(
        canvas,
        'IL ↓ ${result.ilCurrentMA.toStringAsFixed(1)} mA',
        Offset(loadX + 2, size.height * 0.50 + 26),
        color: const Color(0xFFA78BFA),
        fontSize: 11,
        bold: true,
        alignCenter: true,
      );
    }

    // Regulated Output Probe Banner at Top-Right
    _drawOutputProbe(canvas, loadX, topY, size);
  }

  void _drawOutputProbe(Canvas canvas, double loadX, double topY, Size size) {
    final probeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 130, 8, 122, 42),
      const Radius.circular(8),
    );

    final bgPaint = Paint()
      ..color = result.isZenerConductionActive
          ? const Color(0xFF064E3B).withOpacity(0.85)
          : const Color(0xFF78350F).withOpacity(0.85);

    final borderPaint = Paint()
      ..color = result.isZenerConductionActive
          ? const Color(0xFF10B981)
          : const Color(0xFFF59E0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(probeRect, bgPaint);
    canvas.drawRRect(probeRect, borderPaint);

    _drawText(
      canvas,
      'OUTPUT (VL)',
      Offset(size.width - 69, 13),
      color: Colors.white70,
      fontSize: 9.5,
      bold: true,
      alignCenter: true,
    );
    _drawText(
      canvas,
      '${result.vl.toStringAsFixed(3)} V',
      Offset(size.width - 69, 26),
      color: result.isZenerConductionActive
          ? const Color(0xFF6EE7B7)
          : const Color(0xFFFDE68A),
      fontSize: 14,
      bold: true,
      alignCenter: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    Color color = Colors.black87,
    double fontSize = 12,
    bool bold = false,
    bool alignCenter = false,
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

    final Offset drawPos = alignCenter
        ? Offset(position.dx - (textPainter.width / 2),
            position.dy - (textPainter.height / 2))
        : position;

    textPainter.paint(canvas, drawPos);
  }

  @override
  bool shouldRepaint(covariant _SchematicPainter oldDelegate) {
    return true; // Live continuous animation of electron flow
  }
}
