import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../model/session.dart';
import '../../../../model/user.dart';
import '../../../../resource/style.dart';
import '../../../../rest_api/relationship_api.dart';
import '../../../common_widget/custom_profile_image_stack.dart';
import '../../../common_widget/dialog_popup.dart';
import '../friends_from_contact.dart';

class FromContact extends StatefulWidget {
  const FromContact({Key? key}) : super(key: key);

  @override
  State<FromContact> createState() => _FromContactState();
}

class _FromContactState extends State<FromContact> {
  List<String?> imageUrl = [];
  List<User>? friends;
  int? totalCount;

  @override
  void initState() {
    super.initState();
    _getFriends();
  }

  void _getFriends() async {
    List<User> users = [];

    HttpsResponse res = await RelationshipApi.getFollowContact(name: null);
    if (res.statusType == StatusType.success) {
      /// 친구 수 가져오기
      if (res.body['totalCount'] != null) {
        totalCount = res.body['totalCount'];
      }

      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          User user = User.fromJson(e);
          users.add(user);
          imageUrl.add(user.profileImageKey);  // 프로필 이미지 저장
        }
      }

      friends = users;

    } else if (res.statusType == StatusType.error) { // error
      ErrorResponse error = res.body;
      _showError(error.message);
      totalCount = 0;
    }

    if (mounted) setState(() {});
  }

  void _move2FriendsFromContact() {
    if (totalCount != null && totalCount! > 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const FriendsFromContact())
      );
    }
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return _sliverList();
  }

  Widget _sliverList() {
    return SliverList(
        delegate: SliverChildBuilderDelegate((BuildContext context, _) {
          return _body();
        },
            childCount: 1)
    );
  }

  Widget _body() {
    return totalCount != null
        ? _contactInfo(totalCount!)
        : _shimmer();
  }

  Widget _contactInfo(int count) {
    String title = '연락처 친구들';
    String sub;
    String newFriendsCount = '';
    if (count > 0) {
      sub = '연락처에서 $count명의 새로운 OMG 친구들을 찾았어요!';
      newFriendsCount = count.toString();
    } else {
      sub = '연락처에서 찾은 새로운 OMG 친구가 없어요.';
    }

    return Container(
      height: 100,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(left:16, right:16, bottom: 20),
      decoration: BoxDecoration(
          color: kColor.blue10,
          border: Border.all(width: 1.5, color: kColor.blue30),
          borderRadius: BorderRadius.circular(24)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _move2FriendsFromContact(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(    // 연락처 친구들
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomProfileImageStack(imageUrl: imageUrl, size: 28),    // 친구 프로필 사진
                    const SizedBox(width: 12),

                    Text(title, style: kTextStyle.title3ExtraBold20),
                    const SizedBox(width: 6),

                    if (newFriendsCount.isNotEmpty)
                      Container(    // 새로 추가된 친구 숫자 in red circle
                        constraints: const BoxConstraints(
                            minWidth: 20
                        ),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: kColor.red100
                        ),
                        child: Text(newFriendsCount, style: kTextStyle.footnoteMedium14.copyWith(color: Colors.white)),
                      )
                  ],
                ),
                const SizedBox(
                    width: 30,
                    height: 25,
                    child: Icon(Icons.keyboard_arrow_right_rounded, size: 30)
                )
              ],
            ),
          ),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(sub, style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey900)),
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
        height: 100,
        margin: const EdgeInsets.only(left:16, right:16, top: 16, bottom: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24)
        ),
      ),
    );
  }
}