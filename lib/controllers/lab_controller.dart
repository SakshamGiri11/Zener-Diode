import 'package:flutter/foundation.dart';
import '../models/circuit_parameters.dart';
import '../models/simulation_result.dart';
import '../models/observation_entry.dart';
import '../models/quiz_question.dart';
import '../physics/circuit_physics_engine.dart';

class LabController extends ChangeNotifier {
  CircuitParameters _params = const CircuitParameters();
  late SimulationResult _result;

  // Observation table state
  final List<ObservationEntry> _observations = [];
  int _nextObservationId = 1;

  // Cached plot curves
  List<GraphPoint> _lineCurve = [];
  List<GraphPoint> _loadCurve = [];
  List<GraphPoint> _ivCurve = [];

  // Quiz state
  final List<QuizQuestion> _questions = QuizQuestion.defaultQuestions;
  final Map<int, int> _quizAnswers = {}; // questionId -> selectedOptionIndex

  LabController() {
    _recalculate();
  }

  // Getters
  CircuitParameters get params => _params;
  SimulationResult get result => _result;
  List<ObservationEntry> get observations => List.unmodifiable(_observations);
  List<GraphPoint> get lineCurve => _lineCurve;
  List<GraphPoint> get loadCurve => _loadCurve;
  List<GraphPoint> get ivCurve => _ivCurve;
  List<QuizQuestion> get questions => _questions;
  Map<int, int> get quizAnswers => Map.unmodifiable(_quizAnswers);

  int get quizScore {
    int score = 0;
    for (final q in _questions) {
      if (_quizAnswers[q.id] == q.correctOptionIndex) {
        score++;
      }
    }
    return score;
  }

  void _recalculate() {
    _result = CircuitPhysicsEngine.calculate(_params);
    _lineCurve = CircuitPhysicsEngine.generateLineRegulationCurve(_params);
    _loadCurve = CircuitPhysicsEngine.generateLoadRegulationCurve(_params);
    _ivCurve = CircuitPhysicsEngine.generateZenerIVCurve(_params);
    notifyListeners();
  }

  // Parameter Setters
  void updateParameters(CircuitParameters newParams) {
    _params = newParams;
    _recalculate();
  }

  void setVin(double value) {
    _params = _params.copyWith(vin: value);
    _recalculate();
  }

  void setVz(double value) {
    _params = _params.copyWith(vz: value, clearPreset: true);
    _recalculate();
  }

  void setRs(double value) {
    _params = _params.copyWith(rs: value);
    _recalculate();
  }

  void setRl(double value) {
    _params = _params.copyWith(rl: value);
    _recalculate();
  }

  void setIsOpenCircuit(bool value) {
    _params = _params.copyWith(isOpenCircuit: value);
    _recalculate();
  }

  void setPzMax(double value) {
    _params = _params.copyWith(pzMax: value);
    _recalculate();
  }

  void setRz(double value) {
    _params = _params.copyWith(rz: value);
    _recalculate();
  }

  void setUseNonIdealModel(bool value) {
    _params = _params.copyWith(useNonIdealModel: value);
    _recalculate();
  }

  void applyPreset(ZenerPreset preset) {
    _params = _params.copyWith(
      vz: preset.vz,
      pzMax: preset.pzMax,
      rz: preset.rz,
      izk: preset.izk,
      presetName: preset.name,
    );
    _recalculate();
  }

  void setupLineRegulationExperiment() {
    _params = const CircuitParameters(
      vin: 12.0,
      vz: 5.1,
      rs: 220.0,
      rl: 1000.0,
      isOpenCircuit: false,
      pzMax: 1.0,
      presetName: '1N4733A (5.1V, 1W)',
    );
    _recalculate();
  }

  void setupLoadRegulationExperiment() {
    _params = const CircuitParameters(
      vin: 15.0,
      vz: 5.1,
      rs: 220.0,
      rl: 1000.0,
      isOpenCircuit: false,
      pzMax: 1.0,
      presetName: '1N4733A (5.1V, 1W)',
    );
    _recalculate();
  }

  // Observation Management
  void recordObservation({String? experimentType, String notes = ''}) {
    final type = experimentType ??
        (_params.isOpenCircuit
            ? 'Open Circuit Load'
            : 'Virtual Reading');

    final entry = ObservationEntry(
      id: _nextObservationId++,
      timestamp: DateTime.now(),
      experimentType: type,
      vin: _params.vin,
      vz: _params.vz,
      rs: _params.rs,
      rl: _params.rl,
      isOpenCircuit: _params.isOpenCircuit,
      vl: _result.vl,
      isCurrentMA: _result.isCurrentMA,
      izCurrentMA: _result.izCurrentMA,
      ilCurrentMA: _result.ilCurrentMA,
      pzMW: _result.pzMW,
      status: _result.statusMessage,
      notes: notes,
    );
    _observations.add(entry);
    notifyListeners();
  }

  void removeObservation(int id) {
    _observations.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearObservations() {
    _observations.clear();
    _nextObservationId = 1;
    notifyListeners();
  }

  String getObservationsCsv() {
    final buffer = StringBuffer();
    buffer.writeln(ObservationEntry.csvHeader);
    for (final obs in _observations) {
      buffer.writeln(obs.toCsvRow());
    }
    return buffer.toString();
  }

  /// Calculates experimental Line Regulation % from logged entries
  /// Line Regulation % = (Delta VL / Delta Vin) * 100
  double? calculateLineRegulation() {
    if (_observations.length < 2) return null;
    // Filter regulating observations
    final regObs = _observations.where((o) => o.izCurrentMA > 0.1).toList();
    if (regObs.length < 2) return null;

    double minVin = regObs.first.vin;
    double maxVin = regObs.first.vin;
    double vlAtMinVin = regObs.first.vl;
    double vlAtMaxVin = regObs.first.vl;

    for (final o in regObs) {
      if (o.vin < minVin) {
        minVin = o.vin;
        vlAtMinVin = o.vl;
      }
      if (o.vin > maxVin) {
        maxVin = o.vin;
        vlAtMaxVin = o.vl;
      }
    }

    final deltaVin = maxVin - minVin;
    if (deltaVin.abs() < 0.1) return null;
    final deltaVl = (vlAtMaxVin - vlAtMinVin).abs();
    return (deltaVl / deltaVin) * 100.0;
  }

  /// Calculates experimental Load Regulation % from logged entries
  /// % Load Regulation = ((V_NL - V_FL) / V_FL) * 100
  double? calculateLoadRegulation() {
    if (_observations.length < 2) return null;
    // Look for lowest IL (near no-load) and highest IL (full load)
    final regObs = _observations.where((o) => o.izCurrentMA > 0.05).toList();
    if (regObs.length < 2) return null;

    regObs.sort((a, b) => a.ilCurrentMA.compareTo(b.ilCurrentMA));
    final vNoLoad = regObs.first.vl;
    final vFullLoad = regObs.last.vl;

    if (vFullLoad <= 0.01) return null;
    return ((vNoLoad - vFullLoad) / vFullLoad).abs() * 100.0;
  }

  // Quiz Management
  void answerQuizQuestion(int questionId, int optionIndex) {
    _quizAnswers[questionId] = optionIndex;
    notifyListeners();
  }

  void resetQuiz() {
    _quizAnswers.clear();
    notifyListeners();
  }
}
