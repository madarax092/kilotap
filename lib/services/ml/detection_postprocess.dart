// ─── Detection Post-Processing ───
//
// Parses the raw YOLOv8 head output (no NMS baked into the exported
// model) into filtered, non-overlapping Detection objects. Class order
// below must match the training data.yaml exactly (the order of `names`
// in dataset_kilotap/data.yaml) since it maps output row index to class
// name. These are the scanner's sub-classes; collector preference
// categories live in MaterialPreferences.categoryMap.

import 'dart:math' as math;

class Detection {
  final String className;
  final double confidence;
  final double x, y, w, h;
  const Detection({
    required this.className,
    required this.confidence,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

class DetectionPostprocess {
  static const List<String> classNames = [
    'battery',
    'cardboard',
    'copper',
    'crt_television',
    'flatscreentv',
    'hair_dryer',
    'keyboard',
    'laptop_computer',
    'microwave',
    'mobile_phone',
    'motorcycle_block',
    'mouse',
    'plastic_hdpe',
    'plastic_pet',
    'refrigerator_standard',
    'splittype_aircon',
    'vehicle_part_big',
    'glass_bottle',
    'metal_can',
    'paper',
    'washing_machine',
  ];

  // Classes the model still outputs but the app does not report:
  // vehicle_part_big found 0 of 9 test objects (AP 0.03). Households can
  // still add "Large Vehicle Part" by hand in the Sell Scrap picker.
  static const Set<String> hiddenClasses = {'vehicle_part_big'};

  // Confidence acceptance threshold (T_c). The paper's 2.3.2.1.2 states
  // 0.50; lowered to 0.30 because the test-set recall was the weak side
  // (precision 85%, recall 73%) and a wrong item is easier for the
  // household to remove than a missed one is to notice.
  static const double confidenceThreshold = 0.30;
  static const double iouThreshold = 0.45;

  List<Detection> process(List<List<double>> rawOutput) {
    final numAnchors = rawOutput[0].length;
    final candidates = <Detection>[];

    for (var i = 0; i < numAnchors; i++) {
      double bestScore = 0;
      int bestClass = -1;
      for (var c = 0; c < classNames.length; c++) {
        final score = rawOutput[4 + c][i];
        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }
      if (bestClass == -1 || bestScore < confidenceThreshold) continue;
      if (hiddenClasses.contains(classNames[bestClass])) continue;

      candidates.add(Detection(
        className: classNames[bestClass],
        confidence: bestScore,
        x: rawOutput[0][i],
        y: rawOutput[1][i],
        w: rawOutput[2][i],
        h: rawOutput[3][i],
      ));
    }

    return _nms(candidates);
  }

  List<Detection> _nms(List<Detection> candidates) {
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    final kept = <Detection>[];

    for (final det in candidates) {
      var overlaps = false;
      for (final k in kept) {
        if (k.className == det.className && _iou(det, k) > iouThreshold) {
          overlaps = true;
          break;
        }
      }
      if (!overlaps) kept.add(det);
    }
    return kept;
  }

  double _iou(Detection a, Detection b) {
    final ax0 = a.x - a.w / 2, ax1 = a.x + a.w / 2;
    final ay0 = a.y - a.h / 2, ay1 = a.y + a.h / 2;
    final bx0 = b.x - b.w / 2, bx1 = b.x + b.w / 2;
    final by0 = b.y - b.h / 2, by1 = b.y + b.h / 2;

    final interX0 = math.max(ax0, bx0);
    final interY0 = math.max(ay0, by0);
    final interX1 = math.min(ax1, bx1);
    final interY1 = math.min(ay1, by1);

    final interArea =
        math.max(0.0, interX1 - interX0) * math.max(0.0, interY1 - interY0);
    final aArea = a.w * a.h;
    final bArea = b.w * b.h;
    final unionArea = aArea + bArea - interArea;
    if (unionArea <= 0) return 0;
    return interArea / unionArea;
  }
}
