import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../common_widget/custom_tile.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../controller/state_controller.dart';
import '../../../model/school.dart';
import '../../common_widget/custom_snackbar.dart';
import '../components/modal_profile_update.dart';

class ProfileGrade extends StatefulWidget {
  const ProfileGrade({Key? key}) : super(key: key);

  @override
  State<ProfileGrade> createState() => _ProfileGradeState();
}

class _ProfileGradeState extends State<ProfileGrade> {
  final TextEditingController _textController = TextEditingController();
  bool isInputDone = false;
  bool isSelected = false;
  SchoolGrade? originGrade;
  SchoolGrade newGrade = SchoolGrade.first;

  @override
  void initState() {
    super.initState();
    originGrade = service.userMe.value.schoolGrade;
    if (originGrade != null) {
      _textController.text = originGrade!.full;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTap4Grade(int grade) {
    String year;
    if (grade == 1) {
      year = '1학년';
    } else if (grade == 2) {
      year = '2학년';
    } else {
      year = '3학년';
    }
    _textController.text = year;

    if (originGrade?.full != _textController.text) {
      isInputDone = true;
    } else {
      isInputDone = false;
    }
    setState(() {});
    Navigator.pop(context);
  }

  void _modal2ProfileGrade() async {
    final res = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: '정말 학년 정보를 수정할까요?',
          sub: '한 번 수정하면, 다시는 수정할 수 없어요.',
          emoji: '👉',
          newValue: newGrade.full,
          description: '수정 전 현재 학년',
          originValue: originGrade!.full,
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null && res) {
      String type;
      if (service.userMe.value.schoolType == SchoolType.middle) {
        type = 'M';
      } else {
        type = 'H';
      }
      final grade = '$type${newGrade.num}';
      final bool res = await service.updateUserProfile('grade', grade);
      if (res) {
        _moveBack();
        _showSnackbarSuccess();
        setState(() {});
      } else {
        _showError();
      }
    }
  }

  void _moveBack() => Navigator.pop(context, true);

  void _showError() => showSomethingWrong(context);

  void _showSnackbarSuccess() => customSnackbar(context, '✨', '학년이 수정되었어요.', ToastPosition.bottom);

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
              child: Text('학년은 한 번 수정하면, 다시는 수정할 수 없어요.',
                  style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
            ),

            _inputGrade(),
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
          child: Text('학년 수정', style: kTextStyle.largeTitle28),
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

  Widget _inputGrade() {
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
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Text('학년', style: style),
          ),
          TextFormField(
            controller: _textController,
            readOnly: true,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            style: kTextStyle.bodyMedium18,
            decoration: InputDecoration(
              isDense: true,
              hintText: _textController.text.isNotEmpty ? _textController.text : '학년을 입력해주세요',
              hintStyle: kTextStyle.hint,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color, width: 2)
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: color, width: 2)
              ),
              contentPadding: const EdgeInsets.only(right: 10, bottom: 10),
            ),
            onTap: () => _showModalSchoolGrade(),
            onTapOutside: (_) => setState(() {})
          ),
        ],
      ),
    );
  }

  void _showModalSchoolGrade() {
    setState(() => isSelected = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _modalSchoolGrade();
    });
  }

  Future _modalSchoolGrade() {
    return showModalBottomSheet(
        barrierColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            height: 260 + service.bottomMargin.value,
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
                CustomTile(title: '1학년', actionType: ActionType.arrowRight,
                  voidCallback: () => _onTap4Grade(1),
                ),

                CustomTile(title: '2학년', actionType: ActionType.arrowRight,
                  voidCallback: () => _onTap4Grade(2),
                ),

                CustomTile(title: '3학년', actionType: ActionType.arrowRight,
                  voidCallback: () => _onTap4Grade(3),
                ),
              ],
            ),
          );
        }
    ).then((_) => setState(() => isSelected = false));
  }

  Widget _bottomButton() {
    return GestureDetector(
      onTap: () {
        if (isInputDone) {
          if (_textController.text == '1학년') {
            newGrade = SchoolGrade.first;
          } else if (_textController.text == '2학년') {
            newGrade = SchoolGrade.second;
          } else {
            newGrade = SchoolGrade.third;
          }
          _modal2ProfileGrade();
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
}