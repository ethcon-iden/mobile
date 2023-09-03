import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../resource/images.dart';
import '../../resource/style.dart';

class LottieAnimation {
  LottieAnimation();

  static Widget loading(double size, {Color? color}) {
    Color loadingColor = kColor.green100;
    if (color != null) {
      loadingColor = color;
    }
    return SizedBox(
        height: size,
        width: size,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(loadingColor, BlendMode.srcIn),
          child: Lottie.asset(kAnimation.loading,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        )
    );
  }

  static Widget check() {
    return SizedBox(
        height: 30,
        width: 30,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(kColor.green100, BlendMode.srcIn),
          child: Lottie.asset(kAnimation.check,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            repeat: false,
          ),
        )
    );
  }

}




