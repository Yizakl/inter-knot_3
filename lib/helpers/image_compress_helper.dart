import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// 上传前自动压缩图片，减少传输体积，提升上传速度。
/// 支持 Web / Android / iOS / macOS。
class ImageCompressHelper {
  ImageCompressHelper._();

  /// 最大边长（像素），超过此值会等比缩放
  static const int _maxDimension = 1920;

  /// JPEG 压缩质量 (0-100)
  static const int _quality = 82;

  /// 低于此大小不压缩（200KB）
  static const int _skipThreshold = 200 * 1024;

  /// 压缩图片字节数据
  ///
  /// [bytes] 原始图片二进制
  /// [filename] 文件名，用于判断格式
  /// [mimeType] MIME 类型
  ///
  /// 返回压缩后的字节数据。如果压缩失败或图片已足够小，返回原始数据。
  static Future<Uint8List> compress({
    required Uint8List bytes,
    required String filename,
    String mimeType = 'image/jpeg',
  }) async {
    // GIF 不压缩（会丢失动画）
    if (_isGif(filename, mimeType)) return bytes;

    // 小图不压缩
    if (bytes.length <= _skipThreshold) return bytes;

    try {
      final format = _isWebp(filename, mimeType)
          ? CompressFormat.webp
          : _isPng(filename, mimeType)
              ? CompressFormat.png
              : CompressFormat.jpeg;

      final result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        quality: _quality,
        format: format,
      );

      // 如果压缩后反而变大，使用原图
      if (result.length >= bytes.length) {
        debugPrint(
            '[ImageCompress] Skipped: compressed ${result.length} >= original ${bytes.length}');
        return bytes;
      }

      debugPrint(
          '[ImageCompress] ${bytes.length} -> ${result.length} bytes '
          '(${(100 - result.length * 100 ~/ bytes.length)}% saved)');
      return Uint8List.fromList(result);
    } catch (e) {
      debugPrint('[ImageCompress] Failed: $e, using original');
      return bytes;
    }
  }

  static bool _isGif(String filename, String mimeType) =>
      mimeType.contains('gif') ||
      filename.toLowerCase().endsWith('.gif');

  static bool _isPng(String filename, String mimeType) =>
      mimeType.contains('png') ||
      filename.toLowerCase().endsWith('.png');

  static bool _isWebp(String filename, String mimeType) =>
      mimeType.contains('webp') ||
      filename.toLowerCase().endsWith('.webp');
}
