import 'package:flutter/material.dart';

class CreateDiscussionDesktopSidebar extends StatelessWidget {
  const CreateDiscussionDesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectPage,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectPage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Container(
        margin: const EdgeInsets.only(
          top: 16,
          left: 16,
          right: 8,
          bottom: 16,
        ),
        height: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xff313132),
            width: 4,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('正文'),
                selected: selectedIndex == 0,
                onTap: () => onSelectPage(0),
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('封面'),
                selected: selectedIndex == 1,
                onTap: () => onSelectPage(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
