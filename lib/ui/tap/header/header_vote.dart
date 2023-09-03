import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:animated_flip_counter/animated_flip_counter.dart';

import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';

class LeadingOMGVote extends StatelessWidget {
  const LeadingOMGVote({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(   // OMG 로고
      height: kToolbarHeight + 95,
      color: Colors.transparent,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 20),
      child: SvgPicture.asset(kIcon.idenLogoSvg, height: 22, width: 71,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          fit: BoxFit.cover),
    );
  }
}

class ActionOMGVote extends StatefulWidget {
  const ActionOMGVote({Key? key}) : super(key: key);

  @override
  State<ActionOMGVote> createState() => _ActionOMGVoteState();
}

class _ActionOMGVoteState extends State<ActionOMGVote> {
  late int cookieBalance;

  @override
  void initState() {
    super.initState();
    cookieBalance = service.cookieBalance.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: kToolbarHeight + 95,
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SvgPicture.asset(kIcon.idenCoinSvg, height: 22),
          const SizedBox(width: 6),
          _animatedNumber()
        ],
      ),
    );
  }

  Widget _animatedNumber() {
    return Obx(() => AnimatedFlipCounter(
      value: service.cookieBalance.value,
      duration: const Duration(milliseconds: 1500),
      thousandSeparator: ',',
      textStyle: kTextStyle.headlineExtraBold18,
    ));
  }
}

