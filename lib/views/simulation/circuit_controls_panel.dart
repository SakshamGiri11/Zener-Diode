import 'package:flutter/material.dart';
import '../../controllers/lab_controller.dart';
import '../../models/circuit_parameters.dart';
import '../../widgets/parameter_slider_card.dart';

class CircuitControlsPanel extends StatelessWidget {
  final LabController controller;

  const CircuitControlsPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final params = controller.params;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Presets & Guided Quick Experiments
        Container(
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
                  Icon(Icons.tune_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Circuit Presets & Experiments',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Diode Preset Selector
              DropdownButtonFormField<String>(
                initialValue: params.presetName,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Zener Diode Part',
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor, width: 1.2),
                  ),
                  filled: true,
                  fillColor:
                      isDark ? const Color(0xFF090E1A) : const Color(0xFFF8FAFC),
                ),
                items: [
                  ...ZenerPreset.standardPresets.map((p) {
                    return DropdownMenuItem<String>(
                      value: p.name,
                      child: Text(
                        p.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    );
                  }),
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Custom Parameters', style: TextStyle(fontSize: 13)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    final preset = ZenerPreset.standardPresets
                        .firstWhere((p) => p.name == val);
                    controller.applyPreset(preset);
                  }
                },
              ),

              const SizedBox(height: 12),
              // Guided experiment setup quick buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.setupLineRegulationExperiment();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Configured for Line Regulation: Vary Vin from 0V to 25V.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.show_chart_rounded, size: 16),
                      label: const Text(
                        'Line Reg. Setup',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        foregroundColor: const Color(0xFF38BDF8),
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.setupLoadRegulationExperiment();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Configured for Load Regulation: Vary RL from 100Ω to 2kΩ.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bar_chart_rounded, size: 16),
                      label: const Text(
                        'Load Reg. Setup',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        foregroundColor: const Color(0xFF34D399),
                        side: const BorderSide(color: Color(0xFF34D399), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Vin Control
        ParameterSliderCard(
          label: 'Input Voltage (Unregulated)',
          symbol: 'Vin',
          unit: 'V',
          value: params.vin,
          min: 0.0,
          max: 30.0,
          step: 0.5,
          divisions: 300,
          accentColor: const Color(0xFF38BDF8),
          quickValues: const [0, 5, 9, 12, 15, 20, 24, 30],
          onChanged: controller.setVin,
        ),

        // 3. Vz Control
        ParameterSliderCard(
          label: 'Zener Breakdown Voltage',
          symbol: 'Vz',
          unit: 'V',
          value: params.vz,
          min: 1.0,
          max: 24.0,
          step: 0.1,
          divisions: 230,
          accentColor: const Color(0xFF34D399),
          quickValues: const [3.3, 5.1, 6.2, 9.1, 12.0, 15.0],
          onChanged: controller.setVz,
        ),

        // 4. Rs Control
        ParameterSliderCard(
          label: 'Series Resistor',
          symbol: 'Rs',
          unit: 'Ω',
          value: params.rs,
          min: 10.0,
          max: 2000.0,
          step: 10.0,
          divisions: 199,
          accentColor: const Color(0xFFFBBF24),
          quickValues: const [50, 100, 220, 330, 470, 1000],
          onChanged: controller.setRs,
        ),

        // 5. RL Control with Open Circuit Toggle
        ParameterSliderCard(
          label: 'Load Resistance',
          symbol: 'RL',
          unit: 'Ω',
          value: params.rl,
          min: 20.0,
          max: 5000.0,
          step: 20.0,
          divisions: 249,
          accentColor: const Color(0xFFA78BFA),
          enabled: !params.isOpenCircuit,
          disabledMessage: 'Load Disconnected (Open Circuit)',
          quickValues: const [100, 220, 500, 1000, 2000, 4000],
          onChanged: controller.setRl,
        ),

        // Open Circuit Toggle Switch
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: params.isOpenCircuit ? const Color(0xFFF59E0B) : borderColor,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      params.isOpenCircuit
                          ? Icons.toggle_off_outlined
                          : Icons.toggle_on_rounded,
                      color: params.isOpenCircuit
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF38BDF8),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open Circuit Load (RL = ∞)',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            params.isOpenCircuit
                                ? 'No-load condition: Iz = Is'
                                : 'Load connected in shunt',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: params.isOpenCircuit,
                activeThumbColor: const Color(0xFFF59E0B),
                onChanged: controller.setIsOpenCircuit,
              ),
            ],
          ),
        ),

        // 6. Advanced Parameters (Pz Max & Non-Ideal Diode Model)
        Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            collapsedBackgroundColor: cardBg,
            backgroundColor: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 1.2),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 1.2),
            ),
            leading: const Icon(Icons.settings_suggest_rounded,
                size: 20, color: Color(0xFF38BDF8)),
            title: const Text(
              'Advanced Diode Specs',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  children: [
                    // Power rating selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Max Power Rating (Pz,max):',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                        DropdownButton<double>(
                          value: params.pzMax,
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: 0.25, child: Text('0.25 W (250mW)')),
                            DropdownMenuItem(value: 0.5, child: Text('0.50 W (500mW)')),
                            DropdownMenuItem(value: 1.0, child: Text('1.00 W (1W)')),
                            DropdownMenuItem(value: 2.0, child: Text('2.00 W (2W)')),
                            DropdownMenuItem(value: 5.0, child: Text('5.00 W (5W)')),
                          ],
                          onChanged: (v) {
                            if (v != null) controller.setPzMax(v);
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Non-ideal model switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Non-Ideal Diode (Dynamic rz)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Includes internal dynamic slope',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: params.useNonIdealModel,
                          onChanged: controller.setUseNonIdealModel,
                        ),
                      ],
                    ),

                    if (params.useNonIdealModel) ...[
                      const SizedBox(height: 10),
                      ParameterSliderCard(
                        label: 'Dynamic Resistance (rz)',
                        symbol: 'rz',
                        unit: 'Ω',
                        value: params.rz,
                        min: 0.5,
                        max: 50.0,
                        step: 0.5,
                        divisions: 99,
                        accentColor: const Color(0xFFFB7185),
                        onChanged: controller.setRz,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 7. Record Observation CTA Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              controller.recordObservation();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reading logged! (Vin=${params.vin.toStringAsFixed(1)}V, VL=${controller.result.vl.toStringAsFixed(2)}V, Iz=${controller.result.izCurrentMA.toStringAsFixed(1)}mA)',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.bookmark_add_rounded, size: 20),
            label: const Text(
              'Record Virtual Reading',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
