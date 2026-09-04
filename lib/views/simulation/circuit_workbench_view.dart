import 'package:flutter/material.dart';
import '../../controllers/lab_controller.dart';
import 'circuit_controls_panel.dart';
import 'circuit_schematic_canvas.dart';
import 'digital_meter_panel.dart';
import 'status_warning_banner.dart';
import '../../widgets/formula_card.dart';

class CircuitWorkbenchView extends StatelessWidget {
  final LabController controller;

  const CircuitWorkbenchView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Alert Banner (Warning / Danger / Normal)
              StatusWarningBanner(
                result: controller.result,
                params: controller.params,
              ),
              const SizedBox(height: 16),

              if (isWide) ...[
                // Side-by-side layout for desktop / tablet
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Controls & Presets (40% width)
                    SizedBox(
                      width: constraints.maxWidth * 0.38,
                      child: CircuitControlsPanel(controller: controller),
                    ),
                    const SizedBox(width: 24),

                    // Right Column: Schematic, Meters, Formulas (62% width)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Animated Vector Schematic Canvas
                          CircuitSchematicCanvas(
                            params: controller.params,
                            result: controller.result,
                          ),
                          const SizedBox(height: 20),

                          // Digital Instrumentation Multimeter Panel
                          DigitalMeterPanel(
                            result: controller.result,
                            params: controller.params,
                          ),
                          const SizedBox(height: 20),

                          // Live Analytical Formula Breakdown
                          FormulaCard(
                            params: controller.params,
                            result: controller.result,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Stacked layout for mobile / compact screens
                // 1. Animated Vector Schematic Canvas
                CircuitSchematicCanvas(
                  params: controller.params,
                  result: controller.result,
                ),
                const SizedBox(height: 18),

                // 2. Digital Multimeter Readout Panel
                DigitalMeterPanel(
                  result: controller.result,
                  params: controller.params,
                ),
                const SizedBox(height: 20),

                // 3. Sliders & Interactive Controls
                CircuitControlsPanel(controller: controller),
                const SizedBox(height: 20),

                // 4. Formula Walkthrough
                FormulaCard(
                  params: controller.params,
                  result: controller.result,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
