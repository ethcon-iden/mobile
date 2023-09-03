import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';

import '../../../resource/kConstant.dart';
import '../../../rest_api/poll_api.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../rest_api/user_api.dart';
import '../../../resource/style.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/images.dart';
import '../child/invite_none_omg_user.dart';

class Modal4searchFriendSameSchool extends StatefulWidget {
  const Modal4searchFriendSameSchool({Key? key}) : super(key: key);

  @override
  State<Modal4searchFriendSameSchool> createState() => _Modal4searchFriendSameSchoolState();
}

class _Modal4searchFriendSameSchoolState extends State<Modal4searchFriendSameSchool> {
  late StreamController<dynamic> _streamController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _node = FocusNode();
  Paging paging = Paging();
  Paging paging4searchQuery = Paging();
  int? schoolId;

  List<User> allSearchResult = <User>[];
  List<User> tempStore4result = <User>[];
  List<String> invitedList = <String>[];  // 초대한 친구 연락처 저장 -> 초대한 친구는 '초대함' 표기
  bool isReset = false;
  bool hasTextFieldInput = false;
  bool isTextInputEnabled = false;
  bool? hasSmsSent;
  bool isEndOfList = false;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    schoolId = service.userMe.value.school?.id;
    _getSearch();
    _node.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  Future<void> _getSearch() async {
    String query = _textController.text;

    if (schoolId != null) {
      final HttpsResponse res = await UserApi.getUser(schoolId: schoolId, includedNameOrNickname: query, paging: paging);

      List<User> users = [];
      if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
        if (res.body['data']?.isNotEmpty) {
          for (var e in res.body['data']) {
            users.add(User.fromJson(e));
          }
          if (res.body['cursor'] != null) {
            paging = Paging.fromJson(res.body['cursor']);
            if (paging.afterCursor == null) setState(() => isEndOfList = true);
          }
        }

        if (users.isNotEmpty) {
          List<User> prevResult = allSearchResult;
          prevResult += users;
          allSearchResult = prevResult;
        } else {
          allSearchResult = users;
        }
        _streamController.add(users);
        if (!_streamController.isClosed) _streamController.add(users);
        if (mounted) setState(() {});

      } else {
        ErrorResponse error = res.body;
        _showErrorMessage(error.message);
      }
    }
  }

  // Future<void> _getSearch() async {   // 같은 학교 친구 검색
  //   if (schoolId != null) {
  //     final HttpsResponse res = await UserApi.getUser(schoolId: schoolId);
  //
  //     List<User> users = [];
  //     if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
  //       if (res.body['data'].isNotEmpty) {
  //         for (var e in res.body['data']) {
  //           users.add(User.fromJson(e));
  //         }
  //       }
  //       allSearchResult = users;
  //       tempStore4result = users; // 임시 보관 -> 검색 초기화 -> 다시 불러오기
  //       paging4allFollows = Paging.fromJson(res.body['cursor']); // 페이지 나누어서 검색 -> 다음 검색 색인
  //       _streamController.add(users);
  //     } else {
  //       ErrorResponse error = res.body;
  //       _showErrorMessage(error.message);
  //     }
  //   } else {
  //     print('---> no school id');
  //   }
  // }

  // Future<void> _getSearchResult() async {
  //   String query = _textController.text;
  //   isReset = false;
  //
  //   if (schoolId != null) {
  //     final HttpsResponse res = await UserApi.getFriendsSameSchool(schoolId!, query, null);
  //
  //     List<User> friends = [];
  //     if (res.body != null) {
  //       if (res.statusType == StatusType.success) {
  //         if (res.body['data'].isNotEmpty) {
  //           for (var e in res.body['data']) {
  //             friends.add(User.fromJson(e));
  //           }
  //         }
  //         allSearchResult = friends;
  //         paging4searchQuery = Paging.fromJson(res.body['cursor']);
  //         _streamController.add(friends);
  //       } else {
  //         print('---> _getSearchResult > no data');
  //       }
  //     } else {
  //       print('---> HttpsResponse > response is empty');
  //     }
  //   } else {
  //     print('---> no school id');
  //   }
  // }

  // Future<void> _getSearchMore() async {
  //   String query = _textController.text;
  //   isReset = false;
  //
  //   if (schoolId != null) {
  //     if (paging4searchQuery.afterCursor != null) {
  //       HttpsResponse res = await UserApi.getFriendsSameSchool(
  //           schoolId!, query, paging4searchQuery);
  //
  //       List<User> friends = [];
  //       if (res.body != null) {
  //         if (res.statusType == StatusType.success) {
  //           if (res.body['data'].isNotEmpty) {
  //             for (var e in res.body['data']) {
  //               friends.add(User.fromJson(e));
  //             }
  //           }
  //           allSearchResult += friends;
  //           paging4searchQuery = Paging.fromJson(res.body['cursor']);
  //           _streamController.add(allSearchResult);
  //         }
  //       }
  //     }
  //   }
  // }

  void _clearSearchResult() {
    isReset = true;
    hasTextFieldInput = false;
    paging.reset();
    allSearchResult = tempStore4result;   // 검색 꺼지고 -> 기존 리스트 가져오기
    _streamController.add(tempStore4result);
  }

  void _onChange(String value) {
    _clearSearchResult();

    if (value.isNotEmpty) {
      _getSearch();
    } else {
      _streamController.add([]);
    }
    if (mounted) setState(() {});
  }

  void _onComplete() {
    _node.unfocus();
    if (_textController.text.isNotEmpty) {
      hasTextFieldInput = true;
    } else {
     _clearSearchResult();
    }
    isTextInputEnabled = false;
    setState(() {});
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels == metrics.maxScrollExtent - 100) {
      _getSearch();
    }
  }

  void _voteForThisFriend(User user) async {
    String? userId = user.id;
    int? pollId;
    if (service.pollOpen.value.polls?.isNotEmpty ?? false) {
      pollId = service.pollOpen.value.polls?.first.id;
    }
    if (userId != null && pollId != null) {
      final HttpsResponse  res = await PollApi.postPollAnswer(pollId, userId);
      print('---> status: ${res.statusType}');
      if (res.statusType == StatusType.success) {
        _pageBack(user);
      } else {
        _handleError();
      }
    }
  }

  void _showErrorMessage(String? message) => showErrorMessage(context, message);

  void _inviteNoneOmgUser() => modalCupertino(context, const InviteNoneOmgUser(), false);

  void _handleError() {
    showDialog4Action(context,
        '🤕‍',
        '앗! 무언가 잘못되었어요...',
        '현재 OMG 서버에 연결할 수 없어요. 일시적인 장애이거나 네트워크 문제일 수 있으니 잠시 후 다시 시도해주세요!'
    );
  }

  void _pageBack(User user) =>  Navigator.pop(context, user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SafeArea(child: _body()),
      ),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        _title(),
        _searchByNameNickname(),
        Expanded(child: _itemList())
      ],
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('우리 학교 친구들', style: kTextStyle.largeTitle28),
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 26))
      ],
    );
  }

  Widget _searchByNameNickname() {
    return Container(
      height: 52,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24, bottom: 5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: kColor.grey30,
          borderRadius: BorderRadius.circular(16)
      ),
      child: TextFormField(
        controller: _textController,
        focusNode: _node,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.search,
        style: kTextStyle.bodyMedium18,
        autocorrect: false,
        decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: '이름 또는 닉네임으로 찾기',
            hintStyle: kTextStyle.bodyMedium18.copyWith(color: kColor.grey100),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kColor.grey30, width: 2)
            ),
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.only(left: 12, right: 12),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 10),
              child: Icon(CupertinoIcons.search, size: 24),
            ),
            prefixIconConstraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
            prefixIconColor: isTextInputEnabled ? Colors.black : kColor.grey100
        ),
        onChanged: (value) => _onChange(value),
        onTapOutside: (_) => _onComplete(),
        onFieldSubmitted: (_) => _onComplete(),
        onTap: () => setState(() {
          isTextInputEnabled = true;
        }),
      ),
    );
  }

  void _onStartScroll(ScrollMetrics metrics) {
    // print('---> scroll start');
  }
  void _onUpdateScroll(ScrollMetrics metrics) {
    // print('---> scroll update');
  }

  Widget _itemList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // when start to scroll by touching the screen
        if (notification is ScrollStartNotification) {
          _onStartScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> android
        } else if (notification is OverscrollNotification) {
          _onUpdateScroll(notification.metrics);
          // while touching the screen by scrolling up and down -> ios
        } else if (notification is ScrollUpdateNotification) {
          _onUpdateScroll(notification.metrics);
          // when off the touch from screen (end of scroll)
        } else if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            _streamBuilder(),
            _noFound4Friend(),
            const SizedBox(height: 60)
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
              return Container();
            case ConnectionState.waiting:
              return Container();
            default:
              if (snapshot.hasError) {
                return Container();
              } else if (snapshot.hasData) {
                List<User> friends = snapshot.data;
                if (friends.isNotEmpty) {
                  return _itemBuilder(friends);
                } else {
                  return const SizedBox.shrink();
                }
              } else {
                print('---> snapshot no data: ${snapshot.data}');
                return Container();
              }
          }
        }
    );
  }

  Widget _itemBuilder(List<User> lists) {
    List<User> contacts = [];
    if (lists.isNotEmpty) {
      contacts = lists;
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: contacts.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (BuildContext context, int index) {
        // return _item(index, friends[index]);
        return Theme(
          data: ThemeData(
            splashColor: Colors.transparent   // disable splash effect
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 0, right: 0),
            visualDensity: VisualDensity.standard,
            leading: _profileImage(contacts[index]),
            trailing: _button2Vote(contacts[index]),
            title: Text(contacts[index].name ?? '(', style: kTextStyle.callOutBold16),
            subtitle: Text(contacts[index].gradeClass ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
          ),
        );
      },
    );
  }

  Widget _profileImage(User? user) {
    String? profileImage = user?.profileImageKey;

    if (user != null) {
      if (profileImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: profileImage,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
            errorWidget: (BuildContext context, _, image) =>
                SvgPicture.asset(kImage.noProfileGreySvg, height: 40, width: 40),
          ),
        );
      } else {
        String noProfile = kImage.noProfileGreySvg;
        if (user.gender != null) {
          if (user.gender == Gender.male) {
            noProfile = kImage.noProfileMale;
          } else {
            noProfile = kImage.noProfileFemale;
          }
        }
        return SvgPicture.asset(noProfile, height: 40, width: 40);
      }
    } else {
      return const SizedBox.shrink();
    }
  }
  
  Widget _button2Vote(User contact) {
    return GestureDetector(
      onTap: () => _voteForThisFriend(contact),  // 초대됨 아닌 경우만 초대
      child: Container(
        height: 36,
        width: 72,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 6, right: 6),
        decoration: BoxDecoration(
            color: kColor.blue100,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Text('투표하기', style: kTextStyle.subHeadlineBold14
            .copyWith(color: Colors.white)),
      ),
    );
  }

  Widget _noFound4Friend() {
    return Container(
      height: 190,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
          color: kColor.grey20,
          borderRadius: BorderRadius.circular(26)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              const Text('🕳', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
              Text('혹시, 찾는 친구가 없으신가요?', style: kTextStyle.headlineExtraBold18),
            ],
          ),

          GestureDetector(
            onTap: () => _inviteNoneOmgUser(),
            child: Container(
              height: 44,
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: kColor.blue30,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Text('친구 초대하기', style: kTextStyle.callOutBold16.copyWith(color: kColor.blue100))
            ),
          )
        ],
      ),
    );
  }
}
