import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iden/rest_api/api.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../model/omg_card_model.dart';
import '../../model/session.dart';
import '../../services/extensions.dart';
import '../../controller/state_controller.dart';
import '../../resource/images.dart';
import '../../resource/style.dart';
import '../../rest_api/card_api.dart';
import '../common_widget/bottom_modal.dart';
import '../common_widget/dialog_popup.dart';
import '../common_widget/lotti_animation.dart';
import '../../model/user.dart';
import '../pages/child/modal_user_profile.dart';
import '../pages/friends/friends_favorite.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({Key? key,
    required this.onClicked,
  }) : super(key: key);

  final VoidCallback onClicked;

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  // final ScrollController _scrollController = ScrollController();
  late StreamController<dynamic> _streamController;
  List<CompactCard>? feeds;
  Paging? paging;
  late bool filterFavorite;
  List<int> listOfMyFavorite = [];
  bool isEndOfList = false;   // true -> 리스트 마지막
  // bool canShowEndList = false;    // true & isEndOfList true -> 마지막 표시

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_scrollListener);
    _streamController = StreamController<dynamic>();
    filterFavorite = false;
    _getFeed();
  }

  @override
  void dispose() {
    super.dispose();
    // _scrollController.dispose();
    _streamController.close();
  }

  Future<void> _getFeed() async {
    List<CompactCard> cards = [];

    HttpsResponse res = await IdenApi.getFeed(filterFavorite, paging);
    if (res.statusType == StatusType.success) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          CompactCard card = CompactCard.fromJson(e);
          cards.add(card);
        }
        if (res.body['cursor'] != null) {
          paging = Paging.fromJson(res.body['cursor']);
          if (paging?.afterCursor == null) setState(() => isEndOfList = true);
        }
      }

      if (feeds?.isNotEmpty ?? false) { // 피드가 있는 경우 추가 하화
        List<CompactCard> all = feeds!;
        all += cards;
        feeds = all;
      } else { // 피드가 없는 경우 초기화
        feeds = cards;
      }
      if (!_streamController.isClosed) _streamController.add(feeds);
      if (mounted) setState(() {});
    } else if (res.statusType == StatusType.error) { // error
      ErrorResponse error = res.body;
      _showError(error.message);
    }
  }

  Future<void> _callApi4likeUnlike(bool hasMyFavorite, CompactCard card) async {
    bool out;
    int? id = card.id;
    if (id != null) {
      if (hasMyFavorite) {  // true -> 이미 좋아요 선택 -> unlike
        HttpsResponse res = await CardApi.postUnlike(id);
        if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
          out = true;
        } else {
          out = false;
          ErrorResponse error = res.body;
          _showError(error.message);
        }
      } else {  // false -> 좋아요 선택 안됨 -> linke
        HttpsResponse res = await CardApi.postLike(id);
        if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
          out = true;
        } else {
          out = false;
          ErrorResponse error = res.body;
          _showError(error.message);
        }
      }

    } else {
      out = false;
    }
    // if (out) _updateMyFavorite(card.id);
    _updateMyFavorite(hasMyFavorite, card.id);    // todo > test only
  }

  Future<void> _onRefresh() async {
    _resetFeed();
    _getFeed();
  }

  void _updateMyFavorite(bool hasMyFavorite, int? id) {
    if (id != null) {
      if (hasMyFavorite) {  // true -> 좋아요 취소
        listOfMyFavorite.remove(id);
      } else {  // false -> 좋아요 추가
        listOfMyFavorite.add(id);
      }
      if (mounted) setState(() {});
    }
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 100) {
      if (paging?.afterCursor != null) {  // 다음 커서가 있는 경우만 다음 데이터 가져오기
        _getFeed();
      }
    }
  }

  void _resetFeed() {
    feeds = [];
    paging?.reset();
  }

  void _switchFavorite() {
    setState(() => filterFavorite = !filterFavorite);
    _resetFeed();
    _getFeed();
  }

  void _move2OmgMain() => widget.onClicked();

  void _move2addFavorite() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const FriendsFavorite())
    ).then((value) {
      setState(() {});
    });
  }

  void _cupertinoModal4userInfo(String uid) {
    modalCupertino(
        context,
        ModalUserProfile(userId: uid),
        false   // not draggable
    ).then((value) => setState(() {}));
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: _body());
  }

  Widget _body() {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: CustomScrollView(
        // controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()
        ),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            toolbarHeight: 0,
            expandedHeight: 50,
            collapsedHeight: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 10,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _sliverAppbarHeader(),
            ),
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
    Icon icon;
    if (filterFavorite) {   // on
      icon = Icon(Icons.star_rounded, size: 36, color: kColor.blue100);
    } else {  // off
      icon = Icon(Icons.star_outline_rounded, size: 36, color: kColor.grey500);
    }

    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 5),
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Feed', style: kTextStyle.title1ExtraBold24),
          GestureDetector(  // favorite icon button
            onTap: () => _switchFavorite(),
            child: Container(
              height: 35,
              width: 40,
              color: Colors.transparent,
              alignment: Alignment.bottomRight,
              child: icon,
            ),
          )
        ],
      ),
    );
  }

  Widget _streamBuilder() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return filterFavorite
                  ? _EmptyFeedFavorite(onChange: _move2OmgMain)
                  : _EmptyFeed(onChange: _move2addFavorite);
            case ConnectionState.waiting:
              return _loadingIndicator();
            default:
              if (snapshot.hasData) {
                List<dynamic> cards = snapshot.data;
                if (cards.isNotEmpty) {
                  return _sliverList(cards);

                } else {
                  return filterFavorite
                      ? _EmptyFeedFavorite(onChange: _move2OmgMain)
                      : _EmptyFeed(onChange: _move2addFavorite);
                }
              } else {
                print('---> snapshot no data: ${snapshot.data}');
                return _emptyContainer();
              }
          }
        });
  }

  Widget _sliverList(List<dynamic> cards) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      sliver: SliverList(
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            return StickyHeader(
              overlapHeaders: true,
                header: _SideProfileImage(card: cards[index]),
                content: _item(cards[index])
            );
          },
              childCount: cards.length
          )
      ),
    );
  }

  Widget _item(CompactCard card) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _cupertinoModal4userInfo(card.receiver!.id!),
          child: Container(
            height: 260,
            margin: const EdgeInsets.only(left: 48, top: 6, bottom: 2),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: filterFavorite ? kColor.blue10 : kColor.grey20,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _friendInfo(card),
                _cardInfo(card),
                _footer(card)
              ],
            ),
          ),
        ),
        card.comment != null ? _commentBox(card) : const SizedBox.shrink(),
      ],
    );
  }

  Widget _friendInfo(CompactCard card) {
    String? name = card.receiver?.name;
    String? company = card.receiver?.affiliation;
    String? sender = 'received from ${card.sender?.name}';

    return Container(
      height: 27,
      margin: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(name ?? '-', style: kTextStyle.callOutBold16),
              const SizedBox(width: 8),
              Text(company ?? '-', style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey300))
            ],
          ),
          Text(sender ?? '-', style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey900)),
        ],
      ),
    );
  }

  Widget _cardInfo(CompactCard card) {
    String? question = card.question;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(card.emoji ?? '😊', style: const TextStyle(fontSize: 55)),
          const SizedBox(height: 12),
          Text(question ?? ' ', textAlign: TextAlign.center, style: kTextStyle.title3ExtraBold20)
        ],
      ),
    );
  }

  Widget _footer(CompactCard card) {
    String? voteAt;
    if (card.votedAt?.isNotEmpty == true) {
      voteAt = card.votedAt!.whenReceived();
    }
    String? count;
    if (card.likeCount != null) count = card.likeCount.toString().toCurrency();
    bool hasMyFavorite;
    if (card.likedByMe != null && card.likedByMe! > 0 
      || card.id != null && listOfMyFavorite.contains(card.id)) {
      hasMyFavorite = true;
    } else {
      hasMyFavorite = false;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(    // 좋아요 숫자
          onTap: () {
            HapticFeedback.mediumImpact();
            _callApi4likeUnlike(hasMyFavorite, card);
          },
          child: Container(
            constraints: const BoxConstraints(
                minWidth: 65
            ),
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: hasMyFavorite ? kColor.blue50 : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
                color: hasMyFavorite ? kColor.blue10 : null,
                gradient: hasMyFavorite
                    ? null
                    : LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            '#17171B0D'.toColor(),
                            '#17171B0D'.toColor().withOpacity(0.05),
                          ]
                      )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(card.emoji ?? '😊', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 4),
                Text(count ?? ' ', style: kTextStyle.footnoteMedium14)
              ],
            ),
          ),
        ),
        Text(voteAt ?? ' ', style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey300)),
      ],
    );
  }

  Widget _commentBox(CompactCard card) {
    String? name = card.receiver?.name;
    String? comment = card.comment;
    String? commentedAt;
    if (card.commentedOrCreatedAt?.isNotEmpty == true) {
      commentedAt = card.votedAt!.whenReceived();
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 125
      ),
      // height: 125,
      margin: const EdgeInsets.only(left: 40, top: 2, bottom: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: filterFavorite ? kColor.blue10 : kColor.grey20,
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(kIcon.commentEmpty, height: 16, width: 16,
                    colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                  const SizedBox(width: 10),
                  Text(name != null ? 'Comment from $name' : 'Comment', style: kTextStyle.callOutBold16.copyWith(color: kColor.grey900)),
                ],
              ),
              const SizedBox(height: 10),
              Text(comment ?? ' ', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500, height: 1.3)),
            ],
          ),
          const SizedBox(height: 10),
          Text(commentedAt ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
        ],
      ),
    );
  }

  Widget _loadingIndicator() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: LottieAnimation.loading(40)
            ),
          );
        },
            childCount: 1
        )
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
}

class _SideProfileImage extends StatelessWidget {
  const _SideProfileImage({Key? key,
    required this.card,
  }) : super(key: key);

  final CompactCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      alignment: Alignment.centerLeft,
      child: _image()
    );
  }

  Widget _image() {
    return (card.receiver?.profileImageKey?.isNotEmpty == true)
        ? CustomCacheNetworkImage(imageUrl: card.receiver?.profileImageKey, size: 40)
        : customCircleAvatar(name: card.receiver?.name ?? '-', size: 40, fontSize: 18);
  }
}

class _EmptyFeed extends StatefulWidget {
  const _EmptyFeed({Key? key,
    required this.onChange
  }) : super(key: key);

  final VoidCallback onChange;

  @override
  State<_EmptyFeed> createState() => _FeedEmptyFavoriteState();
}

class _FeedEmptyFavoriteState extends State<_EmptyFeed> {
  String title = '친구들이 받은 투표 카드가 없네요.\n친구들을 더 추가해보세요!';

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🌊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(title, textAlign: TextAlign.center,
                        style: kTextStyle.headlineExtraBold18.copyWith(height: 1.3))),
                _button()
              ],
            ),
          );
        },
            childCount: 1
        )
    );
  }
  
  Widget _button() {
    return GestureDetector(
      onTap: () => widget.onChange(),
      child: Container(
        height: 44,
        width: 135,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: kColor.blue100,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Text('친구 추가하기', style: kTextStyle.callOutBold16.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _EmptyFeedFavorite extends StatefulWidget {
  const _EmptyFeedFavorite({Key? key,
    required this.onChange
  }) : super(key: key);

  final VoidCallback onChange;

  @override
  State<_EmptyFeedFavorite> createState() => _EmptyFeedFavoriteState();
}

class _EmptyFeedFavoriteState extends State<_EmptyFeedFavorite> {
  String title = '관심 친구들이 받은 카드가 없네요.\n관심 친구들을 추가해보세요!';

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🤜🤛', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(title, textAlign: TextAlign.center,
                        style: kTextStyle.headlineExtraBold18.copyWith(height: 1.3))),
                _button()
              ],
            ),
          );
        },
            childCount: 1
        )
    );
  }

  Widget _button() {
    return GestureDetector(
      onTap: () => widget.onChange(),
      child: Container(
        height: 44,
        width: 166,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
            color: kColor.blue100,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Text('관심 친구 추가하기', style: kTextStyle.callOutBold16.copyWith(color: Colors.white)),
      ),
    );
  }
}