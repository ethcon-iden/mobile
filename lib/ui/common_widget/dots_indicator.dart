import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../resource/style.dart';

class DotsIndicator extends StatefulWidget {
  const DotsIndicator({Key? key,
    required this.itemCount,
    required this.currentItem,
    this.width = 50
  }) : super(key: key);

  final int itemCount;
  final int currentItem;
  final double width;

  @override
  State<DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<DotsIndicator> {
  late final ScrollController _controller;
  // config parameters
  final Size size = const Size(12, 4);
  final Size unselectedSize = const Size(4, 4);
  final Duration duration = const Duration(milliseconds: 250);
  final EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 4);
  final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16);
  final Alignment alignment = Alignment.center;
  final bool fadeEdges = true;
  final BoxShape boxShape = BoxShape.rectangle;
  final Color selectedColor = kColor.grey900;
  final Color unSelectedColor = kColor.grey100;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _scrollToCurrentPosition();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DotsIndicator oldWidget) {
    if (_controller.hasClients) {
      _scrollToCurrentPosition();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _scrollToCurrentPosition() {
    final widgetOffset = _getOffsetForCurrentPosition();
    _controller.animateTo(
      widgetOffset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  double _getOffsetForCurrentPosition() {
    final offsetPerPosition = _controller.position.maxScrollExtent / widget.itemCount;
    final widgetOffset = widget.currentItem * offsetPerPosition;
    return widgetOffset;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDots();
  }

  Widget _buildDots() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            fadeEdges ? Colors.black : Colors.white,
            Colors.white,
            Colors.white,
            fadeEdges ? Colors.black : Colors.white,
          ],
          tileMode: TileMode.mirror,
          stops: const [0, 0.05, 0.95, 1],
        ).createShader(bounds);
      },
      child: Container(
        width: widget.width,
        alignment: alignment,
        height: size.height,
        child: ListView.builder(
          padding: padding,
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          controller: _controller,
          shrinkWrap: !_needsScrolling(),
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.antiAlias,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              margin: margin,
              duration: duration,
              decoration: BoxDecoration(
                shape: boxShape,
                borderRadius: BorderRadius.circular(20),
                color: index == widget.currentItem
                    ? selectedColor
                    : unSelectedColor,
              ),
              width: index == widget.currentItem
                  ? size.width
                  : unselectedSize.width,
              height: index == widget.currentItem
                  ? size.height
                  : unselectedSize.height,
            );
          },
        ),
      ),
    );
  }

  /// This is important to center the list items if they fit on screen by making
  /// the list shrinkWrap or to make the list more performatic and avoid
  /// rendering all dots at once, otherwise.
  bool _needsScrolling() {
    final viewportWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        unselectedSize.width + margin.left + margin.right;
    final selectedItemWidth =
        size.width + margin.left + margin.right;
    const listViewPadding = 32;
    final shaderPadding = viewportWidth * 0.1;
    return viewportWidth < selectedItemWidth + (widget.itemCount - 1) * itemWidth + listViewPadding + shaderPadding;
  }
}
