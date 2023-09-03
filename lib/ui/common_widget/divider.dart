import 'package:flutter/material.dart';

import '../../resource/style.dart';

class DividerHorizontal extends StatelessWidget {
  const DividerHorizontal({Key? key,
    this.paddingTop,
    this.paddingBottom,
    this.thickness
  }) : super(key: key);

  final double? paddingTop;
  final double? paddingBottom;
  final double? thickness;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop ?? 15, bottom: paddingBottom ?? 15),
      child: Divider(height: 0, thickness: thickness ?? 0.5, color: kColor.grey100),
    );
  }

}
