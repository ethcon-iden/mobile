import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:system_settings/system_settings.dart';

import '../../../resource/style.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/custom_snackbar.dart';
import '../child/invite_none_omg_user.dart';
import '../../../resource/images.dart';
import '../../../controller/state_controller.dart';
import '../../../services/permission_handler.dart';

class ReadyForVote extends StatefulWidget {
  const ReadyForVote({Key? key,
    required this.onComplete,
    required this.heightRatio
  }) : super(key: key);

  final Function onComplete;
  final double heightRatio;

  @override
  State<ReadyForVote> createState() => _ReadyForVoteState();
}

class _ReadyForVoteState extends State<ReadyForVote> {
  @override
  void initState() {
    super.initState();
  }

  void _onClick() => widget.onComplete('vote');

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    double hh = MediaQuery.of(context).size.height * widget.heightRatio;
    String title1 = 'You can start Poll';
    String title2 = '12 questions are ready';
    String buttonTitle = 'Let\'s Poll';

    return Container(
      height: hh,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.only(top: 30, bottom: 16),
      decoration: BoxDecoration(
          color: kColor.blue10,
          borderRadius: BorderRadius.circular(28)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(   // 일러스트
            child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(kImage.idenReadyToGo, fit: BoxFit.contain)
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title1, style: kTextStyle.largeTitle28),
                const SizedBox(height: 8),
                Text(title2, style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey300)),
              ],
            ),
          ),

          CustomButtonWide(
            title: buttonTitle,
            horizontalMargin: 32,
            background: Colors.black,
            titleColor: Colors.white,
            onTap: _onClick,
          )
        ],
      ),
    );
  }
}
