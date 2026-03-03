import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inter_knot/gen/assets.gen.dart';

OverlayEntry? _toastEntry;

/// 显示通用 Toast 提示
///
/// [message] 提示内容
/// [isError] 是否为错误提示（红色背景）
/// [duration] 显示时长，默认 3 秒
void showToast(
  String message, {
  bool isError = false,
  Duration? duration,
}) {
  final context = Get.context;
  if (context == null) return;

  final width = context.width;
  // 简单的桌面端判断，宽度大于 800 视为桌面/平板宽屏模式
  final isDesktop = width >= 800;

  // 桌面端 Toast 宽度
  const toastWidth = 360.0;
  // 桌面端右侧边距
  const rightMargin = 24.0;

  final overlay = Get.key.currentState?.overlay;
  if (overlay == null) return;

  _toastEntry?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ToastOverlay(
      message: message,
      isError: isError,
      duration: duration ?? const Duration(seconds: 3),
      isDesktop: isDesktop,
      toastWidth: toastWidth,
      rightMargin: rightMargin,
      onRemoveSelf: () {
        entry.remove();
        if (identical(_toastEntry, entry)) _toastEntry = null;
      },
    ),
  );

  _toastEntry = entry;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_toastEntry != entry) return;
    overlay.insert(entry);
  });
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.isError,
    required this.duration,
    required this.isDesktop,
    required this.toastWidth,
    required this.rightMargin,
    required this.onRemoveSelf,
  });

  final String message;
  final bool isError;
  final Duration duration;
  final bool isDesktop;
  final double toastWidth;
  final double rightMargin;
  final VoidCallback onRemoveSelf;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: widget.isDesktop ? const Offset(0.0, -0.15) : const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    Future<void>.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      widget.onRemoveSelf();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = !widget.isDesktop;
    final mobileBottom = isCompact
        ? (MediaQuery.sizeOf(context).height * 0.08).clamp(48.0, 96.0)
        : 56.0;
    final backgroundGradient = widget.isError
        ? LinearGradient(
            colors: [
              Colors.red.withValues(alpha: 0.88),
              Colors.red.withValues(alpha: 0.70),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              const Color(0xff0B3D1B).withValues(alpha: 0.92),
              const Color(0xff0A0F0C).withValues(alpha: 0.98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return IgnorePointer(
      ignoring: true,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: widget.isDesktop ? 78 : null,
              right: widget.isDesktop ? widget.rightMargin : 16,
              left: widget.isDesktop ? null : 16,
              bottom: widget.isDesktop ? null : mobileBottom,
              child: SlideTransition(
                position: _slide,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: widget.isDesktop ? widget.toastWidth : null,
                      decoration: BoxDecoration(
                        color: const Color(0xff0A0A0A),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 12 : 14,
                            vertical: isCompact ? 8 : 10,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  Assets.images.discussionPageBgPoint.provider(),
                              repeat: ImageRepeat.repeat,
                              opacity: 0.18,
                            ),
                            gradient: backgroundGradient,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                widget.isError
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                size: isCompact ? 16 : 18,
                                color: widget.isError
                                    ? Colors.white
                                    : const Color(0xffD8FFE8),
                              ),
                              SizedBox(width: isCompact ? 6 : 8),
                              Flexible(
                                child: Text(
                                  widget.message,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isCompact ? 13 : 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
