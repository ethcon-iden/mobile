import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../model/session.dart';
import '../../../rest_api/item_api.dart';
import '../../../model/user.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/custom_snackbar.dart';
import 'cookiebox_friend_list.dart';
import '../../../services/extensions.dart';
import '../../../model/omg_pass.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/divider.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/kConstant.dart';

class CookieBox extends StatefulWidget {
  const CookieBox({Key? key}) : super(key: key);

  @override
  State<CookieBox> createState() => _CookieBoxState();
}

class _CookieBoxState extends State<CookieBox> {
  bool? hasOmgPass;
  // late String cookieBalance;

  @override
  void initState() {
    super.initState();
    // cookieBalance = service.cookieBalance.value.toString();
    _checkValidateOmgPass();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateCookieBalance() async {
    final newCookieBalance = await service.updateCookieBalance();
    // if (newCookieBalance != null) {
    //   if (mounted) setState(() => cookieBalance = newCookieBalance);
    // }
  }

  void _checkValidateOmgPass() async{
    OmgPassStatus res = await service.getOmgPassStatus();
    if (res == OmgPassStatus.activeSub || res == OmgPassStatus.activeUnSub) {
      hasOmgPass = true;
    } else {
      hasOmgPass = false;
    }
    if (mounted )setState(() {});
  }

  void _modal2spend100Cookie() async {
    showCustomBottomSheet(
        context,
        const _ModalCookieUse(),
        350 + service.bottomMargin.value, true
    ).then((value) {
      if (value != null && value) _spend100Cookies();
    });
  }

  void _cupertinoModal4friendList() {
    modalCupertino(
        context,
        const CookieBoxFriendList(),
        false   // not draggable
    ).then((value) {
      print('---> friend list > value : $value');
      if (value != null) {
        User selectedFriend = value;
        print('---> cookiebox > value: ${selectedFriend.name} |id: ${selectedFriend.id}');
        // todo
        if (selectedFriend.id != null) {
          _spend300Cookies(selectedFriend);
        }
      }
    });
  }

  void _spend100Cookies() async {
    final HttpsResponse res = await ItemApi.postItemBuy4InjectRandom(); // 100 쿠키
    if (res.statusType == StatusType.success) {
      _showSnackbarSuccess100Cookie();
    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showErrorCase(error.message);
    }
    _updateCookieBalance();
  }

  void _spend300Cookies(User friend) async {
    final HttpsResponse res = await ItemApi.postItemBuy4InjectCertain(friend.id!); // 300 쿠키
    if (res.statusType == StatusType.success) {
      _showPopupSuccess300Cookie(friend);
    } else if (res.statusType == StatusType.error) {
      ErrorResponse error = res.body;
      _showErrorCase(error.message);
    }
    _updateCookieBalance();
  }

  void _showSnackbarInsufficient() {
    customSnackbar(
        context,
        '🍪',
        '쿠키가 부족해요!',
        ToastPosition.bottom
    );
  }

  void _showSnackbarSuccess100Cookie() {
    customSnackbar(
        context,
        '🤫',
        '랜덤 친구 3명의 투표 선택지에\n이름이 추가되었어요!',
        ToastPosition.bottom
    );
  }

  void _showPopupSuccess300Cookie(User friend) {
    showDialog4Info(
        context,
        '🤫',
        '${friend.name} 님의 투표 선택지에\n내 이름을 추가했어요!',
        '선택한 친구의 다음 투표 선택지에 내 이름이 표시될 거에요. 친구는 내가 추가한 사실을 절대 알 수 없으니 안심하세요!',
        null
    );
  }

  void _showErrorCase(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: kStyle.appBar(context, '쿠키상자'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _myCookie(),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('친구들의 투표 선택지에 몰래 내 이름을 추가하고,\n더 많은 투표를 받아보세요!',
                      style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
                ),
                const SizedBox(height: 20),
                _option1(),
                const SizedBox(height: 8),
                _option2(),
                const DividerHorizontal(paddingTop: 20, paddingBottom: 27),

                if (hasOmgPass != null)
                  if (hasOmgPass!)
                    _bottomSub4omgPassUser()
                  else
                    _bottomSub4noPass()
                else
                  const SizedBox.shrink(),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _myCookie() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 5),
          child: Text('내가 가진 쿠키', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍪', style: TextStyle(fontSize: 42)),
            const SizedBox(width: 10),
            Text('${service.cookieBalance.value.toString().toCurrency()}개', style: kTextStyle.largeTitle28),
          ],
        ),
        const DividerHorizontal(paddingTop: 12, paddingBottom: 1)
      ],
    );
  }

  Widget _option1() {   // 100 쿠키
    String title = '랜덤 친구 3명의 투표 선택지에\n내 이름을 추가하기';
    String cookie = '100';
    bool isAvailable = false;
    if (service.cookieBalance.value >= 100) {
      isAvailable = true;
    } else {
      isAvailable = false;
    }

    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: kColor.grey20,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image.asset(kImage.threeFriends, height: 82),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(title, maxLines: 3, style: kTextStyle.callOutBold16)),
              GestureDetector(
                onTap: () {
                  if (isAvailable) {
                    _modal2spend100Cookie();
                  } else {
                    _showSnackbarInsufficient();
                  }
                },
                child: Container(  // 쿠키 정보
                  height: 34,
                  width: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAvailable ? kColor.blue100 : kColor.blue30,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(    // 쿠키 수량
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(kIcon.idenCoinSvg, height: 18, colorFilter: ColorFilter.mode(
                          Colors.white, isAvailable ? BlendMode.difference : BlendMode.srcIn)),
                      Text('  $cookie', style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.white))
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _option2() {   // 300 쿠키
    String title = '원하는 친구 1명의 투표 선택지에\n내 이름을 추가하기';
    String sub = '내가 추가한 사실을 그 친구는 알 수 없어요!';
    String cookie = '300';
    bool isAvailable = false;
    if (service.cookieBalance.value >= 300) {
      isAvailable = true;
    } else {
      isAvailable = false;
    }

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 16),
      decoration: BoxDecoration(
          color: kColor.grey20,
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Image.asset(kImage.shoulder2shoulder, height: 82),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                  height: 70,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, maxLines: 3, style: kTextStyle.callOutBold16),
                      Flexible(
                          child: Text(sub, maxLines: 2, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500))),
                    ],
                  )),
              GestureDetector(
                onTap: () {
                  print('--->token: ${service.accessToken.value}'); // todo > remove
                  if (isAvailable) {
                    _cupertinoModal4friendList();
                  } else {
                    _showSnackbarInsufficient();
                  }
                },
                child: Container(  // 쿠키 정보
                  height: 34,
                  width: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: isAvailable ? kColor.blue100 : kColor.blue30,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(kIcon.idenCoinSvg, height: 18, colorFilter: ColorFilter.mode(
                          Colors.white, isAvailable ? BlendMode.difference : BlendMode.srcIn)),
                      Text('  $cookie', style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.white))
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _bottomSub4omgPassUser() {
    String title = '쿠키는 투표를 하면 얻을 수 있어요';
    String sub = '투표를 통해 친구들에게 마음을 선물하고,\n쿠키도 얻어보세요!';

    return Column(
      children: [
        Text(title, style: kTextStyle.callOutBold16.copyWith(color: kColor.grey900)),
        const SizedBox(height: 10),
        Text(sub, maxLines: 2, textAlign: TextAlign.center, style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey300)),
      ],
    );
  }

  Widget _bottomSub4noPass() {
    String title = '쿠키 2배로 얻는 방법';
    String sub = 'OMG PASS를 구독하고,\n투표할 때마다 쿠키를 2배로 획득해보세요!';

    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            color: Colors.transparent,
            height: 30,
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: kTextStyle.callOutBold16.copyWith(color: kColor.blue100)),
                const SizedBox(width: 6),
                Icon(Icons.keyboard_arrow_right, size: 20, color: kColor.blue100)
              ],
            ),
          ),
        ),
        Text(sub, maxLines: 2, textAlign: TextAlign.center, style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey300)),
      ],
    );
  }
}


class _ModalCookieUse extends StatelessWidget {
  const _ModalCookieUse({Key? key,
    // required this.cookieBalance
  }) : super(key: key);

  // final String cookieBalance;

  @override
  Widget build(BuildContext context) {
    String title = '랜덤 친구 3명에게\n쿠키를 사용할게요!';

    return Container(
      // height: 320 + service.bottomMargin.value,
      padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScrollIndicatorBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(title, style: kTextStyle.title1ExtraBold24.copyWith(height: 1.5)),
                    ),
                    _cookieBalance()
                  ],
                ),
                _cookie2spend(),
                RichText(text: TextSpan(
                  children: [
                    TextSpan(text: '랜덤 친구 3명에게 ', style: kTextStyle.footnoteMedium14),
                    TextSpan(text: '100쿠키', style: kTextStyle.subHeadlineBold14),
                    TextSpan(text: '를 사용할게요!\n선택된 친구들의 투표 선택지에 내 이름이 추가돼요.',
                        style: kTextStyle.footnoteMedium14),
                  ]
                ))
                // Text(sub, style: kTextStyle.subHeadlineBold14),
              ],
            ),
          ),

          _buttons(context)
        ],
      ),
    );
  }

  Widget _cookieBalance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('내 쿠키', style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500)),
        const SizedBox(height: 4),
        Obx(() => Row(    // 쿠키 수량
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(kIcon.idenCoinSvg, height: 20),
            Text(' ${service.cookieBalance.value.toString().toCurrency()}', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey900))
          ],
        )),
      ],
    );
  }

  Widget _cookie2spend() {
    return Row(    // 쿠키 수량
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgPicture.asset(kIcon.idenCoinSvg, height: 20),
        Text(' -100', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey900))
      ],
    );
  }

  Widget _buttons(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(    // cancel
          onTap: () => Navigator.of(context).pop(false),
          child: Container(
            height: 56,
            width: MediaQuery.of(context).size.width * 0.43,
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('잠깐만요', style: kTextStyle.headlineExtraBold18),
          ),
        ),

        GestureDetector(  // okay
          onTap: () => Navigator.of(context).pop(true),
          child: Container(
            height: 56,
            width: MediaQuery.of(context).size.width * 0.43,
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
            decoration: BoxDecoration(
                color: '#005CFF'.toColor(),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('쿠키 사용하기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
          ),
        )
      ],
    );
  }
}
