import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../resource/style.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../common_widget/custom_button.dart';

void showDialog4Info(BuildContext context, String emoji, String title, String? sub1, String? sub2) {
  AwesomeDialog(
      context: context,
      animType: AnimType.topSlide,
      dialogType: DialogType.noHeader,
      dismissOnTouchOutside: true,
      width: MediaQuery.of(context).size.width * 0.85,
      isDense: true,
      padding: const EdgeInsets.all(20),
      bodyHeaderDistance: 0,
      dialogBorderRadius: BorderRadius.circular(24),
      dialogBackgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.6),
      alignment: Alignment.center,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(title, style: kTextStyle.title3ExtraBold20),
            ),
            if (sub1 != null)
              Text(sub1, textAlign: TextAlign.start, style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500, height: 1.2)),
            if (sub2 != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(sub2, textAlign: TextAlign.start, style: kTextStyle.footnoteMedium14),
              )
          ],
        ),
      ),
  ).show().then((value) => HapticFeedback.mediumImpact());
}

void showDialog4Action(BuildContext context, String? emoji, String title, String? sub1) {
  AwesomeDialog(
    context: context,
    animType: AnimType.topSlide,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    width: MediaQuery.of(context).size.width * 0.85,
    isDense: true,
    padding: const EdgeInsets.all(0),
    bodyHeaderDistance: 10,
    dialogBorderRadius: BorderRadius.circular(24),
    dialogBackgroundColor: Colors.white,
    btnOkText: '확인',
    buttonsTextStyle: kTextStyle.callOutBold16,
    btnOkColor: kColor.grey30,
    btnOkOnPress: () {},
    body: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (emoji != null)
              Text(emoji, style: const TextStyle(fontSize: 48)),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(title, textAlign: TextAlign.start, style: kTextStyle.title3ExtraBold20)),
            ),
            Text('서버에서 이렇게 말하네요...', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
            const SizedBox(height: 15),

            if (sub1 != null)
              Text(sub1, textAlign: TextAlign.start, style: kTextStyle.footnoteMedium14),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  ).show().then((value) => HapticFeedback.mediumImpact());
}

void showSomethingWrong(BuildContext context) {
  AwesomeDialog(
    context: context,
    animType: AnimType.topSlide,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: true,
    padding: const EdgeInsets.all(20),
    bodyHeaderDistance: 0,
    dialogBorderRadius: BorderRadius.circular(24),
    dialogBackgroundColor: Colors.white,
    alignment: Alignment.centerLeft,
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('🤕‍', style: TextStyle(fontSize: 48)),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text('앗! 무언가 잘못되었어요...', style: kTextStyle.title3ExtraBold20),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text('무언가 잘못되어서 요청이 정상적으로 처리되지 않았어요. 다시 시도해주세요!', textAlign: TextAlign.start, style: kTextStyle.footnoteMedium14),
        )
      ],
    ),
  ).show();
}

void showErrorMessage(BuildContext context, String? message, {String? title, String? sub}) {
  AwesomeDialog(
    context: context,
    animType: AnimType.topSlide,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    bodyHeaderDistance: 20,
    padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
    dialogBorderRadius: BorderRadius.circular(24),
    dialogBackgroundColor: Colors.white,
    btnOkText: '확인',
    buttonsTextStyle: kTextStyle.callOutBold16,
    btnOkColor: kColor.grey30,
    btnOkOnPress: () {},
    body: Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('🤕‍', style: TextStyle(fontSize: 48)),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 15),
            child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title ?? '앗! 무언가 잘못되었어요', textAlign: TextAlign.center,
                    style: kTextStyle.title3ExtraBold20)),
          ),
          if (sub == null || sub.isNotEmpty == true)    // sub 가 empty ('') 일경우 -> error 나지 않게 sub 표시 안함
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(sub ?? '서버에서 이렇게 말하네요...', textAlign: TextAlign.center,
                        style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500))),
              ),
          Text(message ?? '무언가 잘못되어서 요청이 정상적으로 처리되지 않았어요. 다시 시도해주세요!', textAlign: TextAlign.start, style: kTextStyle.footnoteMedium14),
        ],
      ),
    ),
  ).show().then((value) => HapticFeedback.mediumImpact());
}

Future<bool?> showDialog4actionIcon(BuildContext context, String? emoji, String title,
    String sub, Widget? buttonIcon, String? buttonTitle, String? secondButtonTitle) async {
  bool? out;
  await AwesomeDialog(
    context: context,
    animType: AnimType.topSlide,
    dialogType: DialogType.noHeader,
    dismissOnTouchOutside: false,
    padding: const EdgeInsets.all(20),
    bodyHeaderDistance: 0,
    dialogBorderRadius: BorderRadius.circular(24),
    dialogBackgroundColor: Colors.white,
    body: _CustomDialog4ActionIcon(context: context,
        emoji: emoji,
        title: title,
        sub: sub,
        buttonIcon: buttonIcon,
        buttonTitle: buttonTitle,
        secondButtonTitle: secondButtonTitle
    ),
  ).show().then((value) {
    HapticFeedback.mediumImpact();
    if (value != null) {
      out = value;
    }
  });
  return Future.value(out);
}

class _CustomDialog4ActionIcon extends StatelessWidget {
  const _CustomDialog4ActionIcon({Key? key,
    required this.context,
    required this.emoji,
    required this.title,
    required this.sub,
    required this.buttonIcon,
    required this.buttonTitle,
    required this.secondButtonTitle,

  }) : super(key: key);

  final BuildContext context;
  final String? emoji;
  final String? title;
  final String? sub;
  final Widget? buttonIcon;
  final String? buttonTitle;
  final String? secondButtonTitle;

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (emoji != null)
          Text(emoji!, style: const TextStyle(fontSize: 48)),
        Padding(
          padding: const EdgeInsets.only(top:10, bottom: 15),
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title ?? '', style: kTextStyle.title3ExtraBold20)),
        ),
        Text(sub ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),

        _button1(),

        secondButtonTitle != null
            ? _button2(context) : const SizedBox.shrink()
      ],
    );
  }

  Widget _button1() {
    return GestureDetector(
      onTap: () => Navigator.pop(context, true),
      child: Container(
        height: 44,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(top: 28, bottom: 8),
        decoration: BoxDecoration(
          color: kColor.blue100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buttonIcon ?? const SizedBox.shrink(),
            const SizedBox(width: 10),
            Text(buttonTitle ?? '', style: kTextStyle.callOutBold16.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _button2(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, false),
      child: Container(
        height: 44,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: kColor.grey30,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(secondButtonTitle ?? '', style: kTextStyle.callOutBold16),
          ],
        ),
      ),
    );
  }
}
