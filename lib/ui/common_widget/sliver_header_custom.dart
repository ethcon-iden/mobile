import 'package:flutter/material.dart';
import 'dart:math';

class SliverCustomHeader extends SliverPersistentHeaderDelegate {
  SliverCustomHeader({
    required this.minHeight,
    required this.maxHeight,
    required this.maxChild,
    required this.minChild,
  });
  final double minHeight, maxHeight;
  final Widget maxChild, minChild;

  late double visibleMainHeight, animationVal, width;

  @override
  bool shouldRebuild(SliverCustomHeader oldDelegate) => true;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  double scrollAnimationValue(double shrinkOffset) {
    double maxScrollAllowed = maxExtent - minExtent;

    return ((maxScrollAllowed - shrinkOffset) / maxScrollAllowed)
        .clamp(0, 1)
        .toDouble();
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    width = MediaQuery.of(context).size.width;
    visibleMainHeight = max(maxExtent - shrinkOffset, minExtent);
    animationVal = scrollAnimationValue(shrinkOffset);

    return Container(
        height: visibleMainHeight,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Stack(
          children: <Widget>[
            getMinTop(),
            animationVal != 0 ? getMaxTop() : Container(),
          ],
        )
    );
  }

  Widget getMaxTop(){
    return Positioned(
      bottom: 0.0,
      child: Opacity(
        opacity: animationVal,
        child: SizedBox(
          height: maxHeight,
          width: width,
          child: maxChild,
        ),
      ),
    );
  }

  Widget getMinTop(){
    return Opacity(
      opacity: animationVal <= 0.1 ? 1 - animationVal : 0,
      child: SizedBox(
          height: visibleMainHeight,
          width: width,
          child: minChild
      ),
    );
  }
}

class SimpleSliverCustomHeader extends SliverPersistentHeaderDelegate {
  SimpleSliverCustomHeader({
    required this.height,
    required this.child,
    required this.backgroundColor
  });
  final double height;
  final Widget child;
  final Color backgroundColor;

  @override
  bool shouldRebuild(SimpleSliverCustomHeader oldDelegate) => true;
  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        height: height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: child
    );
  }
}