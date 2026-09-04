import 'package:flutter/material.dart';
import '../models/simulation_result.dart';

class StatusBadge extends StatelessWidget {
  final CircuitStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String label;

    switch (status) {
      case CircuitStatus.regulatingNormal:
        bg = const Color(0xFF0F3822);
        border = const Color(0xFF22C55E);
        text = const Color(0xFF4ADE80);
        icon = Icons.check_circle_outline;
        label = 'REGULATING (BREAKDOWN ACTIVE)';
        break;
      case CircuitStatus.regulationLost:
        bg = const Color(0xFF38240F);
        border = const Color(0xFFF59E0B);
        text = const Color(0xFFFCD34D);
        icon = Icons.warning_amber_rounded;
        label = 'UNREGULATED (Vth < Vz)';
        break;
      case CircuitStatus.kneeCurrentWarning:
        bg = const Color(0xFF381F0F);
        border = const Color(0xFFFB923C);
        text = const Color(0xFFFDBA74);
        icon = Icons.info_outline;
        label = 'MARGINAL (NEAR KNEE Iz < Izk)';
        break;
      case CircuitStatus.overpowerWarning:
        bg = const Color(0xFF3B1219);
        border = const Color(0xFFEF4444);
        text = const Color(0xFFFCA5A5);
        icon = Icons.local_fire_department_rounded;
        label = 'DANGER: OVERPOWER (Pz > Pmax)';
        break;
      case CircuitStatus.shortCircuit:
        bg = const Color(0xFF3B1219);
        border = const Color(0xFFDC2626);
        text = const Color(0xFFF87171);
        icon = Icons.dangerous_rounded;
        label = 'SHORT CIRCUIT';
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: text),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: text,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: text),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
