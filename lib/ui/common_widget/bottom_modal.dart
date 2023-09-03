import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../controller/state_controller.dart';
import '../../model/user.dart';
import '../../resource/kConstant.dart';
import '../pages/child/modal_user_profile.dart';

Future<dynamic> modalCupertino(BuildContext context, Widget widget, bool enableDrag) async {
  dynamic result;
  await showCupertinoModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      expand: true,
      enableDrag: enableDrag,
      isDismissible: false,
      topRadius: const Radius.circular(20),
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            double topHeight = 60;
            if (details.localPosition.dy < topHeight) {
              print('---> close triggered');
            }
          },
          child: Material(
            child: Container(
              padding: EdgeInsets.only(bottom: kConst.bottomButtonMargin + service.bottomMargin.value),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)
                  )
              ),
              child: widget,
            ),
          ),
        );
      }
  ).then((value) {
    result = value;
  });
  return Future.value(result);
}

Future<dynamic> showCustomBottomSheet(BuildContext context,
    Widget widget, double height, bool enableDrag, {Color? background}) async {
  dynamic result;

  await showModalBottomSheet(
    context: context,
    enableDrag: enableDrag,
    barrierColor: Colors.black.withOpacity(0.6),
    isScrollControlled: true, // Allow the sheet to take up the full height
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
    ),
    builder: (context) {
      return Container(
        height: height,
        decoration: BoxDecoration(
            color: background ?? Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20)
            )
        ),
        child: widget,
      );
    }
  ).then((value) {
    print('---> custom bottom sheet > value: $value');
    result = value;
  });

  return Future.value(result);
}

void showCupertinoModal4userProfile(BuildContext context, String userId) async {
  print('---> following friends > cupertino modal > userId: $userId');
  final res = await modalCupertino(
      context,
      ModalUserProfile(userId: userId),
      false
  );
  if (res != null && res) {
    // todo
  }
}