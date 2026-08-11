/// ───────────────────────────────────────────────────────────
/// MOLO Architecture — Hybrid MobileNetV2 + YOLOv8n Pipeline
/// ───────────────────────────────────────────────────────────
///
/// This is the on-device inference pipeline for KiloTap.
/// It runs entirely on the user's phone — no cloud required.
///
/// ── PIPELINE FLOW ─────────────────────────────────────────
///
///   Camera Snapshot (320×320 RGB)
///       │
///       ▼
///   ┌─────────────────────────────┐
///   │  TFLite Interpreter         │
///   │  Model: kilotap_yolo.tflite │
///   │  Quantization: INT8         │
///   │  Input: [1, 320, 320, 3]    │
///   └─────────────────────────────┘
///       │
///       ▼
///   MobileNetV2 Backbone (conv layers 1-19)
///       │  7×7×1280 feature maps
///       ▼
///   YOLOv8n Detection Head
///       │
///       ▼
///   Raw Output: [1, 2100, 38]
///       │  2100 anchor boxes × (4 bbox + 1 confidence + 33 classes)
///       ▼
///   Post-Processing
///       │  • NMS (Non-Maximum Suppression)
///       │  • Confidence threshold: 0.5
///       │  • IoU threshold: 0.45
///       ▼
///   Detection List: [{class, confidence, bbox}]
///       │
///       ▼
///   Weight Lookup (ScrapWeight Firestore)
///       │  Class_Name → Weight_Kg
///       │  Size_class → Medium weight bias
///       ▼
///   Weighted Item List: [{class, count, weight, size}]
///       │
///       ▼
///   Capacity Matcher
///       │  Total weight → Vehicle selection
///       ▼
///   Dispatch → find_scrap collector
///
/// ── MODEL FILE ────────────────────────────────────────────
///
///   assets/models/kilotap_yolo.tflite
///   - Quantized INT8
///   - Input: 320×320×3
///   - Output: 1×2100×38 (2100 detections × 38 values)
///   - Size: ~9 MB
///
/// ── CLASSES (33 PH scrap types) ───────────────────────────
///
///   0:  aluminum_can
///   1:  aluminum_foil
///   2:  appliance_refrigerator
///   3:  appliance_washing_machine
///   4:  bottle_glass
///   5:  bottle_plastic
///   6:  cardboard_box
///   7:  cardboard_flat
///   8:  copper_wire
///   9:  copper_pipe
///   10: e_waste_monitor
///   11: e_waste_circuit_board
///   12: iron_bar
///   13: iron_sheet
///   14: iron_pipe
///   15: mixed_waste_bag
///   16: newspaper_bundle
///   17: paper_office
///   18: plastic_bag
///   19: plastic_container
///   20: plastic_toys
///   21: rubber_tire
///   22: rubber_mat
///   23: steel_beam
///   24: steel_rod
///   25: steel_drum
///   26: tin_can
///   27: wood_furniture
///   28: wood_pallet
///   29: wood_plank
///   30: wire_copper_insulated
///   31: wire_electrical
///   32: zinc_roof_sheet
///
/// ── WEIGHT LOOKUP (Firestore cache) ───────────────────────
///
///   ScrapWeight collection → cached locally in Hive
///   Key: Class_Name → Weight_Kg + Size_class
///   Example: "refrigerator_standard" → 100 kg
///            "aluminum_can" → 0.015 kg
///
/// ── CAPACITY MATCHING ─────────────────────────────────────
///
///   Total_Kg < 20      → Pushcart
///   Total_Kg < 100     → Tricycle Sidecar
///   Total_Kg < 500     → Multicab
///   Total_Kg >= 500    → Truck
///
///   + Heavy_Override (any item with SizeClass = "Heavy Override")
///     forces next vehicle size up.
///
/// ── FILES ─────────────────────────────────────────────────
///
///   lib/services/ml/tflite_runner.dart       — TFLite inference
///   lib/services/ml/detection_postprocess.dart — NMS, confidence filter
///   lib/services/ml/weight_lookup.dart       — Firestore → Hive cache
///   lib/services/ml/capacity_matcher.dart    — Vehicle logic
///   lib/services/ml/pipeline.dart            — Orchestrator
///   assets/models/kilotap_yolo.tflite        — Model file
///
/// ── FLUTTER DEPENDENCIES ──────────────────────────────────
///
///   tflite_flutter: ^0.10.0
///   image: ^4.0.0        (resize/format camera image)
///   camera: ^0.10.0
///   hive: ^2.2.0         (weight cache)
///   hive_flutter: ^1.1.0
///
/// ── REDMI 9C PERFORMANCE NOTES ────────────────────────────
///
///   Inference time: ~150-300ms per frame (INT8, 320×320)
///   RAM usage:      ~50 MB (model) + ~20 MB (runtime)
///   Fallback:       If model load fails → manual weight entry
///   Retry:          If confidence < 0.5 for all → ask user to retake
///
/// ── TRAINING PLAN (future) ────────────────────────────────
///
///   Dataset:    ~5,000 labeled images of PH scrap (33 classes)
///   Backbone:   MobileNetV2 (pretrained ImageNet weights)
///   Head:       YOLOv8n detection head (configured for 33 classes)
///   Framework:  Ultralytics YOLOv8 (Python)
///   Export:     TFLite INT8 quantized
///   Validation: mAP@0.5 > 0.70 on test set
class MoloArchitecture {
  /// This file is documentation only.
  /// No code here — implementation starts in lib/services/ml/
  const MoloArchitecture();
}
