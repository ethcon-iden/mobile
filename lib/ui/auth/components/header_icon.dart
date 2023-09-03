import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../resource/images.dart';

class HeaderIcon extends StatelessWidget {
  const HeaderIcon({Key? key,
    this.emoji
  }) : super(key: key);

  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.only(left: 20, top: 20),
            child: SvgPicture.asset(kIcon.idenLogoSvg, fit: BoxFit.contain)
        ),
        emoji != null
          ? Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(emoji ?? '', style: const TextStyle(fontSize: 32)),
              // child: Image.asset(emoji!, height: 32, width: 32, fit: BoxFit.contain)
        ),
          )
          : Container()
      ],
    );
  }
}