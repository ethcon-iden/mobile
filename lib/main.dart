import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ui/auth/signIn_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Iden());
}

class Iden extends StatelessWidget {
  const Iden({super.key});

  @override
  build(BuildContext context) {
    return GetMaterialApp(
        title: 'IDEN',
        debugShowCheckedModeBanner: false,
        // initialRoute: '/',
        defaultTransition: Transition.rightToLeftWithFade,
        /// Locale setting
        locale: Get.deviceLocale,
        fallbackLocale: const Locale('en', 'US'),   // default locale
        theme: _themeData(),
        home: const SignInMain()
    );
  }

  ThemeData _themeData() {
    var baseTheme = ThemeData(
      platform: TargetPlatform.iOS,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        toolbarHeight: 52,
        elevation: 0
      )
    );
    return baseTheme;
  }
}
