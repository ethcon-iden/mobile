import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iden/ui/pages/vote/vote_main_B.dart';

import 'common_widget/custom_profile_image_stack.dart';
import 'tap/home_profile.dart';
import '../controller/state_controller.dart';
import '../resource/images.dart';
import 'tap/home_feed.dart';
import 'tap/home_cardbox.dart';
import 'tap/home_vote.dart';
import '../resource/style.dart';

class IdenMain extends StatefulWidget {
  const IdenMain({Key? key,
    this.pageIndex = 0
  }) : super(key: key);

  final int pageIndex;

  @override
  State<IdenMain> createState() => _IdenMainState();
}

class _IdenMainState extends State<IdenMain> {
  late int pageIndex;
  bool? hasProfileUpdate;
  bool? hasCardBoxUpdate;
  bool isBottomNavShow = true;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.pageIndex;
  }

  final pages = [
    Container(),
    Container(),
    Container(),
    Container(),
  ];

  void _tap2OmgMain() {
    setState(() => pageIndex = 0);
  }

  void _tap2CardBox() {
    setState(() => pageIndex = 1);
  }

  void _tap2AddFriends() {
    setState(() => pageIndex = 3);
  }

  void _callbackFromHomeVote(String result) async {
    print('---> _callbackFromHomeVote > result: $result');
    /// hide -> false: hide bottom nav, show -> true: show bottom nav
    ///
    if (result == 'show') {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => isBottomNavShow = true);
    } else if (result == 'hide') {
      setState(() => isBottomNavShow = false);
    } else if (result == 'friend') {
      _tap2AddFriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        // height: isBottomNavShow ? kBottomNavigationBarHeight + 30 + service.bottomMargin.value : 0,
        child: SingleChildScrollView(child: _bottomNavBar()),   // SingleChildScrollView used to avoid bottom overflow
      ),
      body: CupertinoPageScaffold(
        backgroundColor: Colors.white,
          child: _body()
      ),
    );
  }

  Widget _body() {
    if (pageIndex == 0) service.homeRedDot.value = false;

    return pageIndex == 0
        // ? HomeVote(callback: _callbackFromHomeVote)
        ? const VoteMainB()
        : pageIndex == 1
          ? HomeCardBox(onClicked: _tap2OmgMain)
          : pageIndex == 2
            ? HomeFeed(onClicked: _tap2AddFriends)
            : pageIndex == 4
              ? SafeArea(child: HomeProfile(onClicked: _tap2CardBox, hasStateUpdate: hasProfileUpdate))
              : Container();
  }

  Widget _bottomNavBar() {
    return Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 22, right: 22),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: kColor.grey20)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(    // iden home
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => pageIndex = 0);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(Icons.circle, size: 5, color: pageIndex == 0
                        ? Colors.black : Colors.transparent),
                  ),
                  Obx(() => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      service.homeRedDot.value
                          ? const Icon(Icons.circle, size: 5, color: Colors.red) : const SizedBox.shrink(),
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: SvgPicture.asset(kIcon.navIDEN, fit: BoxFit.cover),
                      ),
                    ],
                  )),
                ],
              ),
            ),

            GestureDetector(    // 카드 박스
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => pageIndex = 1);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(Icons.circle, size: 5, color: pageIndex == 1
                        ? Colors.black : Colors.transparent),
                  ),
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: SvgPicture.asset(kIcon.navInbox, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),

            GestureDetector(    // feed              behavior: HitTestBehavior.opaque,
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => pageIndex = 2);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(Icons.circle, size: 5, color: pageIndex == 2
                        ? Colors.black : Colors.transparent),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(kIcon.navFeed, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),

            GestureDetector(    // friends
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => pageIndex = 3);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(Icons.circle, size: 5, color: pageIndex == 3
                        ? Colors.black : Colors.transparent),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: SvgPicture.asset(kIcon.navFriends, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),

            GestureDetector(    // profile
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => pageIndex = 4);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(Icons.circle, size: 5, color: pageIndex == 4
                        ? Colors.black : Colors.transparent),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: pageIndex == 4
                          ? Colors.black45 : Colors.transparent)
                    ),
                      child: service.userMe.value.profileImageKey?.isNotEmpty == true
                          ? CustomCacheNetworkImage(imageUrl: service.userMe.value.profileImageKey!, size: 32)
                          : customCircleAvatar(name: service.username.value,
                              size: 32, fontSize: 20, fontWeight: FontWeight.w500))
                ],
              ),
            ),
          ],
        )
    );
  }
}
