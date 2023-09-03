import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../resource/style.dart';
import '../../../resource/images.dart';

class LeadingProfile extends StatelessWidget {
  const LeadingProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text('프로필', style: kTextStyle.title1ExtraBold24),
        ));
  }
}

class ActionProfile extends StatefulWidget {
  const ActionProfile({Key? key,
    required this.onChange
  }) : super(key: key);

  final ValueChanged<bool> onChange;

  @override
  State<ActionProfile> createState() => _ActionProfileState();
}

class _ActionProfileState extends State<ActionProfile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
              height: 25,
              width: 25,
              margin: const EdgeInsets.only(right: 28),
              child: SvgPicture.asset(kIcon.ticketSvg, height: 26)
          ),
        ),
        GestureDetector(
            onTap: () {},
            child: Image.asset(kIcon.settingsPng, height: 26)
        ),
      ],
    );
  }
}
