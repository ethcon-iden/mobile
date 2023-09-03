import 'package:flutter/material.dart';
import 'package:iden/rest_api/api.dart';

import '../../services/web3_credentials.dart';
import '../../model/session.dart';
import '../auth/signup_request_contacts.dart';
import '../../controller/state_controller.dart';
import '../../resource/style.dart';

class SignUpContinue extends StatefulWidget {
  const SignUpContinue({Key? key}) : super(key: key);

  @override
  State<SignUpContinue> createState() => _SignUpContinueState();
}

class _SignUpContinueState extends State<SignUpContinue> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPhoneNumber = TextEditingController();
  final TextEditingController _controllerDepartment = TextEditingController();
  final TextEditingController _controllerDuty = TextEditingController();
  final FocusNode _nodeName = FocusNode();
  final FocusNode _nodePhoneNumber = FocusNode();
  final FocusNode _nodeDepartment = FocusNode();
  final FocusNode _nodeDuty = FocusNode();
  bool isUserExist = true;
  bool hasDepartmentDone = false;
  bool hasNameDone = false;
  bool hasPhoneNumberDone = false;
  bool hasDutyDone = false;
  bool isInputConfirmed = false;
  bool isRecheckInputData = false;  // 마지막 확인 (잠깐만요) -> 다시 확인 하기
  bool hasAllInputDone = false;

  int schoolYear = 1;   // [1,2,3] -> 1,2,3학년
  int selectedClassNo = 1;

  @override
  void initState() {
    super.initState();
    _requestFocus4name();
  }

  @override
  void dispose() {
    _controllerDepartment.dispose();
    _controllerName.dispose();
    _controllerPhoneNumber.dispose();
    super.dispose();
  }

  void _requestFocus4name() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nodeName.requestFocus();
    });
  }

  void _checkNameField() {
    String name = _controllerName.text;
    if (name.isNotEmpty) {
      String nameAfterTrim = name.trim();
      if (nameAfterTrim.length > 1) {
        hasNameDone = true;
        _controllerName.text = nameAfterTrim;
        service.username.value = _controllerName.text;
        _gotoPhoneNumber();
      } else {
        setState(() => hasNameDone = false);
      }
    }
    _inputFieldsValidation();
  }

  void _gotoPhoneNumber() {
    if (mounted) setState(() => _nodePhoneNumber.requestFocus());
  }

  void _checkPhoneField() {
    String name = _controllerPhoneNumber.text;
    if (name.isNotEmpty) {
      String nameAfterTrim = name.trim();
      if (nameAfterTrim.length > 1) {
        hasPhoneNumberDone = true;
        _controllerPhoneNumber.text = nameAfterTrim;
        service.phoneNumber.value = _controllerPhoneNumber.text;
        _gotoDepartment();

      } else {
        setState(() => hasPhoneNumberDone = false);
      }
    }
    _inputFieldsValidation();
  }

  void _gotoDepartment() {
    if (mounted) setState(() => _nodeDepartment.requestFocus());
  }

  void _generateSharingKey() async {
    List<String> keyShare = [];
    final pKey = Web3Credentials.instance.generatePrivateKey();

    if (pKey.isNotEmpty) {
      keyShare = Web3Credentials.instance.sharingKey(pKey);
    }

    if (keyShare.isNotEmpty) {
      final res = await _callApi4email(keyShare.first);
      if (res == true) {
        _move2nextPage();
      }
    }
  }

  Future<bool> _callApi4register() async {
    bool out = false;

    String name = _controllerName.text;
    String phoneNumber = _controllerPhoneNumber.text;
    String department = _controllerDepartment.text;
    String email = '${DateTime.now().toIso8601String()}@email.com';
    String duty = _controllerDuty.text;

    HttpsResponse res = await IdenApi.postRegister(name, email, phoneNumber, department, duty);

    if (res.statusType == StatusType.success) {

      final accessToken = res.body['accessToken'];
      if (accessToken != null) {
        service.accessToken.value = accessToken;
        print('---> access token: $accessToken');

        out = true;
      }
    } else {  // 에러 처리
      ErrorResponse error = res.body;
      print('---> user register > error: ${error.message}');
    }
    return out;
  }

  Future<bool> _callApi4email(String keyShare) async {
    bool out;
    HttpsResponse res = await IdenApi.postEmail(keyShare);

    if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
      out = true;
    } else {  // 에러 처리
      ErrorResponse error = res.body;
      print('---> user register > error: ${error.message}');
      out = false;
    }
    return Future.value(out);
  }

  void _checkDepartmentField() async {
    String name = _controllerDepartment.text;
    if (name.isNotEmpty) {
      String nameAfterTrim = name.trim();
      if (nameAfterTrim.length > 1) {
        hasDepartmentDone = true;
        _controllerDepartment.text = nameAfterTrim;
        service.department.value = _controllerDepartment.text;
        _gotoDuty();

      } else {
        setState(() => hasDepartmentDone = false);
      }
    }
    _inputFieldsValidation();
  }

  void _gotoDuty() {
    if (mounted) setState(() => _nodeDuty.requestFocus());
  }

  void _checkDuty() async {
    String name = _controllerDuty.text;
    if (name.isNotEmpty) {
      String nameAfterTrim = name.trim();
      if (nameAfterTrim.length > 1) {
        hasDutyDone = true;
        _controllerDuty.text = nameAfterTrim;
        service.department.value = _controllerDuty.text;
        _nodeDuty.unfocus();

      } else {
        setState(() => hasDutyDone = false);
      }
    }
    _inputFieldsValidation();
    if (hasAllInputDone) {
      final res = await _callApi4register();
      if (res) {
        _generateSharingKey();
      }
    }
    // _move2nextPage();   // todo > test
  }

  void _inputFieldsValidation() {
    final department = _controllerDepartment.text;
    final name = _controllerName.text;
    final phoneNumber = _controllerPhoneNumber.text;
    if (department.isNotEmpty && phoneNumber.isNotEmpty && name.isNotEmpty) {
      hasAllInputDone = true;
    } else {
      hasAllInputDone = false;
    }
    setState(() {});
  }

  void _move2nextPage() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const SignUpRequestContacts()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
          // leading: GestureDetector(
          //     onTap: () => Navigator.pop(context),
          //     child: const Icon(Icons.arrow_back, color: Colors.black)),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _header(),

        Visibility(
          maintainState: true,
          visible: hasNameDone && hasPhoneNumberDone & hasDepartmentDone,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return AnimatedContainer(
                key: const ValueKey<String>('duty'),
                duration: const Duration(milliseconds: 300),
                height: 70,
                child: child,
              );
            },
            child: _inputDuty(),
          ),
        ),
        // Visibility( // 직무
        //     maintainState: true,
        //     visible: hasNameDone && hasPhoneNumberDone & hasDepartmentDone,
        //     child: _inputDuty()
        // ),
        Visibility( // 소속
            maintainState: true,
            visible: hasNameDone && hasPhoneNumberDone,
            child: _inputDepartment()
        ),
        Visibility(   // 전화번호
            maintainState: true,
            visible: hasNameDone,
            child: _inputPhoneNumber()
        ),
        _inputName(), // 이름

      ]
    );
  }

  Widget _header() {
    String title = 'User Information';
    String description = 'The following personal information is required to join IDEN.';

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(title, style: kTextStyle.largeTitle28),
          ),
          Text(description, style: kTextStyle.bodySubTitle),
          const SizedBox(height: 40)
        ]
    );
  }

  Widget _inputName() {
    TextStyle style;
    if (_nodeName.hasFocus) {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey500);
    } else {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey300);
    }
    return Container(
      height: 65,
      padding: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: _nodeName.hasFocus ? Colors.black : kColor.grey100),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('Fullname', style: style),
          ),
          TextFormField(
            controller: _controllerName,
            focusNode: _nodeName,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            style: kTextStyle.callOutMedium16.copyWith(color: _nodeName.hasFocus ? Colors.black : kColor.grey900),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'input your fullname',
              hintStyle: kTextStyle.hint,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.only(right: 10),
              suffixIconConstraints: const BoxConstraints(
                  maxHeight: 30, maxWidth: 30
              ),
            ),
            onFieldSubmitted: (_) => _checkNameField(),
            onTap: () => setState(() {_nodeName.requestFocus();}),
            onTapOutside: (_) => setState(() {_nodeName.unfocus();}),
          ),
        ],
      ),
    );
  }

  Widget _inputPhoneNumber() {
    TextStyle style;
    if (_nodePhoneNumber.hasFocus) {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey500);
    } else {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey300);
    }
    return Container(
      height: 65,
      padding: const EdgeInsets.only(left: 16, right: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: _nodePhoneNumber.hasFocus ? Colors.black : kColor.grey100),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('Phone number', style: style),
          ),
          TextFormField(
            controller: _controllerPhoneNumber,
            focusNode: _nodePhoneNumber,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            style: kTextStyle.callOutMedium16.copyWith(color: _nodePhoneNumber.hasFocus ? Colors.black : kColor.grey900),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: kTextStyle.hint,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.only(right: 10),
              suffixIconConstraints: const BoxConstraints(
                  maxHeight: 30, maxWidth: 30
              ),
            ),
            onFieldSubmitted: (_) => _checkPhoneField(),
            onTap: () => setState(() {_nodePhoneNumber.requestFocus();}),
            onTapOutside: (_) => setState(() {_nodePhoneNumber.unfocus();}),
          ),
        ],
      ),
    );
  }

  Widget _inputDepartment() {
    TextStyle style;
    if (_nodeDepartment.hasFocus) {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey500);
    } else {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey300);
    }
    return Container(
      height: 65,
      padding: const EdgeInsets.only(left: 16, right: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: _nodeDepartment.hasFocus ? Colors.black : kColor.grey100),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('Affiliation or Division', style: style),
          ),
          TextFormField(
            controller: _controllerDepartment,
            focusNode: _nodeDepartment,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            style: kTextStyle.callOutMedium16.copyWith(color: _nodeDepartment.hasFocus ? Colors.black : kColor.grey900),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: kTextStyle.hint,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.only(right: 10),
              suffixIconConstraints: const BoxConstraints(
                  maxHeight: 30, maxWidth: 30
              ),
            ),
            onFieldSubmitted: (_) => _checkDepartmentField(),
            onTap: () => setState(() {_nodeDepartment.requestFocus();}),
            onTapOutside: (_) => setState(() {_nodeDepartment.unfocus();}),
          ),
        ],
      ),
    );
  }

  Widget _inputDuty() {
    TextStyle style;
    if (_nodeDuty.hasFocus) {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey500);
    } else {
      style = kTextStyle.caption2Medium12.copyWith(color: kColor.grey300);
    }
    return Container(
      height: 65,
      padding: const EdgeInsets.only(left: 16, right: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          border: Border.all(width: 2, color: _nodeDuty.hasFocus ? Colors.black : kColor.grey100),
          borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text('Jon description', style: style),
          ),
          TextFormField(
            controller: _controllerDuty,
            focusNode: _nodeDuty,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            style: kTextStyle.callOutMedium16.copyWith(color: _nodeDuty.hasFocus ? Colors.black : kColor.grey900),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: kTextStyle.hint,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.only(right: 10),
              suffixIconConstraints: const BoxConstraints(
                  maxHeight: 30, maxWidth: 30
              ),
            ),
            onFieldSubmitted: (_) => _checkDuty(),
            onTap: () => setState(() {_nodeDuty.requestFocus();}),
            onTapOutside: (_) => setState(() {_nodeDuty.unfocus();}),
          ),
        ],
      ),
    );
  }
}
