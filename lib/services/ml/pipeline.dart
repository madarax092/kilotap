// ─── MOLO Pipeline Orchestrator ───
///
/// End-to-end: image → detection → weight → capacity.
/// See molo_architecture.dart for full documentation.

import 'tflite_runner.dart';
import 'detection_postprocess.dart';
import 'weight_lookup.dart';
import 'capacity_matcher.dart';

class MoloPipeline {
  final TfliteRunner runner = TfliteRunner();
  final DetectionPostprocess post = DetectionPostprocess();
  final WeightLookup lookup = WeightLookup();
  final CapacityMatcher matcher = CapacityMatcher();

  // TODO: Implement full pipeline
  // PipelineResult run(Uint8List imageBytes) { ... }
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
