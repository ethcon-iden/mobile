import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:contacts_service/contacts_service.dart';

import '../../../resource/kConstant.dart';
import '../../../resource/images.dart';
import '../../../resource/style.dart';
import '../../../model/session.dart';
import '../child/search_buddy.dart';
import '../../../controller/state_controller.dart';
import '../../../services/service_contacts.dart';
import '../../common_widget/custom_snackbar.dart';
import '../../common_widget/bottom_modal.dart';

class InviteBuddy extends StatefulWidget {
  const InviteBuddy({Key? key}) : super(key: key);

  @override
  State<InviteBuddy> createState() => _InviteBuddyState();
}

class _InviteBuddyState extends State<InviteBuddy> {
  late ScrollController _scrollController;
  // late StreamController<dynamic> _streamController;
  List<int> listInvitedIndex = <int>[];
  List<Contact>? allContacts;
  int numFriendsToAdd = 0;
  HttpsResponse? httpsResponse;
  bool? hasSmsSent;

  @override
  void initState() {
    super.initState();
    service.sendSMSResult.value = SendSmsResult.none;
    _scrollController = ScrollController();
    // _streamController = StreamController<dynamic>();
    _getContacts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // _streamController.close();
    super.dispose();
  }

  Future<void> _getContacts() async {
    print('---> invite buddy > get contact: ${service.buddyInvited}');
    List<Contact> contacts = await ServiceContact.getContact();
    print('---> invite buddy > contact len: ${contacts.length}');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      allContacts = contacts;
      setState(() {});
    });
  }

  void _modal4SearchBuddy() async {
    final res = await modalCupertino(context, const SearchBuddy(), false);
    if (res != null && res) {
      hasSmsSent = true;
      _getContacts();
    } else {
      hasSmsSent = false;
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
        _searchByName(),
        Expanded(
            child: _showAllContacts()
        )
      ],
    );
  }

  Widget _header() {
    return GestureDetector(
      onTap: () => _move2ListTop(),
      child: Column(
        children: [
          Container(
            height: 20,
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
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('친구 초대하기', style: kTextStyle.largeTitle28),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context, hasSmsSent);
                        },
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 0),
                        icon: Icon(CupertinoIcons.xmark_circle_fill, color: kColor.grey500, size: 28)
                    )
                  ],
                ),
                Text('초대한 친구가 OMG에 가입하면,\n투표 대기 시간을 건너뛸 수 있어요.',
                    style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchByName() {
    return GestureDetector(
      onTap: () {
        _modal4SearchBuddy();
      },
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: kColor.grey30,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Icon(CupertinoIcons.search, size: 24, color: kColor.grey100),
            ),
            Text('이름 또는 전화번호로 찾기', style: kTextStyle.hint)
          ],
        ),
      ),
    );
  }

  Widget _showAllContacts() {
    return allContacts != null ? _items(allContacts!) : Container();
  }

  Widget _items(List<Contact> data) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics()
      ),
      shrinkWrap: true,
      itemCount: data.length,
      padding: const EdgeInsets.only(top: 5),
      itemBuilder: (BuildContext context, int index) {
        return _content(index, data[index]);
      },
    );
  }

  Widget _content(int index, Contact contact) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              contact.avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.memory(contact.avatar!, height: 40, width: 40, fit: BoxFit.cover))
                  : SvgPicture.asset(kImage.noProfileMale, height: 40, width: 40),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(contact.displayName ?? '', style: kTextStyle.callOutBold16),
                  // Text(contact.grade ?? '', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
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
}
