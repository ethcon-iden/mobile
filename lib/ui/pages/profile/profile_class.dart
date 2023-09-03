import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../controller/state_controller.dart';
import '../../common_widget/custom_tile.dart';
import '../../../model/user.dart';
import '../../common_widget/custom_snackbar.dart';
import '../components/modal_profile_update.dart';

class ProfileClass extends StatefulWidget {
  const ProfileClass({Key? key}) : super(key: key);

  @override
  State<ProfileClass> createState() => _ProfileClassState();
}

class _ProfileClassState extends State<ProfileClass> {
  final TextEditingController _textController = TextEditingController();
  bool isInputDone = false;
  bool isSelected = false;
  int originClassNo = 0;
  int? selectedClassNo;

  @override
  void initState() {
    super.initState();
    if (service.userMe.value.classNo != null) {
      originClassNo = service.userMe.value.classNo!;
      _textController.text = '$originClassNo반';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showModalClass() {
    setState(() => isSelected = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _modalClass();
    });
  }

  void _onTap() {
    isSelected = true;
    if (originClassNo != selectedClassNo) {
      isInputDone = true;
    } else {
      isInputDone = false;
    }
    setState(() {});
    Navigator.pop(context);
  }

  void _modal2Confirm() async {
    final feedback = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: '정말 반 정보를 수정할까요?',
          sub: '한 번 수정하면, 다시는 수정할 수 없어요.',
          emoji: '👉',
          newValue: '${_textController.text}반',
          description: '수정 전 현재 반',
          originValue: '$originClassNo반',
        ),
        320, true
    );
    if (feedback != null && feedback) {
      if (selectedClassNo != null) {
        final bool res = await service.updateUserProfile('class', selectedClassNo!.toString());
        if (res) {
          service.userMe.value.classNo = selectedClassNo;
          _moveBack();
          _showSnackbarSuccess();
          setState(() {});
        } else {
          _showError();
        }
      }
    }
  }

  void _showError() => showSomethingWrong(context);

  void _moveBack() => Navigator.pop(context, true);

  void _showSnackbarSuccess() => customSnackbar(context, '✨', '반이 수정되었어요.', ToastPosition.bottom);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScrollIndicatorBar(),
            const SizedBox(height: 30),

            _title(),
            const DividerHorizontal(paddingTop: 16, paddingBottom: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('반은 한 번 수정하면, 다시는 수정할 수 없어요.', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
            ),

            _input(),
          ],
        ),
        _bottomButton()
      ],
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text('반 수정', style: kTextStyle.largeTitle28),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 26)),
        )
      ],
    );
  }

  Widget _input() {
    TextStyle style;
    Color color;
    if (isSelected) {
      style = kTextStyle.subHeadlineBold14;
      color = kColor.blue100;
    } else {
      style = kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300);
      color = kColor.grey30;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Text('반', style: style),
          ),
          TextFormField(
              controller: _textController,
              readOnly: true,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: kTextStyle.bodyMedium18,
              decoration: InputDecoration(
                isDense: true,
                hintText: '${_textController.text}반',
                hintStyle: kTextStyle.hint,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2)
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: color, width: 2)
                ),
                contentPadding: const EdgeInsets.only(right: 10, bottom: 10),
              ),
              onTap: () => _showModalClass(),
              onTapOutside: (_) => setState(() {})
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return GestureDetector(
      onTap: () {
        if (isInputDone) _modal2Confirm();
      },
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 16, right: 16, bottom: kConst.bottomButtonMargin),
        decoration: BoxDecoration(
            color: isInputDone ? kColor.blue100 : kColor.blue100.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Text('수정하기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
      ),
    );
  }

  Future _modalClass() {
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        isDismissible: true,
        context: context,
        builder: (context) {
          return Container(
              height: 200 + service.bottomMargin.value,
              padding: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 40,
                    offset: const Offset(0, -12),
                  ),
                ],
              ),
              child: Stack(
                  children: [
                    CupertinoPicker.builder(
                        itemExtent: 60,
                        childCount: 20,
                        onSelectedItemChanged: (index) {
                          setState(() => selectedClassNo = index+1);
                          print('--> selectedClassNo > $selectedClassNo');
                        },
                        itemBuilder: (context, index) {
                          return Center(
                              child: Text('${index + 1}반', style: kTextStyle.callOutBold16)
                          );
                        }
                    ),
                    Positioned(
                      right: 0,
                      bottom: (200 + service.bottomMargin.value) / 2 - 38,    // todo > adjust for android
                      child: GestureDetector(
                        onTap: () {
                          _textController.text = '$selectedClassNo반';
                          _onTap();
                        },
                        child: Container(
                          height: 60,
                          width: 100,
                          color: Colors.transparent,
                          child: const Icon(Icons.keyboard_arrow_right, size: 20),
                        ),
                      ),
                    )
                  ]
              )
          );
        }
    ).then((_) => setState(() => isSelected = false));
  }
}