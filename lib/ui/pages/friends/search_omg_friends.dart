import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import '../../../model/session.dart';
import '../../../services/extensions.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/divider.dart';

import '../../../controller/state_controller.dart';
import '../../../model/user.dart';
import '../../../rest_api/relationship_api.dart';
import '../../../rest_api/user_api.dart';
import '../../../services/service_contacts.dart';
import '../../../resource/images.dart';
import '../../../resource/style.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../../services/local_storage.dart';
import '../../../resource/kConstant.dart';
import '../components/bottom_modal_contents_buttons.dart';

class SearchOmgFriends extends StatefulWidget {
  const SearchOmgFriends({Key? key}) : super(key: key);

  @override
  State<SearchOmgFriends> createState() => _SearchOmgFriendsState();
}

class _SearchOmgFriendsState extends State<SearchOmgFriends> {
  final TextEditingController _textController = TextEditingController();
  late StreamController<dynamic> _streamController;
  Paging paging = Paging();
  List<String> followList = [];   // 추가된 친구 id 저장
  /// search history
  List<User> searchHistory = [];  // 검색 기록 데이터
  bool hasHistoryRecord = false;  // true -> 검색 기록 존재 -> 검색 기록 보여주기
  /// search control
  List<User> searchResult = [];
  final FocusNode _nodeSearch = FocusNode();
  bool hasSearchButtonPressed = false;
  bool isReset = false;
  bool isMoreThan2Character = false;
  bool isTextInputEnabled = false;
  bool isEndOfList = false;   // true -> 리스트 마지막
  bool isItemEmpty = false;   // true -> 리스트 비어 있음

  @override
  void initState() {
    print('---> search omg friends >init');
    super.initState();
    _streamController = StreamController<dynamic>();
    _requestFocus();
    // _getSearchHistory();
    _getSearchHistory();
  }

  @override
  void dispose() {
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nodeSearch.requestFocus();_streamController.onPause;
      setState(() {});
    });
  }

  void _getSearchHistory() async {
    final res = await LocalStorageService.getStringList(kStorageKey.searchHistory);
    print('--->get search history > res: $res');
    List<User> users = [];
    if (res.isNotEmpty) {
      for (var e in res) {
        Map<String, dynamic> data = jsonDecode(e);
        users.add(User.fromJson(data));
      }
      hasHistoryRecord = true;  // 검색 기록 존재
    }
    searchHistory = users;
    _streamController.add(searchHistory);
    if (mounted) setState(() {});
  }

  void _updateSearchHistory(List<User> users) async {
    print('---> update history > users: len ${users.length}');
    List<String> dataset = [];
    if (users.isNotEmpty) {
      for (var e in users) {
        String encoded = jsonEncode(e.toSearchHistory());
        dataset.add(encoded);
      }
    }
    if (dataset.isNotEmpty) {
      LocalStorageService.insertStringList(kStorageKey.searchHistory, dataset);
    }
  }

  void _getSearch() async {
    String query = _textController.text;
    List<User> users = [];
    isReset = false;

    HttpsResponse res = await UserApi.getUser(includedNameOrNickname: query, paging: paging);
    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          users.add(User.fromJson(e));
        }
      }
      /// paging update
      if (res.body['cursor'] != null) {
        paging = Paging.fromJson(res.body['cursor']);
      }
      if (paging.afterCursor == null) setState(() => isEndOfList = true); // 리스트 마지막 표시

      searchResult += users;
      /// save to local storage as search history -> 검색 버튼을 누른 결과만 저장
      _updateSearchHistory(searchResult);

      if (!_streamController.isClosed) _streamController.add(searchResult);
    } else {  // 에러 처리
      ErrorResponse error = res.body;
      _showError(error.message);
    }
    /// 리스트가 비어 있는지 확인
    if (searchResult.isNotEmpty == true) {
      isItemEmpty = false;  // 리스트 있음
    } else {
      isItemEmpty = true;   // 리스트 비어 있음
    }
    if (mounted) setState(() {});
  }

  void _clearSearchResult() {
    isReset = true;
    hasSearchButtonPressed = false;
    hasHistoryRecord = false;
   searchResult.clear();
    _streamController.add(searchResult);
    if(mounted) setState(() {});
  }

  void _onChange(String value) {
    _clearSearchResult();

    if (value.length >= 2 && value.checkKoreanWordValidate()) {
      _getSearch();
    } else {
      _streamController.add([]);
    }
    if (mounted) setState(() {});
  }

  void _onComplete() {
    _nodeSearch.unfocus();
    isTextInputEnabled = false;
    isReset = false;
    hasSearchButtonPressed = true;
    if (mounted) setState(() {});
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

  Future<void> _requestFollow(User user) async {
    if (user.id?.isNotEmpty == true) {
      if (!followList.contains(user.id!)) {   // 이미 추가된 친구 ID가 아닌 경우만 동작
        final res = await _callApi4follow(user.id!);
        if (res) _updateFollow(user.id!);
      }
    }
  }

  void _updateFollow(String id) {
    followList.add(id);
    if (mounted) setState(() {});
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels == metrics.maxScrollExtent - 100) {
      _getSearch();
    }
  }

  void _onClickFromHistory() {  // 검색 기록 모두 지우기
    searchHistory.clear();
    hasHistoryRecord = false;
    _requestFocus();
    if (mounted) setState(() {});
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _header(),
        // if (hasHistoryRecord)
        //   Expanded(
        //       child: _SearchHistory(users: searchHistory, onClick: _onClickFromHistory)
        //   )
        // else
          Expanded(child: _streamBuilder()),
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 16, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.transparent,
                  alignment: Alignment.centerLeft,
                  child: const Icon(CupertinoIcons.back, size: 30)
              )
          ),
          _inputSearch(),
        ],
      ),
    );
  }

  Widget _inputSearch() {
    return Expanded(
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
            hintText: '이름 또는 닉네임으로 찾기',
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
        onTapOutside: (_) => _onComplete(),
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
                  if (hasHistoryRecord) { // 검색 기록이 있는 경우
                    return _SearchHistory(users: data, onClick: _onClickFromHistory);
                  } else {  // 검색 기록이 없는 경우
                    return _buildItems(data);
                  }
                } else {  // 리스트가 비어 있는 경우
                  return isReset
                      ? const SizedBox.shrink()
                      : !isTextInputEnabled && hasSearchButtonPressed
                          ? _emptyCase()
                          : const SizedBox.shrink();
                }
              } else {
                return _emptyCase();
              }
          }
        });
  }

  Widget _buildItems(List<dynamic> friends) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            _onEndScroll(notification.metrics);
          }
          return false;
        },
        child: ListView(
          children: [
            ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (BuildContext context, int index) {
                  return _item(friends[index]);
                }
            ),

            // if (!isItemEmpty && isEndOfList) _endOfList()   // 아이템이 비어 있지 않고 리스트 마지막 일 경우
          ],
        ),
      ),
    );
  }

  Widget _item(User user) {
    bool hasFollowed = false;
    if (followList.contains(user.id)) hasFollowed = true;

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(user.name ?? ' ', style: kTextStyle.callOutBold16),
                        const SizedBox(width: 4),
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(user.nickname != null ? '@${user.nickname}' : ' ', style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey300))),

                      ],
                    ),
                    const SizedBox(width: 4),
                    Text(user.clueWithoutDot ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (user.id?.isNotEmpty == true) _requestFollow(user);
            },
            child: Container(  // 친구 추가 버튼
              width: 76,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: hasFollowed ? kColor.grey30 : kColor.blue100,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: hasFollowed
                  ? Row(  // 친구 추가
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

  Widget _endOfList() {
    return Container(
        padding: const EdgeInsets.only(top: 30, bottom: 60),
        alignment: Alignment.center,
        child: Text('모두 확인했어요!', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey500))
    );
  }

  Widget _emptyCase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(child:Text('🏖', style: TextStyle(fontSize: 48))),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text('친구를 찾지 못했어요...\n검색어를 다시 한 번 확인해주세요!', textAlign: TextAlign.center,
              style: kTextStyle.headlineExtraBold18.copyWith(height: 1.3)),
        ),
      ],
    );
  }
}


class _SearchHistory extends StatefulWidget {
  const _SearchHistory({Key? key,
    required this.users,
    required this.onClick
  }) : super(key: key);

  final List<dynamic> users;
  final VoidCallback onClick;

  @override
  State<_SearchHistory> createState() => _SearchHistoryState();
}

class _SearchHistoryState extends State<_SearchHistory> {
  final GlobalKey<AnimatedListState> _animatedKey = GlobalKey<AnimatedListState>();
  List<dynamic> userSearchHistory = [];

  @override
  void initState() {
    super.initState();
    userSearchHistory = widget.users;
  }

  void _removeItem(User user, int index) async {
    _removeHistoryAt(user);
    if (userSearchHistory.isNotEmpty == true) {
      final newItem = userSearchHistory.removeAt(index);
      _animatedKey.currentState?.removeItem(index, (context, animation) =>
          _buildAnimation(newItem, index, animation), duration: const Duration(milliseconds: 100));
    }
  }

  void _removeHistoryAt(User user) {
    String? url;  // todo > temp
    if (user.profileImageKey != null) {
      url = user.profileImageKey!.replaceFirst('${kConst.bucket}/', '');
    }
    user.profileImageKey = url;
    String encoded = jsonEncode(user.toSearchHistory());
    LocalStorageService.removeValueFromStringList(kStorageKey.searchHistory, encoded);
  }

  void _removeAllHistory() {
    LocalStorageService.deleteAllStringList(kStorageKey.searchHistory);
    userSearchHistory.clear();
    widget.onClick();
  }

  void _modal2removeAll() async {
    final res = await showCustomBottomSheet(
        context,
        ModalContentsButtons(
          header: '검색 기록을 모두 지우시겠어요?',
          sub: null,
          listTitle: const ['모두 지우기', '취소'],
          // index: 0,1
          listColor: [
            kColor.red100,
            Colors.black
          ],
          listIcon: const [null, null],
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) { // 모두 지우기
       _removeAllHistory();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Column(
      children: [
        _header(),
        Expanded(child: _animatedList())
      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('최근 검색', style: kTextStyle.title3ExtraBold20),
              GestureDetector(
                onTap: () => _modal2removeAll(),
                child: Container(
                    height: 36,
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text('모두 지우기', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.blue100))),
              )
            ],
          ),
          const DividerHorizontal(paddingTop: 20, paddingBottom: 1),
        ],
      ),
    );
  }

  Widget _animatedList() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AnimatedList(
          key: _animatedKey,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          initialItemCount: userSearchHistory.length,
          itemBuilder: (context, index, animation) {
            return _buildAnimation(userSearchHistory[index], index, animation);
          }
      ),
    );
  }

  Widget _buildAnimation(item, index, animation) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: _item(item, index)),
    );
  }

  Widget _item(User user, int index) {
    String? url;
    if (user.profileImageKey != null) {
      url = user.profileImageKey!.replaceFirst('${kConst.bucket}/', '');
    }
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                url?.isNotEmpty == true
                    ? CustomCacheNetworkImage(imageUrl: url, gender: user.gender, size: 40)
                    : Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kColor.grey30
                        ),
                        child: Icon(CupertinoIcons.search, color: kColor.grey500, size: 30)
                      ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(user.name ?? ' ', style: kTextStyle.callOutBold16),
                        const SizedBox(width: 4),
                        FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(user.nickname != null ? '@${user.nickname}' : ' ',
                                style: kTextStyle.caption1SemiBold12.copyWith(color: kColor.grey300))),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Text(user.clueWithoutDot ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _removeItem(user, index),
            child: Container(  // 친구 추가 버튼
                width: 40,
                height: 40,
                alignment: Alignment.center,
                color: Colors.transparent,
                child: Icon(CupertinoIcons.xmark, size: 26, color: kColor.grey500)
            ),
          )
        ],
      ),
    );
  }
}
