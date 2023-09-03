import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../services/service_contacts.dart';

import '../../resource/images.dart';
import '../../resource/style.dart';
import '../../services/permission_handler.dart';

class SearchContacts extends StatefulWidget {
  const SearchContacts({Key? key}) : super(key: key);

  @override
  State<SearchContacts> createState() => _SearchContactsState();
}

class _SearchContactsState extends State<SearchContacts> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _nodeSearch = FocusNode();
  List<Contact> searchResult = [];
  List<Contact> friendsAdded = [];

  @override
  void initState() {
    super.initState();
    _requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nodeSearch.requestFocus();
    });
  }

  void _requestUnFocus() {
    if (mounted) _nodeSearch.unfocus();
    setState(() {});
  }

  void _onChange() {
    String input = _textController.text;
    if (input.isNotEmpty) {
      _searchContact(input);
    } else {
      searchResult.clear();
    }
    setState(() {});
  }

  void _searchContact(String name) async {
    List<Contact> res = await ServiceContact.searchQuery(name);
    if (res.isNotEmpty) {
      searchResult = res;
    }
  }

  bool _checkInvitedAlready(Contact contact) {
    bool isFound = false;
    if (friendsAdded.isNotEmpty) {
      for (var e in friendsAdded) {
        if (e.displayName == contact.displayName) {
          isFound = true;
        }
      }
    }
    return isFound;
  }

  void _addInvitedList(Contact contact) {
    friendsAdded.add(contact);
    setState(() {});
  }

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
        const SizedBox(height: 20),

        if (searchResult.isNotEmpty)
          Expanded(child: _buildSearchResult())
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
              onTap: () => Get.back(),
              child: Container(
                  height: 40,
                  width: 40,
                  color: Colors.transparent,
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
        decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: kColor.grey30,
            hintText: '이름 또는 닉네임으로 친구 찾기',
            hintStyle: kTextStyle.hint,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.only(right: 10, bottom: 5),
            prefixIcon: const Icon(Icons.search, size: 30),
            prefixIconColor: _nodeSearch.hasFocus ? Colors.black : kColor.grey100
        ),
        onTap: () => _requestFocus(),
        onChanged: (_) => _onChange(),
        onFieldSubmitted: (_) => _onChange(),
        onTapOutside: (_) => _requestUnFocus(),
      ),
    );
  }

  Widget _buildSearchResult() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: searchResult.length,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
      itemBuilder: (BuildContext context, int index) {
        return content(searchResult[index]);
      },
    );
  }

  Widget content(Contact contact) {
    Uint8List? avatar;
    if (contact.avatar != null && contact.avatar!.isNotEmpty) {
      avatar = contact.avatar;
    }
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
                avatar != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.memory(avatar, height: 40, width: 40, fit: BoxFit.cover))
                    : SvgPicture.asset(kImage.noProfileGreySvg, height: 40, width: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(contact.displayName ?? ' ', style: kTextStyle.callOutBold16)),
                    // Text(friend.grade ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                  ],
                ),
              ],
            ),
          ),
          _button(contact)
        ],
      ),
    );
  }

  Widget _button(Contact contact) {
    bool isInvited = _checkInvitedAlready(contact);
    return GestureDetector(
      onTap: () {
        if (!isInvited) {
          _addInvitedList(contact);
        }
      },
      child: Container(
        height: 36,
        width: 76,
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(left: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: isInvited ? kColor.grey30 : kColor.blue100,
            borderRadius: BorderRadius.circular(10)
        ),
        child: Text(isInvited ? '초대됨' : '초대하기', style: kTextStyle.subHeadlineBold14
            .copyWith(color: isInvited ? Colors.black : Colors.white)),
      ),
    );
  }
}
