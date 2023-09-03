import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_svg/svg.dart';
import '../../common_widget/custom_button.dart';

import '../../../rest_api/card_api.dart';
// import '../../../rest_api/cookie_api.dart';
import '../../../model/omg_card_model.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import 'cardBox_detail_front.dart';
import 'cardBox_detail_back.dart';
import '../../../controller/state_controller.dart';
import '../../common_widget/custom_tile.dart';
import '../../../resource/kConstant.dart';
import '../../../resource/style.dart';
import '../../../services/extensions.dart';
import '../../../resource/images.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/bottom_modal.dart';
import '../../../services/utils.dart';
import '../components/bottom_modal_contents_buttons.dart';
import 'modal_input_comment.dart';

class OpenReceiveCardDetail extends StatefulWidget {
  const OpenReceiveCardDetail({Key? key,
    required this.compactCard,
    required this.direction
  }) : super(key: key);

  final CompactCard compactCard;
  final CardDirection direction;

  @override
  State<OpenReceiveCardDetail> createState() => _OpenReceiveCardDetailState();
}

class _OpenReceiveCardDetailState extends State<OpenReceiveCardDetail> {
  late FlipCardController _flipCardController;
  bool isTurnBack = false;
  bool isQuestionClicked = false;
  late bool isHidingFeed;
  late bool isExpanded4mainWindow;
  bool isAnimateOn = false;
  /// 유저 구독/구매 조건들
  bool hasOmgPass = false;
  bool isCardOpen2Public = false;
  int tryNumOfCheckFullname = 0;
  bool hasHint = false;
  bool hasPermission4Fullname = false;
  bool hasComment = false;
  User? userSend;  // 보낸 친구
  User? userReceived;  // 받은 친구
  OmgCard omgCard = OmgCard();

  @override
  void initState() {
    super.initState();
    _setCardInfo();
    isExpanded4mainWindow = true;
    isHidingFeed = service.isFeedHiding.value;
    _flipCardController = FlipCardController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('---> card detail > didChangeDependencies');
  }

  void _setCardInfo() async {
    if (widget.compactCard.id != null) {
      HttpsResponse res = await CardApi.getCardInfo(widget.compactCard.id!);
      if (res.statusType == StatusType.success) {
        omgCard = OmgCard.fromJson(res.body);
        if (omgCard.comment?.isNotEmpty == true) {
          hasComment = true;
        }
        if (widget.direction == CardDirection.receive) {    // 보낸 카드
          userSend = omgCard.sender;
        } else {  // 받은 카드
          userReceived = omgCard.receiver;
        }
        /// 구독 중인지 확인
        // hasOmgPass = service.hasOmgPassActive.value;   // todo > activate
        hasOmgPass = true; // todo
        //   /// 힌트 구매 확인
        //   hasHint = true; // todo

        // if (widget.direction == CardDirection.receive) { // 받은 카드
        //   /// 카드 보낸 친구 정보
        //   CardReceiveFrom? info = widget.omgCard.cardReceiveFrom;
        //   if (info != null) {
        //     userSend = info.whoSend;
        //   }
        //   User
        //
        //   /// 전체 오픈된 카드 인지 확인
        //   // if (widget.omgCard.isCheckToPublic != null) {
        //   //   isCardOpen2Public = widget.omgCard.isCheckToPublic!;
        //   // }
        //   /// 힌트 구매 확인
        //   hasHint = true; // todo
        //   /// card 답금
        //   cardComment = widget.omgCard.comment;
        //
        //   /// 전체 이름 열람권
        //   tryNumOfCheckFullname = 1; // todo

        // } else { // 보낸 카드
        //   CardSendTo? info = widget.omgCard.cardSendTo;
        //   if (info != null) {
        //
        //   }
        // }
      } else if (res.statusType == StatusType.error) {
        ErrorResponse error = res.body;
        _showError(error.message);
      }
    }
    if (mounted) setState(() {});
  }

  void _callApi4deleteComment() async {
    if (omgCard.id != null) {
      HttpsResponse res = await CardApi.deleteComment(omgCard.id!);
      if (res.statusType == StatusType.success) {
        setState(() => hasComment = false);
        _showSnackbar('😶‍🌫', '이 카드에 남긴 답글이 삭제되었어요.');
      } else if (res.statusType == StatusType.error) {
        ErrorResponse error = res.body;
        _showError(error.message);
      }
    }
  }

  void _modal2Options() async {
    await _showModalOption().then((_) => setState(() {}));
  }

  void _modal2NoPassNoHint() async {
    showCustomBottomSheet(context,
        const _CheckWhoSend(),
        300 + service.bottomMargin.value,
        true
    );
  }

  void _modal2CheckHint() async {
    String? username;
    if (userSend?.name != null) {
      username = userSend?.name;
    }
    if (username != null) {
      showCustomBottomSheet(context,
          _CheckHint(hasOmgPass: hasOmgPass),
          300, true
      ).then((value) {
        if (value == 'full') {
          _modal2CheckConsonantLastName();
        } else if (value == 'half') {
          _modal2CheckLastName();
        }
      });
    } else {
      showSomethingWrong(context);  // 유저 정보 (이름)이 없는 경우
    }
  }

  void _modal2CheckConsonantLastName() async {    // 초성 + 마지막 글자
    String? username;
    if (userSend?.name != null) {
      username = userSend?.name;
    }
    if (username != null) {
      showCustomBottomSheet(context,
          _CheckConsonantLastName(
            username: username,
            tryNumOfCheckFullname: tryNumOfCheckFullname),
          360 + service.bottomMargin.value,
          true
      ).then((value) {
        if (value == 'fullname') _flipCardController.toggleCard();
      });
    }
  }

  void _modal2CheckConsonant() async {  // 초성
    String? username;
    if (userSend?.name != null) {
      username = userSend?.name;
    }
    if (username != null) {
      showCustomBottomSheet(context,
          _CheckConsonant(
              username: username,
              tryNumOfCheckFullname: tryNumOfCheckFullname),
          420 + service.bottomMargin.value,
          true
      ).then((value) {
        if (value == 'fullname') _flipCardController.toggleCard();
        if (value == 'hint') _modal2CheckHint();
      });
    }
  }

  void _modal2CheckLastName() async {   // 마지막 글자
    String? username;
    if (userSend?.name != null) {
      username = userSend?.name;
    }
    if (username != null) {
      showCustomBottomSheet(context,
          _CheckLastName(
              username: username),
          360 + service.bottomMargin.value,
          true
      );
    }
  }

  void _modal2Comment() async {
    final res = await modalCupertino(context, ModalInputComments(omgCard: omgCard), true);
    print('---> comment > res: $res');
    if (res == true) setState(() => hasComment = true);
  }

  void _modal2Report() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '어떤 내용을 신고할까요?',
          sub: '허위 신고가 누적되는 경우, 서비스 이용이 제한될 수 있어요.',
          listTitle: const ['부정적인 내용이 담겨있어요', '개인적으로 기분이 나빠요',
            '여기에 없는 다른 이유가 있어요', '취소'],   // index: 0,1,2,3
          listColor: [kColor.red100, kColor.red100,kColor.blue100,Colors.black],
          listIcon: const [null, null, null, null],
        ),
        460 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 부정적인 내용이 담겨있어요
        // todo
      } else if (res == 1) {    // 개인적으로 기분이 나빠요
        // todo
      } else if (res == 2) {    // 여기에 없는 다른 이유가 있어요
        // todo
      }
    }
    if (res != null && res != 3) {
      _showSnackbar('🙆', '신고가 정상적으로 접수되었어요.');
    }
  }

  void _modal2deleteComment() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '답글을 삭제할까요?',
          sub: '답글을 삭제하면 새로운 답글을 남길 수 있어요.',
          listTitle: const ['삭제하기', '취소'],
          // index: 0,1
          listColor: [kColor.red100, Colors.black],
          listIcon: const [null, null, null, null],
        ),
        340 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) { // 삭제
        setState(() => isExpanded4mainWindow = true);
        _callApi4deleteComment();
      } else if (res == 1) { // 취소
        print('---> _modal2deleteComment > canceled');
      }
    }
  }

  void _showError(String? message) => showErrorMessage(context, message);

  void _showSnackbar(String emoji, String title) {
    customSnackbar(context, emoji, title, ToastPosition.top);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kColor.grey20,
      appBar: AppBar(
        backgroundColor: kColor.grey20,
        elevation: 0,
        leadingWidth: kStyle.leadingWidth,
        systemOverlayStyle: kStyle.setSystemOverlayStyle(
            kScreenBrightness.light),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(left: kStyle.leadingPaddingLeft),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black)
          ),
        ),
        actions: [
          widget.direction == CardDirection.receive
                ? Row(
                  children: [
                    isHidingFeed
                        ? SvgPicture.asset(kIcon.globeSlash, height: 24, width: 24,
                            colorFilter: ColorFilter.mode(kColor.red100, BlendMode.srcIn))
                        : const SizedBox.shrink(),

                    IconButton(
                        onPressed: () => _modal2Options(),
                        padding: const EdgeInsets.only(left: 15, right: 20),
                        icon: const Icon(CupertinoIcons.ellipsis, color: Colors.black)
                    ),
                  ],
                )
              : const SizedBox.shrink()
        ],
      ),
      bottomSheet: isExpanded4mainWindow
          ? SafeArea(
                child: isTurnBack ? _bottomButtonBack() : _bottomButtonFront()
            )
          : null,
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            FlipCard(
                controller: _flipCardController,
                fill: Fill.fillBack,
                flipOnTouch: false,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: CardBoxDetailFront(
                    omgCard: omgCard,
                    direction: widget.direction,
                    isExpanded: isExpanded4mainWindow,
                    isAnimatedOn: isAnimateOn,
                ),
                // front: isExpanded
                //     ? CardDetailFront(omgCard: widget.omgCard, direction: widget.direction)
                //     : CardShrink4CommentFront(omgCard: widget.omgCard, direction: widget.direction),
                // back: CardDetailBack(omgCard: widget.omgCard)
                back: isExpanded4mainWindow
                    ? CardBoxDetailBack(omgCard: omgCard)
                    : const CardShrink4CommentBack()  // sort of dummy widget to avoid overflow error

            ),
            isExpanded4mainWindow ? const SizedBox.shrink() : Expanded(child: _checkComment())
          ],
        )
    );
  }

  Widget _bottomButtonFront() {
    if (widget.direction == CardDirection.receive) {  // 받은 카드
      return _button4ReceiveCard();
    } else {  // 보낸 카드
      return _button4SendCard();
    }
  }

  Widget _button4ReceiveCard() {
    String title;
    Color backgroundColor;
    Color textColor;
    if (isCardOpen2Public) {
      title = '보낸 사람 보기';
      backgroundColor = kColor.grey30;
      textColor = Colors.black;
    } else {
      title = '누가 보냈는지 보기';
      backgroundColor = kColor.blue100;
      textColor = Colors.white;
    }

    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (isCardOpen2Public) {  // 전체 이름이 오픈 O
                _flipCardController.toggleCard();
              } else { // 비공개 카드
                if (hasOmgPass) { // 패스 구독 O
                  if (hasPermission4Fullname) {   // 전체 이름 열람권 O
                    if (hasHint) { // 힌트 구매 O  -> 초성 & 마지막 글자
                      _modal2CheckConsonantLastName();
                    } else {  // 힌트 구매 X -> 초성만
                      _modal2CheckConsonant();
                    }
                  } else {  // 전체 이름 열람권 X
                    if (hasHint) { // 힌트 구매한 경우  -> 초성 & 마지막 글자
                      _modal2CheckConsonantLastName();
                    } else {  // 힌트 구매 X -> 초성만
                      _modal2CheckConsonant();
                    }
                  }
                } else {  // PASS 구독 X
                  if (hasHint) {  // 힌트 구매 O -> 마지막 이름만/구매
                    _modal2CheckLastName();
                  } else {  // 힌트 구매 X -> 힌트 보기 -> 마지막 이름만/구매
                    _modal2NoPassNoHint();
                  }
                }
              }
            },
            child: Container(
              height: 56,
              width: MediaQuery.of(context).size.width * 0.72,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 16, bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(title, style: kTextStyle.headlineExtraBold18.copyWith(color: textColor)),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(    // 답글 버튼
            onTap: () {
              if (hasComment) {   // 답글 있는 경우 -> 답글 보기
                setState(() {
                  isAnimateOn = true;
                  isExpanded4mainWindow = false;
                });
              } else {  // 답글 없는 경우 -> 답글 달기
                _modal2Comment();
              }
            } ,
            child: Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 16, bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
                decoration: BoxDecoration(
                    color: kColor.blue30,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: hasComment  // 답글 있으면 아이콘 변경
                    ? SvgPicture.asset(kIcon.commentWritten, height: 32, width: 32)
                    : SvgPicture.asset(kIcon.commentEmpty, height: 24, width: 24)
            ),
          )
        ],
      ),
    );
  }

  Widget _button4SendCard() {
    String? title;
    if (hasComment) {
      title = '친구가 답글을 남겼어요!';
    } else {
      title = '답글이 달리면 알려드릴께요';
    }

    return GestureDetector(
      onTap: () {
        if (hasComment) {
          setState(() {
            isAnimateOn = true;
            isExpanded4mainWindow = false;
          });
        }
      },
      child: Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        // decoration: BoxDecoration(
        //     color: hasComment ? kColor.blue30 : kColor.grey30,
        //     borderRadius: BorderRadius.circular(12)
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(kIcon.commentEmpty, height: 22, width: 22,
                colorFilter: ColorFilter.mode(
                    hasComment ? kColor.blue100 : kColor.grey300, BlendMode.srcIn)),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(title, style: kTextStyle.headlineExtraBold18
                  .copyWith(color: hasComment ? kColor.blue100 : kColor.grey300)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomButtonBack() {
    String title;
    if (isQuestionClicked) {
      title = '보낸 사람 보기';
    } else {
      title = '질문 보기';
    }

    return GestureDetector(
        onTap: () {
          _flipCardController.toggleCard();
          setState(() {
            isQuestionClicked = !isQuestionClicked;
          });
        },
        child: Container(
            height: 56,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 16, right: 16,
                bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text(title, style: kTextStyle.headlineExtraBold18)
        )
    );
  }

  Widget _checkComment() {
    String? comment;
    String? whenCommented;
    if (omgCard.commentedAt?.isNotEmpty == true) {
      whenCommented = omgCard.commentedAt!.whenReceived();
    }
    comment = omgCard.comment;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: isExpanded4mainWindow ? 0 : null,
      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
      decoration: BoxDecoration(
        color: kColor.grey30,
        borderRadius: BorderRadius.circular(28)
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Container(
                height: 50,
                color: Colors.transparent,
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(  // 답글 header
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(kIcon.commentWrittenBlack, height: 26, width: 26),
                        const SizedBox(width: 10),
                        Text('답글', style: kTextStyle.title3ExtraBold20),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (widget.direction == CardDirection.receive) {  // 받은 카드
                          _modal2deleteComment();
                        } else {  // 보낸 카드
                          _modal2Report();
                        }
                      },
                      child: Container(
                          height: 30,
                          width: 30,
                          color: Colors.transparent,
                          alignment: Alignment.center,
                          child: widget.direction == CardDirection.receive
                              ? Icon(CupertinoIcons.trash, color: kColor.red100)
                              : Icon(CupertinoIcons.info_circle_fill, color: kColor.red100)
                      ),
                    )
                  ],
                ),
              ),
              const DividerHorizontal(paddingTop: 12, paddingBottom: 15),
              Padding(    // 답글
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment ?? ' ', style: kTextStyle.callOutBold16.copyWith(height: 1.3)),
                      const SizedBox(height: 8),
                      Text(whenCommented ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
                    ]
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: CustomButtonWide(   // 닫기 버튼
              title: '닫기',
              background: Colors.white,
              horizontalMargin: 20,
              onTap: () => setState(() => isExpanded4mainWindow = true),
            ),
          )
        ],
      ),
    );
  }

  Future _showModalOption() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        isDismissible: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 280 + service.bottomMargin.value,
                padding: EdgeInsets.only(top: 8, bottom: 50 + service.bottomMargin.value),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)
                    )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center( // horizontal bar indicator
                      child: Container(
                        height: 5, width: 36,
                        decoration: BoxDecoration(
                            color: kColor.grey100,
                            borderRadius: BorderRadius.circular(6)
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, top: 10),
                      child: Text(
                          '이 카드에 대한 옵션', style: kTextStyle.title1ExtraBold24),
                    ),
                    Column(
                      children: [
                        CustomTile(title: '프로필 • 피드에서 숨기기',
                          leadingIcon: SvgPicture.asset(kIcon.globeSlash, height: 20, width: 20),
                          actionType: ActionType.toggleSwitch,
                          isToggleSwitchOn: isHidingFeed,
                          onChanged: (value) {
                          print('---> hiding feed: $value');
                            setState(() => isHidingFeed = value);
                          },
                        ),
                        CustomTile(title: '이미지 저장하기',
                            leadingIcon: SvgPicture.asset(kIcon.download, height: 20, width: 20),
                            voidCallback: null,   // todo,
                            actionType: ActionType.arrowRight
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
        }
    ).then((_) {
      service.isFeedHiding.value = isHidingFeed;
    });
  }
}

class _CheckWhoSend extends StatefulWidget {
  const _CheckWhoSend({Key? key}) : super(key: key);

  @override
  State<_CheckWhoSend> createState() => _CheckWhoSendState();
}

class _CheckWhoSendState extends State<_CheckWhoSend> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _header(),
        _buttonHint(),  //  힌트 보기
        _buttonCheckName(),  // 전체 이름 보기기
        _description()
      ],
    );
  }

  Widget _header() {
    String title = '누가 보냈는지 보기';
    Size size = getTextSize(title, kTextStyle.title1ExtraBold24);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScrollIndicatorBar(),

        Padding(
          padding: const EdgeInsets.only(top:20, bottom: 10),
          child: Text(title, style: kTextStyle.title1ExtraBold24),
        ),
      ],
    );
  }

  Widget _buttonHint() {  // 힌트 보기
    return GestureDetector(
      onTap: () => Navigator.pop(context, 'hint'),
      child: Container(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 15, bottom: 10),
        decoration: BoxDecoration(
          color: kColor.blue10,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text('힌트 보기', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.blue100)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonCheckName() {  // 전체 이름 보기
    return GestureDetector(
      onTap: () => Navigator.pop(context, 'omgPass'),
      child: Container(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: kColor.blue100,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(kIcon.ticketSvg, height: 24, width: 24,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text('전체 이름 보기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _description() {
    String message = 'OMG PASS를 구독하면 전체 이름을 볼 수 있어요.';
    return Text(message, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500));
  }
}

class _CheckHint extends StatefulWidget {
  const _CheckHint({Key? key,
    required this.hasOmgPass
  }) : super(key: key);

  final bool hasOmgPass;

  @override
  State<_CheckHint> createState() => _CheckHintState();
}

class _CheckHintState extends State<_CheckHint> {
  String cookieBalance = '';
  bool hasEnough = true;

  @override
  void initState() {
    super.initState();
    // _getCookieBalance();
  }

  // void _getCookieBalance() async {
  //   final HttpsResponse res = await CookieApi.getBalance();
  //   if (res.statusType == StatusType.success) {
  //     cookieBalance = res.body.toString();
  //     if (cookieBalance.isNotEmpty) {
  //       if (int.parse(cookieBalance) >= 400) {
  //         hasEnough = true;
  //       } else {
  //         hasEnough = false;
  //         if (mounted) _showNotEnough();
  //       }
  //       if (mounted) setState(() {});
  //     }
  //   }
  // }

  void _showNotEnough() => customSnackbar(
      context,
      '🍪',
      '쿠키가 부족해요!',
      ToastPosition.top
  );

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: _body(size),
    );
  }

  Widget _body(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _header(),
        _description(),
        _buttons()
      ],
    );
  }

  Widget _header() {
    String title = '힌트 보기';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScrollIndicatorBar(),

        Padding(
          padding: const EdgeInsets.only(top:20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: kTextStyle.title1ExtraBold24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text('내 쿠키', style: kTextStyle.caption1SemiBold12
                        .copyWith(color: hasEnough ? kColor.grey500 : kColor.red100)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: SvgPicture.asset(kIcon.idenCoinSvg, height: 20, width: 20,
                          colorFilter: hasEnough ? null : ColorFilter.mode(kColor.red100, BlendMode.screen),
                        ),
                      ),
                      Text(cookieBalance.toCurrency(),
                          style: kTextStyle.headlineExtraBold18.copyWith(color: hasEnough ? Colors.black : kColor.red100)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _description() {
    String message = '이 카드에 400 쿠키를 사용할게요!\n보낸 친구 이름의 마지막 글자를 알려드려요.';
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: SvgPicture.asset(kIcon.idenCoinSvg, height: 20, width: 20),
              ),
              Text('-400', style: kTextStyle.headlineExtraBold18),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(message, style: kTextStyle.footnoteMedium14),
          ),
        ],
      ),
    );
  }

  Widget _buttons() {  // 전체 이름 보기
    double ratio = 0.43;
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(  // 버튼 -> 잠깐망요
          onTap: () => Navigator.pop(context, false),
          child: Container(
            height: 60,
            width: size.width * ratio,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('잠깐만요', style: kTextStyle.headlineExtraBold18),
          ),
        ),
        GestureDetector(  // 버튼 -> 쿠키 사용하기
          onTap: () {
            if (hasEnough) {
              String clue;
              if (widget.hasOmgPass) {
                clue = 'full';
              } else {
                clue = 'half';
              }
              Navigator.pop(context, clue);
            }
          },
          child: Container(
            height: 60,
            width: size.width * ratio,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: hasEnough ? kColor.blue100 : kColor.blue30,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('쿠키 사용하기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _CheckConsonantLastName extends StatefulWidget {
  const _CheckConsonantLastName({Key? key,
    required this.username,
    required this.tryNumOfCheckFullname
  }) : super(key: key);

  final String? username;
  final int tryNumOfCheckFullname;

  @override
  State<_CheckConsonantLastName> createState() => _CheckConsonantLastNameState();
}

class _CheckConsonantLastNameState extends State<_CheckConsonantLastName> {
  String? consonant;
  String? lastName;
  late bool isButtonOn;

  @override
  void initState() {
    super.initState();
    _setHintInfo();
  }

  void _setHintInfo() {
    String? username = widget.username;
    if (username != null) {
      consonant = username.getFirstConstant();
      lastName = username.getLastName();
    }
    if (widget.tryNumOfCheckFullname > 0) {
      isButtonOn = true;
    } else {
      isButtonOn = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    String message = '이 카드를 보낸 친구의\n첫 번째 초성과 마지막 글자에요!';

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScrollIndicatorBar(),
          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageHint(consonant),

              SvgPicture.asset(kIcon.question, height: 32),

              _imageHint(lastName)
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(message, style: kTextStyle.title1ExtraBold24),
          ),

          _button(context)
        ],
      ),
    );
  }

  Widget _imageHint(String? input) {
    return input != null
        ? SizedBox(
            height: 100,
            width: 100,
            child: Stack(
                children: [
                  SvgPicture.asset(kImage.flashSvg, fit: BoxFit.contain),
                  Align(
                      alignment: Alignment.center,
                      child: Text(input ?? '', style: TextStyle(fontFamily: 'gothic',
                          fontSize: 32, fontWeight: FontWeight.w400, color: kColor.blue100)))
                ]
            )
          )
        : const SizedBox(height: 50, width: 50);
  }

  Widget _button(context) {
    String message = '이번 주 확인 기회를 모두 사용했어요.';
    if (!isButtonOn) {
      message = '이번 주 확인 기회를 모두 사용했어요.';
    } else {
      message = '${widget.tryNumOfCheckFullname}번의 확인 기회가 남아있어요.';
    }
    return GestureDetector(
        onTap: () {
          if (isButtonOn) Navigator.pop(context, 'fullname');
        },
        child: Column(
          children: [
            Container(
                height: 56,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                decoration: BoxDecoration(
                    color: isButtonOn ? kColor.blue100 : kColor.blue30,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Text('전체 이름 보기', style: kTextStyle.buttonWhite)
            ),
            Text(message, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500))
          ],
        )
    );
  }
}

class _CheckLastName extends StatefulWidget {
  const _CheckLastName({Key? key,
    required this.username,
  }) : super(key: key);

  final String? username;

  @override
  State<_CheckLastName> createState() => _CheckLastNameState();
}

class _CheckLastNameState extends State<_CheckLastName> {
  String? lastName;

  @override
  void initState() {
    super.initState();
    _setHintInfo();
  }

  void _setHintInfo() {
    String? username = widget.username;
    print('---> _CheckConsonantHint > set hint info > username: $username');
    if (username != null) {
      lastName = username.getLastName();
    }
  }

  @override
  Widget build(BuildContext context) {
    String message = '이 카드를 보낸 친구 이름의\n마지막 글자에요!';

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScrollIndicatorBar(),
          const SizedBox(height: 15),

          _imageHint(lastName),

          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(message, style: kTextStyle.title1ExtraBold24),
          ),

          _button(context)
        ],
      ),
    );
  }

  Widget _imageHint(String? input) {
    return SizedBox(
        height: 100,
        width: 100,
        child: Stack(
            children: [
              SvgPicture.asset(kImage.flashSvg, fit: BoxFit.contain),
              Align(
                  alignment: Alignment.center,
                  child: Text(input ?? '', style: TextStyle(fontFamily: 'gothic',
                      fontSize: 32, fontWeight: FontWeight.w400, color: kColor.blue100)))
            ]
        )
    );
  }

  Widget _button(context) {
    return GestureDetector(
        onTap: () => Navigator.pop(context, 'omgPass'),
        child: Column(
          children: [
            Container(
                height: 56,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 10),
                decoration: BoxDecoration(
                    color: kColor.blue100,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(kIcon.ticketSvg, height: 24, width: 24,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text('전체 이름 보기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
            ),
            Text('OMG PASS를 구독하면 전체 이름을 볼 수 있어요.', style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500))
          ],
        )
    );
  }
}


class _CheckConsonant extends StatefulWidget {
  const _CheckConsonant({Key? key,
    required this.username,
    required this.tryNumOfCheckFullname
  }) : super(key: key);

  final String? username;
  final int tryNumOfCheckFullname;

  @override
  State<_CheckConsonant> createState() => _CheckConsonantState();
}

class _CheckConsonantState extends State<_CheckConsonant> {
  String? lastName;
  late bool isButtonOn;

  @override
  void initState() {
    super.initState();
    _setHintInfo();
  }

  void _setHintInfo() {
    String? username = widget.username;
    print('---> _CheckConsonantHint > set hint info > username: $username');
    if (username != null) {
      lastName = username.getFirstConstant();
    }
    if (widget.tryNumOfCheckFullname > 0) {
      isButtonOn = true;
    } else {
      isButtonOn = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String message = '이 카드를 보낸 친구의\n첫 번째 초성이에요!';

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScrollIndicatorBar(),
          const SizedBox(height: 15),

          _imageHint(lastName),

          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(message, style: kTextStyle.title1ExtraBold24),
          ),

          _buttonHint(),  //  힌트 보기
          _buttonCheckName(),  // 전체 이름 보기기
        ],
      ),
    );
  }

  Widget _imageHint(String? input) {
    return SizedBox(
        height: 100,
        width: 100,
        child: Stack(
            children: [
              SvgPicture.asset(kImage.flashSvg, fit: BoxFit.contain),
              Align(
                  alignment: Alignment.center,
                  child: Text(input ?? '', style: TextStyle(fontFamily: 'gothic',
                      fontSize: 32, fontWeight: FontWeight.w400, color: kColor.blue100)))
            ]
        )
    );
  }

  Widget _buttonHint() {  // 힌트 보기
    return GestureDetector(
      onTap: () => Navigator.pop(context, 'hint'),
      child: Container(
        height: 60,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 15, bottom: 5),
        decoration: BoxDecoration(
            color: isButtonOn ? kColor.blue30 : kColor.blue100,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text('힌트 보기', style: kTextStyle.headlineExtraBold18
                  .copyWith(color: isButtonOn ? kColor.blue100 : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonCheckName() {  // 전체 이름 보기
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (isButtonOn) Navigator.pop(context, 'fullname');
          },
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 5, bottom: 10),
            decoration: BoxDecoration(
                color: isButtonOn ? kColor.blue100 : kColor.blue30,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(kIcon.ticketSvg, height: 24, width: 24,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('전체 이름 보기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        _description()
      ],
    );
  }

  Widget _description() {
    String message = '이번 주 확인 기회를 모두 사용했어요.';
    if (!isButtonOn) {
      message = '이번 주 확인 기회를 모두 사용했어요.';
    } else {
      message = '${widget.tryNumOfCheckFullname}번의 확인 기회가 남아있어요.';
    }
    return Text(message, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500));
  }
}
