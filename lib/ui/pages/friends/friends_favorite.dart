import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common_widget/custom_skeleton.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/divider.dart';
import '../../../model/session.dart';
import '../../../rest_api/user_api.dart';
import '../../common_widget/custom_button.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../../controller/state_controller.dart';
import '../../../model/user.dart';
import '../../../rest_api/relationship_api.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../services/extensions.dart';
import '../../common_widget/common_widget.dart';

class FriendsFavorite extends StatefulWidget {
  const FriendsFavorite({Key? key}) : super(key: key);

  @override
  State<FriendsFavorite> createState() => _FriendsFavoriteState();
}

class _FriendsFavoriteState extends State<FriendsFavorite> {
  final TextEditingController _textController = TextEditingController();
  Paging paging = Paging();
  List<String> favoriteList = [];   // 추가된 친구 id 저장
  int? totalFavoriteCount;
  /// search control
  final FocusNode _nodeSearch = FocusNode();
  bool hasInitFetch = false;  // 최초 following 가져온 상태 -> 관심 친구 없는 경우 empty case 보여주기 위해서
  bool hasSearchDone4favorite = false;
  bool hasSearchDone4following = false;
  bool isTextInputEnabled = false;
  // Future<dynamic>? searchFavorite;   // 관심 친구 검색 결과
  // Future<dynamic>? searchFollowing;   // 내 친구들 검색 결과

  List<User>? searchFavorite;   // 관심 친구 검색 결과
  List<User>? searchFollowing;   // 내 친구들 검색 결과

  bool isEndOfList = false;   // true -> 리스트 마지막
  bool isItemEmpty = false;   // true -> 리스트 비어 있음
  bool isLoadingOn = false;   // true -> bottom button 에 로딩 표시

  @override
  void initState() {
    super.initState();
    _requestFocus();
    hasInitFetch = true;
    _getFollowing(true);   // 관심 친구 가져오기
    _getFollowing(false);  // 내 친구들 가져오기
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nodeSearch.requestFocus();
      setState(() {});
    });
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

    // HttpsResponse res = await RelationshipApi.getFollowContact(false, name.isNotEmpty ? name : null);
    HttpsResponse res = await UserApi.getUser(includedNameOrNickname: name, paging: paging);

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      // hasSearchDone = true;   // 검색 완료
      if (res.body['data']?.isNotEmpty == true) {
        for (var e in res.body['data']) {
          users.add(User.fromJson(e));
        }

        /// 연락처 친구들 수
        if (res.body['totalCount'] != null) {
          totalFavoriteCount = res.body['totalCount'];
        }

        /// paging update
        if (res.body['cursor'] != null) {
          paging = Paging.fromJson(res.body['cursor']);
          if (paging.afterCursor == null) setState(() => isEndOfList = true); // 리스트 마지막 표시
        }
      }

    } else {  // 에러 처리
      ErrorResponse error = res.body;
      _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
    }
    if (mounted) setState(() {});
  }

  Future _getFollowing(bool isFavorite) async {
    List<User> users = [];

    HttpsResponse res = await RelationshipApi.getFollowing(isFavorite: isFavorite);

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      if (res.body.isNotEmpty == true) {
        for (var e in res.body) {
          users.add(User.fromJson(e));
        }
        /// 관심 친구 수
        if (isFavorite) {
          totalFavoriteCount = users.length;
        }
      }
      if (isFavorite) {   // 관심 친구
        hasSearchDone4favorite = true;  // 관심 친구 검색 완료 -> skeleton on/off 을 위해서
        searchFavorite = users;
        /// 관심 친구 id 저장 -> checkbox 표시
        for (var e in users) {
          if (e.id?.isNotEmpty == true) favoriteList.add(e.id!);
        }
      } else {  // 내 친구들
        hasSearchDone4following = true;  // 내 친구들 검색 완료 -> skeleton on/off 을 위해서
        searchFollowing = users;
      }

    } else {  // 에러 처리
      ErrorResponse error = res.body;
      _showError(error.message ?? '일시적인 네트워크 장애가 발생했어요!');
    }
    if (mounted) setState(() {});
  }

  Future<bool> _callApi4favorite(User user) async {
    bool out;
    if (user.id!.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postFavorite(user.id!);
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

  Future<bool> _callApi4unFavorite(User user) async {
    bool out;
    if (user.id?.isNotEmpty == true) {
      HttpsResponse res = await RelationshipApi.postUnFavorite(user.id!);
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

  void _updateCheckList(User user, bool isAdd) async {
    if (user.id?.isNotEmpty == true) {
      isLoadingOn = true; // true -> 로딩 켜기
      if (isAdd) {  // 선택
        favoriteList.add(user.id!);
      } else {  // 선택 해제
        favoriteList.remove(user.id!);
      }
      if (mounted) setState(() {});
    }
    await Future.delayed(const Duration(milliseconds: 500));

    /// call API for follow and unfollow
    if (isAdd) {  // follow
      bool res = await _callApi4favorite(user);
      if (!res) favoriteList.remove(user.id!);
    } else {  // unfollow
      bool res = await _callApi4unFavorite(user);
      if (!res) favoriteList.add(user.id!);
    }
    isLoadingOn = false;  // false => 로딩 끄기
    if (mounted) setState(() {});
  }

  void _clearSearchResult() {
    hasInitFetch = false;
    hasSearchDone4favorite = false;
    hasSearchDone4following = false;
    searchFollowing = null;
    searchFavorite = null;
    paging.reset();
  }

  void _onChange(String value) {
    _clearSearchResult();
    if (value.isNotEmpty && value.checkKoreanWordValidate()) {
      _getFollowing(false);
      _getFollowing(true);
    } else {
      hasSearchDone4favorite = true;    // 관심 친구 검색 완료 -> skeleton on/off 을 위해서
      hasSearchDone4following = true;   // 내 친구들 검색 완료 -> skeleton on/off 을 위해서
    }
    if (mounted) setState(() {});
  }

  void _onComplete() {
    _nodeSearch.unfocus();
    isTextInputEnabled = false;
    hasSearchDone4favorite = false;
    if (mounted) setState(() {});
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels == metrics.maxScrollExtent - 100) {
      _getSearch();
    }
  }

  void _goBack() => Navigator.pop(context);

  void _showError(String? message) => customSnackbar(context, '🤗',
      message ?? '일시적인 네트워크 장애가 발생했어요!', ToastPosition.top);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _requestUnFocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: kStyle.appBar(context, '관심 친구 ${totalFavoriteCount != null ? '($totalFavoriteCount)' : ''}'),
        bottomSheet: CustomButtonWide(
          title: isLoadingOn ? '' : '확인',
          isLoadingOn: isLoadingOn,
          onTap: () => _goBack(),
        ),
        body: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _inputSearch(),
        Expanded(child: _listviewCombiner()),
      ],
    );
  }

  Widget _inputSearch() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
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
          onFieldSubmitted: (_) => setState(() {}),
          onTap: () => setState(() => isTextInputEnabled = true)
      ),
    );
  }

  Widget _listviewCombiner() {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      children: [
        if (hasInitFetch)   // 초기 데이터 가져오기 (관심 친구)
          if (searchFavorite?.isNotEmpty == true)   // 데이터 있음
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: _listviewBuilder(searchFavorite!)
            )
          else if (searchFavorite?.isEmpty == true)  // 데이터 없음
            CommonWidget.emptyCase(context, '🌟',
                '관심있는 친구를 아래에서 추가해 보세요!', isAlignCenter: false)
          else
            _loadingSkeleton()
        else  // 데이터 검색
          if (searchFavorite?.isNotEmpty == true)   // 데이터 있음
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: _listviewBuilder(searchFavorite!)
            )
          else if (searchFavorite?.isEmpty == true)  // 데이터 없음
            const SizedBox.shrink()
          else
            _loadingSkeleton(),

        if (searchFollowing?.isNotEmpty == true)   // 데이터 있음
          _following(),

        if (hasInitFetch)   // 초기 데이터 가져오기 (내 친구들)
          if (searchFollowing?.isNotEmpty == true)   // 데이터 있음
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: _listviewBuilder(searchFollowing!)
            )
          else if (searchFollowing?.isEmpty == true)  // 데이터 없음 (empty case)
            const SizedBox.shrink()
          else
            _loadingSkeleton()
        else  // 데이터 검색
          if (searchFollowing?.isNotEmpty == true)   // 데이터 있음
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: _listviewBuilder(searchFollowing!)
            )
          else if (searchFollowing?.isEmpty == true)  // 데이터 없음 (empty case)
            const SizedBox.shrink()
          else
            _loadingSkeleton(),

        if (hasSearchDone4favorite && hasSearchDone4following &&
            searchFavorite?.isEmpty == true && searchFollowing?.isEmpty == true)
          CommonWidget.emptyCase(context, '🏖',
              '친구를 찾지 못했어요...\n검색어를 다시 한 번 확인해주세요!', isAlignCenter: true)
      ],
    );
  }

  Widget _following() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DividerHorizontal(paddingTop: 16, paddingBottom: 12),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text('내 친구들', style: kTextStyle.headlineExtraBold18),
        ),
      ],
    );
  }

  Widget _listviewBuilder(List<dynamic> users) {
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
      bool hasChecked = false;
      if (favoriteList.contains(user.id)) hasChecked = true;

    return ListTile(
      leading: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: 40),
      title: Text(user.name ?? '(', style: kTextStyle.callOutBold16),
      subtitle: Text(user.clueWithoutDot ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
      trailing: _roundCheck(user, hasChecked),
      contentPadding: const EdgeInsets.all(0),
    );
  }

  Widget _roundCheck(User user, bool isSelected) {
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

  Widget _loadingSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: CustomSkeleton.searchingShort(context),
    );
  }
}
