import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  final Interpreter _interpreter;
  final List<String> _labels;
  final int inputHeight;
  final int inputWidth;
  final int inputChannels;

  Classifier._(this._interpreter, this._labels, this.inputHeight,
      this.inputWidth, this.inputChannels);

  static Future<Classifier> create({
    String modelPath = 'assets/model/hijaiyah_model.tflite',
    String labelsPath = 'assets/model/labels.txt',
  }) async {
    final interpreter = await Interpreter.fromAsset(modelPath);

    final inputTensor = interpreter.getInputTensor(0);
    final shape = inputTensor.shape;
    int h = 224, w = 224, c = 1;
    if (shape.length >= 4) {
      h = shape[1];
      w = shape[2];
      c = shape[3];
    }

    final rawLabels = await rootBundle.loadString(labelsPath);
    final labels = rawLabels
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Classifier._(interpreter, labels, h, w, c);
  }

  Future<Map<String, double>> predictFromPngBytes(Uint8List pngBytes) async {
    img.Image? image = img.decodeImage(pngBytes);
    if (image == null) {
      throw Exception('Gagal decode image');
    }

    img.Image converted;
    if (inputChannels == 1) {
      converted = img.copyResize(img.grayscale(image),
          width: inputWidth, height: inputHeight);
    } else {
      converted = img.copyResize(image, width: inputWidth, height: inputHeight);
    }

    final input = List.generate(1, (_) {
      return List.generate(inputHeight, (y) {
        return List.generate(inputWidth, (x) {
          return List.generate(inputChannels, (ch) {
            final pixel = converted.getPixel(x, y);

            if (inputChannels == 1) {
              final g = pixel.luminance;
              return g / 255.0;
            } else {
              final r = pixel.r;
              final g = pixel.g;
              final b = pixel.b;

              if (ch == 0) return r / 255.0;
              if (ch == 1) return g / 255.0;
              return b / 255.0;
            }
          });
        });
      });
    });

    final outputTensor = _interpreter.getOutputTensor(0);
    final outShape = outputTensor.shape;
    final numLabels = outShape.length >= 2 ? outShape[1] : _labels.length;

    var output = List.generate(1, (_) => List.filled(numLabels, 0.0));

    try {
      _interpreter.run(input, output);
    } catch (e) {
      final flat = Float32List(1 * inputHeight * inputWidth * inputChannels);
      int idx = 0;
      for (int y = 0; y < inputHeight; y++) {
        for (int x = 0; x < inputWidth; x++) {
          for (int ch = 0; ch < inputChannels; ch++) {
            flat[idx++] = input[0][y][x][ch];
          }
        }
      }

      final reshaped =
          flat.reshape([1, inputHeight, inputWidth, inputChannels]);
      _interpreter.run(reshaped, output);
    }

    final scores = (output[0] as List).cast<double>();

    double sum = scores.fold(0.0, (a, b) => a + b);
    List<double> probs;

    if ((sum - 1.0).abs() < 1e-3 && scores.every((s) => s >= 0.0)) {
      probs = scores;
    } else {
      final max = scores.reduce((a, b) => a > b ? a : b);
      final exps = scores.map((s) => math.exp(s - max)).toList();
      final expsum = exps.fold(0.0, (a, b) => a + b);
      probs = exps.map((e) => e / expsum).toList();
    }

    final Map<String, double> result = {};
    for (int i = 0; i < probs.length && i < _labels.length; i++) {
      result[_labels[i]] = probs[i];
    }

    return result;
  }
}
