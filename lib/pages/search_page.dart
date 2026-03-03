import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:inter_knot/components/discussions_grid.dart';
import 'package:inter_knot/controllers/data.dart';
import 'package:inter_knot/helpers/throttle.dart';
import 'package:inter_knot/pages/create_discussion_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final c = Get.find<Controller>();

  late final AnimationController _colorController;
  late final Animation<Color?> _colorAnimation;

  final ValueNotifier<bool> _isHovering = ValueNotifier(false);
  final ValueNotifier<bool> _isRefreshHovering = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: const Color(0xfffbfe00),
      end: const Color(0xffdcfe00),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.linear,
    ));
  }

  final keyboardVisibilityController = KeyboardVisibilityController();
  late final keyboardSubscription =
      keyboardVisibilityController.onChange.listen((visible) {
    if (!visible) FocusManager.instance.primaryFocus?.unfocus();
  });

  @override
  void dispose() {
    _colorController.dispose();
    _isHovering.dispose();
    _isRefreshHovering.dispose();
    keyboardSubscription.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  late final fetchData = retryThrottle(
    c.searchData,
    const Duration(milliseconds: 500),
  );

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 640;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/zzz.webp',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  isCompact
                      ? RefreshIndicator(
                          // 让指示器完全出现在 AppBar 下方，不被顶部透明区域遮挡
                          edgeOffset: 0,
                          displacement: 56,
                          onRefresh: () async {
                            await c.refreshSearchData();
                          },
                          child: Obx(() {
                            return DiscussionGrid(
                              list: c.searchResult(),
                              hasNextPage: c.searchHasNextPage(),
                              fetchData: fetchData,
                              controller: _scrollController,
                            );
                          }),
                        )
                      : Obx(() {
                          return DiscussionGrid(
                            list: c.searchResult(),
                            hasNextPage: c.searchHasNextPage(),
                            fetchData: fetchData,
                            controller: _scrollController,
                          );
                        }),
                  Positioned(
                    top: 16,
                    left: 0,
                    right: 0,
                    child: Obx(() {
                      final count = c.newPostCount.value;
                      final hasChange = c.hasContentChange.value;
                      final shouldShow = count > 0 || hasChange;

                      String message = '帖子列表有更新';
                      if (count > 0) {
                        message = '有 $count 个新帖子';
                      }

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        reverseDuration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, -0.2),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ));
                          final scale = Tween<double>(
                            begin: 0.96,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutBack,
                          ));
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: ScaleTransition(
                                scale: scale,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: shouldShow
                            ? Center(
                                key: ValueKey('new-post-banner-$count-$hasChange'),
                                child: Material(
                                  color: const Color(0xffD7FF00),
                                  borderRadius: BorderRadius.circular(24),
                                  elevation: 10,
                                  shadowColor: const Color(0xffD7FF00)
                                      .withValues(alpha: 0.45),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () async {
                                      await c.showNewPosts();
                                      // Ensure layout is built before scrolling
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (_scrollController.hasClients) {
                                          _scrollController.animateTo(
                                            0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeOutQuart,
                                          );
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.north_rounded,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            message,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                key: ValueKey('new-post-banner-hidden'),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isCompact)
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xff1A1A1A).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xff333333),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Refresh Button
                  ValueListenableBuilder<bool>(
                    valueListenable: _isRefreshHovering,
                    builder: (context, isHovering, child) {
                      return AnimatedBuilder(
                        animation: _colorAnimation,
                        builder: (context, child) {
                          return Material(
                            color: isHovering
                                ? _colorAnimation.value
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                            child: InkWell(
                              onHover: (value) =>
                                  _isRefreshHovering.value = value,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(28),
                              onTap: () {
                                c.refreshSearchData();
                              },
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.refresh_rounded,
                                  color:
                                      isHovering ? Colors.black : Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 1,
                    height: 24,
                    color: const Color(0xff333333),
                  ),
                  const SizedBox(width: 4),
                  // Create Discussion Button
                  ValueListenableBuilder<bool>(
                    valueListenable: _isHovering,
                    builder: (context, isHovering, child) {
                      return AnimatedBuilder(
                        animation: _colorAnimation,
                        builder: (context, child) {
                          return Material(
                            color: isHovering
                                ? _colorAnimation.value
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                            child: InkWell(
                              onHover: (value) => _isHovering.value = value,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(28),
                              onTap: () async {
                                if (await c.ensureLogin()) {
                                  CreateDiscussionPage.show(context);
                                }
                              },
                              child: Container(
                                height: 56,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xffFBC02D),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '发布委托',
                                      style: TextStyle(
                                        color: isHovering
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
