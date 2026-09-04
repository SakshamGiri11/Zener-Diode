import 'package:flutter/material.dart';
import '../../controllers/lab_controller.dart';
import 'custom_chart_painter.dart';

class InteractiveGraphsView extends StatefulWidget {
  final LabController controller;

  const InteractiveGraphsView({
    super.key,
    required this.controller,
  });

  @override
  State<InteractiveGraphsView> createState() => _InteractiveGraphsViewState();
}

class _InteractiveGraphsViewState extends State<InteractiveGraphsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = widget.controller;
    final params = controller.params;
    final result = controller.result;

    final double vinMinBreakdown = params.isOpenCircuit
        ? params.vz
        : (params.vz * (params.rs + params.rl) / params.rl);

    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header (Strict H vs P typography separation)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interactive Regulation Curves & Characteristics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Theoretical physics curves dynamically calculated and synchronized with active circuit parameters.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Tab Bar Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0E1726) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? const Color(0xFF0284C7) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              tabs: const [
                Tab(
                  icon: Icon(Icons.show_chart_rounded, size: 18),
                  text: '1. Line Regulation (VL vs Vin)',
                ),
                Tab(
                  icon: Icon(Icons.stacked_line_chart_rounded, size: 18),
                  text: '2. Load Regulation (VL vs IL)',
                ),
                Tab(
                  icon: Icon(Icons.timeline_rounded, size: 18),
                  text: '3. Diode I-V Curve',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Graph Container
          Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Line Regulation (VL vs Vin)
                _buildLineRegulationTab(
                  controller: controller,
                  params: params,
                  result: result,
                  vinMinBreakdown: vinMinBreakdown,
                  isDark: isDark,
                ),

                // TAB 2: Load Regulation (VL vs IL)
                _buildLoadRegulationTab(
                  controller: controller,
                  params: params,
                  result: result,
                  isDark: isDark,
                ),

                // TAB 3: Zener I-V Curve
                _buildIVCurveTab(
                  controller: controller,
                  params: params,
                  result: result,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. Graph Insights Card
          _buildGraphInsightsCard(
            tabIndex: _tabController.index,
            params: params,
            result: result,
            vinMinBreakdown: vinMinBreakdown,
            isDark: isDark,
            cardBg: cardBg,
            borderColor: borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildLineRegulationTab({
    required LabController controller,
    required dynamic params,
    required dynamic result,
    required double vinMinBreakdown,
    required bool isDark,
  }) {
    final expPoints = controller.observations
        .where((o) => (o.rs - params.rs).abs() < 1.0)
        .map((o) => Offset(o.vin, o.vl))
        .toList();

    return CustomPaint(
      painter: CustomChartPainter(
        dataPoints: controller.lineCurve,
        title: 'Line Regulation: VL vs Vin',
        xLabel: 'Input Voltage Vin (V)',
        yLabel: 'Load Voltage VL (V)',
        activePointX: params.vin,
        activePointY: result.vl,
        activePointLabel:
            'Active: Vin=${params.vin.toStringAsFixed(1)}V, VL=${result.vl.toStringAsFixed(2)}V',
        referenceY: params.vz,
        referenceYLabel: 'Vz = ${params.vz.toStringAsFixed(1)}V',
        thresholdX: vinMinBreakdown,
        thresholdXLabel: 'Vin,min = ${vinMinBreakdown.toStringAsFixed(1)}V',
        experimentalPoints: expPoints,
        isDark: isDark,
        curveColor: const Color(0xFF38BDF8),
        showZones: true,
        zoneLeftLabel: 'DROPOUT (UNREGULATED)',
        zoneRightLabel: 'STABLE REGULATION ZONE',
      ),
      size: Size.infinite,
    );
  }

  Widget _buildLoadRegulationTab({
    required LabController controller,
    required dynamic params,
    required dynamic result,
    required bool isDark,
  }) {
    final expPoints = controller.observations
        .where((o) => (o.vin - params.vin).abs() < 0.5)
        .map((o) => Offset(o.ilCurrentMA, o.vl))
        .toList();

    return CustomPaint(
      painter: CustomChartPainter(
        dataPoints: controller.loadCurve,
        title: 'Load Regulation: VL vs IL',
        xLabel: 'Load Current IL (mA)',
        yLabel: 'Load Voltage VL (V)',
        activePointX: result.ilCurrentMA,
        activePointY: result.vl,
        activePointLabel:
            'Active: IL=${result.ilCurrentMA.toStringAsFixed(1)}mA, VL=${result.vl.toStringAsFixed(2)}V',
        referenceY: params.vz,
        referenceYLabel: 'Vz = ${params.vz.toStringAsFixed(1)}V',
        experimentalPoints: expPoints,
        isDark: isDark,
        curveColor: const Color(0xFFA78BFA),
      ),
      size: Size.infinite,
    );
  }

  Widget _buildIVCurveTab({
    required LabController controller,
    required dynamic params,
    required dynamic result,
    required bool isDark,
  }) {
    final double diodeV = result.isZenerConductionActive ? -result.vl : -result.vth;
    final double diodeIMA = -result.izCurrentMA;

    return CustomPaint(
      painter: CustomChartPainter(
        dataPoints: controller.ivCurve,
        title: 'Zener Diode I-V Characteristic',
        xLabel: 'Diode Voltage VD (V)',
        yLabel: 'Diode Current ID (mA)',
        activePointX: diodeV,
        activePointY: diodeIMA,
        activePointLabel:
            'Bias Point: (${diodeV.toStringAsFixed(2)}V, ${diodeIMA.toStringAsFixed(1)}mA)',
        referenceY: 0,
        thresholdX: -params.vz,
        thresholdXLabel: '-Vz Knee',
        isDark: isDark,
        curveColor: const Color(0xFF34D399),
      ),
      size: Size.infinite,
    );
  }

  Widget _buildGraphInsightsCard({
    required int tabIndex,
    required dynamic params,
    required dynamic result,
    required double vinMinBreakdown,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
  }) {
    final vinMinFormatted = vinMinBreakdown.toStringAsFixed(1);
    final vzFormatted = (params.vz as double).toStringAsFixed(2);

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
          // Section Heading (H)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school_rounded, size: 18, color: Color(0xFF38BDF8)),
              ),
              const SizedBox(width: 10),
              Text(
                'Physics Interpretation & Engineering Observations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Body Paragraphs / Bullet List (P)
          _buildInsightBullet(
            title: 'Knee Breakdown Threshold:',
            body: '$vinMinFormatted V is the minimum input voltage needed for regulation. Below this threshold, VL = Vin × [RL / (Rs + RL)].',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildInsightBullet(
            title: 'Regulation Plateau:',
            body: 'Above $vinMinFormatted V, the Zener diode enters reverse breakdown and clamps output load voltage rigidly at $vzFormatted V.',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildInsightBullet(
            title: 'Current Redistribution:',
            body: 'As Vin fluctuates, total source current Is changes, but the excess current is diverted into Iz, keeping load current IL and voltage VL rock steady.',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildInsightBullet(
            title: 'Observation Overlay:',
            body: 'Pink circular markers denote your logged virtual lab readings plotted directly on top of theoretical equations.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBullet({
    required String title,
    required String body,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 6, color: Color(0xFF38BDF8)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
              children: [
                TextSpan(
                  text: '$title ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                  ),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
