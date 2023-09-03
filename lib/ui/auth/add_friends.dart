import 'package:flutter/material.dart';
import 'package:iden/rest_api/api.dart';
import 'package:iden/ui/common_widget/custom_button.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:flutter_svg/svg.dart';

import '../../controller/state_controller.dart';
import '../../model/user.dart';
import '../../ui/common_widget/divider.dart';
import '../../resource/kConstant.dart';
import '../../resource/images.dart';
import '../../resource/style.dart';
import '../../model/session.dart';
import '../common_widget/search_contacts.dart';
import 'set_profile.dart';

class AddFriends extends StatefulWidget {
  const AddFriends({Key? key}) : super(key: key);

  @override
  State<AddFriends> createState() => _AddFriendsState();
}

class _AddFriendsState extends State<AddFriends> {
  List<bool> itemSelected = <bool>[];
  List<User> searchResult = <User>[];
  Paging paging = Paging();
  int? totalCount;
  int numFriendsToAdd = 0;
  late StreamController<dynamic> _streamController;
  HttpsResponse? httpsResponse;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _getSearch();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _getSearch() async {
    List<User> users = [];
    List<User> all = searchResult ?? [];

    HttpsResponse res = await IdenApi.getFollowContact(name: null, afterCursor: paging.afterCursor);

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          users.add(User.fromJson(e));
        }
        /// paging update
        totalCount = res.body['totalCount'];
        if (totalCount != null) {
          numFriendsToAdd = totalCount!;
          itemSelected = List.filled(numFriendsToAdd, true);
        }

        all += users;
        searchResult = all;
      }
      if (!_streamController.isClosed) _streamController.add(searchResult);

    } else {  // 에러 처리
      ErrorResponse error = res.body;
      print('---> add friends > get search > error: ${error.message}');
    }
    if (mounted) setState(() {});
  }

  void _callApi4postFollowBatch() async {
    bool out;
    if (searchResult.isNotEmpty) {
      List<String> ids = [];

      for (var e in searchResult) {
        if (e.userId?.isNotEmpty == true) ids.add(e.userId!);
      }

      print('---> ids: $ids');

      HttpsResponse res = await IdenApi.postFollowBatch(ids);
      if (res.statusType == StatusType.success || res.statusType == StatusType.success) {
        out = true;
      } else {
        out = false;
      }
    } else {
      out = false;
    }
    if (out) _move2setProfile();
  }

  void _move2SearchContact() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const SearchContacts())
    );
  }

  void _move2setProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const SetProfile())
    );
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels == metrics.maxScrollExtent - 50) {
      if (paging.afterCursor?.isNotEmpty == true) _getSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black)),
        title: Text('Add your contacts', style: kTextStyle.headlineExtraBold18),
        centerTitle: true,
      ),
      body: SafeArea(child: _body()),
      bottomSheet: _bottomButton(),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _searchByName(),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 5),
          child: Text('${totalCount ?? '-'} contacts found.', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
        ),

        // _allOmgFriends(),
        // const DividerHorizontal(paddingTop: 10, paddingBottom: 5),
        Expanded(child: _friendsMayKnow())
      ]
    );
  }

  Widget _searchByName() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: GestureDetector(
        onTap: () => _move2SearchContact(),
        child: Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 24, top: 12),
          decoration: BoxDecoration(
            color: kColor.grey30,
            borderRadius: BorderRadius.circular(16)
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 12),
                child: Icon(Icons.search, size: 25, color: kColor.grey300),
              ),
              Text('Search contact', style: kTextStyle.hint)
            ],
          ),
        ),
      ),
    );
  }

  Widget _allOmgFriends() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(left: 20, right: 15,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${totalCount ?? '-'}명의 친구들을 찾음', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
          const SizedBox(height: 15),
          Row(
            children: [
              CustomAvatarStack(users: searchResult, size: 40, background: kColor.blue100),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('내 IDEN 친구들', style: kTextStyle.callOutBold16),
                  const SizedBox(height: 4),
                  Text('모두 선택됨', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _friendsMayKnow() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 10),
            //   child: Text('알 수도 있는 친구들이에요',
            //       style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
            // ),
            _friendsMayKnowContainer(),
          ],
        ),
      ),
    );
  }

  Widget _friendsMayKnowContainer() {
    return StreamBuilder(
        stream: _streamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container();
            case ConnectionState.waiting:
              return _skeleton();
            default:
              if (snapshot.hasError) {
                return _handleError();
              } else if (snapshot.hasData) {
                List<User> users = snapshot.data;

                print('---> snapshot data > len: ${users.length}');

                if (users.isNotEmpty) {
                  return _itemListUp(users);
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

  Widget _itemListUp(List<User> users) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: users.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (BuildContext context, int index) {
        return _item(index, users[index]);
      },
    );
  }

  Widget _item(int index, User user) {
    return Container(
      height: 64,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: kColor.grey20,
        borderRadius: BorderRadius.circular(16)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              customCircleAvatar(name: user.name ?? '이'),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.name ?? '', style: kTextStyle.callOutBold16),
                  const SizedBox(height: 6),
                  Text(user.affiliation ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                ],
              ),
            ],
          ),

          _checkRound(index)
        ],
      ),
    );
  }

  Widget _checkRound(int index) {
    return Container(
      width: 100,
      alignment: Alignment.centerRight,
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
            value: itemSelected[index],
            visualDensity: VisualDensity.compact,
            shape: const CircleBorder(),
            side: BorderSide(width: 1.5, color: kColor.grey300),
            activeColor: Colors.black,
            onChanged: (value) {
              itemSelected[index] = value!;
              _countFriends2Add();
            }
        ),
      ),
    );
  }

  Widget _skeleton() {
    return ListView.builder(
      itemCount: 8,
      shrinkWrap: true,
      itemBuilder: (context, int index) => Shimmer.fromColors(
        baseColor: kColor.grey30,
        highlightColor: Colors.white,
        child: Container(
          height: 52,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: kColor.grey100,
            borderRadius: BorderRadius.circular(12)
          ),
        ),
      ),
    );
  }

  Widget _handleError() {
    return const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 50, right: 50, top: 30),
          child: Text('error has occurred while connecting to server. Please try again later',
            textAlign: TextAlign.center, maxLines: 2,
            style: TextStyle(fontSize: 12, color: Colors.white),),
        )
    );
  }

  Widget _bottomButton() {
    return CustomButtonWide(
      title: 'Add $numFriendsToAdd contacts',
      background: Colors.black,
      isGradientOn: true,
      hasBottomMargie: false,
      onTap: () => _callApi4postFollowBatch(),
    );
  }

  void _countFriends2Add() {
    final listTrue = itemSelected.where((e) => e == true).toList();
    int num = listTrue.length;
    numFriendsToAdd = num;
    print('---> count friends to add > $numFriendsToAdd');
    setState(() {});
  }
}
