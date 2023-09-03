import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';

import 'best_cards.dart';
import 'recent_cards.dart';
import '../components/bottom_modal_contents_buttons.dart';
import '../profile/cookiebox.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/common_widget.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/sliver_header_custom.dart';
import '../../../model/user.dart';
import '../../../model/session.dart';
import '../../../resource/images.dart';
import '../../../resource/style.dart';
import '../../../controller/state_controller.dart';
import '../../../rest_api/user_api.dart';
import '../../../rest_api/relationship_api.dart';

class ModalUserProfile extends StatefulWidget {
  const ModalUserProfile({Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  State<ModalUserProfile> createState() => _ModalUserProfileState();
}

class _ModalUserProfileState extends State<ModalUserProfile> {
  User user = User();
  String? cookieBalance;
  bool? hasFollowing; //  true -> following
  bool? hasFavorite; // true -> 관심 친구
  bool? hasBlocked; // true -> 차단된 친구
  bool isPinnedHeaderOn = false;    // appbar header 변경
  /// count 정보
  UserCount userCount = UserCount();
  /// 실시간 카드
  Paging paging4recentCard = Paging();

  @override
  void initState() {
    super.initState();
    _getUserInfo(widget.userId);
    _getUserCount();
  }

  void _getUserInfo(String userId) async {
    print('---> modal user profile > get user info > user id: $userId');
    HttpsResponse res = await UserApi.getUserInfo(userId);
    if (res.statusType == StatusType.success) {
      user = User.fromJson(res.body);
      if (user.relationship == Relationship.following) {  // 친구
        hasFollowing = true;
        hasFavorite = false;
        hasBlocked = false;
      } else if (user.relationship == Relationship.favorite) {  // 관심 친구
        hasFollowing = true;
        hasFavorite = true;
        hasBlocked = false;
      } else {
        hasFollowing = false;
        hasFavorite = false;
        hasBlocked = false;
      }
      _updateState();
    }
  }

  void _updateState() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(ModalUserProfile oldWidget) {
    // _getBestCard(widget.userId);
    super.didUpdateWidget(oldWidget);
  }

  void _getUserCount() async {
    HttpsResponse res = await UserApi.getUserCount(user.id);   // null -> 나의 카운트 정보
    if (res.statusType == StatusType.success) {
      userCount = UserCount.fromJson(res.body);
    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showError(error.message);
    }
    if (mounted) setState(() {});
  }

  void _move2CookieBox() {
    Navigator.push(
        context,
        MaterialWithModalsPageRoute(
            builder: (BuildContext context) => const CookieBox())
    ).then((value) {
      setState(() {});
    });
  }

  Future<bool> _callApi4block(String userId) async {
    HttpsResponse res = await RelationshipApi.postBlock(userId);
    return _checkResponse(res);
  }

  Future<bool> _callApi4unblock(String userId) async {
    HttpsResponse res = await RelationshipApi.postUnblock(userId);
    return _checkResponse(res);
  }

  Future<bool> _callApi4follow(String userId) async {
    HttpsResponse res = await RelationshipApi.postFollow(userId);
    return _checkResponse(res);
  }

  Future<bool> _callApi4unfollow(String userId) async {
    HttpsResponse res = await RelationshipApi.postUnfollow(userId);
    return _checkResponse(res);
  }

  Future<bool> _callApi4favorite(String userId) async {
    HttpsResponse res = await RelationshipApi.postFavorite(userId);
    return _checkResponse(res);
  }

  Future<bool> _callApi4unfavorite(String userId) async {
    HttpsResponse res = await RelationshipApi.postUnFavorite(userId);
    return _checkResponse(res);
  }

  bool _checkResponse(HttpsResponse response) {
    bool out;
    if (response.statusType == StatusType.success) {
      out = true;
    } else if (response.statusType == StatusType.error){
      ErrorResponse error = response.body;
      _showError(error.message);
      out = false;
    } else {
      out = false;
    }
    return out;
  }

  void _addFollow() async {
    if (user.id?.isNotEmpty == true) {
      final res = await _callApi4follow(user.id!);
      if (res) {
        hasFavorite = false;
        hasFollowing = true;
        hasBlocked = false;
        setState(() {});
      }
    }
  }

  void _modal2ReportBlock() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: null,
          sub: null,
          listTitle: const ['신고하기', '차단하기', '취소'],
          // index: 0, 1, 2
          listColor: [kColor.red100, kColor.red100, Colors.black],
          listIcon: const [null, null, null],
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) { // 신고하기
        _modal2Report();
      } else if (res == 1) { // 차단하기
        _modal2Block();
      }
    }
  }

  void _modal2Report() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '어떤 내용을 신고할까요?',
          sub: '허위 신고가 누적되는 경우, 서비스 이용이 제한될 수 있어요.',
          listTitle: const ['실명이 아니에요', '타인을 사칭하고 있어요', '만 14세 미만이에요',
            '우리 학교 학생이 아니에요', '여기에 없는 다른 이유가 있어요', '취소'],
          // index: 0,1,2,3,4,5,6
          listColor: [
            kColor.red100,
            kColor.red100,
            kColor.red100,
            kColor.red100,
            kColor.blue100,
            Colors.black
          ],
          listIcon: const [null, null, null, null, null, null],
        ),
        600 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) { // 실명 아님
        // todo
      } else if (res == 1) { // 타인 사칭
        // todo
      } else if (res == 2) { // 만 14세 미만
        // todo
      } else if (res == 3) { // 우리 학교 학생 아님
        // todo
      } else if (res == 4) { // 다른 이유
        // todo
      }
    }
    if (res != null && res != 5) {
      _showSnackbar('🙆', '신고가 정상적으로 접수되었어요.');
    }
  }

  void _modal2Block() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '${user.name ?? ''} 님을 차단할까요?',
          sub: '차단할 경우, 이 친구는 나에게 투표할 수 없어요.',
          listTitle: const ['차단하기', '취소'],
          // index: 0, 1
          listColor: [kColor.red100, Colors.black],
          listIcon: const [null, null],
        ),
        340 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 차단하기
        if (user.id?.isNotEmpty == true) {
          final res = await _callApi4block(user.id!);
          if (res) {
            hasFavorite = false;
            hasFollowing = false;
            hasBlocked = true;
            _showSnackbar('🤐', '친구를 차단했어요.');
            setState(() {});
          }
        }
      }
    }
  }

  void _modal2unblock() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '${user.name ?? ''} 님을 차단 해제할까요?',
          sub: '차단차단을 해제할 경우, 서로를 다시 친구로 추가할 수 있어요.',
          listTitle: const ['차단 해제하기', '취소'],
          // index: 0, 1
          listColor: [kColor.blue100, Colors.black],
          listIcon: const [null, null],
        ),
        340 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) _modal2followUnblock();
    }
  }

  void _modal2followUnblock() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '${user.name ?? ''} 님을 친구로 추가할까요?',
          sub: '이 친구를 투표 선택지에서 볼 수 있어요!',
          listTitle: const ['친구 추가하기', '괜찮아요'],
          // index: 0, 1
          listColor: [kColor.blue100, Colors.black],
          listIcon: const [null, null],
        ),
        340 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 친구 추가하기
        if (user.id?.isNotEmpty == true) {
          final res = await _callApi4follow(user.id!);
          if (res) {
            hasFavorite = false;
            hasFollowing = true;
            hasBlocked = false;
            setState(() {});
          }
        }
      } else if (res == 1) {
        final res = await _callApi4unblock(user.id!);
        if (res) {
          hasFavorite = false;
          hasFollowing = false;
          hasBlocked = false;
          _showSnackbar('🤐', '친구를 차단 해제했어요.');
          setState(() {});
        }
      }
    }
  }

  void _modal2unfollow() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '${user.name} 님을 삭제할까요?',
          sub: '친구 목록에서 삭제할 경우, 투표 선택지에서 볼 수 없어요.',
          listTitle: const ['삭제하기', '취소'],
          // index: 0, 1
          listColor: [kColor.red100, Colors.black],
          listIcon: const [null, null],
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 삭제하기
        if (user.id?.isNotEmpty == true) {
          final res = await _callApi4unfollow(user.id!);
          if (res) {
            hasFavorite = false;
            hasFollowing = false;
            setState(() {});
          }
        }
      }
    }
  }

  void _modal2FavoriteUnfollow() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: null,
          sub: null,
          listTitle: const ['관심 친구 설정하기', '친구 삭제하기', '취소'],
          // index: 0, 1, 2
          listColor: [kColor.blue100, Colors.black, Colors.black],
          listIcon: [kIcon.blueStart, null, null],
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) { // 관심 친구 설정
        if (user.id?.isNotEmpty == true) {
          final res = await _callApi4favorite(user.id!);
          if (res) {
            hasFavorite = true;
            setState(() {});
          }
        }
      } else if (res == 1) {  // 친구 삭제
        _modal2unfollow();
      }
    }
  }

  void _modal2unfavorite() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: null,
          sub: null,
          listTitle: const ['관심 친구 해제하기', '친구 삭제하기', '취소'],
          // index: 0, 1, 2
          listColor: [kColor.blue100, Colors.black, Colors.black],
          listIcon: [kIcon.blueStartOutline, null, null],
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) { // 관심 친구 해제
        if (user.id?.isNotEmpty == true) {
          final res = await _callApi4unfavorite(user.id!);
          if (res) {
            hasFavorite = false;
            setState(() {});
          }
        }
      } else if (res == 1) { // 친구 삭제
        _modal2unfollow();
      }
    }
  }

  void _showLargeImage(BuildContext context, String tag) {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        barrierDismissible: true,
        barrierColor: Colors.white.withOpacity(0.96),
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (BuildContext context, _, __) {
          return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: CommonWidget.heroPage(context, user, tag)
          );
        })
    );
  }

  void _onUpdateScroll(ScrollMetrics metrics) {
    double maxExtent = metrics.maxScrollExtent;
    double currentExtent = metrics.extentAfter;

    if (maxExtent - currentExtent >= 60) {

      isPinnedHeaderOn = true;
    } else {
      isPinnedHeaderOn = false;
    }
    if (mounted) setState(() {});
  }

  void _showSnackbar(String emoji, String title) {
    customSnackbar(context, emoji, title, ToastPosition.bottom);
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          // _onStartScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> android
        } else if (notification is OverscrollNotification) {
          // _onUpdateScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> ios
        } else if (notification is ScrollUpdateNotification) {
          _onUpdateScroll(notification.metrics);
          // when off the touch from screen (end of scroll)
        } else if (notification is ScrollEndNotification) {
          // _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()
        ),
        slivers: [
          SliverPersistentHeader(
            delegate: SimpleSliverCustomHeader(
                height: 70,
                child: _sliverAppbarHeader(),
                backgroundColor: Colors.white
            ),
            pinned: true,
          ),

          _sliverList(),
        ],
      ),
    );
  }

  Widget _sliverAppbarHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 10, top: 20),
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            reverseDuration: const Duration(milliseconds: 300),
            child: isPinnedHeaderOn
                ? _pinnedHeader()
                : const SizedBox(width: 100),
          ),

          IconButton(   // 닫기 버튼
              onPressed: () => Navigator.pop(context),
              icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 26))
        ],
      ),
    );
  }

  Widget _pinnedHeader() {
    return Row(    // picture and 학교 학년 정보
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        user.profileImageKey != null
            ? CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 32)
            : customCircleAvatar(name: user.name ?? '-'),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(user.name ?? ' ', style: kTextStyle.headlineExtraBold18),
        )
      ],
    );
  }

  Widget _sliverList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return _listview();
        },
            childCount: 1
        )
    );
  }

  Widget _listview() {
    String? iden;
    if (user.name != null) {
      iden = '${user.name} 님의 IDEN';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _userInfo(),
        _button2addFriend(),
        const DividerHorizontal(paddingTop: 1, paddingBottom: 20),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(iden ?? '', style: kTextStyle.title1ExtraBold24),
        ),
        const SizedBox(height: 16),
        if (user.name != null) BestCards(user: user),
        const DividerHorizontal(paddingTop: 24, paddingBottom: 24),
        RecentCards(userId: widget.userId),  // 실시간 카드
        const SizedBox(height: 40)
      ],
    );
  }

  Widget _userInfo() {
    return Column(
      children: [
        Row(    // picture and 학교 학년 정보
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),

            GestureDetector(
              onTap: () => _showLargeImage(context, 'profileImage'),
              child: Hero(
                tag: 'profileImage',
                child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent,
                    child: user.profileImageKey != null ?
                    CustomCacheNetworkImage(imageUrl: user.profileImageKey,
                        gender: user.gender, size: 90)
                        : customCircleAvatar(name: user.name ?? '-', size: 90, fontSize: 32)
                ),
              ),
            ),
            const SizedBox(width: 24),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name ?? '-', style: kTextStyle.title3ExtraBold20),
                  const SizedBox(height: 10),
                  Text(user.affiliation ?? '-',
                      style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500)),
                  const SizedBox(height: 4),
                  Text(user.duty ?? '-',
                      style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 10),

        Padding(    // 받은 카드, 투데이, 추가한 친구들
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Column(
            children: [
              Row(    // 받은 카드, 투데이  -> 카드 박스
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(   // 친구
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${userCount.receivedCardsCount ?? '-'}', style: kTextStyle.headlineExtraBold18),
                          const SizedBox(height: 6),
                          Text('받은 카드', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey900))
                        ],
                      ),
                    ),

                    Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${userCount.followingCount ?? '-'}', style: kTextStyle.headlineExtraBold18),
                          const SizedBox(height: 6),
                          Text('친구', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey900))
                        ],
                      ),
                    ),
                  ]
              ),
            ]
          ),
        )
      ]
    );
  }

  Widget _button2addFriend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(    // 친구 추가
            onTap: () => _addFollow(),
            child: Container(
              height: 44,
              margin: const EdgeInsets.only(left: 20, right: 10),
              padding: const EdgeInsets.only(left: 10, right: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(kIcon.friends, height: 20, width: 20),
                  const SizedBox(width: 6),
                  Text('친구', style: kTextStyle.subHeadlineBold14),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18)
                ],
              ),
            ),
          ),
        ),

        GestureDetector(  // wallet
          onTap: () => _modal2ReportBlock(),
          child: Container(
            height: 44,
            width: 44,
            margin: const EdgeInsets.only(right: 20, top: 20, bottom: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(10)
            ),
            child: SvgPicture.asset(kIcon.idenCoinSvg, height: 22),
          ),
        ),
      ],
    );
  }
}