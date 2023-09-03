import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../resource/style.dart';
import '../../controller/state_controller.dart';


void customSnackbar(context, String emoji, String message, ToastPosition toastPosition, {double? bottomMargin}) {
  FToast fToast = FToast();
  fToast.init(context);

  Widget toast = Material(
    elevation: 4.0,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(width: 1, color: kColor.grey30),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12.0),
          Flexible(
              child: Text(message, maxLines: 3, style: kTextStyle.callOutBold16)),
        ],
      ),
    ),
  );

  fToast.showToast(
      child: toast,
      gravity: toastPosition == ToastPosition.bottom
          ? ToastGravity.BOTTOM : ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child) {
        return Positioned(
          top:  toastPosition == ToastPosition.top ? 60 : null,
          bottom: toastPosition == ToastPosition.bottom ? 54 + (bottomMargin ?? 0) + service.bottomMargin.value : null,
          left: 16,
          right: 16,
          child: child,
        );
      }
  );
}


void customSnackbar2(String emoji, String message, ToastPosition toastPosition) {
  FToast fToast = FToast();

  Widget toast = Material(
    elevation: 4.0,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(width: 1, color: kColor.grey30),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12.0),
          Flexible(
              child: Text(message, maxLines: 3, style: kTextStyle.callOutBold16)),
        ],
      ),
    ),
  );

  fToast.showToast(
      child: toast,
      gravity: toastPosition == ToastPosition.bottom
          ? ToastGravity.BOTTOM : ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
      positionedToastBuilder: (context, child) {
        return Positioned(
          top:  toastPosition == ToastPosition.top ? 60 : null,
          bottom: toastPosition == ToastPosition.bottom ? 54 : null,
          left: 16,
          right: 16,
          child: child,
        );
      }
  );
}

void customSnackbarAction(context, String emoji, String message, ToastPosition position,
    IconData? tailIcon, VoidCallback onClick, ) {
  FToast fToast = FToast();
  fToast.init(context);

  Widget toast = Material(
    elevation: 4.0,
    borderRadius: BorderRadius.circular(20),
    child: GestureDetector(
      onTap: () => {
        print('---> toast click'),
        onClick()
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(width: 1, color: kColor.grey30),
          color: Colors.white,
        ),
        child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 12.0),
                  Flexible(
                      child: Text(message, maxLines: 3, style: kTextStyle.callOutBold16)),
                ],
              ),
              tailIcon != null
                  ? Positioned(
                      top: 10,
                      right: 0,
                      child: Icon(tailIcon, size: 22))
                  : const SizedBox.shrink()
            ]
        ),
      ),
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: position == ToastPosition.bottom
        ? ToastGravity.BOTTOM : ToastGravity.TOP,
    toastDuration: const Duration(seconds: 3),
    positionedToastBuilder: (context, child) {
      return Positioned(
        top:  position == ToastPosition.top ? 60 : null,
        bottom: position == ToastPosition.bottom ? 54 : null,
        left: 16,
        right: 16,
        child: child,
      );
    }
  );
}

enum ToastPosition {
  top,
  bottom
}