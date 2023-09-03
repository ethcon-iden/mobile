import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../common_widget/custom_button.dart';

import '../../common_widget/custom_profile_image_stack.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../rest_api/user_api.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/images.dart';
import '../../../resource/kConstant.dart';
import '../../../services/extensions.dart';
import '../../common_widget/custom_skeleton.dart';
import '../../common_widget/common_widget.dart';

class CookieBoxFriendList extends StatefulWidget {
  const CookieBoxFriendList({Key? key}) : super(key: key);

  @override
  State<CookieBoxFriendList> createState() => _CookieBoxFriendListState();
}

class _CookieBoxFriendListState extends State<CookieBoxFriendList> {
  late StreamController<dynamic> _streamController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _nodeSearch = FocusNode();
  Paging paging = Paging();
  Paging paging4searchQuery = Paging();

  List<User> searchResult = <User>[];
  User? selectedFriend;
  int? selectedIndex;
  bool isReset = false;
  bool isEndOfList = false;
  bool hasSearchDone = false;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _requestFocus();
    _getSearch();
  }

  @override
  void dispose() {
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _requestFocus() {
    _nodeSearch.requestFocus();
    if (mounted) setState(() {});
  }

  void _requestUnFocus() {
    _nodeSearch.unfocus();
    if (mounted) setState(() {});
  }

  Future<void> _getSearch() async {
    String query = _textController.text;

    final HttpsResponse res = await UserApi.getUser(following: true, includedNameOrNickname: query, paging: paging);

    List<User> users = [];
    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      hasSearchDone = true;   // 검색 완료

      if (res.body['data']?.isNotEmpty) {
        for (var e in res.body['data']) {
          users.add(User.fromJson(e));
        }
        if (res.body['cursor'] != null) {
          paging = Paging.fromJson(res.body['cursor']);
          if (paging.afterCursor == null) setState(() => isEndOfList = true);
        }
      }

      if (users.isNotEmpty) {
        List<User> prevResult = searchResult;
        prevResult += users;
        searchResult = prevResult;
      } else {
        searchResult = users;
      }
      if (!_streamController.isClosed) _streamController.add(searchResult);
      if (mounted) setState(() {});

    } else {
      ErrorResponse error = res.body;
      _showErrorMessage(error.message);
    }
  }

  void _clearSearchResult() {
    isReset = true;
    hasSearchDone = false;
    searchResult.clear();
    paging.reset();
  }

  void _onChange(String value) {
    _clearSearchResult();

    if (value.isNotEmpty) {
      _getSearch();
    } else {
      hasSearchDone = true;
      _streamController.add([]);
    }
    if (mounted) setState(() {});
  }

  void _onComplete() {
    _nodeSearch.unfocus();
    isReset = false;
    hasSearchDone = false;
    if (mounted) setState(() {});
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels == metrics.maxScrollExtent) {
      _getSearch();
    }
  }

  void _modal2spend300Cookie() async {
    if (selectedFriend != null) {
      showCustomBottomSheet(
          context,
          _ModalCookieUse(
            // cookieBalance: widget.cookieBalance,
            friend: selectedFriend!,
          ),
          350 + service.bottomMargin.value, true
      ).then((value) {
        if (value != null && value) {
          Navigator.pop(context, selectedFriend);
        }
      });
    }
  }

  void _showErrorMessage(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomSheet: CustomButtonWide(
        title: '이 친구로 선택할게요',
        isAnimationOn: selectedFriend != null ? true : false,
        onTap: () => _modal2spend300Cookie(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        _title(),
        _searchByNameNickname(),
        Expanded(child: _streamBuilder()),
      ],
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('누구에게 쿠키를\n사용할까요?', style: kTextStyle.largeTitle28),
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 26))
      ],
    );
  }

  Widget _searchByNameNickname() {
    TextStyle style;
    if (_nodeSearch.hasFocus) {
      style = kTextStyle.subHeadlineBold14;
    } else {
      style = kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300);
    }
    return Container(
      height: 52,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24, bottom: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: kColor.grey30,
          borderRadius: BorderRadius.circular(16)
      ),
      child: TextFormField(
          controller: _textController,
          focusNode: _nodeSearch,
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.search,
          style: kTextStyle.bodyMedium18,
          autocorrect: false,
          decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: '이름 또는 닉네임으로 찾기',
              hintStyle: kTextStyle.bodyMedium18.copyWith(color: kColor.grey100),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kColor.grey30, width: 2)
              ),
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(left: 12, right: 12),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 10),
                child: Icon(CupertinoIcons.search, size: 24),
              ),
              prefixIconConstraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
              prefixIconColor: _nodeSearch.hasFocus ? Colors.black : kColor.grey100
          ),
          onChanged: (value) => _onChange(value),
          onFieldSubmitted: (_) => setState(() {}),
          onTapOutside: (_) => _requestUnFocus(),
          onTap: () => setState(() {})
      ),
    );
  }

   Widget _streamBuilder() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return const SizedBox.shrink();
            case ConnectionState.waiting:
              return CustomSkeleton.searchingUsers(context);
            default:
              if (snapshot.hasData) {
                List<dynamic> data = snapshot.data;
                if (data.isNotEmpty) {
                  return _buildItems(data);
                } else {  // 리스트가 비어 있는 경우
                  return hasSearchDone
                      ? CommonWidget.emptyCase(context, '🏖', '친구를 찾지 못했어요...\n검색어를 다시 한 번 확인해주세요!')
                      : CustomSkeleton.searchingUsers(context);
                }
              } else {
                return const SizedBox.shrink();
              }
          }
        }
    );
  }

  Widget _buildItems(List<dynamic> users) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              _item(users[index], index),
              if (index == users.length - 1) const SizedBox(height: 100)
            ],
          );
        },
      ),
    );
  }

  Widget _item(User user, int index) {
    return ListTile(
      leading: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 40),
      title: Text(user.name ?? '(', style: kTextStyle.callOutBold16),
      subtitle: Text(user.clueWithoutDot ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
      trailing: _radioButton(index),
      contentPadding: const EdgeInsets.all(0),
    );
  }

  Widget _radioButton(int index) {
    return Transform.scale(
      scale: 1.2,
      child: Radio(
        value: searchResult[index],
        groupValue: selectedFriend,
        activeColor: kColor.blue100,
        onChanged: (value) {
          if (selectedFriend == value) {
            selectedFriend = null;
          } else {
            selectedFriend = value;
          }
          setState(() {});
        },
      ),
    );
  }
}

class _ModalCookieUse extends StatelessWidget {
  const _ModalCookieUse({Key? key,
    // required this.cookieBalance,
    required this.friend
  }) : super(key: key);

  // final String cookieBalance;
  final User friend;

  @override
  Widget build(BuildContext context) {
    String title = '${friend.name} 님에게\n쿠키를 사용할게요!';

    return Container(
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
                      TextSpan(text: '이 친구에게 ', style: kTextStyle.footnoteMedium14),
                      TextSpan(text: '300쿠키', style: kTextStyle.subHeadlineBold14),
                      TextSpan(text: '를 사용할게요!\n선택한 친구의 선택지에 내 이름이 추가돼요.',
                          style: kTextStyle.footnoteMedium14),
                    ]
                ))
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
        Text(' -300', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey900))
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

