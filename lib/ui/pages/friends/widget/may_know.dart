import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import '../../../common_widget/custom_profile_image_stack.dart';
import '../../../pages/friends/friends_may_know.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../../../../controller/state_controller.dart';
import '../../../../model/session.dart';
import '../../../../model/user.dart';
import '../../../../resource/style.dart';
import '../../../../rest_api/relationship_api.dart';
import '../../../common_widget/dialog_popup.dart';
import '../../../../resource/images.dart';

class MaybeKnow extends StatefulWidget {
  const MaybeKnow({Key? key}) : super(key: key);

  @override
  State<MaybeKnow> createState() => _MaybeKnowState();
}

class _MaybeKnowState extends State<MaybeKnow> {
  final GlobalKey<AnimatedListState> _animatedKey = GlobalKey<AnimatedListState>();
  bool? isItemEmpty;
  List<dynamic>? friends;
  Paging? paging;
  List<String> followList = [];

  @override
  void initState() {
    super.initState();
    _getFriends();
  }

  void _getFriends() async {
    List<User> users = [];

    HttpsResponse res = await RelationshipApi.getFollowCommon();
    if (res.statusType == StatusType.success) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          User user = User.fromJson(e);
          users.add(user);
        }

        if (res.body['afterCursor'] != null) {
          paging?.afterCursor = res.body['afterCursor'];
        }
      }

      if (users.length > 4) {
        friends = users.sublist(0, 4);
      } else {
        friends = users;
      }

      /// 리스트가 비어 있는지 확인
      if (users.isNotEmpty) {
        isItemEmpty = false;
      } else {
        isItemEmpty = true;   // 비어 있는 리스트
      }

    } else if (res.statusType == StatusType.error) {  // error
      ErrorResponse error = res.body;
      _showError(error.message);
    }

    if (mounted) setState(() {});
  }

  Future<bool> _callApi4follow(User user) async {
    bool out = false;
    if (user.id?.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postFollow(user.id!);
      if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
        out = true;
      } else {
        ErrorResponse error = res.body;
        out = false;
        _showError(error.message);
      }
    }
    return out;
  }

  Future<bool> _callApi4unfollow(User user) async {
    bool out = false;
    if (user.id?.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postUnfollow(user.id!);
      if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
        out = true;
      } else {
        ErrorResponse error = res.body;
        out = false;
        _showError(error.message);
      }
    }
    return out;
  }

  Future<bool> _callApi4hide(User user) async {
    bool out = false;
    if (user.id?.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postHide(user.id!);
      if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
        out = true;
      } else {
        ErrorResponse error = res.body;
        out = false;
        _showError(error.message);
      }
    }
    return out;
  }

  void _removeItem(User user, int index) async {
    if (friends?.isNotEmpty == true) {
      bool res = await _callApi4hide(user);
      if (res) {  // api call 성공시 -> 숨기기
        final newItem = friends?.removeAt(index);
        _animatedKey.currentState?.removeItem(index, (context, animation) =>
            _buildAnimation(newItem, index, animation), duration: const Duration(milliseconds: 100));
      }
    }
  }

  void _updateFollow(User user) async {
    if (user.id?.isNotEmpty == true) {
      bool hasFollowed = followList.contains(user.id);
      if (hasFollowed) { // true: 이미 추가된 경우 -> 추가 해제
        bool res = await _callApi4unfollow(user);
        if (res) followList.remove(user.id!);
      } else { // false: 추가 안된 경우 -> 친구 추가
        bool res = await _callApi4follow(user);
        if (res) followList.add(user.id!);
      }

      if (mounted) setState(() {});
    }
  }

  void _move2mayKnow() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const FriendsMayKnow())
    );
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, int idx) {
          return StickyHeader(
              overlapHeaders: false,
              header: isItemEmpty != null ? _stickyHeader() : _shimmer(),
              content: _futureBuilder()
          );
        },
            childCount: 1
        )
    );
  }

  Widget _stickyHeader() {
    String title = '알 수도 있는 친구들';
    String emptyMessage = '알 수도 있는 친구들이 없어요.';

    return GestureDetector(
      onTap: () => _move2mayKnow(),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 15, bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: kTextStyle.title3ExtraBold20),

            isItemEmpty == true
                ? Expanded(   // 친구 리스트가 없는 경우
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(emptyMessage, style: kTextStyle.caption1SemiBold12
                          .copyWith(color: kColor.grey500)),
                    ),
                  )
                : const Icon(Icons.keyboard_arrow_right_rounded, size: 30)  // 리스트가 있는 경우: 친구 있는 경우
          ],
        ),
      ),
    );
  }

  Widget _futureBuilder() {
    return friends != null
        ? _animatedList(friends!)
        : const SizedBox.shrink();
  }

  Widget _animatedList(List<dynamic> users) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AnimatedList(
          key: _animatedKey,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          initialItemCount: users.length,
          itemBuilder: (context, index, animation) {
            return _buildAnimation(users[index], index, animation);
          }
      ),
    );
  }

  Widget _buildAnimation(item, index, animation) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: _slidableItem(item, index)),
    );
  }

  Widget _slidableItem(User user, int index) {
    bool hasFollowed = followList.contains(user.id);

    return Slidable(
      key: user.id != null ? Key(user.id!) : UniqueKey(),
      endActionPane:
          hasFollowed
              ? null    // true: 추가된 경우 -> 숨김 action X
              : ActionPane(
                  extentRatio: 0.23,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      autoClose: false,
                      onPressed: (_) => _removeItem(user, index), // 친구 숨김
                      backgroundColor: kColor.grey300,
                      foregroundColor: Colors.white,
                      label: '숨김',
                    ),
                  ],
                ),
      child: _item(user, index),
    );
  }

  Widget _item(User user, int index) {
    bool hasFollowed = followList.contains(user.id);

    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CustomCacheNetworkImage(imageUrl: user.profileImageKey, size: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user.name ?? '', style: kTextStyle.callOutBold16),
                  const SizedBox(height: 4),
                  Text('함께 아는 친구 ${user.commonFollowingCount ?? 0}명',
                      style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                ],
              ),
            ],
          ),

          GestureDetector(
            onTap: () => _updateFollow(user),
            child: Container(  // 친구 추가 버튼
              width: 75,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: hasFollowed ? kColor.grey30 : kColor.blue100,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: hasFollowed
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(kIcon.addFried, height: 20, width: 20),
                  const SizedBox(width: 4),
                  Text('추가됨', style: kTextStyle.subHeadlineBold14)
                ],
              )
                  : Text('친구 추가', style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.white)),
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
}