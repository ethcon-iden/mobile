import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../pages/child/modal_user_profile.dart';

import '../components/bottom_modal_contents_buttons.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/custom_skeleton.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/common_widget.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../controller/state_controller.dart';
import '../../../services/extensions.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';
import '../../../rest_api/relationship_api.dart';

class FollowingFriends extends StatefulWidget {
  const FollowingFriends({Key? key,
    required this.followingCount
  }) : super(key: key);

  final int? followingCount;

  @override
  State<FollowingFriends> createState() => _FollowingFriendsState();
}

class _FollowingFriendsState extends State<FollowingFriends> {
  final TextEditingController _textController = TextEditingController();
  late StreamController<dynamic> _streamController;
  Paging paging = Paging();
  List<String> unfollowingList = [];   // 삭제된 친구 id 저장
  /// search control
  final FocusNode _nodeSearch = FocusNode();
  bool hasInitDone = false;
  bool hasSearchDone = false;
  bool isTextInputEnabled = false;
  List<User> searchResult = [];   // 검색 결과
  List<User> buffer = [];   // 초기 검색 결과 임시 보관
  bool isEndOfList = false;   // true -> 리스트 마지막

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _getSearch();
  }

  @override
  void dispose() {
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _requestUnFocus() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nodeSearch.unfocus();
      setState(() {});
    });
  }

  void _getSearch() async {
    List<User> users = [];
    String name = _textController.text;
    print('---> get search > name: $name | paging after: ${paging.afterCursor} ');

    HttpsResponse res = await RelationshipApi.getFollowing(isFavorite: false, name: name);
    hasSearchDone = true;   // 검색 완료 -> 로딩 끄기

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      if (res.body?.isNotEmpty == true) {
        for (var e in res.body) {
          users.add(User.fromJson(e));
        }

        searchResult = users;
        print('---> total count: ${users.length}');
      }
      if (!_streamController.isClosed) _streamController.add(searchResult);

    } else {  // 에러 처리
      ErrorResponse error = res.body;
      _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
    }
    // 최초 데이터 buffer 에 저장 -> 검색어 비어 있을 때 API call 하지 않고 전체 리스트 불러오기
    if (!hasInitDone) {
      buffer = users;
      hasInitDone = true;
    }
    if (mounted) setState(() {});
  }

  Future<bool> _callApi4follow(User user) async {
    bool out;
    if (user.id!.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postFollow(user.id!);
      if (res.statusType == StatusType.success) {
        out = true;
      } else if (res.statusType == StatusType.error) {
        ErrorResponse error = res.body;
        _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
        out = false;
      } else {
        out = false;
      }
    } else {
      out = false;
    }
    return out;
  }

  Future<bool> _callApi4unFollow(User user) async {
    bool out;
    if (user.id?.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postUnfollow(user.id!);
      if (res.statusType == StatusType.success) {
        out = true;
      } else if (res.statusType == StatusType.error) {
        ErrorResponse error = res.body;
        _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
        out = false;
      } else {
        out = false;
      }
    }else {
      out = false;
    }
    return out;
  }

  void _updateState(User user, bool isUnfollowing) async {   // toggle action
    /// call API for follow and unfollow
    if (isUnfollowing) {  // 친구 삭제
      bool res = await _callApi4unFollow(user);
      if (res) unfollowingList.add(user.id!);
    } else {  // 친구 추가
      bool res = await _callApi4follow(user);
      if (res) unfollowingList.remove(user.id!);
    }
    if (mounted) setState(() {});
  }

  void _modal2followUnfollow(User user) async {
    String header;
    String sub;
    String buttonTitle;
    Color buttonColor;
    bool isUnfollowing;
    if (unfollowingList.contains(user.id)) {    // 이미 삭제된 경우 -> 친구 추가
      isUnfollowing = false;
      header = '${user.name ?? ''}님을 친구 목록에\n다시 추가할까요?  ';
      sub = '이 친구를 투표 선택지에서 다시 볼 수 있어요!';
      buttonTitle = '추가하기';
      buttonColor = kColor.blue100;
    } else {  // 추가된 친구 -> 삭제 리스트 등록
      isUnfollowing = true;
      header = '${user.name ?? ''}님을 삭제할까요?';
      sub = '친구 목록에서 삭제할 경우, 투표 선택지에서 볼 수 없어요.';
      buttonTitle = '삭제하기';
      buttonColor = kColor.red100;
    }

    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: header,
          sub: sub,
          listTitle: [buttonTitle, '취소'],
          // index: 0,1
          listColor: [
            buttonColor,
            Colors.black
          ],
          listIcon: const [null, null],
        ),
        340 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // 삭제 / 추가 하기
        _updateState(user, isUnfollowing);
      }
    }
  }

  void _clearSearchResult() {
    hasSearchDone = false;
    searchResult = [];
  }

  void _onChange(String value) {
    if (value.isNotEmpty && value.checkKoreanWordValidate()) {
      _clearSearchResult();
      _getSearch();
    } else {
      hasSearchDone = true;
      _streamController.add([]);
    }
  }

  void _onComplete() {
    _nodeSearch.unfocus();
    isTextInputEnabled = false;
    if (_textController.text.isEmpty) _streamController.add(buffer); // 초기 전체 리스트 buffer 에서 불러오기
    if (mounted) setState(() {});
  }

  void _onEndScroll(ScrollMetrics metrics) {
    print('---> on scroll end | after cursor: ${paging.afterCursor}');
    if (metrics.pixels == metrics.maxScrollExtent) {
      if (paging.afterCursor != null) _getSearch();
    }
  }

  // void _cupertinoModal4userProfile(User user) async {
  //   print('---> following friends > cupertino modal > userId: ${user.id}');
  //   if (user.id?.isNotEmpty == true) {
  //     final res = await modalCupertino(
  //         context,
  //         const ModalUserProfile(userId: null),
  //         false
  //     );
  //     if (res != null && res) {
  //       // todo
  //     }
  //   }
  // }

  void _showError(String? message) => customSnackbar(context, '🤗',
      message ?? '일시적인 네트워크 장애가 발생했어요!', ToastPosition.top);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _requestUnFocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: kStyle.appBar(context, '내가 추가한 친구 ${widget.followingCount != null ? '(${widget.followingCount})' : ''}'),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    String title = '내 친구 리스트는 다른 친구들에게 공개되지 않아요.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 16, top: 12),
          child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))),
        ),
        _inputSearch(),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
              child: _streamBuilder(),
            )
        ),
      ],
    );
  }

  Widget _inputSearch() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: TextFormField(
          controller: _textController,
          focusNode: _nodeSearch,
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          style: kTextStyle.bodyMedium18,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: kColor.grey30,
              hintText: '이름으로 찾기',
              hintStyle: kTextStyle.hint,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.only(right: 10, bottom: 5),
              prefixIcon: const Icon(Icons.search, size: 30),
              prefixIconColor: _nodeSearch.hasFocus ? Colors.black : kColor.grey100
          ),
          onChanged: (value) => _onChange(value),
          onFieldSubmitted: (_) => _onComplete(),
          onTap: () => setState(() => isTextInputEnabled = true)
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
                      ? CommonWidget.emptyCase(context, '🏖', '친구를 찾지 못했어요...\n검색어를 다시 한 번 확인해주세요!', isAlignCenter: false)
                      : CustomSkeleton.searchingUsers(context);
                }
              } else {
                return const SizedBox.shrink();
              }
          }
        });
  }

  Widget _buildItems(List<dynamic> friends) {
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
          itemCount: friends.length,
          itemBuilder: (BuildContext context, int index) {
            return _item(friends[index]);
          }
      ),
    );
  }

  Widget _item(User user) {
    bool hasChecked = false;
    if (unfollowingList.contains(user.id)) hasChecked = true;

    return ListTile(
      onTap: () {
        String? userId = user.id;
        if (userId?.isNotEmpty == true) {
          showCupertinoModal4userProfile(context, userId!);
        }
      },
      leading: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 40),
      title: Text(user.name ?? '(', style: kTextStyle.callOutBold16),
      subtitle: Text(user.clueWithoutDot ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
      trailing: CustomButtonSmall(
        titleNorm: '친구', titleOn: '삭제됨',
        colorNorm: Colors.black, colorOn: kColor.red100,
        backgroundNorm: kColor.grey30,
        width: hasChecked ? 83 : 71,
        iconNorm: SvgPicture.asset(kIcon.addFried, height: 18, width: 18),
        iconOn: Icon(CupertinoIcons.xmark, color: kColor.red100, size: 18),
        isToggleOn: hasChecked,
        onClick: () => _modal2followUnfollow(user),
      ),
      contentPadding: const EdgeInsets.all(0),
    );
  }
}
