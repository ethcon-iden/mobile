import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iden/rest_api/api.dart';
import 'package:iden/ui/common_widget/custom_button.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../common_widget/common_widget.dart';
import '../common_widget/custom_animation.dart';
import '../common_widget/custom_profile_image_stack.dart';
import '../common_widget/dialog_popup.dart';
import '../common_widget/divider.dart';
import '../common_widget/sliver_header_custom.dart';
import '../pages/child/following_friends.dart';
import '../pages/child/best_cards.dart';
import '../pages/child/recent_cards.dart';
import '../../model/session.dart';
import '../../model/user.dart';
import '../../resource/images.dart';
import '../../resource/kConstant.dart';
import '../../resource/style.dart';
import '../../services/secure_storage.dart';
import '../../controller/state_controller.dart';
import '../../rest_api/user_api.dart';

class HomeProfile extends StatefulWidget {
  const HomeProfile({Key? key,
    required this.onClicked,
    required this.hasStateUpdate
  }) : super(key: key);

  final bool? hasStateUpdate;   // setting header > go back -> omg main -> state update -> nav profile
  final VoidCallback onClicked;

  @override
  State<HomeProfile> createState() => _HomeProfileState();
}

class _HomeProfileState extends State<HomeProfile> {
  bool showBio = false;   // true -> 한 줄 소개 보이기, false -> 감추기
  bool hasOmgPassActive = false;    // true -> 구독중
  /// count 정보
  UserCount userCount = UserCount();
  int? idenTokenBalance;
  /// controller
  bool isPinnedHeaderOn = false;  // false -> disappear, true -> show profile
  bool isPinnedHeaderOff = true;  // true -> 타이틀 표시, false - > disappear
  /// 실시간 카드
  Paging paging4recentCard = Paging();

  @override
  void initState() {
    super.initState();
    _getIdenTokenBalance();
    _getUserCount();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(HomeProfile oldWidget) {
    print('---> nav profile > did update widget > status update: ${widget.hasStateUpdate}');
    super.didUpdateWidget(oldWidget);
  }

  void _getIdenTokenBalance() async {
    HttpsResponse res = await IdenApi.getIdenTokenBalance();
    if (res.statusType == StatusType.success) {
      idenTokenBalance = res.body;
    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showError(error.message);
    }
    if (mounted) setState(() {});
  }

  void _getUserCount() async {
    HttpsResponse res = await IdenApi.getUserCount(null);   // null -> 나의 카운트 정보
    if (res.statusType == StatusType.success) {
      userCount = UserCount.fromJson(res.body);
    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showError(error.message);
    }
    if (mounted) setState(() {});
  }

  void _onUpdateScroll(ScrollMetrics metrics) {
    double threshold = 60;
    double maxExtent = metrics.maxScrollExtent;
    double currentExtent = metrics.extentAfter;
    if (maxExtent - currentExtent >= threshold) {   // 프로필 사진 slide up
      isPinnedHeaderOn = true;
      isPinnedHeaderOff = false;
    } else {  // 프로필 사진 slide down
      isPinnedHeaderOn = false;
      // isPinnedHeaderOff = true;
      if (!isPinnedHeaderOff) _delay4appbarTitle();
    }

    if (mounted) setState(() {});
  }

  void _delay4appbarTitle() async {
    Future.delayed(const Duration(milliseconds: 150), () {
      isPinnedHeaderOff = true;
      if (mounted) setState(() {});
    });
  }

  void _move2followingFriends() {
    Navigator.push(
        context,
        MaterialWithModalsPageRoute(builder: (BuildContext context) => FollowingFriends(followingCount: userCount.followingCount))
    ).then((value) {
      setState(() {});
    });
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
            child: CommonWidget.heroPage(context, service.userMe.value, tag)
          );
        })
    );
  }

  void _move2cardBox() => widget.onClicked();

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
                height: 60,
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
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _animatedSlider(),

          GestureDetector(
              onTap: () {},
              child: Image.asset(kIcon.settingsPng, height: 26)
          )
        ],
      ),
    );
  }

  Widget _animatedSlider() {
    return CustomAnimation.widgetSlide(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.6,
        firstChild: Text('프로필', style: kTextStyle.title1ExtraBold24),
        secondChild: _pinnedHeader(),
        isTriggerOn4first: isPinnedHeaderOff,
        isTriggerOn4second: isPinnedHeaderOn,
        durationPadeOut: 200,
        durationSlide: 150,
    );
  }

  Widget _pinnedHeader() {
    return Row(    // picture and 학교 학년 정보
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomCacheNetworkImage(imageUrl: service.userMe.value.profileImageKey, size: 32),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(service.userMe.value.name ?? ' ', style: kTextStyle.headlineExtraBold18),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _userInfo(),
        _button(),
        const DividerHorizontal(paddingTop: 20, paddingBottom: 1),

        _myProperty(),

        const DividerHorizontal(paddingTop: 34, paddingBottom: 24),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text('나의 IDEN', style: kTextStyle.title1ExtraBold24),
        ),
        const SizedBox(height: 16),
        // BestCards(user: service.userMe.value),

        const DividerHorizontal(paddingTop: 34, paddingBottom: 24),

        // RecentCards(userId: service.userMe.value.id),

        const SizedBox(height: 40)
      ],
    );
  }

  Widget _userInfo() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
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
                      child: CustomCacheNetworkImage(imageUrl: service.userMe.value.profileImageKey,
                          gender: service.userMe.value.gender, size: 90)
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(service.userMe.value.name ?? '', style: kTextStyle.title3ExtraBold20),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(service.userMe.value.nickname ?? ' ',
                                style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(service.userMe.value.affiliation ?? ' ',
                              style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500))
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(service.userMe.value.name ?? ' ',
                              style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500))
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),

          Padding(    // 받은 카드, 투데이, 내가/나를 추가한 친구들
            padding: const EdgeInsets.all(20),
            child: Row(    // 받은 카드, 투데이  -> 카드 박스
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _move2cardBox(),
                    child: Container(
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
                  ),

                  GestureDetector(
                    onTap: () => _move2followingFriends(),
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(   // 받은 카드
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${userCount.followingCount ?? '-'}', style: kTextStyle.headlineExtraBold18),
                          const SizedBox(height: 6),
                          Text('친구', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey900))
                        ],
                      ),
                    ),
                  ),
                ]
            ),
          )
        ]
      )
    );
  }

  Widget _myProperty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 24, bottom: 12),
          child: Text('내 자산', style: kTextStyle.title2ExtraBold22),
        ),
        
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 16, right: 16),
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          child: Row(
            children: [
              SvgPicture.asset(kIcon.idenCoinSvg, height: 40, width: 40),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('IDEN Token', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
                  const SizedBox(height: 2),
                  Text('${idenTokenBalance ?? '1-'}', style: kTextStyle.title3ExtraBold20)
                ],
              )
            ],
          ),
        ),
        
        CustomButtonWide(
          title: '지갑 보기',
          titleColor: Colors.black,
          background: kColor.grey30,
          hasBottomMargie: false,
          bottomMargin: 0,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _button() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 44,
        width:  MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 6, right: 6),
        margin: const EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kColor.grey30,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text('프로필 수정하기', style: kTextStyle.subHeadlineBold14),
      ),
    );
  }
}