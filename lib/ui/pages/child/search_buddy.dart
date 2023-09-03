import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:contacts_service/contacts_service.dart';

import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';
import '../../../services/service_contacts.dart';
import '../../../resource/images.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../../resource/kConstant.dart';

class SearchBuddy extends StatefulWidget {
  const SearchBuddy({Key? key}) : super(key: key);

  @override
  State<SearchBuddy> createState() => _SearchBuddyState();
}

class _SearchBuddyState extends State<SearchBuddy> {
  List<int> listInvitedIndex = <int>[];
  final TextEditingController _textController = TextEditingController();
  late ScrollController _scrollController;
  late StreamController<dynamic> _streamController;
  final FocusNode _nodeSearch = FocusNode();
  bool? hasSmsSent;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _streamController = StreamController<dynamic>();
    _getContacts();
  }

  @override
  void dispose() {
    _streamController.close();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _getContacts() async {
    ServiceContact.getContact();
  }

  void _searchByName(String name) async {
    listInvitedIndex.clear();
    List<Contact> res = await ServiceContact.searchQuery(name);
    _streamController.add(res);
  }

  void _move2ListTop() {
    _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
          child: _body()
      ),
    );
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(    // drag indicator
          onTap: () => _move2ListTop(),
          child: Container(
            height: 40,
            color: Colors.transparent,
            alignment: Alignment.topCenter,
            child: Container(
              height: 5, width: 36,
              margin: const EdgeInsets.all(7.5),
              decoration: BoxDecoration(
                  color: kColor.grey100,
                  borderRadius: BorderRadius.circular(6)
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context, hasSmsSent),
                  child: const Icon(CupertinoIcons.back, size: 30)
              ),
              const SizedBox(width: 10),
              _inputSearch(),
            ],
          ),
        ),
        Expanded(child: _searchResult())
      ],
    );
  }

  Widget _inputSearch() {
    return Expanded(
      child: TextFormField(
          controller: _textController,
          focusNode: _nodeSearch,
          autofocus: true,
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          style: kTextStyle.bodyMedium18,
          decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: kColor.grey30,
              hintText: '이름 또는 전화번호로 찾기',
              hintStyle: kTextStyle.hint,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: const EdgeInsets.only(right: 10, bottom: 5),
              prefixIcon: Icon(CupertinoIcons.search, size: 22, color: kColor.grey300),
              prefixIconColor: _nodeSearch.hasFocus ? Colors.black : kColor.grey100
          ),
          onTap: () {},
          onChanged: (value) {
            _searchByName(value);
          },
          onTapOutside: (_) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {});
          }
      ),
    );
  }

  Widget _searchResult() {
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
                List<Contact> contacts = snapshot.data;
                if (contacts.isNotEmpty) {
                  return _items(contacts);
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

  Widget _items(List<Contact>? result) {
    List<Contact> data = [];
    if (result != null && result.isNotEmpty) {
      data = result;
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (BuildContext context, int index) {
        return content(index, data[index]);
      },
    );
  }

  Widget content(int index, data) {
    Contact contact = data;

    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              contact.avatar != null
                  ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.memory(contact!.avatar!, height: 40, width: 40, fit: BoxFit.cover))
                  : SvgPicture.asset(kImage.noProfileMale, height: 40, width: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(contact.displayName ?? '', style: kTextStyle.callOutBold16),
                  // Text(friend.grade ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                ],
              ),
            ],
          ),
          _button(index, contact)
        ],
      ),
    );
  }

  Widget _button(int index, Contact contact) {
    bool isAlreadyInvited = false;
    if (listInvitedIndex.contains(index)) {
      isAlreadyInvited = true;
    }
    return isAlreadyInvited ? _buttonAlreadyInvited() : _buttonInvite(index, contact);
  }

  Widget _buttonInvite(int index, Contact contact) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 36,
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
        decoration: BoxDecoration(
            color: kColor.blue10,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Text('초대하기', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.blue100)),
      ),
    );
  }

  Widget _buttonAlreadyInvited() {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
          color: kColor.grey30,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Text('💌초대함', style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.black)),
    );
  }

  // Widget _button(int index, Contact? contact) {
  //   return GestureDetector(
  //     onTap: () {
  //       if (contact != null) {
  //         _sendSms4Invite(context, index, contact);
  //       }
  //     },
  //     child: Container(
  //       height: 36,
  //       padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
  //       decoration: BoxDecoration(
  //           color: kColor.blue10,
  //           borderRadius: BorderRadius.circular(10)
  //       ),
  //       child: Text('초대하기', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.blue100)),
  //     ),
  //   );
  // }

  Widget _noSearchResult() {
    return const Center(
        child: Text('검색 결과가 없습니다!', textAlign: TextAlign.center)
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
}
