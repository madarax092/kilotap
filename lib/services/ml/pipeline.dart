// ─── MOLO Pipeline Orchestrator ───

import 'dart:io';
import 'tflite_runner.dart';
import 'detection_postprocess.dart';
import 'capacity_matcher.dart';
import '../scrap_weight_service.dart';

class MoloPipeline {
  final TfliteRunner runner = TfliteRunner();
  final DetectionPostprocess post = DetectionPostprocess();

  Future<PipelineResult> run(File imageFile) async {
    final raw = await runner.run(imageFile);
    final detections = post.process(raw);

    final weights = <String, double>{};
    double totalWeightKg = 0;
    final sizeClasses = <String>[];

    for (final d in detections) {
      final unitWeight = ScrapWeightService.instance.getWeight(d.className) ?? 0;
      weights[d.className] = (weights[d.className] ?? 0) + unitWeight;
      totalWeightKg += unitWeight;
      sizeClasses.add(ScrapWeightService.instance.getSizeClass(d.className));
    }

    final recommendedVehicle = CapacityMatcher.match(
      totalKg: totalWeightKg,
      sizeClasses: sizeClasses,
    );

    return PipelineResult(
      detections: detections,
      weights: weights,
      totalWeightKg: totalWeightKg,
      recommendedVehicle: recommendedVehicle,
    );
  }
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
