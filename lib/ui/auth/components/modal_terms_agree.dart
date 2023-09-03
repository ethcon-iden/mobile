import 'package:flutter/material.dart';

import '../../common_widget/scroll_indicator._bar.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';

Future showModalTermsAgree(context) {
  return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return const _Agreement();
      }
  );
}

void _move2Page(BuildContext context, Widget page) {
  Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) => page),
  );
}

class _Agreement extends StatefulWidget {
  const _Agreement({Key? key}) : super(key: key);

  @override
  State<_Agreement> createState() => _AgreementState();
}

class _AgreementState extends State<_Agreement> {
  bool agreePhoneAuth = true;
  bool agreeOver14 = true;
  bool agreePrivacy = true;
  bool agreeService = true;
  bool isReadyToGo = true;
  String? born14ago;

  @override
  void initState() {
    super.initState();
    born14ago = service.calcAge14();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450 + service.bottomMargin.value,
      padding: EdgeInsets.only(left: 15, right: 20, top: 8, bottom: service.bottomMargin.value),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24)
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScrollIndicatorBar(),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 10),
            child: RichText(text: TextSpan(
                children: [
                  TextSpan(text: '약관에 동의해주세요\n', style: kTextStyle.title1ExtraBold24),
                  TextSpan(text: '*', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.red100, height: 2)),
                  TextSpan(text: ' 표시는 필수 항목이에요.', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300, height: 2)),
                ]
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 6),
            child: Row(    // 만 14세 이상
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _checkRound(context, 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(text: TextSpan(
                        children: [
                          TextSpan(text: '만 14세 이상이에요. ', style: kTextStyle.callOutBold16),
                          TextSpan(text: '*', style: kTextStyle.callOutBold16.copyWith(color: kColor.red100)),
                        ]
                    )),
                    Text('${born14ago ?? ''} 이전에 태어났어요', style: kTextStyle.caption2Medium12.copyWith(height: 2)),
                  ],
                ),
              ],
            ),
          ),

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _checkRound(context, 0),
                    Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 18),
                      child: RichText(text: TextSpan(
                          children: [
                            TextSpan(text: '제3자 정보제공에 동의해요. ', style: kTextStyle.callOutBold16),
                            TextSpan(text: '*', style: kTextStyle.callOutBold16.copyWith(color: kColor.red100)),
                          ]
                      )),
                    ),
                  ],
                ),
                GestureDetector(
                    onTap: () {},
                    child: Container(
                        color: Colors.transparent,
                        height: 30,
                        width: 40,
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.black))
                )
              ]
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _checkRound(context, 2),
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 18),
                    child: RichText(text: TextSpan(
                        children: [
                          TextSpan(text: '개인정보 처리방침에 동의해요. ', style: kTextStyle.callOutBold16),
                          TextSpan(text: '*', style: kTextStyle.callOutBold16.copyWith(color: kColor.red100)),
                        ]
                    )),
                  ),
                ],
              ),
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      color: Colors.transparent,
                      height: 30,
                      width: 40,
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.black))
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _checkRound(context, 3),
                  Padding(
                    padding: const EdgeInsets.only(top: 18, bottom: 18),
                    child: RichText(text: TextSpan(
                        children: [
                          TextSpan(text: '서비스 이용약관에 동의해요. ', style: kTextStyle.callOutBold16),
                          TextSpan(text: '*', style: kTextStyle.callOutBold16.copyWith(color: kColor.red100)),
                        ]
                    )),
                  ),
                ],
              ),
              GestureDetector(
                  onTap: () {},
                  child: Container(
                      color: Colors.transparent,
                      height: 30,
                      width: 40,
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: Colors.black))
              )
            ],
          ),

          _button(context)
        ],
      ),
    );
  }


  Widget _checkRound(context, int val) {
    bool isSelected;
    if (val == 0) {
      isSelected = agreePhoneAuth;
    } else if (val == 1) {
      isSelected = agreeOver14;
    } else if (val == 2) {
      isSelected = agreePrivacy;
    } else {
      isSelected = agreeService;
    }

    return Container(
      width: 45,
      alignment: Alignment.centerLeft,
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
            value: isSelected,
            visualDensity: VisualDensity.compact,
            shape: const CircleBorder(),
            side: BorderSide(width: 1.5, color: kColor.grey100),
            activeColor: kColor.blue100,
            onChanged: (value) {
              if (val == 0) {
                agreePhoneAuth = value!;
              } else if (val == 1) {
                agreeOver14 = value!;
              } else if (val == 2) {
                agreePrivacy = value!;
              } else {
                agreeService = value!;
              }
              isSelected = value;

              if (agreePhoneAuth && agreeOver14 && agreePrivacy && agreeService) {
                isReadyToGo = true;
              } else {
                isReadyToGo = false;
              }

              setState(() {});
            }
        ),
      ),
    );
  }

  Widget _button(context) {
    return GestureDetector(
      onTap: () {
        if (isReadyToGo) Navigator.of(context).pop(true);
      },
      child: Container(
        height: 56,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
            color: isReadyToGo ? kColor.blue100 : kColor.grey100,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Text('모두 동의하고 다음으로', style: kTextStyle.buttonWhite),
      ),
    );
  }
}
