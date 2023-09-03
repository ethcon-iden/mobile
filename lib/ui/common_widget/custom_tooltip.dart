import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import '../../resource/style.dart';

class CustomTooltip extends StatelessWidget {
  const CustomTooltip({Key? key,
    required this.message,
    required this.child,
    this.direction = AxisDirection.down
  }) : super(key: key);

  final String message;
  final Widget child;
  final AxisDirection direction;

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      // controller: _tooltipController,
      tailLength: 12,
      tailBaseWidth: 12,
      isModal: true,

      preferredDirection: direction,
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.black,
      triggerMode: TooltipTriggerMode.tap,
      content: GestureDetector(
        onTap: () {

        },
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
          child: Text(message, style: kTextStyle.caption2Medium12.copyWith(color: Colors.white)),
        ),
      ),
      child: child,
    );
  }

}
