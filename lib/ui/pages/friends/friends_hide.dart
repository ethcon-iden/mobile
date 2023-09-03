import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common_widget/common_widget.dart';
import '../../common_widget/custom_button.dart';
import '../../../services/extensions.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../../controller/state_controller.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../resource/style.dart';
import '../../../rest_api/relationship_api.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../components/bottom_modal_contents_buttons.dart';
import '../../common_widget/custom_skeleton.dart';

class FriendsHide extends StatefulWidget {
  const FriendsHide({Key? key}) : super(key: key);

  @override
  State<FriendsHide> createState() => _FriendsHideState();
}

class _FriendsHideState extends State<FriendsHide> {
  late StreamController<dynamic> _streamController;
  List<User>? friends;
  Paging paging = Paging();
  bool isEndOfList = true;  // true -> 리스트 마지막, 한번에 모든 리스트 가져와서 초기값 true로 변경
  bool? isItemEmpty;    //  true -> 스트림 데이터가 없음 -> empty case
  List<String> unhideList = [];  // 숨김 해제한 친구 id 저장
  int? hideCount;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _getHideList();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> _getHideList() async {
    List<User> users = [];

    HttpsResponse res = await RelationshipApi.getHide();
    if (res.statusType == StatusType.success) {
      if (res.body?.isNotEmpty == true) {
        for (var e in res.body) {
          User user = User.fromJson(e['hiddenUser']);
          user.createdAt = e['createdAt'];
          users.add(user);
        }
      }
      friends = users;
      if (!_streamController.isClosed) _streamController.add(friends);

    } else if (res.statusType == StatusType.error) {  // error
      ErrorResponse error = res.body;
      _showError(error.message);
    }

    /// 리스트가 비어 있는지 확인
    if (friends?.isNotEmpty == true) {
      isItemEmpty = false;  // 리스트 있음
      hideCount = friends?.length;   // 숨긴 친구들 수
    } else {
      isItemEmpty = true;   // 리스트 비어 있음
      hideCount = 0;
    }
    if (mounted) setState(() {});
  }

  Future<bool> _callApi4unhide(String id) async {
    bool out;
    HttpsResponse res = await RelationshipApi.postUnhide(id);
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

  Future<void> _requestUnhide(User user) async {
    if (user.id?.isNotEmpty == true) {
      if (!unhideList.contains(user.id!)) {   // 숨김 해제 된 ID가 아닌 경우만 동작
        final res = await _callApi4unhide(user.id!);
        if (res) _updateState(user.id!);
      }
    }
  }

  void _updateState(String id) {
    unhideList.add(id);
    if (mounted) setState(() {});
  }

  void _modal2unhide(User user) async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: null,
          sub: null,
          listTitle: const ['숨김 해제하기', '취소'],
          // index: 0,1
          listColor: [
            kColor.blue100,
            Colors.black
          ],
          listIcon: const [null, null],
        ),
        250 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 숨김 해제
        _requestUnhide(user);
      }
    }
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 100) {
      if (!isEndOfList) {  // 마지막 리스트가 아닐 경우만 다음 데이터 가져오기
        // _getFriends();
      }
    }
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kStyle.appBar(context, '숨긴 친구들 (${hideCount ?? 0})'),
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
                  return CommonWidget.emptyCase(context, '⛰', '숨긴 친구가\n아무도 없네요.');
                }
              } else {
                return const SizedBox.shrink();
              }
          }
        });
  }

  Widget _buildItems(List<dynamic> users) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return _item(users[index]);
        }
    );
  }

  Widget _item(User user) {
    bool hasUnhide = false;
    if (unhideList.contains(user.id)) hasUnhide = true;
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
        titleNorm: '숨김 해제',
        titleOn: ' 해제됨',
        isToggleOn: hasUnhide,
        iconOn: const Icon(CupertinoIcons.checkmark_alt, size: 16, color: Colors.black),
        colorNorm: kColor.blue100,
        colorOn: Colors.black,
        backgroundNorm: kColor.grey30,
        onClick: () {
          if (user.id?.isNotEmpty == true && !hasUnhide) _modal2unhide(user);
        },
      ),
    );
  }
}
