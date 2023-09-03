import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:flutter/services.dart';
import 'package:iden/rest_api/api.dart';
import 'package:iden/ui/common_widget/custom_button.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';
import 'package:iden/ui/pages/vote/countdown_for_next_vote.dart';
import 'package:iden/ui/pages/vote/vote_complete_reward_B.dart';
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
import '../../../rest_api/card_api.dart';

class VoteMainB extends StatefulWidget {
  const VoteMainB({Key? key}) : super(key: key);

  @override
  State<VoteMainB> createState() => _VoteMainBState();
}

class _VoteMainBState extends State<VoteMainB> with SingleTickerProviderStateMixin{
  late PageController _pageController;

  bool isCardReady = false;   // true -> 모든 카드를 받음
  bool hasCardEnd = false;    // true -> 투표 종료
  bool isLastCard = false;    // true -> 마지막 카드
  bool hasVoteStarted = false;    // 처음 시작할 때 스펙터 모드 안 보이게 하기 위해서
  bool isNextVoteStarted = false;   // 아래 검색 아이콘에 텍스트 보여 주기 위해서
  List<int> clickSpeeds = [];  // unit: ms. 카드 선택 클릭 속도 확인, 연속 4번 1초 이내로 클릭 하면 -> warning snackbar
  bool isClickTooFast = false;    // true -> 클릭 속도가 빠름, 총 4초 이내 -> warning snackbar
  DateTime? firstClickTime;  // 첫 클릭 시간 기록
  bool hasClickTimeChecked = false;   // 중복 확인 피하기 위해서
  /// one batch card
  CardBatch? cardBatch;
  List<Color> backgroundColors = [];

  /// vote main B
  List<bool> isVoteDone = [];    // true -> 각 카드에 대한 투표 마침
  List<int> selectedCandidateIndex = [];
  List<Color> baseColor = [];
  List<OmgCard> cards = [];
  List<List<double?>> gaugeRatio = [];
  List<bool> isSpectorMode = [];
  List<int> refreshCount = [];   // 3번 기회 -> 0 : decent
  List<String> selectedUserNames = [];    // for reward page
  List<String> emojis = [];   // for reward page
  int totalPages = 0;
  int totalVoteCount = 0;
  int currentPageIndex = 0;
  int spectorModeCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
        initialPage: 0
    );
    if (!service.isVoteComplete.value) {
      List<double?> ratio = List.generate(4, (index) => null);
      gaugeRatio = List.generate(5, (index) => ratio);
      isVoteDone = List.generate(5, (index) => false);
      selectedCandidateIndex = List.generate(5, (index) => 0);
      isSpectorMode = List.generate(5, (index) => false);
      refreshCount = List.generate(5, (index) => 3);
      _setGauge();
      _setOMGCard();
      _setColor();
    }
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

  void _setGauge() {
    final random = Random();
    for (int i = 0; i < 5; i++) {
      List<double> ratios = [];
      for (int j=0; j < 4; j++) {
        double r = 1 - random.nextDouble();
        ratios.add(r);
      }
      gaugeRatio[i] = ratios;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (!hasCardEnd) {
      service.voteStatus.value == VoteStatus.inProcess;
    } else {
      service.voteStatus.value == VoteStatus.completed;
    }
    super.dispose();
    print('---> votes > dispose');
  }

  @override
  void didUpdateWidget(VoteMainB oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('---> vote main B > didUpdateWidget');
  }

  void _setOMGCard() {  // todo
    cards = service.generateSampleCards();
    totalPages = cards.length;
    isCardReady = true;
    if (mounted) setState(() {});
  }
  // void _setOMGCard() async {
  //   print('---> set omg card');
  //   HttpsResponse response = await IdenApi.getCardBatchStart(); // load new cards set
  //   if (response.statusType == StatusType.success) {
  //     cardBatch = CardBatch.fromJson(response.body);
  //   }
  //
  //   if (cardBatch?.cards?.isNotEmpty == true) {
  //     cards = cardBatch!.cards!;
  //     if (cards.isNotEmpty) {
  //       for (var e in cards) {
  //         emojis.add(e.emoji!);
  //       }
  //       totalPages = cards.length;
  //     }
  //     isCardReady = true;
  //   }
  //
  //   if (mounted) setState(() {});
  // }

  void _move2VoteCompleteReward() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => VoteCompleteReward(
          totalVoteCount: totalVoteCount,
          emojis: emojis,
          candidates: selectedUserNames,
        ))
    ).then((value) {
      // if (value == true) widget.onCompleted();
    });
  }

  void _castVote(int page, int index, int? cardId, User user) {    // todo
    isNextVoteStarted = false;
    if (isSpectorMode[currentPageIndex] && spectorModeCount > 0) {
      spectorModeCount -= 1;
    }

    /// record 투표 결과
    print('---> username: ${user.name!}');
    selectedUserNames.add(user.name!);
    emojis.add(cards[currentPageIndex].emoji!);

    setState(() {
      isVoteDone[currentPageIndex] = true;
      totalVoteCount += 1;
    });
  }

  void _refreshCandidates(int page) async {   // todo
    cards[page].candidates = service.generateSampleCandidates();
    refreshCount[page]--;
    if (mounted) setState(() {});
  }

  // void _castVote(int page, int index, int? cardId, User? user) async {
  //   bool res = _updateClickSpeed();
  //   if (res) {    // true -> too fast
  //     _showBlockClickTime();
  //   } else {
  //     isNextVoteStarted = false;
  //     if (cardId != null && user?.id != null) {
  //       if (isSpectorMode[page] && spectorModeCount > 0) {
  //         service.spectorModeCount.value -= 1;
  //       }
  //
  //       final HttpsResponse res = await _callApi4cardVote(
  //           cardId, user!.id!, isSpectorMode[page]);
  //       if (res.statusType == StatusType.success) {
  //         OmgCard card = OmgCard.fromJson(res.body);
  //         if (card.candidates != null && card.candidates!.isNotEmpty) {
  //           int i = 0;
  //           for (var e in card.candidates!) {
  //             double? ratio;
  //             if (e.fillBoxRatio != null) {
  //               ratio = 1 - e.fillBoxRatio!;
  //             }
  //             gaugeRatio[page][i] = ratio;
  //             i++;
  //           }
  //         }
  //         /// record 투표 결과
  //         print('---> username: ${user.name!}');
  //         selectedUserNames.add(user.name!);
  //
  //         setState(() {
  //           isVoteDone[page] = true;
  //           totalVoteCount += 1;
  //         });
  //         _showTransparentDialog();
  //       } else if (res.statusType == StatusType.error) {
  //         if (isSpectorMode[page]) {
  //           _showSnackbarOutOfSpector();
  //         } else {
  //           ErrorResponse error = res.body;
  //           _showErrorMessage(error.message);
  //         }
  //       }
  //     }
  //   }
  // }

  Future<dynamic> _callApi4cardVote(int cardId, String userId, bool isSpectorMode) async {
    // 카드에 투표할 때마다 api call
    final HttpsResponse res = await IdenApi.postCardVote(
        cardId,
        userId,
        isSpectorMode
    );
    return Future.value(res);
  }

  // Future<bool> _refreshCandidates(int page) async {
  //   // cards[cardIndex].printOut();
  //   if (cards[page].id != null) {
  //     int cardId = cards[page].id!;
  //     HttpsResponse response = await CardApi.postCardReset(cardId);
  //
  //     if (response.statusType == StatusType.success) {
  //       OmgCard card = OmgCard.fromJson(response.body);
  //       cards[page] = card;
  //       refreshCount[page]--;
  //       return Future.value(true);
  //     } else {
  //       return Future.value(false);
  //     }
  //   } else {
  //     return Future.value(false);
  //   }
  // }

  bool _updateClickSpeed() {  // 각 카드 종료 시점에서 확인
    bool out = false;
    DateTime now = DateTime.now();
    if (!hasClickTimeChecked) {
      if (firstClickTime != null) {
        Duration duration = now.difference(firstClickTime!);
        clickSpeeds.add(duration.inMilliseconds);
      }
      if ((currentPageIndex) % 4 == 0 && currentPageIndex < 11 && currentPageIndex != 0) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: isSpectorMode[currentPageIndex]
        //     ? Colors.black : isVoteDone[currentPageIndex] ? backgroundColors[cardIndex] : '#EBEBEB'.toColor(),
        body: isCardReady
            ? _body()
            : service.isVoteComplete.value
              ? const _VoteCountDown()
              : Center(child: CupertinoActivityIndicator(color: kColor.grey100, radius: 20))
    );
  }

  Widget _body() {
    return AnnotatedRegion(
        value: kStyle.setSystemOverlayStyle(isSpectorMode[currentPageIndex] ? kScreenBrightness.dark : kScreenBrightness.light),
        child: _build4voteCards()
    );
  }

  Widget _build4voteCards() {
    return PageView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        onPageChanged: (page) {
          if (mounted) {
            setState(() {
              print('---> page: $page');
              if (page > 0 && page < totalPages + 1) currentPageIndex = page-1;
          });
          }
        },
        itemCount: totalPages + 2,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _ready2start();
          } else if (index < totalPages + 1){
            int page = index - 1;
            return _cardBuild(page, cards[page]);
          } else {
            return VoteCompleteRewardB(totalVoteCount: totalVoteCount, emojis: emojis, candidates: selectedUserNames);
          }
        },
    );
  }

  Widget _cardBuild(int page,OmgCard omgCard) {
    double height = MediaQuery.of(context).size.height;
    double hh = height * 0.7;
    return Container(
      // height: hh,
      width: double.infinity,
      padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: kToolbarHeight,
          bottom: 30
      ),
      decoration: BoxDecoration(
          color: isSpectorMode[page]
              ? Colors.black
              : isVoteDone[page]
                  ? baseColor[page]
                  : kColor.grey20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _questionNo(page),
          _question(hh, page, omgCard),
          omgCard.emoji != null
              ? _showEmoji(omgCard.emoji!)
              : SizedBox(height: hh * 0.15),

          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _voteFriends(hh, page, omgCard),
              _buttons(page)
            ],
          ),
        ],
      ),
    );
  }

  Widget _ready2start() {
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.72,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: kColor.grey20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.1),
              Text('Ready For Vote', style: kTextStyle.largeTitle28),
              const SizedBox(height: 10),
              Text('You can cast your vote upto $totalPages ', style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey900)),
              const SizedBox(height: 50),

              _iden3D(),
              const SizedBox(height: 100),
            ],
          ),

          Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Text('Scroll up to start', style: kTextStyle.bodyMedium18.copyWith(color: kColor.grey500))
          )
        ],
      ),
    );
  }

  Widget _questionNo(int page) {
    String token;
    if (totalVoteCount == 0) {
      token = '0';
    } else {
      token = '+$totalVoteCount';
    }

    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text('${page+1} / 5', style: kTextStyle.headlineExtraBold18.copyWith(
                color: isSpectorMode[page] ? kColor.grey20 : Colors.black
            )),
          ),
        ),
        if (totalVoteCount >= 0)
          Align(
            alignment: Alignment.centerRight,
            child: Row(   // 쿠키 수량
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(isSpectorMode[page] ? kIcon.idenCoinLight : kIcon.idenCoinSvg, height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(token, style: kTextStyle.headlineExtraBold18.copyWith(
                      color: isSpectorMode[page] ? kColor.grey20 : null)),
                )
              ],
            ),
          )
      ],
    );
  }

  Widget _question(double height, int page, OmgCard card) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Text(cards[page].question ?? '-', maxLines: 2, textAlign: TextAlign.center,
              style: kTextStyle.largeTitle28.copyWith(color: isSpectorMode[page] ? Colors.white : null, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _showEmoji(String emoji) {
    return CustomCacheNetworkEmoji(emojiUrl: emoji, size: 120);
  }

  Widget _voteFriends(double height, int page, OmgCard card) {
    // double hh = height * 0.55; // 0.4
    double ratio = 1/0.75; // 1/0.8

    if (MediaQuery.of(context).size.height <= 700) {
      ratio = 1/0.4;
      // hh = height * 0.3;
    }

    List<String> names = List.generate(4, (_) => '').toList();
    List<String> affiliation = List.generate(4, (_) => '').toList();
    List<String> images = List.generate(4, (_) => '').toList();
    List<User?> users = List.generate(4, (_) => User()).toList();

    if (cards[page].candidates != null && cards[page].candidates!.isNotEmpty) {
      int i = 0;
      for (var e in cards[page].candidates!) {
        users[i] = e.user;
        if (e.user?.name != null) {
          // names.add(e.user!.name!);
          names[i] = e.user!.name!;
        }
        String? aff = e.user?.affiliation;
        if (aff != null) {
          affiliation[i] = aff;
        }
        String? img = e.user?.profileImageKey;
        if (img != null) {
          images[i] = img;
        }
        i++;
      }
    }

    return Container(
      // height: hh,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSpectorMode[page] ? kColor.grey900 : Colors.white,
        borderRadius: BorderRadius.circular(20)
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        childAspectRatio: ratio,
        padding: const EdgeInsets.all(0),
        children: List.generate(4, (idx) {
          return _unitVote(page, idx, users[idx], card.id);
        }),
      ),
    );
  }

  Widget _unitVote(int page, int index, User? user, int? cardId) {
    return GestureDetector(
      onTap: () {
        if (!isVoteDone[page]) { // 투표가 끈나지 않은 경우
          if (!isSpectorMode[page]) {
            setState(() => selectedCandidateIndex[page] = index);
            _castVote(page, index, cardId, user!);
          } else {    // 스펙터 모드 인 경우
            if (spectorModeCount > 0) {
              setState(() => selectedCandidateIndex[page] = index);
              _castVote(page, index, cardId, user!);
            }
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSpectorMode[page]
                ? isVoteDone[page]  // 스펙터 모드
                    ? LinearGradient(   // 투표 마침
                          colors: [
                            isVoteDone[page] && selectedCandidateIndex[page] == index ? Colors.black : Colors.black38,
                            isVoteDone[page] && selectedCandidateIndex[page] == index ? Colors.white10 : Colors.black12
                          ],
                          stops: [gaugeRatio[page][index] ?? 0.75, gaugeRatio[page][index] ?? 0.75],  // stop ratio 0 ~ 1: 0->full, 1->none
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
                : isVoteDone[page]    // 스펙터 모드 아닌 경우
                    ? LinearGradient(   // 투표 마침
                          colors: [
                            isVoteDone[page] && selectedCandidateIndex[page]== index ? baseColor[page].withOpacity(0.2) : kColor.grey20,
                            isVoteDone[page] && selectedCandidateIndex[page] == index ? baseColor[page].withOpacity(0.5) : kColor.grey100
                          ],
                          stops: [gaugeRatio[page][index] ?? 0.75, gaugeRatio[page][index] ?? 0.75],  // stop ratio 0 ~ 1: 0->full, 1->none
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      )
                    : LinearGradient(   // 투표 전
                          colors: [
                            baseColor[page].withOpacity(0.2),
                            baseColor[page].withOpacity(0.4),
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
              colorFilter: isVoteDone[page] && selectedCandidateIndex[page] != index
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
                            isSpectorMode[page]
                                ? isVoteDone[page] && selectedCandidateIndex[page] != index ? Colors.grey.shade600 : Colors.white
                                : isVoteDone[page] && selectedCandidateIndex[page] != index ? Colors.grey.shade600 : null))),
                ),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(user?.affiliation ?? '_',
                        style: kTextStyle.footNoteGrey.copyWith(color: isSpectorMode[page]
                            ? isVoteDone[page] && selectedCandidateIndex[page] != index ? Colors.grey.shade700 : Colors.grey.shade400
                            : kColor.grey1000.withOpacity(0.5))))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttons(int page) {
    double wd = MediaQuery.of(context).size.width * 0.25;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _spectorSwitch(page, wd),
          _search(page, wd),
          _shuffleUser(page, wd)
        ],
      ),
    );
  }

  Widget _spectorSwitch(int page, double wd) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (mounted) {
          setState(() {
            if (!isVoteDone[page] && spectorModeCount > 0) isSpectorMode[page] = !isSpectorMode[page];
        });
        }
      },
      child: Container(
          height: 44,
          width: wd,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: isSpectorMode[page] ? kColor.grey900 : Colors.white,
              borderRadius: BorderRadius.circular(40)
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: isSpectorMode[page] ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              isSpectorMode[page]
                  ? _spectorModeCount(page)
                  : _spectorIcon(page),
              isSpectorMode[page]
                  ? _spectorIcon(page)
                  : _spectorModeCount(page)
            ],
          )
      ),
    );
  }

  Widget _spectorIcon(int page) {
    String icon;
    if (isSpectorMode[page]) {
      icon = kIcon.ghostBlack;
    } else {
      icon = kIcon.ghost;
    }
    return Container(
        height: 30,
        width: 30,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: isSpectorMode[page] ? Colors.white : Colors.black,
            shape: BoxShape.circle
        ),
        child: SvgPicture.asset(icon, height: 14, width: 14)
    );
  }
  Widget _spectorModeCount(int page) {
    EdgeInsets padding;
    if (isSpectorMode[page]) {
      padding = const EdgeInsets.only(right: 10);
    } else {
      padding = const EdgeInsets.only(left: 10);
    }

    return Padding(
      padding: padding,
      child: Text('$spectorModeCount/3', style: kTextStyle.subHeadlineBold14.copyWith(
        color: isSpectorMode[page] ? Colors.white : Colors.black
      )),
    );
  }

  Widget _search(int page, double wd) {
    return Container(
      height: 44,
      width: wd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: isSpectorMode[page] ? kColor.grey900 : Colors.white,
          borderRadius: BorderRadius.circular(40)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Icon(CupertinoIcons.search, size: 24, color: isSpectorMode[page] ? kColor.grey20 : kColor.grey500),
    );
  }

  Widget _shuffleUser(int page, double wd) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (refreshCount[page] > 0) {
          if (!isVoteDone[page]) _refreshCandidates(page);
        }
      },
      child: Container(
        height: 44,
        width: wd,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isSpectorMode[page] ? kColor.grey900 : Colors.white,
            borderRadius: BorderRadius.circular(40)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // child: Icon(Icons.rora, size: 24, color: isSpectorMode ? kColor.grey300 : kColor.grey500),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(kIcon.refreshSvg, height: 18, width: 18,
                colorFilter: ColorFilter.mode(isSpectorMode[page] ? kColor.grey20 : kColor.grey500, BlendMode.srcIn)
            ),
            const SizedBox(width: 8),
            Text('${refreshCount[page]}/3', style: kTextStyle.subHeadlineBold14.copyWith(color: isSpectorMode[page] ? kColor.grey20 : kColor.grey500))
          ],
        )
      ),
    );
  }

  Widget _profileImage(User? user) {
    String? profileImage = user?.profileImageKey;

    if (user != null) {
      if (profileImage != null) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(profileImage, height: 40, width: 40, fit: BoxFit.cover)
        );
      } else {
        return customCircleAvatar(name: user.name ?? '-', size: 40, fontSize: 18, fontWeight: FontWeight.w800);
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  // Widget _profileImage(User? user) {
  //   String? profileImage = user?.profileImageKey;
  //
  //   if (user != null) {
  //     if (profileImage != null) {
  //       return CustomCacheNetworkImage(imageUrl: profileImage, size: 40,);
  //     } else {
  //       return customCircleAvatar(name: user.name ?? '-', size: 40, fontSize: 18, fontWeight: FontWeight.w800);
  //     }
  //   } else {
  //     return const SizedBox.shrink();
  //   }
  // }

  Widget _iden3D() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Image.asset(kAnimation.iden3D, height: 180,),
    );
  }
}

class _VoteCountDown extends StatefulWidget {
  const _VoteCountDown({Key? key}) : super(key: key);

  @override
  State<_VoteCountDown> createState() => _VoteCountDownState();
}

class _VoteCountDownState extends State<_VoteCountDown> {

  void _countdownTimeOver() {
    /// -1 -> 타이머에 00:00 (0초)까지 표시하고 이후 리셋
    if (service.countdown30min.value.inSeconds <= -1 && service.hasVoteCountdownTriggered.value) {
      service.voteCountdownDone();
      // _callbackResult('countdownDone)
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted )setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.72,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 40),
      decoration: BoxDecoration(
          color: kColor.grey20,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _title(),
          _clock3D(),
          Obx(() => _timer()),
          const SizedBox(height: 16),
          Text('질문 준비 중', style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey900)),
          const SizedBox(height: 32),
          CustomButtonWide(
            title: '친구 초대하고 초기화하기',
            background: '#EAEAEF'.toColor(),
            titleColor: Colors.black,
            bottomMargin: 5,
            onTap: () {
              service.isVoteComplete.value = false;
              service.cancelTimer4Vote();
            },
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return Container(
      height: kToolbarHeight + 95,
      color: Colors.transparent,
      alignment: Alignment.center,
      // margin: const EdgeInsets.only(left: 20),
      child: SvgPicture.asset(kIcon.idenLogoSvg, height: 22, width: 71,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          fit: BoxFit.cover),
    );
  }

  Widget _timer() {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    String min;
    final mm = service.countdown30min.value.inMinutes;
    if (mm < 10) {
      min = '0$mm';
    } else {
      min = mm.toString();
    }
    final sec = strDigits(service.countdown30min.value.inSeconds.remainder(60));
    _countdownTimeOver();

    TextStyle style = kTextStyle.largeTitle28.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()]
    );

    return Text('00:$min:$sec', style: style);
  }

  Widget _clock3D() {
    return Expanded(
      child: Image.asset(kAnimation.clock3D),
    );
  }
}
