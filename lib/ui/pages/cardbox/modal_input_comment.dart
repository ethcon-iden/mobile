import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model/omg_card_model.dart';
import '../../../model/session.dart';
import '../../../rest_api/card_api.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/custom_tooltip.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../services/extensions.dart';
import '../../../resource/kConstant.dart';

class ModalInputComments extends StatefulWidget {
  const ModalInputComments({Key? key,
    required this.omgCard
  }) : super(key: key);

  final OmgCard omgCard;

  @override
  State<ModalInputComments> createState() => _ModalInputCommentsState();
}

class _ModalInputCommentsState extends State<ModalInputComments> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _node = FocusNode();
  String? initComment;
  bool isInputDone = false;
  bool isTextInputEnabled = false;

  @override
  void initState() {
    super.initState();
    _setOmgCardInfo();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _setOmgCardInfo() {
    OmgCard? card = widget.omgCard;
    initComment = card.comment;
  }

  void _showError() => showSomethingWrong(context);

  void _moveBack() => Navigator.pop(context);

  void _callApi4comment() async {
    if (widget.omgCard.id != null && _textController.text.isNotEmpty) {
      HttpsResponse res = await CardApi.postComment(widget.omgCard.id!, _textController.text);
      if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
        _showSnackbarSuccess();
      }
    }
  }

  void _showSnackbarSuccess() {
    Navigator.pop(context, true);
    customSnackbar(context, '🤓', '이 카드에 답글을 남겼어요!', ToastPosition.top);
  }

  void _onChange() {
    bool isDone = false;
    if (_textController.text.isNotEmpty) {
      String input = _textController.text.trim();
      if (input.isNotEmpty) {   // space (white space) 일 결우 -> 입력 X
        isDone = true;
      }
    }
    setState(() => isInputDone = isDone);
  }

  void _onComplete() {
    bool isDone = false;
    if (_textController.text.isNotEmpty) {
      String input = _textController.text.trim();
      if (input.isNotEmpty) {   // space (white space) 일 결우 -> 입력 X
        isDone = true;
      }
    }
    _node.unfocus();
    isTextInputEnabled = false;
    isInputDone = isDone;
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
            const SizedBox(height: 20),

            _title(),
            const DividerHorizontal(paddingTop: 16, paddingBottom: 20,),
            _description(),

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
          child: Text('답글 남기기', style: kTextStyle.largeTitle28),
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

  Widget _description() {
    return Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Text('내가 남긴 답글은 피드 탭에서 친구들에게 보여져요.',
                style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
            CustomTooltip(
              message: '프로필•피드에서 숨기기 기능을 켠 경우에는 보여지지 않아요.',
              direction: AxisDirection.up,
              child: Container(
                height: 20,
                width: 30,
                color: Colors.transparent,
                alignment: Alignment.topCenter,
                child: Icon(CupertinoIcons.info, size: 18, color: kColor.grey500),
              ),
            )
          ],
        )
    );
  }

  Widget _inputName() {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 12),
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
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: kTextStyle.bodyMedium18,
              maxLines: null,   // 자동 줄바꿈
              maxLength: 40,
              decoration: InputDecoration(
                  isDense: true,
                  hintText: initComment ?? '이 카드에 재미있는 답글을 남겨봐요!',
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
                    TextSpan(text: '${_textController.text.length}',
                        style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey900)),
                    TextSpan(text: '/40자',
                        style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300)),
                  ]
              )),
            )
          ]
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
                    style: kTextStyle.caption2Medium12.copyWith(color: '#FF7A00'.toColor())),
                TextSpan(text: '서비스 이용에 제한',
                    style: kTextStyle.subHeadlineBold14.copyWith(color: '#FF7A00'.toColor())),
                TextSpan(text: '을 받을 수 있으니 유의해주세요.',
                    style: kTextStyle.caption2Medium12.copyWith(color: '#FF7A00'.toColor())),
              ]
          )
      ),
    );
  }

  Widget _bottomButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  children: [
                    TextSpan(text: '한 번 남긴 답글은 수정할 수 없어요.\n',
                        style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey900)),
                    TextSpan(text: '답글을 삭제하고 새로운 답글을 남길 수는 있어요.',
                        style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey500)),
                  ]
              )
          ),
          GestureDetector(
            onTap: () => _callApi4comment(),
            child: Container(
              height: 56,
              width: double.infinity,
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 16, bottom: kConst.bottomButtonMargin),
              decoration: BoxDecoration(
                  color: isInputDone ? kColor.blue100 : kColor.blue100.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Text('남기기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
