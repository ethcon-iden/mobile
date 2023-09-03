import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../../controller/state_controller.dart';
import '../../../../model/session.dart';
import '../../../../model/user.dart';
import '../../../../resource/style.dart';
import '../../../../resource/images.dart';
import '../../../../rest_api/relationship_api.dart';
import '../../../common_widget/dialog_popup.dart';
import '../../../common_widget/custom_snackbar.dart';
import '../../../common_widget/end_of_list.dart';

class Invite extends StatefulWidget {
  const Invite({Key? key}) : super(key: key);

  @override
  State<Invite> createState() => _InviteState();
}

class _InviteState extends State<Invite> {
  late StreamController<dynamic> _streamController;
  bool? isItemEmpty;   //  true -> 스트림 데이터가 없음 -> empty case
  List<User>? friends;
  Paging? paging;
  bool isEndOfList = false;  // true -> 리스트 마지막
  List<String> invitedList = [];  // 초대한 친구 id 저장

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _getFriends();
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
  }

  Future<void> _getFriends() async {
    List<User> users = [];

    HttpsResponse res = await RelationshipApi.getFollowCommon(paging: paging);
    if (res.statusType == StatusType.success) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          User user = User.fromJson(e);
          users.add(user);
        }
        if (res.body['afterCursor'] != null) {
          paging?.afterCursor = res.body['afterCursor'];
          if (paging?.afterCursor == null) setState(() => isEndOfList = true);    // 리스트 마지막 표시
        }
      }

      if (friends?.isNotEmpty ?? false) { // 피드가 있는 경우 추가 하기
        List<User> all = friends!;
        all += users;
        friends = all;
      } else {    // 피드가 없는 경우 초기화
        friends = users;
      }
      if (!_streamController.isClosed) _streamController.add(friends);

    } else if (res.statusType == StatusType.error) { // error
      ErrorResponse error = res.body;
      _showError(error.message);
    }

    /// 리스트가 비어 있는지 확인
    if (friends?.isNotEmpty == true) {
      isItemEmpty = false;  // 리스트 있음
    } else {
      isItemEmpty = true;   // 리스트 비어 있음
    }
    if (mounted) setState(() {});
  }

  void _inviteFriend(User friend) {
    if (friend.id?.isNotEmpty == true) {
      invitedList.add(friend.id!);
      _callApi4Invite(friend);
    }
    if (mounted) setState(() {});
  }

  void _callApi4Invite(User friend) async {
    if (friend.id?.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postFollow(friend.id!);
      if (res.statusType == StatusType.success) {
        _showSnackbar();
      }
    }
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 100) {
      if (paging?.afterCursor != null) {  // 다음 커서가 있는 경우만 다음 데이터 가져오기
        _getFriends();
      }
    }
  }

  void _showSnackbar() {
    customSnackbar(context, '💌', '친구에게 초대 메시지를 보냈어요!', ToastPosition.bottom, bottomMargin: 50);
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int idx) {
          return Column(
            children: [
              StickyHeader(
                  overlapHeaders: false,
                  header: isItemEmpty != null ? _stickyHeader() : _shimmer(),
                  content: _streamBuilder()
              ),

              if (isEndOfList) const EndOfList()   // 마지막 리스트 인 경우
            ],
          );
        },
            childCount: 1
        )
    );
  }

  Widget _stickyHeader() {
    String title = '초대할 수 있는 친구들';
    String sub = '친구를 초대하면, 기다리지 않고 바로 투표할 수 있어요.';

    return GestureDetector(
      onTap: () {
        // todo
      },
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(    // 타이틀
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: kTextStyle.title3ExtraBold20),
                SvgPicture.asset(kIcon.share, height: 28, width: 28)
              ],
            ),

            Padding(    // 설명
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(sub, textAlign: TextAlign.center,
                          style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                  )
              ),
            )
          ],
        ),
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
              return const SizedBox.shrink();
            default:
              if (snapshot.hasData) {
                List<dynamic> data = snapshot.data;
                if (data.isNotEmpty) {
                  return _buildItems(data);

                } else {  // 리스트가 비어 있는 경우
                  return _emptyCase();
                }
              } else {
                return _emptyCase();
              }
          }
        });
  }

  Widget _buildItems(List<dynamic> friends) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            _onEndScroll(notification.metrics);
          }
          return false;
        },
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: _item(friends[index]),
              );
            }
        ),
      ),
    );
  }

  Widget _item(User user) {
    bool hasInvited = false;
    if (invitedList.contains(user.id)) hasInvited = true;

    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(kImage.contactProfileSvg, height: 40, width: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.name ?? user.phoneNumber ?? ' ', style: kTextStyle.callOutBold16),
                  const SizedBox(height: 4),
                  Text('OMG 친구 ${user.followerCount ?? 0}명',
                      style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                ],
              ),
            ],
          ),

          GestureDetector(
            onTap: () => _inviteFriend(user),
            child: Container(  // 친구 추가 버튼
              width: 75,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: hasInvited ? kColor.grey30 : kColor.blue100,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: hasInvited
                  ? Text('💌 초대함', style: kTextStyle.subHeadlineBold14)
                  : Text('초대하기', style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
      baseColor: kColor.grey30,
      highlightColor: Colors.white,
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(left:16, right:16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)
        ),
      ),
    );
  }

  Widget _emptyCase() {
    String title = '초대할 수 있는 연락처 친구들이 없어요.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 50),
        child: Column(
          children: [
            const Text('☕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, style: kTextStyle.headlineExtraBold18))
          ],
        ),
      ),
    );
  }
}