import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../rest_api/user_api.dart';
import '../../../services/service_contacts.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/images.dart';
import '../../../resource/kConstant.dart';
import '../../../services/extensions.dart';

class InviteNoneOmgUser extends StatefulWidget {
  const InviteNoneOmgUser({Key? key}) : super(key: key);

  @override
  State<InviteNoneOmgUser> createState() => _InviteNoneOmgUserState();
}

class _InviteNoneOmgUserState extends State<InviteNoneOmgUser> {
  late StreamController<dynamic> _streamController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _nodeSearch = FocusNode();
  Paging paging = Paging();

  List<User> searchResult = <User>[];
  List<String> invitedList = <String>[];  // 초대한 친구 연락처 저장 -> 초대한 친구는 '초대함' 표기
  User? selectedFriend;
  bool isReset = false;
  bool? hasSmsSent;
  bool hasSearchDone = false;
  bool isEndOfList = false;

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

  // Future<void> _getSearchResult() async {
  //   String query = _textController.text;
  //   isReset = false;
  //
  //   final HttpsResponse res = await UserApi.getUser(following: true, includedNameOrNickname: query, paging: paging);
  //
  //   List<User> follows = [];
  //   if (res.body != null) {
  //     if (res.statusType == StatusType.success) {
  //       if (res.body['data'].isNotEmpty) {
  //         for (var e in res.body['data']) {
  //           follows.add(User.fromJson(e));
  //         }
  //       }
  //       allSearchResult = follows;
  //       paging4searchQuery = Paging.fromJson(res.body['cursor']);
  //       _streamController.add(follows);
  //     } else {
  //       print('---> _getSearchResult > no data');
  //     }
  //   } else {
  //     print('---> HttpsResponse > response is empty');
  //   }
  // }

  // Future<void> _getSearchMore() async {
  //   String query = _textController.text;
  //   isReset = false;
  //
  //   if (paging4searchQuery.afterCursor != null) {
  //     HttpsResponse res = await UserApi.searchFollows(
  //         query, paging4searchQuery);
  //
  //     List<User> follows = [];
  //     if (res.body != null) {
  //       if (res.statusType == StatusType.success) {
  //         if (res.body['data'].isNotEmpty) {
  //           for (var e in res.body['data']) {
  //             follows.add(User.fromJson(e));
  //           }
  //         }
  //         allSearchResult += follows;
  //         paging4searchQuery = Paging.fromJson(res.body['cursor']);
  //         _streamController.add(allSearchResult);
  //       }
  //     }
  //   }
  // }

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

  void _showErrorMessage(String? message) => showErrorMessage(context, message);

  void _showSnackbar() =>
      customSnackbar(context,
          '💌',
          '친구에게 초대 메시지를 보냈어요!',
          ToastPosition.top
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        _title(),
        _searchByNameNickname(),
        Expanded(child: _itemList()),
      ],
    );
  }

  Widget _title() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('친구 초대하기', style: kTextStyle.largeTitle28),
            IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 26))
          ],
        ),
        Text('초대한 친구가 OMG에 가입하면,\n투표 대기 시간을 건너뛸 수 있어요.', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
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
      margin: const EdgeInsets.only(top: 24, bottom: 5),
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
          onTapOutside: (_) => _requestUnFocus(),
          onFieldSubmitted: (_) => _onComplete(),
          onTap: () => setState(() {})
      ),
    );
  }

  void _onStartScroll(ScrollMetrics metrics) {
    // print('---> scroll start');
  }
  void _onUpdateScroll(ScrollMetrics metrics) {
    // print('---> scroll update');
  }

  Widget _itemList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // when start to scroll by touching the screen
        if (notification is ScrollStartNotification) {
          _onStartScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> android
        } else if (notification is OverscrollNotification) {
          _onUpdateScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> ios
        } else if (notification is ScrollUpdateNotification) {
          _onUpdateScroll(notification.metrics);
          // when off the touch from screen (end of scroll)
        } else if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _items(),
            const SizedBox(height: 60)
          ],
        ),
      ),
    );
  }

  Widget _items() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container();
            case ConnectionState.waiting:
              return Container();
            default:
              if (snapshot.hasError) {
                return Container();
              } else if (snapshot.hasData) {
                List<User> friends = snapshot.data;
                if (friends.isNotEmpty) {
                  return _buildItems(friends);
                } else {
                  return const SizedBox.shrink();
                }
              } else {
                print('---> snapshot no data: ${snapshot.data}');
                return Container();
              }
          }
        }
    );
  }

  Widget _buildItems(List<User> lists) {
    List<User> contacts = [];
    if (lists.isNotEmpty) {
      contacts = lists;
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: contacts.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (BuildContext context, int index) {
        // return _item(index, friends[index]);
        return Theme(
          data: ThemeData(
            splashColor: Colors.transparent   // disable splash effect
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0, right: 0),
            visualDensity: VisualDensity.standard,
            leading: SvgPicture.asset(kImage.contactProfileSvg, height: 40, width: 40),
            trailing: _buttonInvite(contacts[index]),
            title: Text(contacts[index].name ?? '(', style: kTextStyle.callOutBold16),
            subtitle: Text('OMG 친구 10명', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
          ),
        );
      },
    );
  }

  Widget _buttonInvite(User contact) {
    bool hasInvited = false;
    String title;
    if (invitedList.contains(contact.phoneNumber)) {
      title = '💌초대함';
      hasInvited = true;
    } else {
      title = '초대하기';
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 36,
        width: 72,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 6, right: 6),
        decoration: BoxDecoration(
            color: hasInvited ? kColor.grey30 : kColor.blue10,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Text(title, style: kTextStyle.subHeadlineBold14
            .copyWith(color: hasInvited ? Colors.black : kColor.blue100)),
      ),
    );
  }

  // Widget _buttonAlreadyInvited() {
  //   return Container(
  //     height: 36,
  //     padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
  //     decoration: BoxDecoration(
  //         color: kColor.grey30,
  //         borderRadius: BorderRadius.circular(10)
  //     ),
  //     child: Text('💌초대함', style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.black)),
  //   );
  // }
  //
  // Widget _bottomButton() {
  //   return GestureDetector(
  //     onTap: () => _modal2spend300Cookie(),
  //     child: Container(
  //       height: 56,
  //       width: double.infinity,
  //       margin: const EdgeInsets.only(left: 16, right: 16),
  //       alignment: Alignment.center,
  //       decoration: BoxDecoration(
  //           // color: selectedIem != null ? kColor.blue100 : kColor.blue100.withOpacity(0.1),
  //           color: kColor.blue100,
  //           borderRadius: BorderRadius.circular(12)
  //       ),
  //       child: Text('이 친구로 선택할게요', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
  //     ),
  //   );
  // }
}

class _ModalCookieUse extends StatelessWidget {
  const _ModalCookieUse({Key? key,
    required this.cookieBalance,
    required this.friend
  }) : super(key: key);

  final String cookieBalance;
  final User friend;

  @override
  Widget build(BuildContext context) {
    String title = '${friend.name} 님에게\n쿠키를 사용할게요!';
    String sub = '이 친구에게 300쿠키를 사용할게요!\n선택한 친구의 선택지에 내 이름이 추가돼요.';

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
                Text(sub, style: kTextStyle.subHeadlineBold14),
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
        Text('내 쿠기', style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey500)),
        const SizedBox(height: 4),
        Row(    // 쿠키 수량
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(kIcon.idenCoinSvg, height: 20),
            Text(' ${cookieBalance.toCurrency()}', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey900))
          ],
        ),
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
            width: MediaQuery.of(context).size.width * 0.42,
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('잠깐만요', style: kTextStyle.buttonBlack),
          ),
        ),

        GestureDetector(  // okay
          onTap: () => Navigator.of(context).pop(true),
          child: Container(
            height: 56,
            width: MediaQuery.of(context).size.width * 0.42,
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
            decoration: BoxDecoration(
                color: '#005CFF'.toColor(),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('쿠키 사용하기', style: kTextStyle.buttonWhite),
          ),
        )
      ],
    );
  }
}

