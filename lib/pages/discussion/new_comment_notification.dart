import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NewCommentCounts {
  const NewCommentCounts({
    required this.newCount,
    required this.serverCount,
  });

  final int newCount;
  final int serverCount;
}

class NewCommentNotification extends StatelessWidget {
  const NewCommentNotification({
    super.key,
    required this.countsListenable,
    required this.onTap,
  });

  final ValueListenable<NewCommentCounts> countsListenable;
  final Future<void> Function(NewCommentCounts counts) onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<NewCommentCounts>(
      valueListenable: countsListenable,
      builder: (context, counts, _) {
        if (counts.newCount <= 0) return const SizedBox.shrink();

        return Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: const Color(0xffD7FF00),
              borderRadius: BorderRadius.circular(20),
              elevation: 4,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onTap(counts),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '有 ${counts.newCount} 条新评论',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
