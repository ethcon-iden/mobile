import 'package:flutter/material.dart';

import '../../../ui/common_widget/scroll_indicator._bar.dart';
import '../../../resource/images.dart';
import '../../../controller/state_controller.dart';
import '../../../services/extensions.dart';
import '../../../resource/style.dart';
import '../../../resource/kConstant.dart';

Future showModalLastConfirm(context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: 300 + service.bottomMargin.value,
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 40 + service.bottomMargin.value),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24)
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScrollIndicatorBar(),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text('마지막으로 확인할게요!', style: kTextStyle.title1ExtraBold24),
                  ),
                  FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('아래 정보들은 가입 후에, 딱 한 번씩만 수정할 수 있어요.', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))
                  ),
                ],
              ),

              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.username.value, style: kTextStyle.callOutBold16),
                          RichText(text: TextSpan(
                            children: [
                              TextSpan(text: service.userSchoolName.value, style: kTextStyle.callOutBold16.copyWith(color: kColor.grey300)),
                              TextSpan(text: ' ${service.userSchoolYear.value}학년 ', style: kTextStyle.callOutBold16),
                              TextSpan(text: '${service.userSchoolClass.value}반 ', style: kTextStyle.callOutBold16),
                              TextSpan(text: kConst.gender[service.userGender.value], style: kTextStyle.callOutBold16),
                            ]
                          )),
                        ]
                    ),
                  ],
                ),
              ),
              _buttons(context)
            ],
          ),
        );
      }
  );
}

Widget _buttons(context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(    // cancel
        onTap: () {
          Navigator.of(context).pop(false);
        },
        child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width * 0.43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12)
          ),
          child: Text('잠깐만요', style: kTextStyle.buttonBlack),
        ),
      ),

      GestureDetector(  // okay
        onTap: () {
          Navigator.of(context).pop(true);
        },
        child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width * 0.43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: '#005CFF'.toColor(),
              borderRadius: BorderRadius.circular(12)
          ),
          child: Text('맞아요', style: kTextStyle.buttonWhite),
        ),
      )
    ],
  );
}
