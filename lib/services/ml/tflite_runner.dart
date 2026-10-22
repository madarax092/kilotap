// ─── TFLite Inference Runner ───

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteRunner {
  static const String modelAsset = 'assets/models/molo.tflite';
  static const int inputSize = 640;
  static const int numClasses = 21;
  static const int numAnchors = 8400;

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset(modelAsset);
  }

  /// Runs detection on [imageFile] and returns the raw model output,
  /// shape (25, 8400): rows 0-3 are box [cx, cy, w, h] normalized 0-1,
  /// rows 4-24 are per-class confidence scores (0-1) for the 21 classes.
  ///
  /// The exported model (MOLO: MobileNetV2 backbone, YOLOv8n neck/head)
  /// takes float32 input in channels-first layout, shape (1, 3, 640, 640),
  /// RGB scaled to 0-1.
  Future<List<List<double>>> run(File imageFile) async {
    await loadModel();

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode image for detection.');
    }
    // Letterbox, as in training: scale the photo to fit inside the square
    // without changing its shape, centre it, and fill the rest with grey
    // (114), instead of stretching it to a square. Camera EXIF rotation is
    // applied first so the model sees the photo upright.
    final upright = img.bakeOrientation(decoded);
    final scale = inputSize / math.max(upright.width, upright.height);
    final newW = math.max(1, (upright.width * scale).round());
    final newH = math.max(1, (upright.height * scale).round());
    final resized = img.copyResize(upright,
        width: newW, height: newH, interpolation: img.Interpolation.linear);
    final padX = (inputSize - newW) ~/ 2;
    final padY = (inputSize - newH) ~/ 2;
    const padValue = 114 / 255.0;

    final input = List.generate(
      1,
      (_) => List.generate(
        3,
        (c) => List.generate(
          inputSize,
          (y) => List.generate(inputSize, (x) {
            final sx = x - padX;
            final sy = y - padY;
            if (sx < 0 || sy < 0 || sx >= newW || sy >= newH) return padValue;
            final pixel = resized.getPixel(sx, sy);
            final value = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
            return value / 255.0;
          }),
        ),
      ),
    );

    final output = List.generate(
        1, (_) => List.generate(4 + numClasses, (_) => List.filled(numAnchors, 0.0)));

    final watch = Stopwatch()..start();
    _interpreter!.run(input, output);
    watch.stop();
    lastInferenceMs = watch.elapsedMilliseconds;
    // Read with `adb logcat | findstr KiloTapML` to measure on-device speed
    // (paper NFR: under 1.5 s per scan).
    debugPrint('KiloTapML inference ${lastInferenceMs}ms '
        '(${inputSize}px letterboxed, $numClasses classes)');

    // Boxes come back relative to the padded square; convert them to be
    // relative to the photo itself (callers use w*h as an area fraction).
    final rows = output[0];
    final fx = newW / inputSize, fy = newH / inputSize;
    final ox = padX / inputSize, oy = padY / inputSize;
    for (var i = 0; i < numAnchors; i++) {
      rows[0][i] = (rows[0][i] - ox) / fx;
      rows[1][i] = (rows[1][i] - oy) / fy;
      rows[2][i] = rows[2][i] / fx;
      rows[3][i] = rows[3][i] / fy;
    }
    return rows;
  }

  /// Model-only time of the most recent scan, in milliseconds.
  int? lastInferenceMs;

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
