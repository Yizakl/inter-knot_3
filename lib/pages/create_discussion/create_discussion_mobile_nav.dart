import 'package:flutter/material.dart';

class CreateDiscussionMobileNav extends StatelessWidget {
  const CreateDiscussionMobileNav({
    super.key,
    required this.isLoading,
    required this.onPickImage,
    required this.onSubmit,
    this.imageCount = 0,
  });

  final bool isLoading;
  final VoidCallback onPickImage;
  final VoidCallback onSubmit;
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: const BoxDecoration(
        color: Color(0xff181818),
        border: Border(
          top: BorderSide(color: Color(0xff2A2A2A), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Image picker button
          _ToolButton(
            icon: Icons.image_outlined,
            label: imageCount > 0 ? '$imageCount' : null,
            onTap: onPickImage,
          ),
          const Spacer(),
          // Submit button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: isLoading
                ? const SizedBox(
                    width: 80,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xffD7FF00),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: onSubmit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xffD7FF00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '发布',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xffA0A0A0), size: 24),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: const TextStyle(
                  color: Color(0xffD7FF00),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
