import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:get/get.dart';

import '../auth/signIn_main.dart';
import '../../controller/state_controller.dart';
import '../../resource/images.dart';
import '../../resource/style.dart';
import '../common_widget/dialog_popup.dart';

class AccountRecovery extends StatefulWidget {
  const AccountRecovery({Key? key,
    required this.hasJustRequested
  }) : super(key: key);

  final bool hasJustRequested;

  @override
  State<AccountRecovery> createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery> {
  @override
  void initState() {
    super.initState();
    _showPopup();
    _checkDeleteAtTime();
  }

  void _showPopup() {
    if (widget.hasJustRequested) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _popupConfirmation();
      });
    }
  }

  void _checkDeleteAtTime() async {
    await Future.delayed(const Duration(milliseconds: 600));
    DateTime dt = DateTime.now().subtract(const Duration(minutes: 5758));
    String dt1 = dt.toIso8601String();
    service.setTimer4AccountRecovery(dt1);
  }

  void _popupConfirmation() {
    showDialog4Info(context,
        '🗄️',
        '탈퇴가 완료되었어요',
        '탈퇴 처리 시점 기준으로 설정된 120시간이 모두 지난 후에는 계정 데이터 삭제가 진행돼요. 삭제된 데이터는 영구적으로 복구할 수 없어요.',
        null
    );
  }

  void _recoverAccount() {
    _move2page();
  }

  void _move2page() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const SignInMain())
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
          statusBarBrightness: Brightness.light));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    }
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: SafeArea(child: _button()),
      body: SafeArea(
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // _image(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.075),
        _countdown(),
      ],
    );
  }

  // Widget _image() {
  //   return Container(
  //       height: MediaQuery.of(context).size.height * 0.32,
  //       width: double.infinity,
  //       margin: const EdgeInsets.only(top: 30),
  //       child: Image.asset(kImage.boyCarryingBox, fit: BoxFit.contain)
  //   );
  // }

  Widget _countdown() {
    return Column(
      children: [
        Text('계정 영구 삭제까지...', textAlign: TextAlign.center,
            style: kTextStyle.title1ExtraBold24.copyWith(height: 1.2)),
        const SizedBox(height: 14),
        Obx(() => _timer()),
        _description(),
      ],
    );
  }

  Widget _timer() {
    int hh = service.countdown120hour.value.inHours;
    bool isLessThen24Hrs;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    if (hh < 24) {
      isLessThen24Hrs = true;
    } else {
      isLessThen24Hrs = false;
    }
    String hours = '';
    if (hh < 10) {
      hours = '00$hh';
    } else if (hh < 100) {
      hours = '0$hh';
    } else {
      hours = hh.toString();
    }
    String minutes = strDigits(service.countdown120hour.value.inMinutes.remainder(60));
    String seconds = strDigits(service.countdown120hour.value.inSeconds.remainder(60));

    return Container(
      height: 112,
      width: 304,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1): kColor.grey30,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : kColor.grey100, width: 2)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _hour(hours, isLessThen24Hrs),
          _min(minutes, isLessThen24Hrs),
          _sec(seconds, isLessThen24Hrs)
        ],
      ),
    );
  }

  Widget _hour(String num, bool isLessThen24Hrs) {
    String hour = num.toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(  // 첫 자리 -> 0xx
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(hour[0], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
            Container(  // 가운데 자리 -> x0x
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(hour[1], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
            Container(  // 마지막 자리 -> xx0
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(hour[hour.length-1], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('시간', style: kTextStyle.subHeadlineBold14
              .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
        )
      ],
    );
  }

  Widget _min(String num, bool isLessThen24Hrs) {
    String min = num.toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(min[0], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
            Container(
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(min[min.length-1], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('분', style: kTextStyle.subHeadlineBold14
              .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
        )
      ],
    );
  }

  Widget _sec(String num, bool isLessThen24Hrs) {
    String sec = num.toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(sec[0], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
            Container(
              height: 48,
              width: 32,
              alignment: Alignment.center,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isLessThen24Hrs ? kColor.red100.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(sec[sec.length-1], style: kTextStyle.largeTitle28
                  .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('초', style: kTextStyle.subHeadlineBold14
              .copyWith(color: isLessThen24Hrs ? kColor.red100 : kColor.grey900)),
        )
      ],
    );
  }

  Widget _description() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text('탈퇴 처리 시점 기준으로 설정된 120시간이\n모두 지난 후에는 계정이 완전히 탈퇴 및 삭제돼요.\n삭제된 데이터는 영구적으로 복구할 수 없어요.',
          textAlign: TextAlign.center,
          style: kTextStyle.footnoteMedium14.copyWith(height: 1.2)),
    );
  }

  Widget _button() {
    return GestureDetector(
      onTap: () => _recoverAccount(),
      child: kStyle.bottomButton('계정 복구하기', kColor.blue100),
    );
  }
}
