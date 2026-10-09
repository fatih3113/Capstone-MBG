import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../constants/app_constants.dart';

class ImageUtils {
  ImageUtils._();

  /// Compress and resize image file for upload
  static Future<File?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.parent.path}/compressed_${file.path.split('/').last}',
      quality: AppConstants.imageQuality,
      minWidth: AppConstants.imageMaxWidth,
      minHeight: AppConstants.imageMaxHeight,
    );
    return result != null ? File(result.path) : null;
  }

  /// Convert file to bytes for ML inference
  static Future<Uint8List> fileToBytes(File file) async {
    return await file.readAsBytes();
  }

  /// Decode image to ui.Image for processing
  static Future<ui.Image> decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Get file size in KB
  static double getFileSizeKB(File file) {
    return file.lengthSync() / 1024;
  }

  /// Get file size in MB
  static double getFileSizeMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Check if file is valid image
  static bool isValidImageFile(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final extension = file.path.toLowerCase().split('.').last;
    return validExtensions.contains('.$extension');
  }

  /// Generate thumbnail path
  static String getThumbnailPath(String imagePath) {
    final parts = imagePath.split('/');
    final filename = parts.last;
    parts[parts.length - 1] = 'thumb_$filename';
    return parts.join('/');
  }

  /// Validate image dimensions
  static Future<bool> isValidDimensions(
    Uint8List bytes, {
    int minWidth = 100,
    int minHeight = 100,
  }) async {
    try {
      final image = await decodeImage(bytes);
      return image.width >= minWidth && image.height >= minHeight;
    } catch (e) {
      return false;
    }
  }
}
