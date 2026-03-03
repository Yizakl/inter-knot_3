import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inter_knot/components/image_viewer.dart';
import 'package:inter_knot/controllers/data.dart';
import 'package:inter_knot/models/discussion.dart';
import 'package:markdown_widget/markdown_widget.dart' hide ImageViewer;
import 'package:url_launcher/url_launcher_string.dart';

class DiscussionDetailBox extends StatefulWidget {
  const DiscussionDetailBox({
    super.key,
    required this.discussion,
  });

  final DiscussionModel discussion;

  @override
  State<DiscussionDetailBox> createState() => _DiscussionDetailBoxState();
}

class _DiscussionDetailBoxState extends State<DiscussionDetailBox> {
  final c = Get.find<Controller>();

  @override
  Widget build(BuildContext context) {
    final discussion = widget.discussion;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                discussion.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              SelectionArea(
                child: MarkdownWidget(
                  data: discussion.rawBodyText,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  config: MarkdownConfig.darkConfig.copy(
                    configs: [
                      ImgConfig(
                        builder: (url, attributes) {
                          return GestureDetector(
                            onTap: () => ImageViewer.show(
                              context,
                              imageUrls: [url],
                            ),
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.redAccent,
                              ),
                            ),
                          );
                        },
                      ),
                      LinkConfig(
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        onTap: (url) {
                          if (url.isNotEmpty) {
                            launchUrlString(url);
                          }
                        },
                      ),
                      const PConfig(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xffE0E0E0),
                        ),
                      ),
                      PreConfig.darkConfig.copy(
                        wrapper: (child, code, language) => Stack(
                          children: [
                            child,
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Text(
                                language,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
