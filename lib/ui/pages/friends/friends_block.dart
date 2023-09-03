import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../services/extensions.dart';
import '../../../controller/state_controller.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../resource/style.dart';
import '../../../rest_api/relationship_api.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/common_widget.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/custom_skeleton.dart';
import '../../common_widget/dialog_popup.dart';
import '../components/bottom_modal_contents_buttons.dart';
import '../../../resource/images.dart';

class FriendsBlock extends StatefulWidget {
  const FriendsBlock({Key? key}) : super(key: key);

  @override
  State<FriendsBlock> createState() => _FriendsBlockState();
}

class _FriendsBlockState extends State<FriendsBlock> {
  late StreamController<dynamic> _streamController;
  List<User>? friends;
  Paging paging = Paging();
  bool isEndOfList = true;  // true -> 리스트 마지막, 한번에 모든 리스트 가져와서 초기값 true로 변경
  bool? isItemEmpty;    //  true -> 스트림 데이터가 없음 -> empty case
  List<String> unblockList = [];  // 차단 해제한 친구 id 저장
  List<String> followedList = [];  // 차단 해제 & 추가된  친구 id 저장
  int? blockCount;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _getBlockList();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> _getBlockList() async {
    List<User> users = [];

    HttpsResponse res = await RelationshipApi.getBlock();
    if (res.statusType == StatusType.success) {
      if (res.body?.isNotEmpty == true) {
        for (var e in res.body) {
          User user = User.fromJson(e['blockedUser']);
          user.createdAt = e['createdAt'];
          users.add(user);
        }
      }
      friends = users;
      if (!_streamController.isClosed) _streamController.add(friends);

    } else if (res.statusType == StatusType.error) { // error
      ErrorResponse error = res.body;
      _showError(error.message);
    }

    /// 리스트가 비어 있는지 확인
    if (friends?.isNotEmpty == true) {
      isItemEmpty = false;  // 리스트 있음
      blockCount = friends?.length;   // 숨긴 친구들 수
    } else {
      isItemEmpty = true;   // 리스트 비어 있음
      blockCount = 0;
    }
    if (mounted) setState(() {});
  }

  Future<void> _requestFollow(User user) async {
    if (user.id?.isNotEmpty == true) {
      if (!followedList.contains(user.id!)) {   // 이미 추가된 친구 ID가 아닌 경우만 동작
        final res = await _callApi4follow(user.id!);
        if (res) _updateFollow(user.id!);
      }
    }
  }

  void _updateFollow(String id) {
    print('---> update follow: id: $id');
    followedList.add(id);
    if (mounted) setState(() {});
  }

  Future<void> _requestUnblock(User user) async {
    if (user.id?.isNotEmpty == true) {
      if (!unblockList.contains(user.id!)) {   // 차단 해제 된 ID가 아닌 경우만 동작
        final res = await _callApi4unblock(user.id!);
        if (res) _updateUnblock(user.id!);
      }
    }
  }

  void _updateUnblock(String id) {
    unblockList.add(id);
    if (mounted) setState(() {});
  }

  Future<bool> _callApi4unblock(String id) async {
    bool out;
    HttpsResponse res = await RelationshipApi.postUnblock(id);
    if (res.statusType == StatusType.success) {
      out = true;
    } else if (res.statusType == StatusType.error){
      ErrorResponse error = res.body;
      _showError(error.message);
      out = false;
    } else {
      out = false;
    }
    return out;
  }

  Future<bool> _callApi4follow(String id) async {
    bool out;
    HttpsResponse res = await RelationshipApi.postFollow(id);
    if (res.statusType == StatusType.success) {
      out = true;
    } else if (res.statusType == StatusType.error){
      ErrorResponse error = res.body;
      _showError(error.message);
      out = false;
    } else {
      out = false;
    }
    return out;
  }

  void _modal2unhideFollow(User user) async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: null,
          sub: null,
          listTitle: const ['차단 해제하고 친구 추가하기', '차단 해제하기', '취소'],
          // index: 0,1,2
          listColor: [
            kColor.blue100,
            kColor.blue100,
            Colors.black
          ],
          listIcon: const [null, null, null],
        ),
        300 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 차단 해제 & 친구 추가
        _requestFollow(user);
      } else if (res == 1) {  // 차단 해제
        _requestUnblock(user);
      }
    }
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 100) {
      if (!isEndOfList) {  // 마지막 리스트가 아닐 경우만 다음 데이터 가져오기
        _getBlockList();
      }
    }
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kStyle.appBar(context, '차단한 친구들 (${blockCount ?? 0})'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left:16, right: 16, top: 10),
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: _streamBuilder(),
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
                  return CommonWidget.emptyCase(context, '⛰', '차단한 친구가\n아무도 없네요.');
                }
              } else {
                return const SizedBox.shrink();
              }
          }
        }
    );
  }

  Widget _buildItems(List<dynamic> friends) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: friends.length,
        itemBuilder: (BuildContext context, int index) {
          return _item(friends[index]);
        }
    );
  }

  Widget _item(User user) {
    bool isToggleOn = false;
    bool hasUnblock = false;
    bool hasFollowed = false;
    if (unblockList.contains(user.id)) hasUnblock = true;
    if (followedList.contains(user.id)) hasFollowed = true;
    if (hasUnblock) {
      isToggleOn = true;
    } else if (hasFollowed) {
      isToggleOn = true;
    }
    String? timeAt;
    if (user.createdAt?.isNotEmpty == true) {
      timeAt = user.createdAt!.toTimeFormat();
    }

    return ListTile(
      leading: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 40),
      title: Text(user.name ?? '(', style: kTextStyle.callOutBold16),
      subtitle: Text(timeAt ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
      contentPadding: const EdgeInsets.all(0),
      trailing: CustomButtonSmall(
        titleNorm: '차단 해제',
        titleOn: hasUnblock ? ' 해제됨' : hasFollowed ? ' 추가됨' : null,
        isToggleOn: isToggleOn,
        iconOn: hasUnblock
            ? const Icon(CupertinoIcons.checkmark_alt, size: 16, color: Colors.black)
            : hasFollowed
                ? SvgPicture.asset(kIcon.addFried, height: 20, width: 20)
                : null,
        colorNorm: kColor.blue100,
        colorOn: Colors.black,
        backgroundNorm: kColor.grey30,
        onClick: () {
          if (user.id?.isNotEmpty == true) {
            if (!isToggleOn) _modal2unhideFollow(user);
          }
        }
      ),
    );
  }
}
