import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iden/resource/images.dart';
import 'package:iden/services/extensions.dart';
import 'package:iden/ui/pages/vote/vote_main_B.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:get/get.dart';

import '../../controller/state_controller.dart';
import '../common_widget/custom_button.dart';
import '../pages/vote/vote_main_A.dart';
import '../tap/header/header_vote.dart';
import '../../resource/style.dart';

class HomeVote extends StatefulWidget {
  const HomeVote({Key? key,
    required this.callback,
  }) : super(key: key);

  final Function callback;

  @override
  State<HomeVote> createState() => _HomeVoteState();
}

class _HomeVoteState extends State<HomeVote> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bouncing;

  bool isFront = true;
  bool hasCountdownTriggered = false;
  bool? hasVoteCompleted;
  /// 투표 종류/상태/진행 관련 변수
  bool? hasNetworkError;    // network error 발생시
  List<Widget> listWidget = [
  ];

  @override
  void initState() {
    super.initState();
    _setAnimationController();
  }

  void _setAnimationController() {
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this
    );

    // _bouncing =
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _countdownTimeOver() {
    /// -1 -> 타이머에 00:00 (0초)까지 표시하고 이후 리셋
    if (service.countdown30min.value.inSeconds <= -1 && service.hasVoteCountdownTriggered.value) {
      service.voteCountdownDone();
      // _callbackResult('countdownDone)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted )setState(() {});
      });
    }
  }

  void _onCompletedFromVote() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted )setState(() {});
    });
  }

  // void _move2voteMain() {
  //   Navigator.push(
  //       context,
  //       MaterialWithModalsPageRoute(builder: (BuildContext context) => VoteMainB(onCompleted: _onCompletedFromVote,))
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Stack(
      children: [
        _header(),
        // Align(
        //     alignment: Alignment.bottomCenter,
        //     child: service.hasVoteCountdownTriggered.value
        //         ? _showCountdownTimer()
        //         : _ready2start()),
      ],
    );
  }

  // Widget _ready2start() {
  //   return Container(
  //     height: MediaQuery.of(context).size.height * 0.72,
  //     width: double.infinity,
  //     margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
  //     padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
  //     decoration: BoxDecoration(
  //         color: kColor.grey20,
  //         borderRadius: BorderRadius.circular(12)
  //     ),
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             const SizedBox(height: 30),
  //             Text('투표가 가능합니다.', style: kTextStyle.largeTitle28),
  //             const SizedBox(height: 10),
  //             Text('5개의 질문이 준비됨', style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey900)),
  //             const SizedBox(height: 50),
  //
  //             _iden3D(),
  //             const SizedBox(height: 100),
  //           ],
  //         ),
  //
  //         GestureDetector(
  //           onTap: () => _move2voteMain(),
  //           child: Container(
  //               margin: const EdgeInsets.only(bottom: 20),
  //               child: Text('위로 밀어서 투표 시작하기!', style: kTextStyle.title3ExtraBold20)
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _showCountdownTimer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: kColor.grey20,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _clock3D(),
          Obx(() => _timer()),
          const SizedBox(height: 16),
          Text('질문 준비 중', style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey900)),
          const SizedBox(height: 32),
          CustomButtonWide(
            title: '친구 초대하고 초기화하기',
            background: '#EAEAEF'.toColor(),
            titleColor: Colors.black,
            bottomMargin: 5,
            // onTap: () => _move2voteMain(),
          ),
        ],
      ),
    );
  }
  Widget _timer() {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    String min;
    final mm = service.countdown30min.value.inMinutes;
    if (mm < 10) {
      min = '0$mm';
    } else {
      min = mm.toString();
    }
    final sec = strDigits(service.countdown30min.value.inSeconds.remainder(60));
    _countdownTimeOver();

    TextStyle style = kTextStyle.largeTitle28.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()]
    );

    return Text('00:$min:$sec', style: style);
  }

  Widget _iden3D() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Image.asset(kAnimation.iden3D, height: 180,),
    );
  }

  Widget _clock3D() {
    return Expanded(
      child: Image.asset(kAnimation.clock3D),
    );
  }

  Widget _header() {
    return const LeadingOMGVote();
  }
}