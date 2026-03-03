import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inter_knot/components/avatar.dart';
import 'package:inter_knot/components/click_region.dart';
import 'package:inter_knot/controllers/data.dart';
import 'package:inter_knot/gen/assets.gen.dart';

class CreateDiscussionHeader extends StatelessWidget {
  const CreateDiscussionHeader({
    super.key,
    required this.controller,
    required this.title,
    required this.onClose,
  });

  final Controller controller;
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.discussionPageBgPoint.provider(),
          repeat: ImageRepeat.repeat,
        ),
        gradient: const LinearGradient(
          colors: [Color(0xff161616), Color(0xff080808)],
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Row(
        children: [
          Obx(() {
            final user = controller.user.value;
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xff2D2D2D),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Avatar(
                user?.avatar,
                onTap: controller.isLogin.value
                    ? controller.pickAndUploadAvatar
                    : null,
              ),
            );
          }),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ClickRegion(
            child: Assets.images.closeBtn.image(),
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}
