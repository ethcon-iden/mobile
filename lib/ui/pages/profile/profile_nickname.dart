import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../common_widget/lotti_animation.dart';

import '../../../controller/state_controller.dart';
import '../../../model/session.dart';
import '../../../resource/images.dart';
import '../../../resource/kConstant.dart';
import '../../../resource/style.dart';
import '../../../rest_api/user_api.dart';
import '../../../services/extensions.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../common_widget/custom_snackbar.dart';
import '../components/modal_profile_update.dart';

class ProfileNickname extends StatefulWidget {
  const ProfileNickname({Key? key}) : super(key: key);

  @override
  State<ProfileNickname> createState() => _ProfileNicknameState();
}

class _ProfileNicknameState extends State<ProfileNickname> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _node = FocusNode();
  String? userNicknameOrigin;

  Timer? _timer;
  bool hasValidated = false;  // 닉네임 입력 유효성 판단 : true -> 닉네임 사용 가능
  bool hasTriggered4ApiCall = false;  // 닉네임 필드 입력 후 일정 시간 지난 는지 확인: true -> API call
  bool hasNicknameUnique = false;   // api 응답 결과: true -> nickname 사용 가능
  bool isDuplicated = false;  // 닉네임 중보 메시지 표시

  @override
  void initState() {
    super.initState();
    userNicknameOrigin = service.userMe.value.nickname ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _modal2ProfileName() async {
    final res = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: '닉네임을 수정할까요?',
          sub: '부적절한 닉네임을 사용하는 경우, 통보없이 닉네임이 수정될 수 있으며 현상이 지속되는 경우 서비스 이용에 제한을 받을 수 있어요.',
          subColor: '#FF7A00'.toColor(),
          emoji: '👉',
          newValue: _textController.text,
          description: '수정 전 현재 닉네임',
          originValue: '$userNicknameOrigin',
        ),
        340 + service.bottomMargin.value, true
    );
    if (res != null && res) {
      final res = await service.updateUserProfile('nickname', _textController.text);
      if (res) {
        // service.userMe.value.nickname = _textController.text;
        _moveBack();
        _showSnackbar();
        setState(() {});
      } else {
        _showError();
      }
    }
  }

  void _showError() => showSomethingWrong(context);

  void _moveBack() => Navigator.pop(context, true);

  void _showSnackbar() => customSnackbar(context, '✨', '닉네임이 수정되었어요.', ToastPosition.bottom);

  void _resetConfig() {
    hasValidated = false;
    hasNicknameUnique = false;
    hasTriggered4ApiCall = false;
    isDuplicated = false;
    setState(() {});
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onChanged() {
    String nickname = _textController.text;
    if (nickname.isNotEmpty) {
      if (userNicknameOrigin != _textController.text) { // 이전 닉네임과 같은지 확인
        if (nickname.length >= 3) {   // 3 글자 이상 부터 확인
          _resetTimer();
          _resetConfig();

          /// 다음 입력까지 기다렸다 입력 없으면 -> 닉네임 API call
          _timer = Timer(const Duration(milliseconds: 500), () {
            print('---> nickname no chage > call api | $nickname');

            setState(() => hasTriggered4ApiCall = true);
            _checkNicknameAvailable(nickname);
          });
        } else {
          _resetConfig();
        }
      } else {
        _resetConfig();
      }
    } else {
      _resetConfig();
    }
  }

  void _checkInputField() {
    _node.unfocus();

    String nickname = _textController.text;
    if (nickname.isNotEmpty) {
      if (userNicknameOrigin != _textController.text) { // 이전 닉네임과 같은지 확인
        _checkNicknameAvailable(nickname);
      } else {
        _resetConfig();
      }
    } else {
      _resetConfig();
    }
  }

  void _checkNicknameAvailable(String nickname) async {
    final isValid = _validateInput(nickname);
    if (isValid) {
      hasValidated = true;
    } else {
      hasValidated = false;
    }
    if (hasValidated) {
      final res = await _checkNickname(nickname);
      if (res) {
        hasNicknameUnique = true;
      } else {
        hasNicknameUnique = false;
      }
    }
    await Future.delayed(const Duration(milliseconds: 300));
    hasTriggered4ApiCall = false;   // waiting indicator 초기화
    setState(() {});
  }

  bool _validateInput(String input) {   // 입력 조건 판단 -. regular expression
    bool out = false;
    const pattern = r'^[a-zA-Z0-9가-힣_\-]{3,10}$';
    final regex = RegExp(pattern);
    out = regex.hasMatch(input);
    return out;
  }

  Future<bool> _checkNickname(String nickname) async {
    bool out;
    final HttpsResponse res = await UserApi.checkNickname(nickname);
    if (res.statusType == StatusType.success) {
      final List<dynamic> body = res.body['data'];
      if (body.isEmpty) {   // 비어 있는 경우 (내용 없는 경우, 빈 리스트) -> 사용자 중복 아님 (사용 가능)
        out = true;
      } else {  // 이미 사용중인 닉네임 (중복)
        isDuplicated = true;
        out = false;
      }
    } else {
      out = false;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomSheet: SafeArea(child: _bottomButton()),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('닉네임을 한 번 수정하면, 14일 동안은 수정할 수 없어요.',
                      style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, right: 6),
                        child: Icon(Icons.circle, size: 4,),
                      ),
                      Text('3~12자 이내의 한글, 영문, 숫자, 특수문자(-, _)',
                          style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
                    ],
                  ),
                ],
              ),
            ),

            _inputNickname(),
            isDuplicated ? _errorMessage() : const SizedBox.shrink()
          ],
        ),
        // _bottomButton()
      ],
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text('닉네임 수정', style: kTextStyle.largeTitle28),
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

  Widget _inputNickname() {
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
            padding: const EdgeInsets.only(top: 30, bottom: 20),
            child: Text('닉네임', style: style),
          ),
          TextFormField(
            controller: _textController,
            focusNode: _node,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.done,
            style: kTextStyle.bodyMedium18,
            maxLength: 12,
            inputFormatters: const [],
            decoration: InputDecoration(
                isDense: true,
                counterText: '',
                hintText: userNicknameOrigin ?? '닉네임을 입력해주세요',
                hintStyle: kTextStyle.bodyMedium18.copyWith(color: kColor.grey100),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kColor.grey30, width: 2)
                ),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2)
                ),
                contentPadding: const EdgeInsets.only(right: 10, bottom: 10),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text('@ ', style: kTextStyle.bodyMedium18),
                ),
                suffixIcon: hasTriggered4ApiCall
                    ? LottieAnimation.loading(30)
                    : hasNicknameUnique
                        ? LottieAnimation.check()
                        : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 30, maxHeight: 30),
                prefixIconConstraints: const BoxConstraints(minWidth: 20, maxHeight: 30)
            ),
            onChanged: (_) => _onChanged(),
            onFieldSubmitted: (_) => _checkInputField(),
            onTapOutside: (_) => _checkInputField(),
            onTap: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _errorMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text('이미 존재하는 닉네임이에요.', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.red100)),
          )),
    );
  }

  Widget _warning() {
    return Padding(
      padding: const EdgeInsets.only(left: 26, right: 26, top: 20, bottom: 20),
      child: RichText(
          text: TextSpan(
              children: [
                TextSpan(text: '부적절한 닉네임을 사용하는 경우, ',
                    style: kTextStyle.footnoteMedium14.copyWith(color: '#FF7A00'.toColor())),
                TextSpan(text: '통보없이 닉네임이 수정',
                    style: kTextStyle.subHeadlineBold14.copyWith(color: '#FF7A00'.toColor())),
                TextSpan(text: '될 수 있으며 현상이 지속되는 경우 ',
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
    return GestureDetector(
      onTap: () {
        if (hasNicknameUnique) _modal2ProfileName();
      },
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: hasNicknameUnique ? kColor.blue100 : kColor.blue100.withOpacity(0.1),
        ),
        child: Text('수정하기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
      ),
    );
  }
}