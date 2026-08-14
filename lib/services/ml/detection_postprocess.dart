// ─── Detection Post-Processing ───

class DetectionPostprocess {
  // TODO: Implement NMS and confidence filtering
}

class Detection {
  final String className;
  final double confidence;
  final double x, y, w, h;
  const Detection({required this.className, required this.confidence, required this.x, required this.y, required this.w, required this.h});
}
