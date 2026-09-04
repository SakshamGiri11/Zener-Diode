import 'package:flutter_test/flutter_test.dart';
import 'package:zener_regulator_lab/models/circuit_parameters.dart';
import 'package:zener_regulator_lab/models/simulation_result.dart';
import 'package:zener_regulator_lab/physics/circuit_physics_engine.dart';
import 'package:zener_regulator_lab/controllers/lab_controller.dart';

void main() {
  group('Zener Diode Circuit Physics Engine Tests', () {
    test('1. Normal Regulation: Vin > Vz and Vth >= Vz', () {
      const params = CircuitParameters(
        vin: 15.0,
        vz: 5.1,
        rs: 220.0,
        rl: 1000.0,
        isOpenCircuit: false,
        pzMax: 1.0,
        useNonIdealModel: false,
      );

      final result = CircuitPhysicsEngine.calculate(params);

      expect(result.status, CircuitStatus.regulatingNormal);
      expect(result.isZenerConductionActive, isTrue);
      expect(result.vl, closeTo(5.1, 0.001));
      expect(result.isCurrentMA, closeTo(45.0, 0.05));
      expect(result.ilCurrentMA, closeTo(5.1, 0.05));
      expect(result.izCurrentMA, closeTo(39.9, 0.05));
      expect(result.pzMW, closeTo(203.5, 0.5));
    });

    test('2. Regulation Loss: Vth < Vz (Diode OFF)', () {
      const params = CircuitParameters(
        vin: 5.0,
        vz: 5.1,
        rs: 220.0,
        rl: 1000.0,
        isOpenCircuit: false,
      );

      final result = CircuitPhysicsEngine.calculate(params);

      expect(result.status, CircuitStatus.regulationLost);
      expect(result.isZenerConductionActive, isFalse);
      expect(result.izCurrentMA, equals(0.0));
      expect(result.vl, closeTo(4.098, 0.01));
      expect(result.isCurrentMA, closeTo(5.0 / 1220.0 * 1000.0, 0.01));
    });

    test('3. Open Circuit Load: RL = infinity', () {
      const params = CircuitParameters(
        vin: 12.0,
        vz: 5.1,
        rs: 220.0,
        isOpenCircuit: true,
      );

      final result = CircuitPhysicsEngine.calculate(params);

      expect(result.status, CircuitStatus.regulatingNormal);
      expect(result.vl, closeTo(5.1, 0.001));
      expect(result.ilCurrentMA, equals(0.0));
      expect(result.izCurrentMA, equals(result.isCurrentMA));
      expect(result.isCurrentMA, closeTo((12.0 - 5.1) / 220.0 * 1000.0, 0.01));
    });

    test('4. Overpower Hazard Warning: Pz > Pz,max', () {
      const params = CircuitParameters(
        vin: 30.0,
        vz: 5.1,
        rs: 50.0,
        rl: 1000.0,
        pzMax: 0.5,
      );

      final result = CircuitPhysicsEngine.calculate(params);

      expect(result.status, CircuitStatus.overpowerWarning);
      expect(result.pz, greaterThan(0.5));
    });

    test('5. Non-Ideal Diode Model with dynamic rz', () {
      const params = CircuitParameters(
        vin: 15.0,
        vz: 5.1,
        rs: 220.0,
        rl: 1000.0,
        useNonIdealModel: true,
        rz: 10.0,
      );

      final result = CircuitPhysicsEngine.calculate(params);

      expect(result.vl, greaterThan(5.1));
      expect(result.isZenerConductionActive, isTrue);
    });

    test('6. Curve Generation Validation', () {
      const params = CircuitParameters();
      final linePoints = CircuitPhysicsEngine.generateLineRegulationCurve(params);
      final loadPoints = CircuitPhysicsEngine.generateLoadRegulationCurve(params);
      final ivPoints = CircuitPhysicsEngine.generateZenerIVCurve(params);

      expect(linePoints.length, greaterThan(50));
      expect(loadPoints.length, greaterThan(50));
      expect(ivPoints.length, greaterThan(50));
    });

    test('7. Controller & Observation Calculations', () {
      final controller = LabController();
      controller.setupLineRegulationExperiment();

      controller.recordObservation(experimentType: 'Line Reg');
      controller.setVin(18.0);
      controller.recordObservation(experimentType: 'Line Reg');

      expect(controller.observations.length, equals(2));
      final lineReg = controller.calculateLineRegulation();
      expect(lineReg, isNotNull);
      expect(lineReg!, closeTo(0.0, 0.001));

      final csv = controller.getObservationsCsv();
      expect(csv, contains('Vin (V)'));
      expect(csv, contains('12.00'));
      expect(csv, contains('18.00'));
    });
  });
}
