import 'dart:math' as math;
import '../models/circuit_parameters.dart';
import '../models/simulation_result.dart';

class GraphPoint {
  final double x;
  final double y;
  final Map<String, double> extras;

  const GraphPoint({
    required this.x,
    required this.y,
    this.extras = const {},
  });
}

class CircuitPhysicsEngine {
  /// Solves the complete DC state of the Zener Diode Voltage Regulator circuit
  static SimulationResult calculate(CircuitParameters params) {
    // 1. Safety check for short circuit
    if (params.rs < 0.1) {
      return const SimulationResult(
        vth: 0,
        rth: 0,
        vl: 0,
        vRs: 0,
        isCurrent: 0,
        izCurrent: 0,
        ilCurrent: 0,
        pz: 0,
        pRs: 0,
        pLoad: 0,
        pIn: 0,
        efficiency: 0,
        isZenerConductionActive: false,
        status: CircuitStatus.shortCircuit,
        statusMessage: 'Short Circuit Warning',
        statusDescription:
            'Series resistance Rs is too close to 0 Ohm. Current is unbounded.',
      );
    }

    final double vin = params.vin;
    final double vz = params.vz;
    final double rs = params.rs;
    final double rl = params.rl;
    final bool isOpen = params.isOpenCircuit;
    final double pzMax = params.pzMax;
    final double rz = params.useNonIdealModel ? math.max(0.1, params.rz) : 0.0;
    final double izk = params.izk;

    // 2. Thevenin Equivalent calculations across load terminals
    final double vth;
    final double rth;
    if (isOpen) {
      vth = vin;
      rth = rs;
    } else {
      vth = vin * (rl / (rs + rl));
      rth = (rs * rl) / (rs + rl);
    }

    // 3. Operating state determination
    // If Vth < Vz, diode is OFF (acts as open circuit)
    if (vth < vz || vin <= 0) {
      final double vl;
      final double isCurrent;
      final double ilCurrent;
      const double izCurrent = 0.0;

      if (isOpen) {
        vl = vin;
        isCurrent = 0.0;
        ilCurrent = 0.0;
      } else {
        vl = vth;
        isCurrent = vin / (rs + rl);
        ilCurrent = isCurrent;
      }

      final double vRs = isCurrent * rs;
      final double pz = 0.0;
      final double pRs = isCurrent * isCurrent * rs;
      final double pLoad = ilCurrent * vl;
      final double pIn = vin * isCurrent;
      final double efficiency = pIn > 0.000001 ? (pLoad / pIn) * 100.0 : 0.0;

      return SimulationResult(
        vth: vth,
        rth: rth,
        vl: vl,
        vRs: vRs,
        isCurrent: isCurrent,
        izCurrent: izCurrent,
        ilCurrent: ilCurrent,
        pz: pz,
        pRs: pRs,
        pLoad: pLoad,
        pIn: pIn,
        efficiency: efficiency,
        isZenerConductionActive: false,
        status: CircuitStatus.regulationLost,
        statusMessage: 'Regulation Lost (Vth < Vz)',
        statusDescription:
            'Thevenin open-circuit voltage (${vth.toStringAsFixed(2)} V) is below breakdown threshold (${vz.toStringAsFixed(2)} V). Zener diode is OFF; circuit acts as an unregulated resistor divider.',
      );
    }

    // 4. Breakdown active: Diode is conducting
    final double vl;
    final double isCurrent;
    final double ilCurrent;
    final double izCurrent;

    if (rz > 0.0 && params.useNonIdealModel) {
      // Non-ideal model with dynamic resistance rz:
      // Node equation at VL: (Vin - VL)/Rs = (VL - Vz)/rz + (isOpen ? 0 : VL/RL)
      final double gRs = 1.0 / rs;
      final double gRz = 1.0 / rz;
      final double gRl = isOpen ? 0.0 : (1.0 / rl);
      final double numerator = (vin * gRs) + (vz * gRz);
      final double denominator = gRs + gRz + gRl;
      vl = numerator / denominator;

      isCurrent = (vin - vl) / rs;
      ilCurrent = isOpen ? 0.0 : (vl / rl);
      izCurrent = (vl - vz) / rz;
    } else {
      // Ideal Zener model: VL is clamped exactly to Vz
      vl = vz;
      isCurrent = (vin - vz) / rs;
      ilCurrent = isOpen ? 0.0 : (vz / rl);
      izCurrent = isCurrent - ilCurrent;
    }

    final double vRs = vin - vl;
    final double pz = vl * izCurrent;
    final double pRs = isCurrent * isCurrent * rs;
    final double pLoad = ilCurrent * vl;
    final double pIn = vin * isCurrent;
    final double efficiency = pIn > 0.000001 ? (pLoad / pIn) * 100.0 : 0.0;

    // 5. Evaluate warnings
    CircuitStatus status;
    String statusMsg;
    String statusDesc;

    if (pz > pzMax) {
      status = CircuitStatus.overpowerWarning;
      statusMsg = 'Zener Rating Exceeded (Pz > Pz,max)';
      statusDesc =
          'Power dissipation (${(pz * 1000).toStringAsFixed(1)} mW) exceeds maximum rating (${(pzMax * 1000).toStringAsFixed(0)} mW). Diode will overheat and burn out!';
    } else if (izCurrent < izk) {
      status = CircuitStatus.kneeCurrentWarning;
      statusMsg = 'Near Knee Region (Iz < Izk)';
      statusDesc =
          'Zener current (${(izCurrent * 1000).toStringAsFixed(2)} mA) is below recommended knee current (${(izk * 1000).toStringAsFixed(2)} mA). Voltage regulation is poor.';
    } else {
      status = CircuitStatus.regulatingNormal;
      statusMsg = 'Regulating Normally';
      statusDesc =
          'Zener diode is in stable reverse breakdown. Output voltage is clamped at ${vl.toStringAsFixed(2)} V. Variations in Vin are absorbed by Iz.';
    }

    return SimulationResult(
      vth: vth,
      rth: rth,
      vl: vl,
      vRs: vRs,
      isCurrent: isCurrent,
      izCurrent: izCurrent,
      ilCurrent: ilCurrent,
      pz: pz,
      pRs: pRs,
      pLoad: pLoad,
      pIn: pIn,
      efficiency: efficiency,
      isZenerConductionActive: true,
      status: status,
      statusMessage: statusMsg,
      statusDescription: statusDesc,
    );
  }

  /// Generates data points for Line Regulation: VL vs Vin with fixed Rs, RL
  static List<GraphPoint> generateLineRegulationCurve(
    CircuitParameters params, {
    double minVin = 0.0,
    double maxVin = 30.0,
    int points = 120,
  }) {
    final List<GraphPoint> data = [];
    final double step = (maxVin - minVin) / points;

    for (int i = 0; i <= points; i++) {
      final double testVin = minVin + (i * step);
      final sim = calculate(params.copyWith(vin: testVin));
      data.add(GraphPoint(
        x: testVin,
        y: sim.vl,
        extras: {
          'isMA': sim.isCurrentMA,
          'izMA': sim.izCurrentMA,
          'ilMA': sim.ilCurrentMA,
          'pzMW': sim.pzMW,
          'isRegulating': sim.isZenerConductionActive ? 1.0 : 0.0,
        },
      ));
    }
    return data;
  }

  /// Generates data points for Load Regulation: VL vs IL (sweeping RL)
  static List<GraphPoint> generateLoadRegulationCurve(
    CircuitParameters params, {
    int points = 100,
  }) {
    final List<GraphPoint> data = [];
    // Sweep RL from very high (near open circuit) down to a low value (overloaded)
    // Low RL -> High IL, High RL -> Low IL
    const double minRl = 20.0;
    const double maxRl = 4000.0;

    for (int i = 0; i <= points; i++) {
      // Use logarithmic or smooth distribution for RL
      final double t = i / points;
      final double testRl = minRl * math.pow(maxRl / minRl, t);
      final sim = calculate(params.copyWith(rl: testRl, isOpenCircuit: false));
      data.add(GraphPoint(
        x: sim.ilCurrentMA,
        y: sim.vl,
        extras: {
          'rl': testRl,
          'izMA': sim.izCurrentMA,
          'isMA': sim.isCurrentMA,
          'pzMW': sim.pzMW,
          'isRegulating': sim.isZenerConductionActive ? 1.0 : 0.0,
        },
      ));
    }
    // Sort by IL ascending
    data.sort((a, b) => a.x.compareTo(b.x));
    return data;
  }

  /// Generates complete Zener Diode I-V characteristic curve: I_D (mA) vs V_D (V)
  static List<GraphPoint> generateZenerIVCurve(
    CircuitParameters params, {
    int points = 200,
  }) {
    final List<GraphPoint> data = [];
    final double vz = params.vz;
    final double rz = params.useNonIdealModel ? math.max(0.1, params.rz) : 0.5;

    // We sweep V_D from -1.3*Vz (deep reverse breakdown) up to +0.8V (forward conduction)
    final double vMin = -1.35 * vz;
    const double vMax = 0.85;
    final double step = (vMax - vMin) / points;

    for (int i = 0; i <= points; i++) {
      final double vd = vMin + (i * step);
      double idMA = 0.0; // Current in mA flowing anode -> cathode

      if (vd >= 0.0) {
        // Forward bias: Standard Shockley diode equation approx (Vf ~ 0.65V - 0.7V)
        // Id = Is_sat * (e^(vd / 0.026) - 1)
        if (vd < 0.6) {
          idMA = 0.01 * (math.exp(vd / 0.09) - 1.0);
        } else {
          // Linearized forward conduction above knee
          idMA = 0.01 * (math.exp(0.6 / 0.09) - 1.0) + ((vd - 0.6) / 0.005) * 1000;
        }
      } else if (vd > -vz) {
        // Reverse leakage region (before breakdown): very small microamp leakage
        idMA = -0.0005 * (1.0 - math.exp(vd / 0.5));
      } else {
        // Reverse breakdown region: vd <= -vz
        // Reverse current Iz = (abs(vd) - vz) / rz
        final double deltaV = -vd - vz;
        final double izAmps = (deltaV / rz) + 0.001; // knee transition
        idMA = -izAmps * 1000.0; // Negative mA in standard I-V quadrant
      }

      data.add(GraphPoint(x: vd, y: idMA));
    }
    return data;
  }
}
