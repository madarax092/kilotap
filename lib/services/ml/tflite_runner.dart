// ─── TFLite Inference Runner ───

import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteRunner {
  static const String modelAsset = 'assets/models/molo.tflite';
  static const int inputSize = 320;
  static const int numClasses = 19;
  static const int numAnchors = 2100;

  Interpreter? _interpreter;

  Future<void> loadModel() async {
    _interpreter ??= await Interpreter.fromAsset(modelAsset);
  }

  /// Runs detection on [imageFile] and returns the raw model output,
  /// shape (23, 2100): rows 0-3 are box [cx, cy, w, h] normalized 0-1,
  /// rows 4-22 are per-class confidence scores for the 19 MOLO classes.
  Future<List<List<double>>> run(File imageFile) async {
    await loadModel();

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Could not decode image for detection.');
    }
    final resized =
        img.copyResize(decoded, width: inputSize, height: inputSize);

    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    final output = List.generate(
        1, (_) => List.generate(4 + numClasses, (_) => List.filled(numAnchors, 0.0)));

    _interpreter!.run(input, output);
    return output[0];
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
