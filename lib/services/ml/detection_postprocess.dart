// ─── Detection Post-Processing ───
///
/// Converts raw TFLite output into clean detection results.
/// - Non-Maximum Suppression (NMS)
/// - Confidence threshold: 0.5
/// - IoU threshold: 0.45

class DetectionPostprocess {
  // TODO: Implement NMS and confidence filtering
  // List<Detection> process(Float32List rawOutput, int inputWidth, int inputHeight) { ... }
}

class Detection {
  final String className;
  final double confidence;
  final double x, y, w, h; // Bounding box (normalized 0-1)
  const Detection({required this.className, required this.confidence, required this.x, required this.y, required this.w, required this.h});
}
