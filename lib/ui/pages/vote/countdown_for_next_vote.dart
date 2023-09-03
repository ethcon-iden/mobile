import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

class CountDownForNextVote extends StatefulWidget {
  const CountDownForNextVote({Key? key,
    required this.heightRatio,
    required this.onComplete
  }) : super(key: key);

  final double heightRatio;
  final Function onComplete;

  @override
  State<CountDownForNextVote> createState() => _CountDownForNextVoteState();
}

class _CountDownForNextVoteState extends State<CountDownForNextVote> {
  @override
  void initState() {
    super.initState();
  }

  void _countdownTimeOver() {
    /// -1 -> 타이머에 00:00 (0초)까지 표시하고 이후 리셋
    if (service.countdown30min.value.inSeconds <= -1 && service.hasVoteCountdownTriggered.value) {
      service.voteCountdownDone();
      widget.onComplete('countdownDone');
    }
  }

  void _onClick() async {   // 친구 초대하고 바로 투표하기
    final res = await PermissionHandler.contacts();
    if (res) {
      _showCupertinoModal();
    } else {
      _showSnackbar();
    }
  }

  void _showCupertinoModal() async {
    final res = modalCupertino(context, const InviteNoneOmgUser(), false);
  }

  void _showSnackbar() {
    String title = '연락처 권한 허용이 필요해요!';
    String emoji = '📒';
    customSnackbarAction(context, emoji, title, ToastPosition.top,
        Icons.keyboard_arrow_right, _openSystemSetting);
  }

  void _openSystemSetting() => SystemSettings.system();   // 스시템 세팅 연결 오픈

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    double hh = MediaQuery.of(context).size.height * widget.heightRatio;
    return Container(
      height: hh,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 16, right: 16, top:12, bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: kColor.grey20,
          borderRadius: BorderRadius.circular(28)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _showTimer(),
          _illustration(),
          _bottomButton()
        ],
      ),
    );
  }

  Widget _showTimer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('다음 투표까지 남은 시간', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
        const SizedBox(height: 12),
        SizedBox(
          height: 35,
          width: MediaQuery.of(context).size.width * 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.clock, color: Colors.black, size: 24),
              const SizedBox(width: 5),
              Obx(() => _timer()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timer() {
    Color colorTimer = Colors.black;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final min = (service.countdown30min.value.inMinutes.remainder(60)).toString();
    final sec = strDigits(service.countdown30min.value.inSeconds.remainder(60));
    _countdownTimeOver();

    TextStyle style = kTextStyle.title1ExtraBold24.copyWith(color: colorTimer,
        fontFeatures: const [FontFeature.tabularFigures()]
    );

    return Text('$min:$sec', style: style);
  }

  Widget _illustration() {
    return Expanded(   // 일러스트
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(kImage.voteCountdown, fit: BoxFit.contain)
        ),
      ),
    );
  }

  Widget _bottomButton() {
    String title ='친구 초대하고 바로 투표하기';
    String sub = '기다리지 않고 바로 투표할 수 있어요.';

    return Column(
      children: [
        CustomButtonWide(
          title: title,
          onTap: _onClick,
        ),
        Text(sub, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500))
      ],
    );
  }
}
