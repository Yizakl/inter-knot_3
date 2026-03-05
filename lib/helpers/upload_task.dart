import 'dart:typed_data';

import 'package:get/get.dart';

/// 单张图片上传任务的状态
enum UploadStatus {
  /// 等待压缩/上传
  pending,

  /// 正在压缩
  compressing,

  /// 正在上传
  uploading,

  /// 上传完成
  done,

  /// 上传失败
  error,
}

/// 单张图片的上传任务
class UploadTask {
  UploadTask({
    required this.localId,
    required this.filename,
    required this.bytes,
    required this.mimeType,
  });

  /// 本地唯一标识
  final String localId;

  /// 文件名
  final String filename;

  /// 原始字节（上传用）
  Uint8List bytes;

  /// MIME 类型
  final String mimeType;

  /// 上传状态
  final Rx<UploadStatus> status = UploadStatus.pending.obs;

  /// 上传进度 0-100
  final RxInt progress = 0.obs;

  /// 服务器返回的 id
  String? serverId;

  /// 服务器返回的 url
  String? serverUrl;

  /// 错误信息
  String? errorMessage;

  /// 本地预览用的内存图片（用于在上传前就显示缩略图）
  Uint8List? localPreviewBytes;
}
