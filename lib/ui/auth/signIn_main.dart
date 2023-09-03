import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iden/ui/auth/signup_continue.dart';
import 'package:iden/ui/common_widget/bottom_modal.dart';

import '../../resource/images.dart';
import '../pages/components/bottom_modal_contents_buttons.dart';
import '../../controller/state_controller.dart';
import '../../services/auth_service.dart';

class SignInMain extends StatefulWidget {
  const SignInMain({Key? key}) : super(key: key);

  @override
  State<SignInMain> createState() => _SignInMainState();
}

class _SignInMainState extends State<SignInMain> {

  @override
  void initState() {
    super.initState();
    _showModal();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _call4appleSingIn() {
    AuthService.signInWithApple().then((value) {
      print('---> apple sign in > value: $value');

      if (value != null) {
        _move2signContinue();
      } else {
        _move2signContinue();
      }
    });
  }

  void _call4googleSigIn() {
    AuthService.signInWithGoogle().then((value) {
      print('---> google sign in > value: $value');

      if (value) {
        _move2signContinue();
      } else {
        _move2signContinue();
      }
    });
  }

  void _move2signContinue() {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const SignUpContinue())
    );
  }

  void _showModal() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _modal4signIn();
    });
  }

  void _modal4signIn() async {
    final res = await showCustomBottomSheet(
        context,
        background: Colors.white54,
        ModalContentsButtons(
          listTitle: const ['Sign in with Apple', 'Sign in with Google'],
          bottomSub: 'sign in with email',
          // index: 0,1
          listColor: const [Colors.white, Colors.black],
          listIcon: [kIcon.appleLogo, kIcon.googleLogo],
          background: const [Colors.black, Colors.white],
        ),
        260 + service.bottomMargin.value, true
    );
    if (res != null) {
      if (res == 0) {   // apple login
        _call4appleSingIn();
      } else if (res == 1) {  // email login
        _call4googleSigIn();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark
        )
    );
    return GestureDetector(
      onTap: () {
        print('---> tap');
        _showModal();
      },
      child: Scaffold(
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Image.asset(kImage.singInBackground, fit: BoxFit.cover, height: double.infinity, width: double.infinity,),
        Positioned(
          top: 80,
          child: SvgPicture.asset(kIcon.idenLogoSvg, height: 40, fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        ),
      ],
    );
  }
}
