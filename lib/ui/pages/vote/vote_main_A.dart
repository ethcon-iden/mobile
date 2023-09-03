import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/services.dart';
import 'package:iden/rest_api/api.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'vote_complete_reward.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../../controller/state_controller.dart';
import '../../../model/user.dart';
import '../../../services/image_color.dart';
import '../../../resource/images.dart';
import '../../../resource/style.dart';
import '../../../model/omg_card_model.dart';
import '../../../model/session.dart';
import '../../../services/extensions.dart';
import '../../common_widget/dialog_popup.dart';

class VoteMainA extends StatefulWidget {
  const VoteMainA({Key? key,
    required this.onCompleted
  }) : super(key: key);

  final VoidCallback onCompleted;

  @override
  State<VoteMainA> createState() => _VoteMainAState();
}

class _VoteMainAState extends State<VoteMainA> with SingleTickerProviderStateMixin{
  late AppinioSwiperController _swipeController;
  late RefreshController _refreshController;

  int totalCount = 0;
  int cardIndex = 0;
  int refreshCount = 3;   // 3번 기회 -> 0 : decent
  int totalVoteCount = 0;
  int bonusCookies = 0;
  bool isCardReady = false;   // true -> 모든 카드를 받음
  bool hasCardEnd = false;    // true -> 투표 종료
  bool isVoteDone = false;    // true -> 각 카드에 대한 투표 마침
  bool isLastCard = false;    // true -> 마지막 카드
  bool isSpectorMode = false;
  int selectedCandidateIndex = 0;
  bool isSpectorOn = false;   // true -> 스펙터 모드 화면 전환
  bool hasVoteStarted = false;    // 처음 시작할 때 스펙터 모드 안 보이게 하기 위해서
  bool isNextVoteStarted = false;   // 아래 검색 아이콘에 텍스트 보여 주기 위해서
  List<int> clickSpeeds = [];  // unit: ms. 카드 선택 클릭 속도 확인, 연속 4번 1초 이내로 클릭 하면 -> warning snackbar
  bool isClickTooFast = false;    // true -> 클릭 속도가 빠름, 총 4초 이내 -> warning snackbar
  DateTime? firstClickTime;  // 첫 클릭 시간 기록
  bool hasClickTimeChecked = false;   // 중복 확인 피하기 위해서
  /// one batch card
  CardBatch? cardBatch;
  List<Color> baseColor = [];
  List<Color> backgroundColors = [];
  List<OmgCard> cards = [];
  List<String> emojis = [];
  List<String> candidates = [];
  List<Color> primaryColors = [];
  late List<double?> gaugeRatio;

  @override
  void initState() {
    super.initState();
    gaugeRatio = List.generate(4, (index) => null);
    _refreshController = RefreshController(initialRefresh: false);
    _swipeController = AppinioSwiperController();
    _setOMGCard();
    _setColor();
  }

  void _setColor() {
    baseColor = [
      '68B8FD'.toColor(),
      '74D2C0'.toColor(),
      'E05A5C'.toColor(),
      '8FA511'.toColor(),
      'F6CECE'.toColor(),
    ];
    backgroundColors = [
      'D2EAFF'.toColor(),
      'D5F2EC'.toColor(),
      'F6CECE'.toColor(),
      'E8EFBC'.toColor(),
      'F6CECE'.toColor(),
    ];
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _refreshController.dispose();
    if (!hasCardEnd) {
      service.voteStatus.value == VoteStatus.inProcess;
    } else {
      service.voteStatus.value == VoteStatus.completed;
    }
    super.dispose();
    print('---> votes > dispose');
  }

  void _reset4NewCard() {
    isVoteDone = false;
    cardIndex++;
    // service.currentCardIndex.value = cardIndex;
    setState(() {});
  }

  void _setOMGCard() async {
    HttpsResponse response = await IdenApi.getCardBatchStart(); // load new cards set
    if (response.statusType == StatusType.success) {
      cardBatch = CardBatch.fromJson(response.body);
    }

    if (cardBatch?.cards?.isNotEmpty == true) {
      cards = cardBatch!.cards!;
      if (cards.isNotEmpty) {
        for (var e in cards) {
          emojis.add(e.emoji!);
        }
        totalCount = cards.length;
      }
      isCardReady = true;
    }

    if (mounted) setState(() {});
  }

  void _onLoading() async {
    await Future.delayed(const Duration(seconds: 2));
    _refreshController.loadComplete();
  }

  void _onSwipe(int index, AppinioSwiperDirection direction) {
    // index 1 ~ 12 (주위. 0부터 아닌 1 부터 시작) -> index - 1 적용 -> 0 부터 시작
    if (index == cards.length) {
      setState(() => hasCardEnd = true);
    } else {
      if (!isVoteDone) _skipVote(index - 1);  // isVoteDone -> false : 투표가 끝나지 않은 경우만 스킵 처리
      _reset4NewCard();
    }
  }

  void _onEnd() async {
    _move2VoteCompleteReward();
  }

  void _move2VoteCompleteReward() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => VoteCompleteReward(
          totalVoteCount: totalVoteCount,
          emojis: emojis,
          candidates: candidates,
        ))
    ).then((value) {
      if (value == true) widget.onCompleted();
    });
  }

  void _castVote(int index, int? cardId, User? user) async {
    bool res = _updateClickSpeed();
    if (res) {    // true -> too fast
      _showBlockClickTime();
    } else {
      isNextVoteStarted = false;
      if (cardId != null && user?.id != null) {
        if (isSpectorMode && service.spectorModeCount.value > 0) {
          service.spectorModeCount.value -= 1;
        }

        final HttpsResponse res = await _callApi4cardVote(
            cardId, user!.id!, isSpectorMode);
        if (res.statusType == StatusType.success) {
          OmgCard card = OmgCard.fromJson(res.body);
          if (card.candidates != null && card.candidates!.isNotEmpty) {
            int i = 0;
            for (var e in card.candidates!) {
              double? ratio;
              if (e.fillBoxRatio != null) {
                ratio = 1 - e.fillBoxRatio!;
              }
              gaugeRatio[i] = ratio;
              i++;
            }
          }
          /// record 투표 결과
          print('---> username: ${user.name!}');
          candidates.add(user.name!);

          setState(() {
            isVoteDone = true;
            totalVoteCount += 1;
          });
          _showTransparentDialog();
        } else if (res.statusType == StatusType.error) {
          if (isSpectorMode) {
            _showSnackbarOutOfSpector();
          } else {
            ErrorResponse error = res.body;
            _showErrorMessage(error.message);
          }
        }
      }
    }
  }

  void _skipVote(int index) async {
    int? cardId = cards[index].id;
    if (cardId != null) _callApi4cardVote(cardId, '', false);
  }

  Future<dynamic> _callApi4cardVote(int cardId, String userId, bool isSpectorMode) async {
    // 카드에 투표할 때마다 api call
    final HttpsResponse res = await IdenApi.postCardVote(
        cardId,
        userId,
        isSpectorMode
    );
    return Future.value(res);
  }

  bool _updateClickSpeed() {  // 각 카드 종료 시점에서 확인
    bool out = false;
    DateTime now = DateTime.now();
    if (!hasClickTimeChecked) {
      if (firstClickTime != null) {
        Duration duration = now.difference(firstClickTime!);
        clickSpeeds.add(duration.inMilliseconds);
      }
      if ((cardIndex) % 4 == 0 && cardIndex < 11 && cardIndex != 0) {
        double sum = clickSpeeds.fold(0, (previousValue, element) => previousValue + element);
        print('---> 4 click speed sun: $sum');
        if (sum <= clickSpeeds.length * 1000) {
          out = true;
        }
      }
    }
    return out;
  }

  void _showTransparentDialog() {
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () {
              _swipeController.swipeLeft();
              isNextVoteStarted = true;
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          );
        }
    ).then((_) {
      hasClickTimeChecked = false;
      firstClickTime = DateTime.now();
    });
  }

  void _showBlockClickTime() {
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 76,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(width: 1, color: kColor.grey30),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('🧐', style: TextStyle(fontSize: 34)),
                      const SizedBox(width: 12.0),
                      Flexible(
                          child: Text('조금만 더 신중하게 선택해주세요!', maxLines: 3, style: kTextStyle.callOutBold16)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    ).then((value) {
      clickSpeeds.clear();
      hasClickTimeChecked = true;
    });   // 클릭 속도 reset for next event

    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  void _showSnackbarOutOfSpector() {
    customSnackbar(context,
        '👻',
        '스펙터 모드 기회를 모두 사용했어요.',
        ToastPosition.bottom);
  }

  void _showErrorMessage(String? message) => showErrorMessage(context, message);

  void _spectorModeController() {
    HapticFeedback.heavyImpact();
    bool isOn = false;
    if (isSpectorMode) isOn = true;
    if (!hasVoteStarted) hasVoteStarted = true;

    setState(() => isSpectorOn = isOn);
    Future.delayed(const Duration(milliseconds: 500), () => setState(() => isSpectorMode = !isSpectorMode));
  }

  @override
  Widget build(BuildContext context) {
    String token;
    if (totalVoteCount == 0) {
      token = '0';
    } else {
      token = '+$totalVoteCount';
    }

    return GestureDetector(
      onLongPress: () => _spectorModeController(),
      child: Scaffold(
          // backgroundColor: isSpectorMode ? Colors.black : isVoteDone ? primaryColors[cardIndex] : '#EBEBEB'.toColor(),  // todo > activate
          backgroundColor: isSpectorMode ? Colors.black : isVoteDone ? backgroundColors[cardIndex] : '#EBEBEB'.toColor(),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leadingWidth: kStyle.leadingWidth,
            systemOverlayStyle: kStyle.setSystemOverlayStyle(isSpectorMode ? kScreenBrightness.dark : kScreenBrightness.light),
            leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.black)),
            title: hasVoteStarted ? _animatedHeader() : null,
            centerTitle: true,
            actions: [
              if (totalVoteCount >= 0)
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Row(   // 쿠키 수량
                    children: [
                      SvgPicture.asset(kIcon.idenCoinSvg, height: 22,
                          colorFilter: isSpectorMode ? ColorFilter.mode(kColor.grey20, BlendMode.difference) : null),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(token, style: kTextStyle.headlineExtraBold18.copyWith(color: isSpectorMode ? kColor.grey20 : null)),
                      )
                    ],
                  ),
                )
            ],
          ),
          body: isCardReady ?_body() : Container()   // todo
      ),
    );
  }

  Widget _animatedHeader() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 400),
      crossFadeState: isSpectorMode
          ? isSpectorOn ? CrossFadeState.showFirst : CrossFadeState.showSecond
          : isSpectorOn ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstCurve: Curves.fastLinearToSlowEaseIn,
      secondCurve: Curves.elasticOut,
      firstChild: isSpectorOn
          ? Text('스펙터 모드 해제', style: kTextStyle.callOutBold16.copyWith(color: kColor.grey20))
          : Text('스펙터 모드', style: kTextStyle.callOutBold16),
      secondChild: isSpectorMode
          ?  _spectorModeTitle() : const SizedBox.shrink()
    );
  }

  Widget _spectorModeTitle() {
    return  Container(
      height: 36,
      width: 82,
      padding: const EdgeInsets.only(left: 12, right: 12),
      decoration: BoxDecoration(
          color: kColor.grey900,
          borderRadius: BorderRadius.circular(30)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(kIcon.ghost, height: 18, width: 18),
          Obx(() => RichText(text: TextSpan(
              children: [
                TextSpan(text: '${service.spectorModeCount.value}', style: kTextStyle.callOutBold16.copyWith(color: kColor.grey300)),
                TextSpan(text: '/', style: kTextStyle.callOutBold16.copyWith(color: kColor.grey20)),
              ])
          ))
        ],
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        Container(
            height: 2,
            margin: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _dashIndicator(),
              ],
            )
        ),

        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: _cardsAction(),
        ),

      ],
    );
  }

  Future<void> _onRefresh() async {
    if (refreshCount < 3) {
      setState(() {});
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshFailed();
    }
  }

  Widget _cardsAction() {
    double height = MediaQuery.of(context).size.height;
    double hh = height * 0.8;    // 카드 전체 높이

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: hasCardEnd ? false : true,
      enablePullUp: false,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: _refreshClassicHeader(),
      child: ListView(
          physics: hasCardEnd ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
          children: [
            SizedBox(
                height: hh,
                child: isCardReady
                    ? AppinioSwiper(
                        controller: _swipeController,
                        allowUnswipe: false,
                        threshold: 100,
                        padding: const EdgeInsets.only(top: 25, bottom: 10),
                        direction: AppinioSwiperDirection.left,
                        swipeOptions: const AppinioSwipeOptions.symmetric(horizontal: true),
                        // onSwiping: _onSwiping,
                        onSwipe: _onSwipe,
                        onEnd: _onEnd,
                        cardsCount: cards.length,
                        cardsBuilder: (BuildContext context, int index) {
                          bool isVisible;
                          if (index == cardIndex) {
                            isVisible = true;
                          } else {
                            isVisible = false;
                          }
                          if (cardIndex == cards.length - 1) {
                            isLastCard = true;
                          }

                          return _cardBuild(
                              index,
                              hh,
                              isVisible,    // 뒷 카지 보이지 않게 하기 위해서
                              cards[index]
                          );
                        },
                )
                    : const CupertinoActivityIndicator()
            ),
          ]
      ),
    );
  }

  Widget _refreshClassicHeader() {
    return ClassicHeader(
      height: 40,
      completeText: '',
      idleText: '다른 친구들 보기 - $refreshCount/3',
      failedText: '',
      completeIcon: null,
      completeDuration: const Duration(milliseconds: 300),
      textStyle: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey500),
      refreshingText: '',
      releaseText: '',
    );
  }

  Widget _dashIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(
              parent: BouncingScrollPhysics()
          ),
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              width: MediaQuery.of(context).size.width / (cards.length + 1),
              height: 2,
              margin: const EdgeInsets.only(left: 2, right: 2),
              decoration: BoxDecoration(
                  color: (index <= cardIndex)
                      ? isSpectorMode ? Colors.white : Colors.black87
                      : isSpectorMode ? kColor.grey500 : Colors.black12
              ),
            );
          }
      ),
    );
  }

  Widget _cardBuild(int index, double height, bool isVisible, OmgCard omgCard) {
    return Container(
      height: height,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 20, right: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: isSpectorMode ? kColor.grey900 : Colors.white,
          borderRadius: BorderRadius.circular(28)
      ),
      child: Visibility(
        visible: isVisible,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _question(height, index, omgCard),
            omgCard.emoji != null
                ? Text(omgCard.emoji ?? '', style: const TextStyle(fontSize: 100))
                : SizedBox(height: height * 0.15),
            _voteFriends(height, index, omgCard),
          ],
        ),
      ),
    );
  }

  Widget _question(double height, int index, OmgCard card) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text('$totalCount개 중 ${cards[index].order}번째 질문이에요',
              style: kTextStyle.caption1.copyWith(color: isSpectorMode ? kColor.grey300 : kColor.grey500)),
          const SizedBox(height: 10),
          Text(cards[index].question ?? ' ', maxLines: 2, textAlign: TextAlign.center,
              style: kTextStyle.largeTitle28.copyWith(color: isSpectorMode ? Colors.white : null, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _voteFriends(double height, int index, OmgCard card) {
    double hh = height * 0.4; // 0.4
    double ratio = 1/0.8; // 1/0.8
    bool isCompactSize = false;

    if (MediaQuery.of(context).size.height <= 700) {
      isCompactSize = true;
      ratio = 1/0.4;
      hh = height * 0.3;
    }

    List<String> names = List.generate(4, (_) => '').toList();
    List<String> grade = List.generate(4, (_) => '').toList();
    List<String> images = List.generate(4, (_) => '').toList();
    List<User?> users = List.generate(4, (_) => User()).toList();

    if (cards[index].candidates != null && cards[index].candidates!.isNotEmpty) {
      int i = 0;
      for (var e in cards[index].candidates!) {
        users[i] = e.user;
        if (e.user?.name != null) {
          // names.add(e.user!.name!);
          names[i] = e.user!.name!;
        }
        String? gd = e.user?.clueWithDot;
        if (gd != null) {
          // grade.add(gd);
          grade[i] = gd;
        }
        String? img = e.user?.profileImageKey;
        if (img != null) {
          // images.add('${kConst.bucket}/$img');
          images[i] = img;
        }
        i++;
      }
    }

    return SizedBox(
      height: hh,
      width: double.infinity,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: ratio,
        children: List.generate(4, (idx) {
          return isCompactSize
              ? _unitVoteSmall(idx, users[idx], card.id)
              : _unitVote(idx, users[idx], card.id);
        }),
      ),
    );
  }

  Widget _unitVote(int index, User? user, int? cardId) {
    return GestureDetector(
      onTap: () {
        if (!isVoteDone) {  // 투표가 끈나지 않은 경우
          setState(() => selectedCandidateIndex = index);
          _castVote(index, cardId, user);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSpectorMode
                ? isVoteDone  // 스펙터 모드
                    ? LinearGradient(   // 투표 마침
                          colors: [
                            isVoteDone && selectedCandidateIndex == index ? Colors.black : Colors.black38,
                            isVoteDone && selectedCandidateIndex == index ? Colors.white10 : Colors.black12
                          ],
                          stops: [gaugeRatio[index] ?? 0.75, gaugeRatio[index] ?? 0.75],  // stop ratio 0 ~ 1: 0->full, 1->none
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      )
                    : const LinearGradient(   // 투표 전
                          colors: [
                            Colors.black,
                            Colors.black,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      )
                : isVoteDone    // 스펙터 모드 아닌 경우
                    ? LinearGradient(   // 투표 마침
                          colors: [
                            isVoteDone && selectedCandidateIndex == index ? baseColor[cardIndex].withOpacity(0.2) : kColor.grey20,
                            isVoteDone && selectedCandidateIndex == index ? baseColor[cardIndex].withOpacity(0.5) : kColor.grey100
                          ],
                          stops: [gaugeRatio[index] ?? 0.75, gaugeRatio[index] ?? 0.75],  // stop ratio 0 ~ 1: 0->full, 1->none
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      )
                    : LinearGradient(   // 투표 전
                          colors: [
                            baseColor[cardIndex].withOpacity(0.2),
                            baseColor[cardIndex].withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: isVoteDone && selectedCandidateIndex != index
                  ? greyscale : const ColorFilter.mode(Colors.transparent, BlendMode.difference),
                child: _profileImage(user)
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(user?.name ?? '-',
                          style: kTextStyle.callOutBold16.copyWith(color:
                            isSpectorMode
                                ? isVoteDone && selectedCandidateIndex != index ? Colors.grey.shade600 : Colors.white
                                : isVoteDone && selectedCandidateIndex != index ? Colors.grey.shade600 : null))),
                ),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(user?.affiliation ?? '_',
                        style: kTextStyle.footNoteGrey.copyWith(color: isSpectorMode
                            ? isVoteDone && selectedCandidateIndex != index ? Colors.grey.shade700 : Colors.grey.shade400
                            : kColor.grey1000.withOpacity(0.5))))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitVoteSmall(int index, User? user, int? cardId) {
    return GestureDetector(
      onTap: () {
        if (!isVoteDone) {  // 투표가 끈나지 않은 경우
          _castVote(index, cardId, user);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(left: 12, right: 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
                colors: [
                  baseColor[cardIndex].withOpacity(0.1),
                  baseColor[cardIndex].withOpacity(0.5)
                ],
                stops: [gaugeRatio[index] ?? 0.75, gaugeRatio[index] ?? 0.75],  // stop ratio 0 ~ 1: 0->full, 1->none
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _profileImage(user),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(user?.name ?? '', style: kTextStyle.callOutBold16)),
                ),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(user?.clueWithoutDot ?? '', style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey500)))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileImage(User? user) {
    String? profileImage = user?.profileImageKey;

    if (user != null) {
      if (profileImage != null) {
        return CustomCacheNetworkImage(imageUrl: profileImage, size: 40,);
      } else {
        return customCircleAvatar(name: user.name ?? '-', size: 40, fontSize: 18, fontWeight: FontWeight.w800);
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
