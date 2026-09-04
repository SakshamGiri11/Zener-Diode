import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/lab_controller.dart';

class ObservationTableView extends StatelessWidget {
  final LabController controller;

  const ObservationTableView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final observations = controller.observations;

    final lineReg = controller.calculateLineRegulation();
    final loadReg = controller.calculateLoadRegulation();

    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header & Actions Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Virtual Lab Observation Table',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log experimental readings across various input voltages (Vin) and load resistances (RL).',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.recordObservation();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reading logged to observation table.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Log Reading', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: observations.isEmpty
                        ? null
                        : () {
                            final csv = controller.getObservationsCsv();
                            Clipboard.setData(ClipboardData(text: csv));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Observation data copied to clipboard as CSV!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Copy CSV', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (observations.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                      tooltip: 'Clear Table',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear All Observations?'),
                            content: const Text(
                                'This will delete all logged readings in the observation table.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  controller.clearObservations();
                                  Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Clear All'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Statistical Analysis Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: '% Line Regulation',
                  formula: 'ΔVL / ΔVin × 100%',
                  value: lineReg != null
                      ? '${lineReg.toStringAsFixed(2)} %'
                      : (observations.length < 2 ? 'Need ≥ 2 readings' : 'Ideal: 0.00 %'),
                  ideal: 'Target: 0.00 % (Flat slope)',
                  accentColor: const Color(0xFF38BDF8),
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  context: context,
                  title: '% Load Regulation',
                  formula: '(V_NL - V_FL) / V_FL × 100%',
                  value: loadReg != null
                      ? '${loadReg.toStringAsFixed(2)} %'
                      : (observations.length < 2 ? 'Need ≥ 2 readings' : 'Ideal: 0.00 %'),
                  ideal: 'Target: 0.00 % (Stable VL)',
                  accentColor: const Color(0xFF34D399),
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Data Table Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: observations.isEmpty
                ? _buildEmptyState(isDark)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(
                          isDark ? const Color(0xFF090E1A) : const Color(0xFFF1F5F9),
                        ),
                        horizontalMargin: 16,
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Vin (V)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Vz (V)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Rs (Ω)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('RL (Ω)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('VL (V)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)))),
                          DataColumn(label: Text('Is (mA)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFBBF24)))),
                          DataColumn(label: Text('Iz (mA)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34D399)))),
                          DataColumn(label: Text('IL (mA)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFA78BFA)))),
                          DataColumn(label: Text('Pz (mW)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFB7185)))),
                          DataColumn(label: Text('Operating Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: observations.map((obs) {
                          final isReg = obs.izCurrentMA > 0.05;
                          return DataRow(
                            cells: [
                              DataCell(Text('${obs.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(
                                '${obs.timestamp.hour.toString().padLeft(2, '0')}:${obs.timestamp.minute.toString().padLeft(2, '0')}:${obs.timestamp.second.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
                              )),
                              DataCell(Text(obs.vin.toStringAsFixed(2))),
                              DataCell(Text(obs.vz.toStringAsFixed(2))),
                              DataCell(Text(obs.rs.toStringAsFixed(1))),
                              DataCell(Text(obs.isOpenCircuit ? 'Open (∞)' : obs.rl.toStringAsFixed(0))),
                              DataCell(Text(
                                obs.vl.toStringAsFixed(3),
                                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                              )),
                              DataCell(Text(obs.isCurrentMA.toStringAsFixed(2))),
                              DataCell(Text(
                                obs.izCurrentMA.toStringAsFixed(2),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isReg ? const Color(0xFF34D399) : Colors.grey,
                                ),
                              )),
                              DataCell(Text(obs.ilCurrentMA.toStringAsFixed(2))),
                              DataCell(Text(obs.pzMW.toStringAsFixed(1))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isReg
                                        ? const Color(0xFF0F3822)
                                        : const Color(0xFF38240F),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: isReg
                                          ? const Color(0xFF22C55E).withOpacity(0.5)
                                          : const Color(0xFFF59E0B).withOpacity(0.5),
                                    ),
                                  ),
                                  child: Text(
                                    obs.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isReg
                                          ? const Color(0xFF4ADE80)
                                          : const Color(0xFFFCD34D),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                                  tooltip: 'Delete reading',
                                  onPressed: () => controller.removeObservation(obs.id),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String formula,
    required String value,
    required String ideal,
    required Color accentColor,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.08 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF090E1A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              formula,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: accentColor,
                ),
              ),
              Text(
                ideal,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.table_chart_outlined, size: 52, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 14),
            Text(
              'No virtual readings logged yet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Adjust input voltage (Vin) or load resistance (RL) on the Simulation Workbench and click "Record Virtual Reading" to log your readings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
