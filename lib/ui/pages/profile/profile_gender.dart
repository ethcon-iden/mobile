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

class ProfileGender extends StatefulWidget {
  const ProfileGender({Key? key}) : super(key: key);

  @override
  State<ProfileGender> createState() => _ProfileGenderState();
}

class _ProfileGenderState extends State<ProfileGender> {
  final TextEditingController _textController = TextEditingController();
  bool isInputDone = false;
  bool isSelected = false;
  Gender originGender = Gender.female;
  Gender? newGender;

  @override
  void initState() {
    super.initState();
    if (service.userMe.value.gender != null) {
      originGender = service.userMe.value.gender!;
    }
    _textController.text = originGender.student;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showModalGender() {
    setState(() => isSelected = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _modalGender();
    });
  }

  void _onTap4Gender(int genderNo) {    // 0,1
    String gender;
    if (genderNo == 0) {
      gender = '남학생';
    } else {
      gender = '여학생';
    }
    _textController.text = gender;
    if (originGender.student != _textController.text) {
      isInputDone = true;
    } else {
      isInputDone = false;
    }
    setState(() {});
    Navigator.pop(context);
  }

  void _modal2ProfileGender() async {
    final feedback = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: '정말 학년 정보를 수정할까요?',
          sub: '한 번 수정하면, 다시는 수정할 수 없어요.',
          emoji: '👉',
          newValue: _textController.text,
          description: '수정 전 현재 학년',
          originValue: originGender.student,
        ),
        320, true
    );
    if (feedback != null && feedback) {
      final bool res = await service.updateUserProfile('gender', newGender!.name);
      if (res) {
        _moveBack();
        _showSnackbarSuccess();
        setState(() {});
      } else {
        _showError();
      }
    }
  }

  void _showError() => showSomethingWrong(context);

  void _moveBack() => Navigator.pop(context, true);

  void _showSnackbarSuccess() => customSnackbar(context, '✨', '셩별이 수정되었어요.', ToastPosition.bottom);

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
              child: Text('성별은 한 번 수정하면, 다시는 수정할 수 없어요.', style: kTextStyle.footnoteMedium14),
            ),

            _inputGender(),
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
          child: Text('성별 수정', style: kTextStyle.largeTitle28),
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

  Widget _inputGender() {
    TextStyle style;
    if (isSelected) {
      style = kTextStyle.subHeadlineBold14;
    } else {
      style = kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 10),
            child: Text('성별', style: style),
          ),
          TextFormField(
              controller: _textController,
              readOnly: true,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: kTextStyle.bodyMedium18,
              decoration: InputDecoration(
                isDense: true,
                hintText: _textController.text,
                hintStyle: kTextStyle.hint,
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kColor.grey30, width: 2)
                ),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kColor.grey30, width: 2)
                ),
                contentPadding: const EdgeInsets.only(right: 10, bottom: 10),
              ),
              onTap: () => _showModalGender(),
              onTapOutside: (_) => setState(() {})
          ),
        ],
      ),
    );
  }

  Widget _bottomButton() {
    return GestureDetector(
      onTap: () {
        if (isInputDone) {
          if (_textController.text == '남학생') {
            newGender = Gender.male;
          } else {
            newGender = Gender.female;
          }
          _modal2ProfileGender();
        }
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

  Future _modalGender() {
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
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
            child: Column(
              children: [
                CustomTile(title: '남학생이에요', actionType: ActionType.arrowRight,
                  voidCallback: () => _onTap4Gender(0),
                ),

                CustomTile(title: '여학생이에요', actionType: ActionType.arrowRight,
                  voidCallback: () => _onTap4Gender(1),
                ),
              ],
            ),
          );
        }
    ).then((_) => setState(() => isSelected = false));
  }
}