import 'package:flutter/material.dart';

import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';
import '../../../services/utils.dart';

class ModalProfileUpdate extends StatefulWidget {
  const ModalProfileUpdate({Key? key,
    required this.title,
    required this.sub,
    this.subColor,
    this.emoji,
    this.newValue,
    this.description,
    this.originValue,
    this.buttonTitle
  }) : super(key: key);

  final String title;
  final String sub;
  final Color? subColor;
  final String? emoji;
  final String? newValue;
  final String? description;
  final String? originValue;
  final String? buttonTitle;

  @override
  State<ModalProfileUpdate> createState() => _ModalProfileUpdateState();
}

class _ModalProfileUpdateState extends State<ModalProfileUpdate> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _header(),
        widget.emoji == null && widget.newValue == null && widget.description == null && widget.originValue == null
            ? const SizedBox.shrink() : _description(),
        _bottomButtons(),
      ],
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(    // drag indicator bar
          height: 20,
          color: Colors.transparent,
          alignment: Alignment.topCenter,
          child: Container(
            height: 5, width: 36,
            margin: const EdgeInsets.all(7.5),
            decoration: BoxDecoration(
                color: kColor.grey100,
                borderRadius: BorderRadius.circular(6)
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(widget.title ?? '', style: kTextStyle.title1ExtraBold24)),
              const SizedBox(height: 10),

              Text(widget.sub ?? '', maxLines: 3, style: kTextStyle.callOutMedium16
                  .copyWith(color: widget.subColor ?? kColor.grey300)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _description() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
            text: TextSpan(
                children: [
                  TextSpan(text: '️${widget.emoji ?? ''} ', style: const TextStyle(fontSize: 24)),
                  TextSpan(text: widget.newValue ?? '', style: kTextStyle.headlineExtraBold18)
                ])
        ),
        Row(
          children: [
            SizedBox(width: getTextSize('${widget.emoji ?? ''}️ ', const TextStyle(fontSize: 24)).width),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(widget.description ?? '', style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey300)),
            ),
            Flexible(
                child: Text(widget.originValue ?? '', textAlign: TextAlign.start,
                    style: kTextStyle.callOutBold16))
          ],
        )
      ],
    );
  }

  Widget _bottomButtons() {
    String title;
    if (widget.buttonTitle != null) {
      title = widget.buttonTitle!;
    } else {
      title = '수정하기';
    }
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 20, bottom: 40 + service.bottomMargin.value),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  height: 56,
                  width: MediaQuery.of(context).size.width * 0.43,
                  // margin: const EdgeInsets.only(top: 12, bottom: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: kColor.grey30,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text('취소', style: kTextStyle.headlineExtraBold18),
                ),
              ),

              GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 56,
                  width: MediaQuery.of(context).size.width * 0.43,
                  // margin: const EdgeInsets.only(top: 12, bottom: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: kColor.blue100,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(title, style: kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
