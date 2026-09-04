import 'package:flutter/material.dart';
import '../../models/simulation_result.dart';
import '../../models/circuit_parameters.dart';

class DigitalMeterPanel extends StatelessWidget {
  final SimulationResult result;
  final CircuitParameters params;

  const DigitalMeterPanel({
    super.key,
    required this.result,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 720
            ? 4
            : (constraints.maxWidth > 400 ? 2 : 1);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.15,
          children: [
            // 1. Regulated Load Voltage VL
            _buildMeterCard(
              context: context,
              label: 'LOAD VOLTAGE',
              symbol: 'VL',
              value: result.vl.toStringAsFixed(3),
              unit: 'V',
              accentColor: const Color(0xFF38BDF8),
              subtitle: 'Target: ${params.vz.toStringAsFixed(2)} V',
              icon: Icons.electric_bolt_rounded,
              isHighlight: true,
            ),

            // 2. Zener Current Iz
            _buildMeterCard(
              context: context,
              label: 'ZENER CURRENT',
              symbol: 'Iz',
              value: result.izCurrentMA.toStringAsFixed(2),
              unit: 'mA',
              accentColor: const Color(0xFF34D399),
              subtitle: result.isZenerConductionActive ? 'Shunt active' : 'Diode OFF',
              icon: Icons.alt_route_rounded,
              isHighlight: true,
            ),

            // 3. Load Current IL
            _buildMeterCard(
              context: context,
              label: 'LOAD CURRENT',
              symbol: 'IL',
              value: result.ilCurrentMA.toStringAsFixed(2),
              unit: 'mA',
              accentColor: const Color(0xFFA78BFA),
              subtitle: params.isOpenCircuit ? 'Open Circuit' : 'Through RL',
              icon: Icons.arrow_downward_rounded,
            ),

            // 4. Source Current Is
            _buildMeterCard(
              context: context,
              label: 'TOTAL CURRENT',
              symbol: 'Is',
              value: result.isCurrentMA.toStringAsFixed(2),
              unit: 'mA',
              accentColor: const Color(0xFFFBBF24),
              subtitle: 'Is = Iz + IL',
              icon: Icons.input_rounded,
            ),

            // 5. Zener Power Dissipation Pz
            _buildMeterCard(
              context: context,
              label: 'ZENER POWER',
              symbol: 'Pz',
              value: result.pzMW.toStringAsFixed(1),
              unit: 'mW',
              accentColor: result.pz > params.pzMax
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFFB7185),
              subtitle: 'Rating: ${(params.pzMax * 1000).toStringAsFixed(0)} mW',
              icon: Icons.local_fire_department_rounded,
              isWarning: result.pz > params.pzMax,
            ),

            // 6. Resistor Rs Drop VRs
            _buildMeterCard(
              context: context,
              label: 'SERIES DROP',
              symbol: 'VRs',
              value: result.vRs.toStringAsFixed(2),
              unit: 'V',
              accentColor: const Color(0xFFF59E0B),
              subtitle: 'Vin - VL',
              icon: Icons.remove_circle_outline_rounded,
            ),

            // 7. Load Power PL
            _buildMeterCard(
              context: context,
              label: 'LOAD POWER',
              symbol: 'PL',
              value: result.pLoadMW.toStringAsFixed(1),
              unit: 'mW',
              accentColor: const Color(0xFF818CF8),
              subtitle: 'Useful output',
              icon: Icons.lightbulb_outline_rounded,
            ),

            // 8. Circuit Efficiency
            _buildMeterCard(
              context: context,
              label: 'EFFICIENCY',
              symbol: 'η',
              value: result.efficiency.toStringAsFixed(1),
              unit: '%',
              accentColor: const Color(0xFF2DD4BF),
              subtitle: 'PL / Pin × 100',
              icon: Icons.speed_rounded,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMeterCard({
    required BuildContext context,
    required String label,
    required String symbol,
    required String value,
    required String unit,
    required Color accentColor,
    required String subtitle,
    required IconData icon,
    bool isHighlight = false,
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFEF4444)
              : (isHighlight ? accentColor.withOpacity(0.6) : borderColor),
          width: isHighlight || isWarning ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isWarning ? Colors.red : accentColor).withOpacity(isDark ? 0.08 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$label ($symbol)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: accentColor),
            ],
          ),

          // Main Reading
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isWarning ? const Color(0xFFEF4444) : accentColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
            ],
          ),

          // Subtitle / Target
          Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
