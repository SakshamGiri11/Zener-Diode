import 'package:flutter/material.dart';
import '../../models/simulation_result.dart';
import '../../models/circuit_parameters.dart';

class StatusWarningBanner extends StatelessWidget {
  final SimulationResult result;
  final CircuitParameters params;

  const StatusWarningBanner({
    super.key,
    required this.result,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    IconData icon;
    String title;
    String description;

    switch (result.status) {
      case CircuitStatus.regulatingNormal:
        bg = const Color(0xFF064E3B).withOpacity(0.35);
        border = const Color(0xFF10B981);
        text = const Color(0xFF6EE7B7);
        icon = Icons.verified_rounded;
        title = 'Voltage Regulation Active';
        description =
            'Zener diode is operating in stable reverse breakdown. Load voltage is clamped at ${result.vl.toStringAsFixed(2)} V. Any source or load variations are compensated by Zener current adjustments.';
        break;

      case CircuitStatus.regulationLost:
        bg = const Color(0xFF78350F).withOpacity(0.35);
        border = const Color(0xFFF59E0B);
        text = const Color(0xFFFDE68A);
        icon = Icons.warning_amber_rounded;
        title = 'Regulation Lost: Below Breakdown Threshold';
        description =
            'Thevenin voltage Vth (${result.vth.toStringAsFixed(2)} V) is less than breakdown voltage Vz (${params.vz.toStringAsFixed(2)} V). The diode is OFF (Iz = 0). The circuit behaves as an unregulated voltage divider: VL = ${result.vl.toStringAsFixed(2)} V.';
        break;

      case CircuitStatus.kneeCurrentWarning:
        bg = const Color(0xFF7C2D12).withOpacity(0.35);
        border = const Color(0xFFFB923C);
        text = const Color(0xFFFED7AA);
        icon = Icons.info_outline_rounded;
        title = 'Marginal Regulation: Near Knee Current';
        description =
            'Zener current Iz (${result.izCurrentMA.toStringAsFixed(2)} mA) is below the minimum knee current (${(params.izk * 1000).toStringAsFixed(2)} mA). The diode is close to turning off; regulation stiffness is degraded.';
        break;

      case CircuitStatus.overpowerWarning:
        bg = const Color(0xFF7F1D1D).withOpacity(0.45);
        border = const Color(0xFFEF4444);
        text = const Color(0xFFFCA5A5);
        icon = Icons.local_fire_department_rounded;
        title = 'CRITICAL: Zener Maximum Power Rating Exceeded!';
        description =
            'Power dissipation Pz = ${result.pzMW.toStringAsFixed(1)} mW exceeds diode rating of ${(params.pzMax * 1000).toStringAsFixed(0)} mW! In real hardware, the diode would rapidly overheat and burn out. Increase series resistance Rs or lower Vin.';
        break;

      case CircuitStatus.shortCircuit:
        bg = const Color(0xFF831843).withOpacity(0.45);
        border = const Color(0xFFF43F5E);
        text = const Color(0xFFFECDD3);
        icon = Icons.dangerous_rounded;
        title = 'Short Circuit Hazard';
        description =
            'Series resistor Rs is virtually zero. Unbounded current will destroy the power supply and diode.';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.12),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: text,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: text.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
