// ─── MOLO Pipeline Orchestrator ───

import 'tflite_runner.dart';
import 'detection_postprocess.dart';
import 'weight_lookup.dart';
import 'capacity_matcher.dart';

class MoloPipeline {
  final TfliteRunner runner = TfliteRunner();
  final DetectionPostprocess post = DetectionPostprocess();
  final WeightLookup lookup = WeightLookup();

  // TODO: Implement full pipeline
}

class PipelineResult {
  final List<Detection> detections;
  final Map<String, double> weights;
  final double totalWeightKg;
  final VehicleSize recommendedVehicle;
  const PipelineResult({
    required this.detections,
    required this.weights,
    required this.totalWeightKg,
    required this.recommendedVehicle,
  });
}
