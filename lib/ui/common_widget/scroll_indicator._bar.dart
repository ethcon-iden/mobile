import 'package:flutter/material.dart';

import '../../resource/style.dart';

class ScrollIndicatorBar extends StatelessWidget {
  const ScrollIndicatorBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(   // horizontal bar indicator
      child: Container(
        height: 5, width: 36,
        margin: const EdgeInsets.all(7.5),
        decoration: BoxDecoration(
            color: kColor.grey100,
            borderRadius: BorderRadius.circular(6)
        ),
      ),
    );
  }
}
