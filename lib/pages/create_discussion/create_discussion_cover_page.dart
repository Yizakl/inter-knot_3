import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inter_knot/components/image_viewer.dart';

typedef DroppedImageFile = ({String filename, Uint8List bytes, String mimeType});

class CreateDiscussionCoverPage extends StatelessWidget {
  const CreateDiscussionCoverPage({
    super.key,
    required this.uploadedImages,
    required this.isDragging,
    required this.isCoverUploading,
    required this.onPickImages,
    required this.onRemoveImageAt,
    required this.onDroppedImages,
    required this.onDraggingChanged,
  });

  final RxList<({String id, String url})> uploadedImages;
  final bool isDragging;
  final bool isCoverUploading;
  final VoidCallback onPickImages;
  final void Function(int index) onRemoveImageAt;
  final Future<void> Function(List<DroppedImageFile> files) onDroppedImages;
  final ValueChanged<bool> onDraggingChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DropTarget(
            onDragDone: (detail) async {
              final files = detail.files;
              if (files.isEmpty) return;

              final imageFiles = <DroppedImageFile>[];
              for (final file in files) {
                final mimeType = file.mimeType ?? 'image/jpeg';
                if (!mimeType.startsWith('image/')) continue;

                final bytes = await file.readAsBytes();
                imageFiles.add((
                  filename: file.name,
                  bytes: bytes,
                  mimeType: mimeType,
                ));
              }

              if (imageFiles.isNotEmpty) {
                await onDroppedImages(imageFiles);
              }
            },
            onDragEntered: (_) => onDraggingChanged(true),
            onDragExited: (_) => onDraggingChanged(false),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDragging
                      ? const Color(0xffFBC02D)
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() {
                final images = uploadedImages;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: images.length + (images.length < 9 ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == images.length) {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: onPickImages,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDragging
                                    ? const Color(0xffFBC02D)
                                    : const Color(0xff313132),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isDragging
                                  ? const Color(0xffFBC02D)
                                      .withValues(alpha: 0.1)
                                  : const Color(0xff1E1E1E),
                            ),
                            child: isCoverUploading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isDragging
                                            ? Icons.cloud_upload
                                            : Icons.add,
                                        size: 32,
                                        color: isDragging
                                            ? const Color(0xffFBC02D)
                                            : Colors.grey,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isDragging ? '释放以上传' : '添加图片',
                                        style: TextStyle(
                                          color: isDragging
                                              ? const Color(0xffFBC02D)
                                              : Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      );
                    }

                    final img = images[index];
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              ImageViewer.show(
                                context,
                                imageUrls: images.map((e) => e.url).toList(),
                                initialIndex: index,
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                img.url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: InkWell(
                            onTap: () => onRemoveImageAt(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
