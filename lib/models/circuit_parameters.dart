class ZenerPreset {
  final String name;
  final String partNumber;
  final double vz; // Breakdown voltage in Volts
  final double pzMax; // Max power rating in Watts
  final double rz; // Dynamic resistance in Ohms
  final double izk; // Knee current in Amps

  const ZenerPreset({
    required this.name,
    required this.partNumber,
    required this.vz,
    required this.pzMax,
    required this.rz,
    this.izk = 0.001, // 1 mA default knee
  });

  static const List<ZenerPreset> standardPresets = [
    ZenerPreset(
      name: '1N4728A (3.3V, 1W)',
      partNumber: '1N4728A',
      vz: 3.3,
      pzMax: 1.0,
      rz: 10.0,
      izk: 0.001,
    ),
    ZenerPreset(
      name: '1N4733A (5.1V, 1W)',
      partNumber: '1N4733A',
      vz: 5.1,
      pzMax: 1.0,
      rz: 7.0,
      izk: 0.001,
    ),
    ZenerPreset(
      name: '1N4735A (6.2V, 1W)',
      partNumber: '1N4735A',
      vz: 6.2,
      pzMax: 1.0,
      rz: 2.0,
      izk: 0.001,
    ),
    ZenerPreset(
      name: '1N4739A (9.1V, 1W)',
      partNumber: '1N4739A',
      vz: 9.1,
      pzMax: 1.0,
      rz: 5.0,
      izk: 0.0005,
    ),
    ZenerPreset(
      name: '1N4742A (12.0V, 1W)',
      partNumber: '1N4742A',
      vz: 12.0,
      pzMax: 1.0,
      rz: 9.0,
      izk: 0.00025,
    ),
    ZenerPreset(
      name: '1N4744A (15.0V, 1W)',
      partNumber: '1N4744A',
      vz: 15.0,
      pzMax: 1.0,
      rz: 16.0,
      izk: 0.00025,
    ),
    ZenerPreset(
      name: 'BZX55C5V6 (5.6V, 0.5W)',
      partNumber: 'BZX55C5V6',
      vz: 5.6,
      pzMax: 0.5,
      rz: 15.0,
      izk: 0.001,
    ),
  ];
}

class CircuitParameters {
  final double vin; // Input voltage in Volts (e.g., 0 - 30V)
  final double vz; // Zener breakdown voltage in Volts (e.g., 1 - 20V)
  final double rs; // Series resistor in Ohms (e.g., 10 - 2000 Ohm)
  final double rl; // Load resistor in Ohms (e.g., 10 - 10000 Ohm)
  final bool isOpenCircuit; // If true, RL is disconnected (RL = infinity)
  final double pzMax; // Zener maximum power rating in Watts (e.g., 0.5W, 1.0W)
  final double rz; // Dynamic resistance in Ohms (0 for ideal)
  final double izk; // Minimum knee current in Amps
  final bool useNonIdealModel; // Whether to include rz in calculations
  final String? presetName;

  const CircuitParameters({
    this.vin = 15.0,
    this.vz = 5.1,
    this.rs = 220.0,
    this.rl = 1000.0,
    this.isOpenCircuit = false,
    this.pzMax = 1.0,
    this.rz = 7.0,
    this.izk = 0.001,
    this.useNonIdealModel = false,
    this.presetName = '1N4733A (5.1V, 1W)',
  });

  CircuitParameters copyWith({
    double? vin,
    double? vz,
    double? rs,
    double? rl,
    bool? isOpenCircuit,
    double? pzMax,
    double? rz,
    double? izk,
    bool? useNonIdealModel,
    String? presetName,
    bool clearPreset = false,
  }) {
    return CircuitParameters(
      vin: vin ?? this.vin,
      vz: vz ?? this.vz,
      rs: rs ?? this.rs,
      rl: rl ?? this.rl,
      isOpenCircuit: isOpenCircuit ?? this.isOpenCircuit,
      pzMax: pzMax ?? this.pzMax,
      rz: rz ?? this.rz,
      izk: izk ?? this.izk,
      useNonIdealModel: useNonIdealModel ?? this.useNonIdealModel,
      presetName: clearPreset ? null : (presetName ?? this.presetName),
    );
  }
}
