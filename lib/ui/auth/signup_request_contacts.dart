import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../model/session.dart';
import '../../rest_api/api.dart';
import '../common_widget/custom_button.dart';
import '../../services/permission_handler.dart';
import '../auth/add_friends.dart';
import '../../resource/images.dart';
import '../../resource/style.dart';
import '../../services/extensions.dart';
import '../../resource/kConstant.dart';
import '../iden_main.dart';

class SignUpRequestContacts extends StatefulWidget {
  const SignUpRequestContacts({Key? key}) : super(key: key);

  @override
  State<SignUpRequestContacts> createState() => _SignUpRequestContactsState();
}

class _SignUpRequestContactsState extends State<SignUpRequestContacts> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _uploadContacts() async {
    bool out;
    HttpsResponse res = await IdenApi.postContact();

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      out = true;
    } else {  // 에러 처리
      ErrorResponse error = res.body;
      print('---> add friends > get search > error: ${error.message}');
      out = false;
    }
    return out;
  }

  void _proceedNext() async {
    final res = await PermissionHandler.contacts();
    if (res) {
      final result = await _uploadContacts();
      if (result) {
        _moveNextPage();
      } else {
        print('---> sign up request contacts > upload contacgts > error');
      }
    }
  }

  void _moveNextPage() {
    Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => const AddFriends()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      bottomSheet: _bottomButton(),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              children: [
                Image.asset(kIcon.contactBook, height: 100, width: 100),
                Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 12),
                  child: Text('Sync with your contacts', style: kTextStyle.title1ExtraBold24),
                ),
                Text('Your contacts will be required to use IDEN services.', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
              ],
            ),
          ),
        ]
    );
  }

  Widget _bottomButton() {
    return CustomButtonWide(
      horizontalMargin: 16,
      hasBottomMargie: true,
      title: 'Sync with contacts',
      titleColor: Colors.white,
      background: Colors.black,
      onTap: () => _proceedNext(),
      // onTap: () => _move2setProfileComplete(),  // todo > test
    );
  }
}
