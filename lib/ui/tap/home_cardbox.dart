import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iden/rest_api/api.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';
import 'package:iden/ui/pages/child/modal_user_profile.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'dart:async';

import '../common_widget/dialog_popup.dart';
import '../common_widget/sliver_header_custom.dart';
import '../../model/session.dart';
import '../../rest_api/card_api.dart';
import '../../controller/state_controller.dart';
import '../../model/omg_card_model.dart';
import '../../model/user.dart';
import '../common_widget/bottom_modal.dart';
import '../common_widget/scroll_indicator._bar.dart';
import '../../resource/style.dart';
import '../../resource/images.dart';
import '../../services/extensions.dart';
import '../../services/utils.dart';
import '../pages/cardbox/open_receive_card_detail.dart';
import '../common_widget/lotti_animation.dart';

class HomeCardBox extends StatefulWidget {
  const HomeCardBox({Key? key,
    required this.onClicked
  }) : super(key: key);

  final VoidCallback onClicked;

  @override
  State<HomeCardBox> createState() => _HomeCardBoxState();
}

class _HomeCardBoxState extends State<HomeCardBox> {
  // final ScrollController _scrollController = ScrollController();
  /// dataset
  List<CompactCard>? receivedCard;
  List<CompactCard>? sendCards;
  int countReceiveCard = 0;
  int countReceivedComment = 0;
  /// control
  late StreamController<dynamic> _streamController;
  Paging? paging4receive;
  Paging? paging4send;
  bool hasReadAll = false;
  late CardDirection cardDirection;
  late Filter4receive filter4receiveCard; // default -> 전체
  late Filter4send filter4sendCard;  // default -> 전체
  bool isEndOfList = false;   // true -> 리스트 마지막
  List<int> listChecked = [];

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_scrollListener);
    cardDirection = CardDirection.send;  // 받은 카드 (default), 보낸 카드
    filter4receiveCard = service.cardBoxFilter4Receive.value;
    filter4sendCard = service.cardBoxFilter4Send.value;
    _streamController = StreamController<dynamic>();
    _getCardCount();
    // _getReceivedCard();
    _getSentCard();
  }

  @override
  void dispose() {
    // _scrollController.dispose();
    _streamController.close();
    service.cardBoxFilter4Send.value = Filter4send.all;
    service.cardBoxFilter4Receive.value = Filter4receive.all;
    super.dispose();
  }

  Future<void> _getCardCount() async {
    // 받은카드/보낸카드 갯수 가져오기
    List<CompactCard> cards = [];
    HttpsResponse res = await CardApi.getCount();

    if (res.statusType == StatusType.success) {
      int? countReceive = res.body['receivedCardCount'];
      int? countComments = res.body['receivedCommentCount'];
      if (countReceive != null) countReceiveCard = countReceive;
      if (countComments != null) countReceivedComment = countComments;
      if (mounted) setState(() {});
    }
  }
  
  Future<void> _getReceivedCard() async {   // 받은 카드
    List<CompactCard> cards = [];
    HttpsResponse res;

    if (filter4receiveCard == Filter4receive.unread) {
      res = await CardApi.getCardReceived(null, true, null, null, paging4receive);
    } else if (filter4receiveCard == Filter4receive.nameChecked) {
      res = await CardApi.getCardReceived(null, null, null, true, paging4receive);
    } else if (filter4receiveCard == Filter4receive.fromMale) {
      res = await CardApi.getCardReceived(null, null, Gender.male, null, paging4receive);
    } else if (filter4receiveCard == Filter4receive.fromFemale) {
      res = await CardApi.getCardReceived(null, null, Gender.female, null, paging4receive);
    } else {  // 모두
      res = await CardApi.getCardReceived(null, null, null, null, paging4receive);
    }

    if (res.statusType == StatusType.success) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          CompactCard card = CompactCard.fromJson(e);
          cards.add(card);
        }
        if (res.body['cursor'] != null)  {
          paging4receive = Paging.fromJson(res.body['cursor']);
          if (paging4receive?.afterCursor == null) setState(() => isEndOfList = true);
        }
      }

      if (receivedCard?.isNotEmpty ?? false) {
        List<CompactCard> all  = receivedCard!;
        all += cards;
        receivedCard = all;
      } else {
        receivedCard = cards;
      }
      if (!_streamController.isClosed) _streamController.add(receivedCard);
      if (mounted) setState(() {});

    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showError(error.message);
    }
  }

  Future<void> _getSentCard() async {   // 보낸 카드
    List<CompactCard> cards = [];
    HttpsResponse res;

    if (filter4sendCard == Filter4send.hasComment) { // 답글 달린 카드
      res = await IdenApi.getCardSent(null, true, null, paging4send);
    } else if (filter4sendCard == Filter4send.toMale) {
      res = await IdenApi.getCardSent(null, null, Gender.male, paging4send);
    } else if (filter4sendCard == Filter4send.toFemale) {
      res = await IdenApi.getCardSent(null, null, Gender.female, paging4send);
    } else {  // 모든 보낸 카드
     res = await IdenApi.getCardSent(null, null, null, paging4send);
    }

    if (res.statusType == StatusType.success) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          CompactCard card = CompactCard.fromJson(e);
          cards.add(card);
        }
        if (res.body['cursor'] != null) {
          paging4send = Paging.fromJson(res.body['cursor']);
          if (paging4send?.afterCursor == null) setState(() => isEndOfList = true);
        }
      }

      if (sendCards?.isNotEmpty ?? false) { // 카드가 있는 경우 추가
        List<CompactCard> all  = sendCards!;
        all += cards;
        sendCards = all;
      } else {  // 카드가 없는 경우 초기화
        sendCards = cards;
      }
      if (!_streamController.isClosed) _streamController.add(sendCards);
      if (mounted) setState(() {});

    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showError(error.message);
    }
  }

  void _modal2Filter(BuildContext context) async {
    await showCustomBottomSheet(
        context,
        _FilterContents(cardDirection: cardDirection),
        cardDirection == CardDirection.receive ? 500 : 420,
        true
    );
    _filterUpdate();
    setState(() {});
  }

  void _filterUpdate() {
    if (cardDirection == CardDirection.receive) {
      if (filter4receiveCard != service.cardBoxFilter4Receive.value) {
        filter4receiveCard = service.cardBoxFilter4Receive.value;
        _resetReceiveCard();
        _getReceivedCard();
      }
    } else {
      if (filter4sendCard != service.cardBoxFilter4Send.value) {
        filter4sendCard = service.cardBoxFilter4Send.value;
        _resetSentCard();
        _getSentCard();
      }
    }
  }

  void _onTapReceiveSendCard(CardDirection option) {
    isEndOfList = false;    // 초기화
    // HapticFeedback.lightImpact();
    if (cardDirection != option)  {
      cardDirection = option;
      if (option == CardDirection.receive) {  // 받은 카드
        _streamController.add(receivedCard ?? []);
      } else {  // 보낸 카드
        if (sendCards != null) {
          _streamController.add(sendCards ?? []);
        } else {
          _getSentCard();
        }
      }
      setState(() {});
    }
  }

  void _handleReadAll() async {
    if (!hasReadAll) {
      HttpsResponse res = await CardApi.postMarkReadAllReceivedCards();
      if (res.statusType == StatusType.success ||
          res.statusType == StatusType.empty) {
        _resetReceiveCard();
        setState(() {
          hasReadAll = true;
          countReceiveCard = 0; // todo > get from API
        });
      } else if (res.statusType == StatusType.error) {
        ErrorResponse error = res.body;
        _showError(error.message);
      }
    }
  }

  void _resetReceiveCard() {
    isEndOfList = false;   // 초기화
    receivedCard = [];
    paging4receive?.reset();
  }

  void _resetSentCard() {
    isEndOfList = false;   // 초기화
    sendCards = [];
    paging4send?.reset();
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 100) {
      _getMore();
    }
  }

  void _getMore() {
    if (cardDirection == CardDirection.receive) {
      if (paging4receive?.afterCursor != null) _getReceivedCard();
    } else {
      if (paging4send?.afterCursor != null) _getSentCard();
    }
  }

  void _selectCard(String? uid) {
    print('---> uid: $uid');
    if (uid?.isNotEmpty == true) _cupertinoModal4userInfo(uid!);
  }

  Future<void> _onRefresh() async {
    if (cardDirection == CardDirection.receive) {   // 받은 카드
      _resetReceiveCard();
      _getReceivedCard();
    } else {  // 보낸 카드
      _resetSentCard();
      _getSentCard();
    }
  }

  void _cupertinoModal4userInfo(String uid) {
    modalCupertino(
        context,
        ModalUserProfile(userId: uid),
        false   // not draggable
    ).then((value) => setState(() {}));
  }

  void _move2OmgMain() => widget.onClicked();

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // when start to scroll by touching the screen
        if (notification is ScrollStartNotification) {
          // _onStartScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> android
        } else if (notification is OverscrollNotification) {
          // _onUpdateScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> ios
        } else if (notification is ScrollUpdateNotification) {
          // _onUpdateScroll(notification.metrics);
          // when off the touch from screen (end of scroll)
        } else if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: CustomScrollView(
        // controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            toolbarHeight: 0,
            expandedHeight: 45,
            collapsedHeight: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 10,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _sliverAppbarHeader(),
            ),
          ),
          SliverPersistentHeader(
              delegate: SimpleSliverCustomHeader(
                height: 60,
                child: _sliverAppbarButtons(),
                backgroundColor: Colors.white
              ),
            pinned: true,
          ),

          CupertinoSliverRefreshControl(
            onRefresh: _onRefresh,
            builder: (BuildContext context, RefreshIndicatorMode refreshState,
                double pulledExtent, double refreshTriggerPullDistance,
                double refreshIndicatorExtent) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                      top: 0,
                      child: SizedBox(
                        height: pulledExtent,
                          child: Center(
                              child: LottieAnimation.loading(40)
                          )
                      )
                  ),
                ],
              );
            }
          ),
          _streamBuilder(),
        ],
      ),
    );
  }

  Widget _sliverAppbarHeader() {
    String title = '';
    bool isActivated = true;
    if (cardDirection == CardDirection.receive) { // 받은 카드
      if (filter4receiveCard == Filter4receive.unread) {
        title = '읽지 않은 카드';
      } else if (filter4receiveCard == Filter4receive.nameChecked) {
        title = '이름 확인 카드';
      } else if (filter4receiveCard == Filter4receive.fromMale) {
        title = '남학생 카드';
      } else if (filter4receiveCard == Filter4receive.fromFemale) {
        title = '여학생 카드';
      } else {
        isActivated = false;
      }
    } else {  // 보낸 카드
      if (filter4sendCard == Filter4send.hasComment) {
        title = '답글 달린 카드';
      } else if (filter4sendCard == Filter4send.toMale) {
        title = '남학생 카드';
      } else if (filter4sendCard == Filter4send.toFemale) {
        title = '여학생 카드';
      } else {
        isActivated = false;
      }
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 25),
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('CardBox', style: kTextStyle.title1ExtraBold24),

          Row(  // 카드 필터 버튼
            children: [
              if (isActivated)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(title, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.blue100)),
                ),

              GestureDetector(
                  onTap: () => _modal2Filter(context),
                  child: SvgPicture.asset(
                      isActivated ? kIcon.filterOn : kIcon.filter, height: 30)
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _sliverAppbarButtons() {
    return Container(
      height: 50,
      color: Colors.white,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(  // 보낸 카드 버튼
                onTap: () => _onTapReceiveSendCard(CardDirection.send),
                child: Container(
                    height: 37,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: cardDirection == CardDirection.send ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sent', style: kTextStyle.callOutBold16.copyWith(
                            color: cardDirection == CardDirection.send ? Colors.white : Colors.black)),
                        if (countReceivedComment > 0)
                          Container(
                              height: 18,
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: kColor.red100,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Text(countReceivedComment > 99 ? '99+' : '$countReceivedComment',
                                  style: const TextStyle(fontSize: 12, color: Colors.white))
                          )
                      ],
                    )
                ),
              ),

              GestureDetector(  // 받은 카드 버튼
                onTap: () => _onTapReceiveSendCard(CardDirection.receive),
                child: Container(
                    height: 37,
                    width: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: cardDirection == CardDirection.receive ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Received', style: kTextStyle.callOutBold16.copyWith(
                            color: cardDirection == CardDirection.receive ? Colors.white : Colors.black)),
                        if (countReceiveCard > 0)
                          Container(
                              height: 18,
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: kColor.red100,
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Text(countReceiveCard > 99 ? '99+' : '$countReceiveCard',
                                  style: const TextStyle(fontSize: 12, color: Colors.white))
                          )
                      ],
                    )
                ),
              ),
            ],
          ),

          if (cardDirection == CardDirection.receive)   // 모두 읽음 버튼
            GestureDetector(
              onTap: () => _handleReadAll(),
              child: Container(
                  height: 37,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      color: kColor.grey20,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text('Mark all read', style: kTextStyle.subHeadlineBold14.copyWith(
                      color: hasReadAll ? kColor.grey300 : Colors.black))
              ),
          ),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: const Center(child: CupertinoActivityIndicator(radius: 16))
          );
        },
            childCount: 1
        )
    );
  }

  Widget _streamBuilder() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return _emptyContainer();
            case ConnectionState.waiting:
              return _loadingIndicator();
            default:
              if (snapshot.hasError) {
                return _emptyContainer();
              } else if (snapshot.hasData) {
                List<dynamic> cards = snapshot.data;
                if (cards.isNotEmpty) {
                  return _sliverList(cards);
                } else {
                  return _emptyCase();
                }
              } else {
                print('---> snapshot no data: ${snapshot.data}');
                return _emptyContainer();
              }
          }
        }
    );
  }

  Widget _sliverList(List<dynamic> cards) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          if (cardDirection == CardDirection.receive) {
            return _cardReceive(cards[index]);
          } else {
            return _cardSend(cards[index]);
          }
        },
          childCount: cards.length
        )
    );
  }

  Widget _cardReceive(CompactCard card) {  // 0 -> receive, 1 -> send
    bool hasRead = false;
    if (card.isCardReadByReceiver == true) {  // 받은 카드 읽음
      hasRead = true;
    }
    return _cardInfo(CardDirection.receive, hasRead, card);
  }

  Widget _cardSend(CompactCard card) {    // 0 -> receive, 1 -> send
    bool hasComment = false;
    if (card.isCommentReadBySender == true) {  // 받은 카드 읽음
      hasComment = true;
    }
    return _cardInfo(CardDirection.send, hasComment, card);
  }

  Widget _cardInfo(CardDirection cardDirection, bool hasRead, CompactCard card) {
    Size paddingRight = getTextSize('59분 전', kTextStyle.subHeadlineBold14);
    String nameField = '';
    String? image;
    String? name;
    String? uid;
    bool hasChecked;
    if (listChecked.contains(card.id)) {
      hasChecked = true;
    } else {
      hasChecked = false;
    }

    if (cardDirection == CardDirection.receive) {  // 받은 카드
      User? user = card.sender;
      image = user?.profileImageKey;
      name = user?.name;
      uid = user?.id;
      if (user != null) {
        nameField = '${user.clueWithoutDot}에게 받았아요';
      }
    } else {  // 보낸 카드
      User? user = card.receiver;
      image = user?.profileImageKey;
      name = user?.name;
      uid = user?.id;
      if (user != null) {
        nameField = '${user.name} 님에게 보냈어요';
      }
    }

    return GestureDetector(
      onTap: () {
        if (card.id != null) listChecked.add(card.id!);
        _selectCard(uid);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left:16, right:16, top: 5, bottom: 5),
        padding: const EdgeInsets.only(left: 12, right: 12, top:16, bottom: 16),
        decoration: BoxDecoration(
            color: kColor.grey20,
            borderRadius: BorderRadius.circular(16)
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (cardDirection == CardDirection.receive)  // receive  -> card icon with color
                  CustomCacheNetworkImage(imageUrl: card.sender?.profileImageKey, size: 24)
                else  // send -> profile image
                  image?.isNotEmpty  == true ?
                      CustomCacheNetworkImage(imageUrl: image, size: 40)
                  : customCircleAvatar(name: name ?? '-', size: 40, fontSize: 18, background: Colors.black),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: paddingRight.width, bottom: 8),
                        child: Text(card.question ?? ' ', maxLines: 3, style: kTextStyle.subHeadlineBold14),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(nameField, style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
                          Text(card.votedAt != null
                              ? card.votedAt!.whenReceived()
                              : ' ',
                              style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            cardDirection == CardDirection.send   // receive: true -> 카드 읽음, false -> 안읽음: red dot
                ? hasChecked
                  ? const SizedBox.shrink()
                  : Positioned(
                      top: -10,
                      right: 0,
                      child: Container(
                        height: 5,
                        width: 5,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kColor.red100
                        ),
                      ),
                    )
                : const SizedBox.shrink()   // send mode
          ],
        ),
      ),
    );
  }

  Widget _emptyContainer() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return const SizedBox.shrink();
        },
            childCount: 1
        )
    );
  }

  Widget _emptyCase() {
    String msg;
    String buttonTitle;
    if (cardDirection == CardDirection.receive) {
      msg = '아직 받은 투표 카드가 없어요.\n친구를 초대하고 투표 카드를 받아보세요!';
      buttonTitle = '친구 초대하기';
    } else {
      msg = '아직 보낸 투표 카드가 없네요.\n지금 OMG 투표를 시작해보세요!';
      buttonTitle = '투표하러 가기';
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🕳', style: TextStyle(fontSize: 48)),
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Text(msg, textAlign: TextAlign.center, style: kTextStyle.headlineExtraBold18),
                ),
                GestureDetector( // 버튼
                  onTap: () {
                    if (cardDirection == CardDirection.send) {  // 보낸 카드 경우 -> 투표 하러 가기
                      _move2OmgMain();
                    } else {  // 받은 카드 경우 -> 친구 초대하기
                      // todo
                    }
                  },
                  child: Container(
                    height: 44,
                    width: 135,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: kColor.blue100,
                        borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text(buttonTitle, style: kTextStyle.callOutBold16.copyWith(color: Colors.white)),
                  ),
                )
              ],
            ),
          );
        },
            childCount: 1
        )
    );
  }
}

class _FilterContents extends StatefulWidget {
  const _FilterContents({Key? key,
    required this.cardDirection
  }) : super(key: key);

  final CardDirection cardDirection;

  
  @override
  State<_FilterContents> createState() => _FilterContentsState();
}

class _FilterContentsState extends State<_FilterContents> {
  final List<Filter4receive> filter4receive = [Filter4receive.all, Filter4receive.unread,
    Filter4receive.nameChecked, Filter4receive.fromMale, Filter4receive.fromFemale];
  final List<Filter4send> filter4send = [Filter4send.all, Filter4send.hasComment,
    Filter4send.toMale, Filter4send.toFemale];
  late int selectedIndex;
  late bool isCardReceived;

  @override
  void initState() {
    super.initState();
    if (widget.cardDirection == CardDirection.receive) {
      isCardReceived = true;
      selectedIndex = service.cardBoxFilter4Receive.value.idx;
    } else {
      isCardReceived = false;
      selectedIndex = service.cardBoxFilter4Send.value.idx;
    }
  }

  void _onChange(int index) {
    Navigator.pop(context);
    selectedIndex = index;
    if (isCardReceived) {
      service.cardBoxFilter4Receive.value = filter4receive[index];

    } else {
      service.cardBoxFilter4Send.value = filter4send[index];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const ScrollIndicatorBar(),

        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 20, bottom: 20),
              child: Text('필터', style: kTextStyle.title1ExtraBold24),
            )
        ),

        GestureDetector(
          onTap: () {
            _onChange(0);
          },
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 16, right: 10),
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('전체', style: kTextStyle.callOutBold16),
                SizedBox(
                  width: 40,
                  child: Transform.scale(
                    scale: 1.3,
                    child: Radio(
                      value: 0,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        _onChange(value!);
                      },
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return kColor.blue100;
                          }
                          return kColor.grey100;  // Change the inactive color here
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _onChange(1);
          },
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 16, right: 10),
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCardReceived ? '읽지 않은 카드' : '답글이 달린 카드',
                    style: kTextStyle.callOutBold16),
                SizedBox(
                  width: 40,
                  child: Transform.scale(
                    scale: 1.4,
                    child: Radio(
                      value: 1,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        _onChange(value!);
                      },
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return kColor.blue100;
                          }
                          return kColor.grey100;  // Change the inactive color here
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _onChange(2);
          },
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 16, right: 10),
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCardReceived ? '이름 확인한 카드' : '남학생에게 보낸 카드',
                    style: kTextStyle.callOutBold16),
                SizedBox(
                  width: 40,
                  child: Transform.scale(
                    scale: 1.4,
                    child: Radio(
                      value: 2,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        _onChange(value!);
                        // setState(() => selectedIndex = value!);
                      },
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return kColor.blue100;
                          }
                          return kColor.grey100;  // Change the inactive color here
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _onChange(3);
          },
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.only(left: 16, right: 10),
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isCardReceived ? '남학생이 보낸 카드' : '여학생에게 보낸 카드', style: kTextStyle.callOutBold16),
                SizedBox(
                  width: 40,
                  child: Transform.scale(
                    scale: 1.4,
                    child: Radio(
                      value: 3,
                      groupValue: selectedIndex,
                      onChanged: (value) {
                        _onChange(value!);
                        // setState(() => selectedIndex = value!);
                      },
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return kColor.blue100;
                          }
                          return kColor.grey100;  // Change the inactive color here
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (isCardReceived)  // 받은 카드 경우만 보이기
          GestureDetector(
            onTap: () {
              _onChange(4);
            },
            child: Container(
              height: 60,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.only(left: 16, right: 10),
              decoration: BoxDecoration(
                  color: kColor.grey30,
                  borderRadius: BorderRadius.circular(16)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('여학생이 보낸 카드', style: kTextStyle.callOutBold16),
                  SizedBox(
                    width: 40,
                    child: Transform.scale(
                      scale: 1.4,
                      child: Radio(
                        value: 4,
                        groupValue: selectedIndex,
                        onChanged: (value) {
                          _onChange(4);
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return kColor.blue100;
                            }
                            return kColor.grey100;  // Change the inactive color here
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}

enum Filter4receive {
  all(0),
  unread(1),   // 읽지 않은 카드
  nameChecked(2),  // 이름 확인한 카드
  fromMale(3),   // 남학생이 보낸 카드
  fromFemale(4); // 여학생이 보낸 카드

  const Filter4receive(this.idx);
  final int idx;
}

enum Filter4send {
  all(0),
  hasComment(1), // 답글 달린 카드
  toMale(2),   // 남학생에게 보낸 카드
  toFemale(3);  // 여학생에게 보낸 카드

  const Filter4send(this.idx);
  final int idx;
}