import 'package:flutter/material.dart';
import '../../controllers/lab_controller.dart';
import 'quiz_viva_view.dart';

class LabManualView extends StatefulWidget {
  final LabController controller;

  const LabManualView({
    super.key,
    required this.controller,
  });

  @override
  State<LabManualView> createState() => _LabManualViewState();
}

class _LabManualViewState extends State<LabManualView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    final cardBg = isDark ? const Color(0xFF131D2F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Page Header (Strict H vs P separation)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Color(0xFF38BDF8), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zener Diode Voltage Regulator Lab Manual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Department of Electronics & Electrical Engineering — Laboratory Course Curriculum',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Sub-Tab Navigation Bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0E1726) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.0),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(icon: Icon(Icons.flag_rounded, size: 16), text: '1. Objectives'),
                Tab(icon: Icon(Icons.psychology_rounded, size: 16), text: '2. Theory & Principle'),
                Tab(icon: Icon(Icons.calculate_rounded, size: 16), text: '3. Equations & Derivations'),
                Tab(icon: Icon(Icons.format_list_numbered_rounded, size: 16), text: '4. Lab Procedures'),
                Tab(icon: Icon(Icons.quiz_rounded, size: 16), text: '5. Viva-Voce Quiz'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Section Body
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              switch (_tabController.index) {
                case 0:
                  return _buildObjectivesSection(isDark, cardBg, borderColor);
                case 1:
                  return _buildTheorySection(isDark, cardBg, borderColor);
                case 2:
                  return _buildEquationsSection(isDark, cardBg, borderColor);
                case 3:
                  return _buildProceduresSection(isDark, cardBg, borderColor);
                case 4:
                  return QuizVivaView(controller: widget.controller);
                default:
                  return _buildObjectivesSection(isDark, cardBg, borderColor);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivesSection(bool isDark, Color cardBg, Color borderColor) {
    return _buildCard(
      isDark: isDark,
      cardBg: cardBg,
      borderColor: borderColor,
      title: 'Experiment Aim & Learning Outcomes',
      icon: Icons.flag_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParagraph(
            'Aim: To design, simulate, and analyze the voltage regulation characteristics of a reverse-biased Zener Diode under fluctuating DC input voltages (Line Regulation) and varying load resistances (Load Regulation).',
            isDark: isDark,
            isBold: true,
          ),
          const SizedBox(height: 16),
          _buildSectionSubheading('Key Learning Objectives:', isDark),
          const SizedBox(height: 8),
          _buildBulletPoint(
              'Understand the reverse breakdown mechanism (Zener Tunneling vs. Avalanche Multiplication) in heavily doped p-n junctions.',
              isDark),
          _buildBulletPoint(
              'Analyze the Thevenin equivalent criterion required for a Zener diode to turn ON and clamp the load voltage.',
              isDark),
          _buildBulletPoint(
              'Observe how Kirchhoff\'s Current Law (Is = Iz + IL) operates to maintain constant load voltage by diverting excess current through the Zener diode.',
              isDark),
          _buildBulletPoint(
              'Determine the bounds for the current-limiting series resistor Rs (Rs,min and Rs,max) to prevent diode thermal burnout and avoid dropouts.',
              isDark),
          _buildBulletPoint(
              'Calculate % Line Regulation and % Load Regulation from experimental readings.',
              isDark),
        ],
      ),
    );
  }

  Widget _buildTheorySection(bool isDark, Color cardBg, Color borderColor) {
    return _buildCard(
      isDark: isDark,
      cardBg: cardBg,
      borderColor: borderColor,
      title: 'Theory & Physics Principle',
      icon: Icons.psychology_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionSubheading('1. The Zener Diode in Reverse Breakdown', isDark),
          const SizedBox(height: 6),
          _buildParagraph(
            'A Zener diode is a silicon p-n junction semiconductor device manufactured with heavy doping concentrations (1 part in 10^4). Unlike standard rectifying diodes, it is specifically engineered to operate in the reverse breakdown region without damage, provided its thermal power rating is respected.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildParagraph(
            '• Zener Breakdown (Vz < 5.6V): Occurs in very thin depletion regions (< 10 nm) due to intense electric fields (~10^6 V/m) that pull valence electrons directly across the bandgap (quantum mechanical tunneling). Exhibits a negative temperature coefficient.\n\n'
            '• Avalanche Breakdown (Vz > 6.0V): Occurs in wider depletion regions where thermally generated carriers accelerate, collide with crystal lattice atoms, and free electron-hole pairs by impact ionization. Exhibits a positive temperature coefficient.',
            isDark: isDark,
          ),
          const SizedBox(height: 18),
          _buildSectionSubheading('2. Voltage Regulation Working Mechanism', isDark),
          const SizedBox(height: 6),
          _buildParagraph(
            'When connected in parallel (shunt) across a load resistance RL with a series current-limiting resistor Rs, the Zener diode acts as a self-adjusting dynamic resistor:\n\n'
            '1. If Vin increases: The voltage across the Zener tries to rise slightly. Due to its very low dynamic resistance (rz ≈ 0), the Zener current Iz increases significantly. The increased current flows through Rs, creating a larger voltage drop VRs = (Vin - Vz), thereby absorbing the entire voltage increase while keeping VL clamped at Vz.\n\n'
            '2. If RL decreases (Load current IL increases): The source current Is remains constant because (Vin - Vz)/Rs is fixed. To supply the additional load current IL, the Zener current Iz decreases automatically (Iz = Is - IL), maintaining VL unchanged.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildEquationsSection(bool isDark, Color cardBg, Color borderColor) {
    return _buildCard(
      isDark: isDark,
      cardBg: cardBg,
      borderColor: borderColor,
      title: 'Analytical Equations & Mathematical Derivations',
      icon: Icons.calculate_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEquationBox(
            title: '1. Thevenin Open-Circuit Voltage across Load (Breakdown Criterion)',
            formula: r'Vth = Vin × [ RL / (Rs + RL) ]  ≥  Vz',
            explanation:
                'If Vth < Vz, the Zener diode remains in OFF state (Iz = 0) and the circuit is simply an unregulated voltage divider: VL = Vth.',
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildEquationBox(
            title: '2. Branch Currents (Kirchhoff\'s Current Law)',
            formula: r'Is = (Vin - VL) / Rs' '\n'
                r'IL = VL / RL' '\n'
                r'Iz = Is - IL',
            explanation:
                'Total source current Is splits at the top node into Zener current Iz and Load current IL.',
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildEquationBox(
            title: '3. Series Resistor Design Bounds (Rs,min and Rs,max)',
            formula: r'Rs,min = (Vin,max - Vz) / Iz,max' '\n'
                r'Rs,max = (Vin,min - Vz) / (IL,max + Izk)',
            explanation:
                'Rs must be > Rs,min to prevent Iz exceeding maximum power rating Pz,max = Vz × Iz,max. Rs must be < Rs,max to ensure Iz does not drop below knee current Izk.',
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildEquationBox(
            title: '4. Performance Metrics (% Line & Load Regulation)',
            formula: r'% Line Regulation = (ΔVL / ΔVin) × 100%  (at constant RL)' '\n'
                r'% Load Regulation = [(V_NL - V_FL) / V_FL] × 100%  (at constant Vin)',
            explanation:
                'An ideal voltage regulator has 0.00% Line Regulation and 0.00% Load Regulation.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildProceduresSection(bool isDark, Color cardBg, Color borderColor) {
    return _buildCard(
      isDark: isDark,
      cardBg: cardBg,
      borderColor: borderColor,
      title: 'Step-by-Step Experimental Procedure',
      icon: Icons.format_list_numbered_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionSubheading('Part A: Line Regulation (VL vs. Vin)', isDark),
          const SizedBox(height: 8),
          _buildNumberedStep(1, 'Select a 5.1V Zener diode (1N4733A) and set Series Resistor Rs = 220 Ω, Load Resistor RL = 1000 Ω.', isDark),
          _buildNumberedStep(2, 'Start with Input Voltage Vin = 0 V. Tap "Record Virtual Reading".', isDark),
          _buildNumberedStep(3, 'Increase Vin in steps of 2V (e.g. 2V, 4V, 6V, 8V, 10V, 12V, 15V, 18V, 20V, 25V).', isDark),
          _buildNumberedStep(4, 'Observe the transition point where Vth ≥ Vz (~6.2V). Notice how VL rises linearly initially, then clamps flat at 5.1V.', isDark),
          _buildNumberedStep(5, 'Review the Line Regulation curve tab and observe the % Line Regulation in the Observation Table.', isDark),
          const SizedBox(height: 18),
          _buildSectionSubheading('Part B: Load Regulation (VL vs. IL)', isDark),
          const SizedBox(height: 8),
          _buildNumberedStep(1, 'Set Input Voltage Vin = 15.0 V and Series Resistor Rs = 220 Ω.', isDark),
          _buildNumberedStep(2, 'Enable the "Open Circuit Load" switch (RL = ∞, IL = 0). Record reading (No-load voltage V_NL).', isDark),
          _buildNumberedStep(3, 'Turn off open-circuit switch. Set RL = 4000 Ω, 2000 Ω, 1000 Ω, 500 Ω, 220 Ω, 100 Ω, 50 Ω.', isDark),
          _buildNumberedStep(4, 'Observe that as RL drops below ~100 Ω, IL exceeds available source current, causing Iz to drop to zero and regulation to fail.', isDark),
          _buildNumberedStep(5, 'Inspect the % Load Regulation calculation and export your completed dataset via CSV.', isDark),
        ],
      ),
    );
  }

  Widget _buildCard({
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                child: Icon(icon, size: 20, color: const Color(0xFF38BDF8)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionSubheading(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildParagraph(String text, {required bool isDark, bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.55,
        fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedStep(int step, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.5)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF38BDF8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquationBox({
    required String title,
    required String formula,
    required String explanation,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090E1A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
        ),
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
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D2F) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF22324D) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              formula,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF38BDF8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
