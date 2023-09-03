import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/common_widget.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/custom_skeleton.dart';
import '../../common_widget/dialog_popup.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../controller/state_controller.dart';
import '../../../rest_api/relationship_api.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../services/extensions.dart';

class FriendsFromContact extends StatefulWidget {
  const FriendsFromContact({Key? key}) : super(key: key);

  @override
  State<FriendsFromContact> createState() => _FriendsFromContactState();
}

class _FriendsFromContactState extends State<FriendsFromContact> {
  final TextEditingController _textController = TextEditingController();
  late StreamController<dynamic> _streamController;
  List<String> checkList = [];   // 추가된 친구 id 저장
  int? totalCount;
  /// search control
  final FocusNode _nodeSearch = FocusNode();
  bool hasInitDone = false;
  bool hasSearchDone = false;
  bool isTextInputEnabled = false;
  List<User> searchResult = [];   // 검색 결과
  List<User> buffer = [];   // 초기 검색 결과
  bool isEndOfList = false;   // true -> 리스트 마지막
  bool isItemEmpty = false;   // true -> 리스트 비어 있음

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
    String name = _textController.text;

    HttpsResponse res = await RelationshipApi.getFollowContact(name: name.isNotEmpty ? name : null);
    hasSearchDone = true;   // 검색 완료 -> 로딩 끄기

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          users.add(User.fromJson(e));
        }
        searchResult = users;
      }

      if (!_streamController.isClosed) _streamController.add(searchResult);

    } else {  // 에러 처리
      ErrorResponse error = res.body;
      _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
    }
    // 최초 데이터 buffer 에 저장 -> 검색어 비어 있을 때 API call 하지 않고 전체 리스트 불러오기
    if (!hasInitDone) {
      /// 연락처 친구들 수
      if (res.body['totalCount'] != null) {
        totalCount = res.body['totalCount'];
      }
      buffer = users;
      hasInitDone = true;
    }
    if (mounted) setState(() {});
  }

  Future<bool> _callApi4followBatch() async {
    bool out;
    HttpsResponse res = await RelationshipApi.postFollowBatch(checkList);
    if (res.statusType == StatusType.success) {
      out = true;
    } else if (res.statusType == StatusType.error){
      ErrorResponse error = res.body;
      _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
      out = false;
    } else {
      out = false;
    }
    return out;
  }

  void _requestFollowBatch() async {
    bool res = await _callApi4followBatch();
    if (res) {
      _goBack();
      _showSnackbar('${checkList.length}명의 연락처 친구를 추가했어요!');
    }
  }

  void _updateCheckList(User user, bool isAdd) {
    if (user.userId?.isNotEmpty == true) {
      if (isAdd) {    // 선택
        checkList.add(user.userId!);
      } else {    // 선택 해제
        checkList.remove(user.userId!);
      }
    }
    if (mounted) setState(() {});
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
      _streamController.add([]);
      hasSearchDone = true;
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
      _getSearch();
    }
  }

  void _showSnackbar(String message) {
    customSnackbar(context, '🤗', message, ToastPosition.top);
  }

  void _goBack() => Navigator.pop(context);

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    int selectedCount = checkList.length;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: kStyle.appBar(context, '연락처 친구들 ${totalCount != null ? '($totalCount)' : ''}'),
        bottomSheet:   CustomButtonWide(
          title: '선택한 친구 $selectedCount명 추가하기',
          isAnimationOn: selectedCount > 0 ? true : false,
          onTap: () => _requestFollowBatch()
        ),
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

          // inputFormatters: [
          //   FilteringTextInputFormatter.allow(RegExp(r'[a-z|A-Z|0-9|ㄱ-ㅎ|ㅏ-ㅣ|가-힣|ᆞ|ᆢ]', unicode: true)),
          // ],
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
    String sub = '함께 아는 친구 ${user.commonFollowingCount}명';
    bool hasChecked = false;
    if (checkList.contains(user.userId)) hasChecked = true;
    bool isNewContact = true;    // todo > get from API

    return ListTile(
      leading: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, isNew: isNewContact, size: 40),
      title: Text(user.name ?? '(', style: kTextStyle.callOutBold16),
      subtitle: Text(sub, style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
      trailing: _checkRound(user, hasChecked),
      contentPadding: const EdgeInsets.all(0),
    );
  }

  Widget _checkRound(User user, bool isSelected) {
    return Container(
      width: 100,
      alignment: Alignment.centerRight,
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
            value: isSelected,
            visualDensity: VisualDensity.comfortable,
            shape: const CircleBorder(),
            side: BorderSide(width: 2,
                color: isSelected ? Colors.transparent : kColor.grey100),
            activeColor: kColor.blue100,
            onChanged: (value) {  // 선택 토글
              if (isSelected) {  // true -> 해제
                _updateCheckList(user, false);
              } else {  // false -> 선택
                _updateCheckList(user, true);
              }
            }
        ),
      ),
    );
  }
}
