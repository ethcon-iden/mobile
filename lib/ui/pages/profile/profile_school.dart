import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../../model/session.dart';
import '../../../model/school.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/divider.dart';
import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';
import '../../../controller/state_controller.dart';
import '../../common_widget/custom_snackbar.dart';
import '../components/modal_profile_update.dart';
import '../../../rest_api/school_api.dart';

class ProfileSchool extends StatefulWidget {
  const ProfileSchool({Key? key}) : super(key: key);

  @override
  State<ProfileSchool> createState() => _ProfileSchoolState();
}

class _ProfileSchoolState extends State<ProfileSchool> {
  List<School> allSearchResult = [];
  late StreamController<dynamic> _streamController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _node = FocusNode();
  String? schoolOrigin;
  School schoolSelected = School();
  bool isInputDone = false;
  bool isReset = false;
  bool isMoreThan2Character = false;
  bool isTextInputEnabled = false;
  Paging? paging;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    schoolOrigin = service.userMe.value.school?.name;
  }

  @override
  void dispose() {
    _textController.dispose();
    _streamController.close();
    super.dispose();
  }

  void _modal2ProfileSchool() async {
    final res = await showCustomBottomSheet(
        context,
        ModalProfileUpdate(
          title: '정말 학교 정보를 수정할까요?',
          sub: '한 번 수정하면, 다시는 수정할 수 없어요.',
          emoji: '👉',
          newValue: schoolSelected.name,
          description: '수정 전 현재 학교 ',
          originValue: schoolOrigin,
        ),
        320 + service.bottomMargin.value, true
    );
    if (res != null && res) {
      String? grade;
      if (schoolSelected.type != service.userMe.value.school?.type) {
        String type;
        if (schoolSelected.type == SchoolType.middle) {
          type = 'M';
        } else {
          type = 'H';
        }
        if (service.userMe.value.schoolGrade != null) {
          grade = '$type${service.userMe.value.schoolGrade!.num}';
        }
      }
      if (schoolSelected.id != null) {
        final String id = schoolSelected.id.toString();
        final bool result = await service.updateUserProfile('schoolId', id);
        if (grade != null) {
          await service.updateUserProfile('grade', grade);
        }
        if (result) {
          service.userMe.value.school = schoolSelected;
          _moveBack();
          _showSnackbarSuccess();
          setState(() {});
        } else {
          _showError();
        }
      } else {
        _showNoInput();
      }
    }
  }

  void _showNoInput() {
    showDialog4Info(
        context,
        '🤕‍',
        '학교 선택을 먼저 하고 다시 시도해주세요.',
        null,
        null);
  }

  void _moveBack() => Navigator.pop(context, true);

  void _showError() => showSomethingWrong(context);

  void _showSnackbarSuccess() => customSnackbar(context, '✨', '학교가 수정되었어요.', ToastPosition.bottom);

  Future<void> _getSearchResult() async {
    String query = _textController.text;
    isReset = false;

    final HttpsResponse res = await SchoolApi.getSearch(query, null);

    List<School> schools = [];
    if (res.body != null) {
      if (res.statusType == StatusType.success) {
        if (res.body['data'].isNotEmpty) {
          for (var e in res.body['data']) {
            schools.add(
                School.fromJson(e)
            );
          }
        }
        allSearchResult = schools;
        paging = Paging.fromJson(res.body['cursor']);
        _streamController.add(schools);
      } else {
        print('---> _getSearchResult > no data');
      }
    } else {
      print('---> HttpsResponse > response is empty');
    }
  }

  Future<void> _getSearchMore(Paging? nextSearch) async {
    String query = _textController.text;
    isReset = false;

    HttpsResponse res = await SchoolApi.getSearch(query, nextSearch);

    List<School> schools = [];
    if (res.body != null) {
      if (res.statusType == StatusType.success) {
        if (res.body['data'].isNotEmpty) {
          for (var e in res.body['data']) {
            schools.add(
                School.fromJson(e)
            );
          }
        }
        allSearchResult += schools;
        nextSearch = Paging.fromJson(res.body['cursor']);
        _streamController.add(allSearchResult);
      }
    }
  }

  void _clearSearchResult() {
    isReset = true;
    isInputDone = false;
    allSearchResult = [];
    _streamController.add(allSearchResult);
    setState(() {});
  }

  void _onChange(String value) {
    if (value.isEmpty) {
      _clearSearchResult();
    } else if (value.length >= 2) {
      isMoreThan2Character = true;
      _getSearchResult();
    } else {
      isMoreThan2Character = false;
    }
    setState(() {});
  }

  void _onComplete() {
    _node.unfocus();
    if (_textController.text.isNotEmpty) {
      isInputDone = true;
    } else {
      isInputDone = false;
    }
    isTextInputEnabled = false;
    setState(() {});
  }

  void _onEndScroll(ScrollMetrics metrics) {
    if (metrics.pixels == metrics.maxScrollExtent - 100) {
      _onRefresh(PageCursor.after);
    }
  }

  Future<void> _onRefresh(PageCursor cursor) async {
    Paging? schoolPaging = paging;

    if (schoolPaging != null) {
      if (schoolPaging.afterCursor != null) { // Page after
        schoolPaging.pageCursor = PageCursor.after;
        _getSearchMore(schoolPaging);
      }
    }
  }

  void _selectSchool(School? school) {
    if (school != null) {
      _textController.text = school.name ?? '';
      schoolSelected = school;
      if (schoolOrigin != _textController.text) {
        isInputDone = true;
      } else {
        isInputDone = false;
      }
    } else {
      // isInputDone = false;
    }
    setState(() {});
    FocusManager.instance.primaryFocus?.unfocus();    // keyboard dismiss
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScrollIndicatorBar(),
              const SizedBox(height: 30),

              _title(),
              const DividerHorizontal(paddingTop: 16, paddingBottom: 20,),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text('학교는 한 번 수정하면, 다시는 수정할 수 없어요.',
                    style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
              ),

              _inputSchool(),

              isMoreThan2Character
                  ? const SizedBox(height: 25)
                  : _moreThan2Character(),
              const SizedBox(height: 10),
              Expanded(
                  child: _searchResult()
              ),
            ],
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: _bottomButton())
      ],
    );
  }

  Widget _moreThan2Character() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10,),
      child: Text('2글자 이상 입력해주세요!', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
    );
  }

  Widget _title() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text('학교 수정', style: kTextStyle.largeTitle28),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 26)),
        )
      ],
    );
  }

  Widget _inputSchool() {
    TextStyle style;
    if (_node.hasFocus) {
      style = kTextStyle.subHeadlineBold14;
    } else {
      style = kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300);
    }
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Text('학교', style: style),
          ),
          TextFormField(
            controller: _textController,
            focusNode: _node,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.search,
            style: kTextStyle.bodyMedium18,
            autocorrect: false,
            decoration: InputDecoration(
                isDense: true,
                hintText: schoolOrigin ?? '트리니티고등학교',
                hintStyle: kTextStyle.bodyMedium18.copyWith(color: kColor.grey100),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kColor.grey30, width: 2)
                ),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2)
                ),
                contentPadding: const EdgeInsets.only(right: 10, bottom: 10),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(right: 10, bottom: 10),
                  child: Icon(CupertinoIcons.search, size: 20),
                ),
                prefixIconConstraints: const BoxConstraints(maxWidth: 50, maxHeight: 50),
                prefixIconColor: kColor.grey100
            ),
            onChanged: (value) => _onChange(value),
            onTapOutside: (_) => _onComplete(),
            onFieldSubmitted: (_) => _onComplete(),
            onTap: () => setState(() {
              isTextInputEnabled = true;
            }),
          ),
        ],
      ),
    );
  }

  // void _onStartScroll(ScrollMetrics metrics) {
  //   print('---> scroll start');
  // }
  // void _onUpdateScroll(ScrollMetrics metrics) {
  //   print('---> scroll update');
  // }

  Widget _searchResult() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // when start to scroll by touching the screen
        // if (notification is ScrollStartNotification) {
        //   _onStartScroll(notification.metrics);
        //   // while touching the screen by scrolling up and down -> android
        // } else if (notification is OverscrollNotification) {
        //   _onUpdateScroll(notification.metrics);
        //   // while touching the screen by scrolling up and down -> ios
        // } else if (notification is ScrollUpdateNotification) {
        //   _onUpdateScroll(notification.metrics);
        //   // when off the touch from screen (end of scroll)
        // } else if (notification is ScrollEndNotification) {
        //   _onEndScroll(notification.metrics);
        // }

        if (notification is ScrollEndNotification) {
          _onEndScroll(notification.metrics);
        }
        return true;
      },
      child: CupertinoScrollbar(
        radius: const Radius.circular(8),
        thickness: 4,
        child: RefreshIndicator(
          onRefresh: () => _getSearchResult(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: _getSchools(),
          ),
        ),
      ),
    );
  }

  Widget _getSchools() {
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
                return _handleError();
              } else if (snapshot.hasData) {
                List<School> schools = snapshot.data;
                if (schools.isNotEmpty) {
                  return _schoolListUp(schools);
                } else {
                  return isReset
                      ? const SizedBox.shrink()
                      : !isTextInputEnabled && isInputDone
                          ? Center(child: _noSearchResult())
                          : const SizedBox.shrink();
                }
              } else {
                print('---> snapshot no data: ${snapshot.data}');
                return Container();
              }
          }
        }
    );
  }

  Widget _schoolListUp(List<School>? schoolList) {
    List<School> schools = [];
    if (schoolList != null && schoolList.isNotEmpty) {
      schools = schoolList;
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: schools.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (BuildContext context, int index) {
        return item(schools[index]);
      },
      separatorBuilder: (context, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Divider(height: 0.5, color: Colors.grey.shade300),
        );
      },
    );
  }

  Widget item(data) {
    School? school = data;
    String emoji = '🏫';
    if (school?.type == SchoolType.high) {
      emoji = '🏛';
    } else {
      emoji = '🏫';
    }

    return GestureDetector(
      onTap: () => _selectSchool(school),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(school?.name ?? '', style: kTextStyle.callOutBold16),
                Text(school?.location ?? '', style: kTextStyle.footNoteGrey)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _noSearchResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Text('🏖', style: TextStyle(fontSize: 58)),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text('학교를 찾지 못했어요...\n검색어를 다시 한 번 확인해주세요!', textAlign: TextAlign.center,
              style: kTextStyle.headlineExtraBold18.copyWith(height: 1.5)),
        ),
        GestureDetector(
          onTap: () {
            // todo   > 카카오톡 체널
          },
          child: Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
            decoration: BoxDecoration(
                color: kColor.blue100,
                borderRadius: BorderRadius.circular(12)
            ),
            child: Text('우리 학교가 없어요', style: kTextStyle.callOutBold16.copyWith(color: Colors.white)),
          ),
        )
      ],
    );
  }

  Widget _handleError() {
    return const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 50, right: 50, top: 30),
          child: Text('error has occurred while connecting to server. Please try again later',
            textAlign: TextAlign.center, maxLines: 2,
            style: TextStyle(fontSize: 12, color: Colors.white),),
        )
    );
  }

  Widget _bottomButton() {
    bool isSelected = false;
    if (schoolSelected.name == _textController.text) {
      isSelected = true;
    } else {
      isSelected = false;
    }
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          _modal2ProfileSchool();
        }
      },
      child: Container(
        height: 50,
        width: double.infinity,
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 16, right: 16, bottom: kConst.bottomButtonMargin),
        decoration: BoxDecoration(
            color: isSelected ? kColor.blue100 : kColor.blue100.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Text('수정하기', style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
      ),
    );
  }
}