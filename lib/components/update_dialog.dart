import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:inter_knot/services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Show update dialog
Future<void> showUpdateDialog(
  BuildContext context,
  UpdateInfo updateInfo,
) async {
  return showDialog(
    context: context,
    barrierDismissible: !updateInfo.forceUpdate,
    builder: (context) => WillPopScope(
      onWillPop: () async => !updateInfo.forceUpdate,
      child: _UpdateDialog(updateInfo: updateInfo),
    ),
  );
}

class _UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  
  const _UpdateDialog({required this.updateInfo});
  
  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> with WidgetsBindingObserver {
  bool _waitingForPermission = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start periodic update to sync with global download state
    if (UpdateService.downloadStatus == DownloadStatus.downloading ||
        UpdateService.downloadStatus == DownloadStatus.completed) {
      _startProgressSync();
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app resumes from settings, retry installation
    if (state == AppLifecycleState.resumed && _waitingForPermission) {
      _waitingForPermission = false;
      // Delay a bit to ensure settings are applied
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _installDownloadedApk();
        }
      });
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _startProgressSync() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {});
        return UpdateService.downloadStatus == DownloadStatus.downloading;
      }
      return false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDownloading = UpdateService.downloadStatus == DownloadStatus.downloading;
    final downloadProgress = UpdateService.downloadProgress;
    final downloadStatus = UpdateService.statusMessage;
    return AlertDialog(
      backgroundColor: const Color(0xff1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xff333333), width: 1),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffD7FF00).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.system_update,
              color: Color(0xffD7FF00),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '发现新版本',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '当前版本：${widget.updateInfo.currentVersion}',
                  style: const TextStyle(
                    color: Color(0xff808080),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16, color: Color(0xff808080)),
                const SizedBox(width: 8),
                Text(
                  '最新版本：${widget.updateInfo.version}',
                  style: const TextStyle(
                    color: Color(0xffD7FF00),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (widget.updateInfo.fileSize.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '文件大小：${widget.updateInfo.fileSize}',
                style: const TextStyle(
                  color: Color(0xff808080),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              '更新内容：',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff333333), width: 1),
              ),
              child: Text(
                widget.updateInfo.updateLog,
                style: const TextStyle(
                  color: Color(0xffE0E0E0),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            if (isDownloading || UpdateService.downloadStatus == DownloadStatus.completed) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    downloadStatus,
                    style: const TextStyle(
                      color: Color(0xff808080),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: const Color(0xff2A2A2A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffD7FF00)),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!isDownloading && UpdateService.downloadStatus != DownloadStatus.completed) ...[
          if (!widget.updateInfo.forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '稍后更新',
                style: TextStyle(color: Color(0xff808080)),
              ),
            ),
          ElevatedButton(
            onPressed: _downloadAndInstall,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD7FF00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '立即更新',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ] else if (UpdateService.downloadStatus == DownloadStatus.completed) ...[
          if (!widget.updateInfo.forceUpdate)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '稍后安装',
                style: TextStyle(color: Color(0xff808080)),
              ),
            ),
          ElevatedButton(
            onPressed: _installDownloadedApk,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffD7FF00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '立即安装',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }
  
  Future<void> _downloadAndInstall() async {
    _startProgressSync();
    
    try {
      final filePath = await UpdateService.downloadApk(
        widget.updateInfo.downloadUrl,
        onProgress: (received, total) {
          if (mounted) {
            setState(() {});
          }
        },
      );
      
      if (filePath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('下载失败，请检查网络连接')),
          );
        }
        return;
      }
      
      // Download completed, update UI to show install button
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败：$e')),
        );
      }
    }
  }
  
  Future<void> _installDownloadedApk() async {
    final filePath = UpdateService.downloadedFilePath;
    if (filePath == null) return;
    
    try {
      // Try to install APK
      final success = await UpdateService.installApk(filePath);
      
      // If failed (permission denied), guide user to settings
      if (!success && Platform.isAndroid && mounted) {
        final shouldOpenSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xff1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xff333333), width: 1),
            ),
            title: const Text(
              '需要安装权限',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '为了安装更新，需要允许应用安装未知来源的应用。\n\n点击"去设置"将跳转到权限设置页面。',
              style: TextStyle(color: Color(0xffE0E0E0)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消', style: TextStyle(color: Color(0xff808080))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffD7FF00),
                  foregroundColor: Colors.black,
                ),
                child: const Text('去设置'),
              ),
            ],
          ),
        );
        
        if (shouldOpenSettings == true) {
          // Use Intent to jump to install permission settings
          final packageInfo = await PackageInfo.fromPlatform();
          final intent = AndroidIntent(
            action: 'android.settings.MANAGE_UNKNOWN_APP_SOURCES',
            data: 'package:${packageInfo.packageName}',
          );
          
          // Set waiting flag before jumping to settings
          _waitingForPermission = true;
          await intent.launch();
        }
        return;
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开安装包失败：$e')),
        );
      }
    }
  }
}
