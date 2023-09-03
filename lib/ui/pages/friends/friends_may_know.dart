import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';

import '../../common_widget/common_widget.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/custom_skeleton.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/dialog_popup.dart';
import '../../../controller/state_controller.dart';
import '../../../services/extensions.dart';
import '../../../model/user.dart';
import '../../../model/session.dart';
import '../../../rest_api/relationship_api.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';

class FriendsMayKnow extends StatefulWidget {
  const FriendsMayKnow({Key? key}) : super(key: key);

  @override
  State<FriendsMayKnow> createState() => _FriendsMayKnowState();
}

class _FriendsMayKnowState extends State<FriendsMayKnow> {
  final GlobalKey<AnimatedListState> _animatedKey = GlobalKey<AnimatedListState>();
  final TextEditingController _textController = TextEditingController();
  late StreamController<dynamic> _streamController;
  Paging paging = Paging();
  List<String> followList = [];   // 추가된 친구 id 저장
  /// search control
  List<User> searchResult = [];
  List<User> buffer = [];   // 초기 검색 결과 임시 보관
  final FocusNode _nodeSearch = FocusNode();
  bool hasSearchDone = false;
  bool hasInitDone = false;
  bool isTextInputEnabled = false;
  bool isEndOfList = false;   // true -> 리스트 마지막

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nodeSearch.requestFocus();
      setState(() {});
    });
  }

  void _getSearch() async {
    List<User> users = [];
    List<User> all = searchResult ?? [];
    String name = _textController.text;
    print('---> get search > name: $name | paging after: ${paging.afterCursor} ');

    HttpsResponse res = await RelationshipApi.getFollowCommon(name: name, paging: paging);
    hasSearchDone = true;   // 검색 완료 -> 로딩 끄기

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          users.add(User.fromJson(e));
        }
        /// paging update
        paging.afterCursor = res.body['afterCursor'];

        all += users;
        searchResult = all;
      }
      if (!_streamController.isClosed) _streamController.add(searchResult);

    } else {  // 에러 처리
      ErrorResponse error = res.body;
      _showError(error.message);
    }
    // 최초 데이터 buffer 에 저장 -> 검색어 비어 있을 때 API call 하지 않고 전체 리스트 불러오기
    if (!hasInitDone) {
      buffer = users;
      hasInitDone = true;
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
    if (searchResult.isNotEmpty == true) {
      bool res = await _callApi4hide(user);
      res = true;   // todo > test
      if (res) {  // api call 성공시 -> 숨기기
        final newItem = searchResult.removeAt(index);
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

  void _clearSearchResult() {
    hasSearchDone = false;
    searchResult = [];
    paging.reset();
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
    if (metrics.pixels == metrics.maxScrollExtent - 100) {
      if (paging.afterCursor?.isNotEmpty == true) _getSearch();
    }
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: kStyle.appBar(context, '알 수도 있는 친구들'),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _inputSearch(),
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
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
              return const SizedBox.shrink();
            default:
              if (snapshot.hasData) {
                List<dynamic> data = snapshot.data;
                if (data.isNotEmpty) {
                  return _buildItems(data);

                } else {  // 리스트가 비어 있는 경우
                  return hasSearchDone
                      ? CommonWidget.emptyCase(context, '🏖', '친구를 찾지 못했어요...\n검색어를 다시 한 번 확인해주세요!', isAlignCenter: false)
                      : Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: CustomSkeleton.searchingUsers(context),
                        );
                }
              } else {
                return const SizedBox.shrink();
              }
          }
        });
  }

  Widget _buildItems(List<dynamic> users) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            _onEndScroll(notification.metrics);
          }
          return false;
        },
        child: ListView(
          children: [
           _animatedList(users),

            // if (!isItemEmpty && isEndOfList) _endOfList()   // 아이템이 비어 있지 않고 리스트 마지막 일 경우
          ],
        ),
      ),
    );
  }

  Widget _animatedList(List<dynamic> users) {
    return AnimatedList(
        key: _animatedKey,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        initialItemCount: users.length,
        itemBuilder: (context, index, animation) {
          return _buildAnimation(users[index], index, animation);
        }
    );
  }

  Widget _buildAnimation(item, index, animation) {
    return SizeTransition(
        sizeFactor: animation,
        axis: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: _slidableItem(item, index),
        ));
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
    String sub = '함께 아는 친구 ${user.commonFollowingCount ?? '-'}명';
    bool hasFollowed = followList.contains(user.id);

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      leading: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 40),
      title: Text(user.name ?? '(', style: kTextStyle.callOutBold16),
      subtitle: Text(sub, style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
      trailing: CustomButtonSmall(
        titleNorm: '친구 추가', titleOn: '추가됨',
        colorNorm: Colors.white, colorOn: Colors.black,
        backgroundNorm: kColor.blue100,
        width: hasFollowed ? 83 : 76,
        iconOn: SvgPicture.asset(kIcon.addFried, height: 18, width: 18),
        isToggleOn: hasFollowed,
        onClick: () => _updateFollow(user),
      ),
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
    );
  }
}
