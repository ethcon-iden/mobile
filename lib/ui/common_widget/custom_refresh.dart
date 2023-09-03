import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../resource/images.dart';

class CustomRefresh extends StatefulWidget {
  const CustomRefresh({Key? key,
    required this.isOn
  }) : super(key: key);

  final bool isOn;

  @override
  State<CustomRefresh> createState() => _CustomRefreshState();
}

class _CustomRefreshState extends State<CustomRefresh> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CustomRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _controller() {
    if (widget.isOn) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animationController,
      child: SvgPicture.asset(kIcon.refreshSvg, height: 20, width: 20),
    );
  }
}
