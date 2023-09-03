import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../services/extensions.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/divider.dart';
import '../../../services/secure_storage.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../controller/state_controller.dart';
import '../../common_widget/custom_snackbar.dart';
import '../components/modal_profile_update.dart';

class ProfileBio extends StatefulWidget {
  const ProfileBio({Key? key}) : super(key: key);

  @override
  State<ProfileBio> createState() => _ProfileBioState();
}

class _ProfileBioState extends State<ProfileBio> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _node = FocusNode();
  String? origin;
  bool isInputDone = false;
  bool isTextInputEnabled = false;
  bool? hasSelfIntroRecord;

  @override
  void initState() {
    super.initState();
    if (service.userMe.value.bio == null ||
        service.userMe.value.bio!.trim().isEmpty) {   // check if only white space and empty
      origin = null;
    } else {
      origin = service.userMe.value.bio;
    }
    _checkSelfIntroState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _checkSelfIntroState() async {
    final res = await OmgSecureStorage.instance.getKey(kStorageKey.bio);  // 최초 클릭 됬는지 확인
    if (res != null) {  // true -> 클릭 기록 있음 -> 한 줄 소개 숨기긱
      hasSelfIntroRecord = true;
    } else {    // false -> 한 줄 소개 보이기
      hasSelfIntroRecord = false;
    }
    setState(() {});
  }

  void _modal2ProfileName(bool isNew) async {
    final feedback = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: isNew ? '한 줄 소개를 입력할까요?' : '한 줄 소개를 수정할까요?',
          sub: '언제든지 다시 수정할 수 있어요!',
          buttonTitle: isNew ? '입력하기' : '수정하기',
        ),
        240 + service.bottomMargin.value, true
    );
    if (feedback != null && feedback) {
      if (hasSelfIntroRecord != null && !hasSelfIntroRecord!) {   // false -> 최초 클릭 기록 없음
        OmgSecureStorage.instance.saveKey(kStorageKey.bio, 'true');
      }
      final bool res = await service.updateUserProfile('bio', _textController.text);
      if (res) {
        _moveBack();
        _showSnackbarSuccess(isNew);
        setState(() {});
      } else {
        _showError();
      }
    }
  }

  void _showError() => showSomethingWrong(context);

  void _moveBack() => Navigator.pop(context);

  void _showSnackbarSuccess(bool isNew) {
    String message;
    if (isNew) {
      message = '한 줄 소개가 입력되었어요!';
    } else {
      message = '한 줄 소개가 수정되었어요.';
    }
    customSnackbar(context, '✨', message, ToastPosition.bottom);
  }

  void _onChange() {
    print('---> bio > origin: $origin | new: ${_textController.text} | ${origin == _textController.text}');
    if (_textController.text.isNotEmpty) {
      if (_textController.text.trim().isNotEmpty) {   // space (white space) 일 결우 -> 입력 X
        if (origin != _textController.text) {   // 이전 입력과 동일 하지 않은 경우만 적용
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

  void _onComplete() {
    if (_textController.text.isNotEmpty) {
      if (_textController.text.trim().isNotEmpty) { // space (white space) 일 결우 -> 입력 X
        if (origin != _textController.text) { // 이전 입력과 동일 하지 않은 경우만 적용
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
    _node.unfocus();
    isTextInputEnabled = false;
    setState(() {});
  }

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
              child: Text('나는 어떤 사람인지 친구들에게 재미있게 소개해보세요!',
                  style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
            ),

            _inputName(),
            _warning()
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
          child: Text('한 줄 소개', style: kTextStyle.largeTitle28),
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
    int len = _textController.text.length;

    return GestureDetector(
      onTap: () => _node.requestFocus(),
      child: Container(
        height: 180,
        width: double.infinity,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: isTextInputEnabled ? kColor.blue50 : kColor.grey30),
            borderRadius: BorderRadius.circular(20)
        ),
        child: Stack(
            children: [
              TextFormField(
                controller: _textController,
                focusNode: _node,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                style: kTextStyle.bodyMedium18,
                maxLines: null,   // 자동 줄바꿈
                maxLength: 40,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: origin ?? '한 줄 소개',
                  hintStyle: kTextStyle.bodyMedium18.copyWith(color: kColor.grey100),
                  hintMaxLines: 4,
                  border: InputBorder.none,
                  counterText: ''   // 카운터 (글짜 길이/maxLength) 보이지 않게 하기
                ),
                onChanged: (value) => _onChange(),
                onFieldSubmitted: (_) => _onComplete(),
                onTapOutside: (_) => _onComplete(),
                onTap: () => setState(() {
                  isTextInputEnabled = true;
                }),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: RichText(text: TextSpan(
                    children: [
                      TextSpan(text: '$len',
                          style: kTextStyle.subHeadlineBold14
                              .copyWith(color: len > 0 ? kColor.grey900 : kColor.grey300)),
                      TextSpan(text: '/40자',
                          style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300)),
                    ]
                )),
              )
            ]
        ),
      ),
    );
  }

  Widget _warning() {
    return Padding(
      padding: const EdgeInsets.only(left: 26, right: 26, top: 20, bottom: 20),
      child: RichText(
          text: TextSpan(
              children: [
                TextSpan(text: '욕설, 비방, 명예훼손 등을 포함한 부정적인 내용이나 선정적인 내용이 담긴 경우, ',
                    style: kTextStyle.footnoteMedium14.copyWith(color: '#FF7A00'.toColor())),
                TextSpan(text: '서비스 이용에 제한',
                    style: kTextStyle.subHeadlineBold14.copyWith(color: '#FF7A00'.toColor())),
                TextSpan(text: '을 받을 수 있으니 유의해주세요.',
                    style: kTextStyle.footnoteMedium14.copyWith(color: '#FF7A00'.toColor())),
              ]
          )
      ),
    );
  }

  Widget _bottomButton() {
    String title;
    bool isNew;
    if (origin == null || origin!.isEmpty) {  // 기록 없음
      title = '입력하기';
      isNew = true;
    } else {
      title = '수정하기';
      isNew = false;
    }

    return GestureDetector(
      onTap: () {
        if (isInputDone) {
          _modal2ProfileName(isNew);
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
        child: Text(title, style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
      ),
    );
  }
}
