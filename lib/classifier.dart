// lib/classifier.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  final Interpreter _interpreter;
  final List<String> _labels;
  final int inputHeight;
  final int inputWidth;
  final int inputChannels;

  Classifier._(
      this._interpreter, this._labels, this.inputHeight, this.inputWidth, this.inputChannels);

  static Future<Classifier> create({
    String modelPath = 'assets/model/hijaiyah_model.tflite',
    String labelsPath = 'assets/model/labels.txt',
  }) async {
    final interpreter = await Interpreter.fromAsset(modelPath);
    // try to read input shape from interpreter (best-effort)
    final inputTensor = interpreter.getInputTensor(0);
    final shape = inputTensor.shape; // e.g. [1,224,224,3]
    int h = 224, w = 224, c = 1;
    if (shape.length >= 4) {
      h = shape[1];
      w = shape[2];
      c = shape[3];
    }

    // load labels file
    final rawLabels = await rootBundle.loadString(labelsPath);
    final labels = rawLabels.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Classifier._(interpreter, labels, h, w, c);
  }

  /// passes a ui.Image (or PNG bytes) — here we accept PNG bytes
  Future<Map<String, double>> predictFromPngBytes(Uint8List pngBytes) async {
    // decode PNG to image package format
    img.Image? image = img.decodeImage(pngBytes);
    if (image == null) {
      throw Exception('Gagal decode image');
    }

    // convert to RGB (image package uses RGBA)
    img.Image converted;
    if (inputChannels == 1) {
      // convert to grayscale then resize
      converted = img.copyResize(img.grayscale(image), width: inputWidth, height: inputHeight);
    } else {
      converted = img.copyResize(image, width: inputWidth, height: inputHeight);
    }

    // prepare input tensor
    // Most MobileNet style models expect floats normalized to [-1,1] or [0,1].
    // We'll try [0,1] and if output seems garbage, change normalization later.
    // Build input as List<List<List<List<double>>>> shape: [1,h,w,c]
    final input = List.generate(1, (_) {
      return List.generate(inputHeight, (y) {
        return List.generate(inputWidth, (x) {
          return List.generate(inputChannels, (ch) {
            final px = converted.getPixel(x, y);
            if (inputChannels == 1) {
              final g = img.getLuminance(px);
              return g / 255.0;
            } else {
              final r = img.getRed(px);
              final g = img.getGreen(px);
              final b = img.getBlue(px);
              if (ch == 0) return r / 255.0;
              if (ch == 1) return g / 255.0;
              return b / 255.0;
            }
          });
        });
      });
    });

    // prepare output buffer
    // try to infer output shape from interpreter
    final outputTensor = _interpreter.getOutputTensor(0);
    final outShape = outputTensor.shape; // e.g. [1, 28] or [1, numLabels]
    final numLabels = outShape.length >= 2 ? outShape[1] : _labels.length;
    var output = List.filled(numLabels, 0.0).reshape([1, numLabels]);

    // run inference
    try {
      _interpreter.run(input, output);
    } catch (e) {
      // try casting input to Float32List flattened (some models require that)
      final flat = Float32List(1 * inputHeight * inputWidth * inputChannels);
      int idx = 0;
      for (int y = 0; y < inputHeight; y++) {
        for (int x = 0; x < inputWidth; x++) {
          for (int ch = 0; ch < inputChannels; ch++) {
            flat[idx++] = input[0][y][x][ch];
          }
        }
      }
      final inputTensor = [flat.reshape([1, inputHeight, inputWidth, inputChannels])];
      _interpreter.run(inputTensor, output);
    }

    // output is 2D [1, numLabels]
    final scores = (output[0] as List).cast<double>();
    // map label -> score (softmax not guaranteed; if not normalized we apply softmax)
    // check if scores already sum to ~1
    double sum = scores.fold(0.0, (a, b) => a + b);
    List<double> probs;
    if ((sum - 1.0).abs() < 1e-3 && scores.every((s) => s >= 0.0)) {
      probs = scores;
    } else {
      // apply softmax
      final max = scores.reduce((a, b) => a > b ? a : b);
      final exps = scores.map((s) => (s - max).exp()).toList();
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

extension _Exp on double {
  double exp() => mathExp(this);
}

// small math exp helper to avoid importing dart:math directly at top (keeps code simple)
double mathExp(double x) => (x).exp();
