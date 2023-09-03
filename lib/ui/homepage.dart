import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'auth/signIn_main.dart';
import 'pages/account_recovery.dart';
import '../controller/state_controller.dart';
import 'iden_main.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key,
    required this.route,
  }) : super(key: key);

  final String route;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late bool isSignInAlready;

  @override
  void initState() {
    super.initState();
    service.setBottomMarginByPlatform();
  }

  void _move2route() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.route == 'idenMain')  {
        _move2OmgHome();
      } else if (widget.route == 'recovery') {
        _move2Recovery();
      } else {    // sign in
        _move2SignIn();
      }
    });
  }

  void _move2OmgHome() {
    Navigator.pushReplacement(
        context,
        MaterialWithModalsPageRoute(builder: (BuildContext context) => const IdenMain())
    );
  }

  void _move2SignIn() {
    Navigator.pushReplacement(
        context,
        MaterialWithModalsPageRoute(builder: (BuildContext context) => const SignInMain())
    );
  }

  void _move2Recovery() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const AccountRecovery(hasJustRequested: false))
    );
  }

  @override
  Widget build(BuildContext context) {
    _move2route();
    return Container();
  }
}
