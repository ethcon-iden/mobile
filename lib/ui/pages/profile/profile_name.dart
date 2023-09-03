import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/custom_snackbar.dart';

import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../controller/state_controller.dart';
import '../components/modal_profile_update.dart';

class ProfileName extends StatefulWidget {
  const ProfileName({Key? key}) : super(key: key);

  @override
  State<ProfileName> createState() => _ProfileNameState();
}

class _ProfileNameState extends State<ProfileName> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _node = FocusNode();
  String? userNameOrigin;
  bool isInputDone = false;

  @override
  void initState() {
    super.initState();
    userNameOrigin = service.userMe.value.name;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _modal2ProfileName() async {
    final feedback = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: '정말 이름을 수정할까요?',
          sub: '한 번 수정하면, 다시는 수정할 수 없어요.',
          emoji: '👉',
          newValue: _textController.text,
          description: '수정 전 현재 이름 ',
          originValue: userNameOrigin,
        ),
        320 + service.bottomMargin.value, true
    );
    if (feedback != null && feedback) {
      final bool res = await service.updateUserProfile('name', _textController.text);
      if (res) {
        // service.userMe.value.name = _textController.text;
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

  void _showSnackbarSuccess() => customSnackbar(context, '✨', '이름이 수정되었어요.', ToastPosition.bottom);

  void _checkNameField() {
    _node.unfocus();

    String name = _textController.text;
    if (name.isNotEmpty) {
      if (userNameOrigin != _textController.text) {   // 이전 이름과 같은지 확인
        final res = _validateInput(_textController.text);
        if (res) {
          isInputDone = true;
        } else {
          isInputDone = false;
        }
      } else {
        isInputDone = false;
      }
    } else {
      isInputDone = false;
    }
    setState(() {});
  }

  bool _validateInput(String input) {   // 입력 조건 판단 -. regular expression
    const pattern = r'^[가-힣]{2,10}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,   // 키보드 위 버튼 따리 다니게
      bottomSheet: SafeArea(child: _bottomButton()),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScrollIndicatorBar(),
        const SizedBox(height: 30),

        _title(),
        const DividerHorizontal(paddingTop: 16, paddingBottom: 20,),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text('이름은 한 번 수정하면, 다시는 수정할 수 없어요.', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
        ),

        _inputName(),
        // _guideline(),
      ],
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text('이름 수정', style: kTextStyle.largeTitle28),
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

  Widget _inputName() {
    TextStyle style;
    if (_node.hasFocus) {
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
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Text('이름', style: style),
          ),
          TextFormField(
            controller: _textController,
            focusNode: _node,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            style: kTextStyle.bodyMedium18,
            decoration: InputDecoration(
                isDense: true,
                hintText: userNameOrigin ?? '실명을 입력해주세요',
                hintStyle: kTextStyle.bodyMedium18.copyWith(color: kColor.grey100),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kColor.grey30, width: 2)
                ),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2)
                ),
                contentPadding: const EdgeInsets.only(right: 10, bottom: 10),
            ),
            onFieldSubmitted: (_) => _checkNameField(),
            onTapOutside: (_) => _checkNameField(),
            onTap: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  // Widget _guideline() {
  //   return Align(
  //     alignment: Alignment.centerLeft,
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
  //       child: Text('2~10자 한글만 사용 가능', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
  //     ),
  //   );
  // }

  Widget _bottomButton() {
    return GestureDetector(
      onTap: () {
        if (isInputDone) {
          _modal2ProfileName();
        }
      },
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isInputDone ? kColor.blue100 : kColor.blue100.withOpacity(0.1),
        ),
        child: Text('수정하기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
      ),
    );
  }
}
