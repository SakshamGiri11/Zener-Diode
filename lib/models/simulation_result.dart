enum CircuitStatus {
  regulatingNormal,
  regulationLost,
  kneeCurrentWarning,
  overpowerWarning,
  shortCircuit,
}

class SimulationResult {
  final double vth; // Thevenin voltage (V)
  final double rth; // Thevenin resistance (Ohm)
  final double vl; // Load output voltage (V)
  final double vRs; // Series resistor voltage drop (V)
  final double isCurrent; // Source current Is (A)
  final double izCurrent; // Zener current Iz (A)
  final double ilCurrent; // Load current IL (A)
  final double pz; // Zener power dissipation (W)
  final double pRs; // Rs power dissipation (W)
  final double pLoad; // Load power dissipation (W)
  final double pIn; // Total power input (W)
  final double efficiency; // Efficiency % (PL / Pin * 100)
  final bool isZenerConductionActive; // Whether Zener is in breakdown conduction
  final CircuitStatus status;
  final String statusMessage;
  final String statusDescription;

  const SimulationResult({
    required this.vth,
    required this.rth,
    required this.vl,
    required this.vRs,
    required this.isCurrent,
    required this.izCurrent,
    required this.ilCurrent,
    required this.pz,
    required this.pRs,
    required this.pLoad,
    required this.pIn,
    required this.efficiency,
    required this.isZenerConductionActive,
    required this.status,
    required this.statusMessage,
    required this.statusDescription,
  });

  // Convenient getters for engineering display units
  double get isCurrentMA => isCurrent * 1000.0;
  double get izCurrentMA => izCurrent * 1000.0;
  double get ilCurrentMA => ilCurrent * 1000.0;
  double get pzMW => pz * 1000.0;
  double get pRsMW => pRs * 1000.0;
  double get pLoadMW => pLoad * 1000.0;
  double get pInMW => pIn * 1000.0;
}
