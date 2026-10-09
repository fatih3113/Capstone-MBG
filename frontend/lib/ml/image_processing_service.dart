import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';

/// Image Processing Pipeline for ML preprocessing.
///
/// Implements the Pengolahan Citra Digital pipeline:
/// Input → Resize → Normalize → Tensor Conversion → ML Input
///
/// [MATA KULIAH: Pengolahan Citra Digital]
class ImageProcessingService {
  static const int _inputSize = AppConstants.mlInputSize; // 224

  /// Full preprocessing pipeline
  /// Returns normalized tensor ready for ML model input
  Future<Float32List> preprocessForML(File imageFile) async {
    // Step 1: Read image bytes
    final bytes = await imageFile.readAsBytes();

    // Step 2: Decode image
    final image = await _decodeImage(bytes);

    // Step 3: Resize to model input size
    final resized = await _resizeImage(image, _inputSize, _inputSize);

    // Step 4: Convert to float tensor and normalize
    final tensor = await _normalizeToTensor(resized);

    return tensor;
  }

  /// Step 1: Decode image bytes to ui.Image
  Future<ui.Image> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Step 2: Resize image to target dimensions
  Future<ui.Image> _resizeImage(
    ui.Image image,
    int targetWidth,
    int targetHeight,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final srcRect = ui.Rect.fromLTWH(
      0, 0, image.width.toDouble(), image.height.toDouble(),
    );
    final dstRect = ui.Rect.fromLTWH(
      0, 0, targetWidth.toDouble(), targetHeight.toDouble(),
    );

    // Use center crop to maintain aspect ratio
    final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
    canvas.drawImageRect(image, srcRect, dstRect, paint);

    final picture = recorder.endRecording();
    return picture.toImage(targetWidth, targetHeight);
  }

  /// Step 3: Extract pixel data and normalize to [0, 1]
  Future<Float32List> _normalizeToTensor(ui.Image image) async {
    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (byteData == null) {
      throw Exception('Failed to extract image byte data');
    }

    final pixels = byteData.buffer.asUint8List();
    // RGBA → RGB tensor: [H, W, 3]
    const tensorSize = _inputSize * _inputSize * 3;
    final tensor = Float32List(tensorSize);

    int tensorIdx = 0;
    for (int i = 0; i < pixels.length; i += 4) {
      tensor[tensorIdx++] = pixels[i] / AppConstants.imageNormalizeValue;     // R
      tensor[tensorIdx++] = pixels[i + 1] / AppConstants.imageNormalizeValue; // G
      tensor[tensorIdx++] = pixels[i + 2] / AppConstants.imageNormalizeValue; // B
      // Skip alpha channel (i+3)
    }

    return tensor;
  }

  /// Apply histogram equalization (contrast enhancement)
  Future<Uint8List> enhanceContrast(Uint8List imageBytes) async {
    return compute(_histogramEqualization, imageBytes);
  }

  /// Apply Gaussian blur for noise reduction
  Future<ui.Image> applyGaussianBlur(ui.Image image, {double sigma = 1.0}) async {
    // Blur using ImageFilter (Dart ui)
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
    canvas.drawImage(image, ui.Offset.zero, paint);
    final picture = recorder.endRecording();
    return picture.toImage(image.width, image.height);
  }

  /// Get image metadata
  Future<ImageMetadata> getImageMetadata(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = await _decodeImage(bytes);
    return ImageMetadata(
      width: image.width,
      height: image.height,
      fileSizeKB: imageFile.lengthSync() / 1024,
      aspectRatio: image.width / image.height,
    );
  }

  /// Static: Histogram equalization (runs in isolate via compute)
  static Uint8List _histogramEqualization(Uint8List pixels) {
    // Build histogram for luminance channel
    final histogram = List<int>.filled(256, 0);
    for (int i = 0; i < pixels.length; i += 4) {
      final luma = (0.299 * pixels[i] + 0.587 * pixels[i + 1] + 0.114 * pixels[i + 2]).round();
      histogram[luma]++;
    }

    // Compute CDF
    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    final cdfMin = cdf.firstWhere((v) => v > 0, orElse: () => 0);
    final totalPixels = pixels.length ~/ 4;

    // Apply equalization
    final result = Uint8List.fromList(pixels);
    for (int i = 0; i < result.length; i += 4) {
      for (int c = 0; c < 3; c++) {
        final val = result[i + c];
        final equalized = totalPixels > cdfMin
            ? ((cdf[val] - cdfMin) * 255 / (totalPixels - cdfMin)).round()
            : val;
        result[i + c] = equalized.clamp(0, 255);
      }
    }
    return result;
  }
}

class ImageMetadata {
  final int width;
  final int height;
  final double fileSizeKB;
  final double aspectRatio;

  const ImageMetadata({
    required this.width,
    required this.height,
    required this.fileSizeKB,
    required this.aspectRatio,
  });

  @override
  String toString() =>
      'ImageMetadata(${width}x$height, ${fileSizeKB.toStringAsFixed(1)}KB)';
}
