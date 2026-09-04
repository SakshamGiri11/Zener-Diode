class ObservationEntry {
  final int id;
  final DateTime timestamp;
  final String experimentType;
  final double vin;
  final double vz;
  final double rs;
  final double rl;
  final bool isOpenCircuit;
  final double vl;
  final double isCurrentMA;
  final double izCurrentMA;
  final double ilCurrentMA;
  final double pzMW;
  final String status;
  final String notes;

  const ObservationEntry({
    required this.id,
    required this.timestamp,
    required this.experimentType,
    required this.vin,
    required this.vz,
    required this.rs,
    required this.rl,
    required this.isOpenCircuit,
    required this.vl,
    required this.isCurrentMA,
    required this.izCurrentMA,
    required this.ilCurrentMA,
    required this.pzMW,
    required this.status,
    this.notes = '',
  });

  String toCsvRow() {
    final rlStr = isOpenCircuit ? 'Open (Inf)' : rl.toStringAsFixed(1);
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    return '$id,"$timeStr","$experimentType",${vin.toStringAsFixed(2)},${vz.toStringAsFixed(2)},${rs.toStringAsFixed(1)},$rlStr,${vl.toStringAsFixed(3)},${isCurrentMA.toStringAsFixed(2)},${izCurrentMA.toStringAsFixed(2)},${ilCurrentMA.toStringAsFixed(2)},${pzMW.toStringAsFixed(1)},"$status","$notes"';
  }

  static String get csvHeader =>
      'Reading #,Time,Experiment,Vin (V),Vz (V),Rs (Ohm),RL (Ohm),VL (V),Is (mA),Iz (mA),IL (mA),Pz (mW),Status,Notes';
}
