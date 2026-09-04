import 'package:flutter/material.dart';
import '../models/circuit_parameters.dart';
import '../models/simulation_result.dart';

class FormulaCard extends StatelessWidget {
  final CircuitParameters params;
  final SimulationResult result;

  const FormulaCard({
    super.key,
    required this.params,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.functions_rounded, size: 18, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Analytical Formula Walkthrough',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Step-by-step mathematical substitution for active circuit values',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Thevenin Check
          _buildFormulaRow(
            stepNumber: '1',
            title: 'Thevenin Open-Circuit Voltage Across Diode (Vth)',
            formula: r'Vth = Vin × [ RL / (Rs + RL) ]',
            substitution: params.isOpenCircuit
                ? 'RL is disconnected (Open Circuit)  =>  Vth = Vin = ${params.vin.toStringAsFixed(2)} V'
                : 'Vth = ${params.vin.toStringAsFixed(2)} V × [ ${params.rl.toStringAsFixed(0)} / (${params.rs.toStringAsFixed(0)} + ${params.rl.toStringAsFixed(0)}) ] = ${result.vth.toStringAsFixed(2)} V',
            conclusion: result.isZenerConductionActive
                ? 'Condition Satisfied: Vth (${result.vth.toStringAsFixed(2)} V) ≥ Vz (${params.vz.toStringAsFixed(2)} V) => Zener Diode is ON (Breakdown)'
                : 'Condition Failed: Vth (${result.vth.toStringAsFixed(2)} V) < Vz (${params.vz.toStringAsFixed(2)} V) => Zener Diode is OFF (Unregulated)',
            isPassed: result.isZenerConductionActive,
            isDark: isDark,
          ),
          const Divider(height: 24),

          // 2. Source Current Is
          _buildFormulaRow(
            stepNumber: '2',
            title: 'Source Series Current (Is)',
            formula: r'Is = (Vin - VL) / Rs',
            substitution:
                'Is = (${params.vin.toStringAsFixed(2)} V - ${result.vl.toStringAsFixed(2)} V) / ${params.rs.toStringAsFixed(1)} Ω = ${result.isCurrentMA.toStringAsFixed(2)} mA',
            conclusion: null,
            isPassed: true,
            isDark: isDark,
          ),
          const Divider(height: 24),

          // 3. Load Current IL
          _buildFormulaRow(
            stepNumber: '3',
            title: 'Load Branch Current (IL)',
            formula: r'IL = VL / RL',
            substitution: params.isOpenCircuit
                ? 'RL is Open Circuit => IL = 0.00 mA'
                : 'IL = ${result.vl.toStringAsFixed(2)} V / ${params.rl.toStringAsFixed(1)} Ω = ${result.ilCurrentMA.toStringAsFixed(2)} mA',
            conclusion: null,
            isPassed: true,
            isDark: isDark,
          ),
          const Divider(height: 24),

          // 4. Zener Current Iz (KCL)
          _buildFormulaRow(
            stepNumber: '4',
            title: "Zener Shunt Current (Iz by Kirchhoff's Current Law)",
            formula: r'Iz = Is - IL',
            substitution:
                'Iz = ${result.isCurrentMA.toStringAsFixed(2)} mA - ${result.ilCurrentMA.toStringAsFixed(2)} mA = ${result.izCurrentMA.toStringAsFixed(2)} mA',
            conclusion: result.izCurrentMA < 1.0 && result.isZenerConductionActive
                ? 'Warning: Iz is very close to knee current (Izk ~ 1.0 mA)'
                : null,
            isPassed: result.izCurrentMA >= 1.0,
            isDark: isDark,
          ),
          const Divider(height: 24),

          // 5. Zener Power Dissipation Pz
          _buildFormulaRow(
            stepNumber: '5',
            title: 'Zener Power Dissipation (Pz)',
            formula: r'Pz = Vz × Iz',
            substitution:
                'Pz = ${result.vl.toStringAsFixed(2)} V × ${result.izCurrentMA.toStringAsFixed(2)} mA = ${result.pzMW.toStringAsFixed(1)} mW (Max: ${(params.pzMax * 1000).toStringAsFixed(0)} mW)',
            conclusion: result.pz > params.pzMax
                ? 'CRITICAL: Pz EXCEEDS MAXIMUM RATING!'
                : 'Safe Operating Area: Thermal dissipation is within rated limits.',
            isPassed: result.pz <= params.pzMax,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaRow({
    required String stepNumber,
    required String title,
    required String formula,
    required String substitution,
    required String? conclusion,
    required bool isPassed,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Step $stepNumber',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Formula pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF090E1A) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Text(
            formula,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF38BDF8),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Paragraph / Calculation result
        Text(
          substitution,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.45,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          ),
        ),

        // Conclusion / Warning
        if (conclusion != null) ...[
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPassed
                  ? const Color(0xFF10B981).withOpacity(0.12)
                  : const Color(0xFFEF4444).withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              conclusion,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isPassed ? const Color(0xFF34D399) : const Color(0xFFF87171),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
