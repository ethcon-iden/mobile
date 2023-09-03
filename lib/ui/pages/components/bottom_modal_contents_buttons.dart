import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common_widget/scroll_indicator._bar.dart';
import '../../../resource/style.dart';

class ModalContentsButtons extends StatelessWidget {
  const ModalContentsButtons({Key? key,
    this.header,
    this.sub,
    this.bottomSub,
    required this.listTitle,
    required this.listColor,
    this.background,
    required this.listIcon  // svg format
  }) : super(key: key);

  final String? header;
  final String? sub;
  final String? bottomSub;
  final List<String> listTitle;
  final List<Color> listColor;
  final List<Color>? background;
  final List<String?> listIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ScrollIndicatorBar(),
        const SizedBox(height: 15),
        header !=null ? _header() : const SizedBox.shrink(),
        Expanded(child: _buildButtonList()),

      ],
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(header!, style: kTextStyle.title1ExtraBold24)),
          if (sub != null) const SizedBox(height: 10),
          if (sub != null)
            FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(sub!, style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey300))),
        ],
      ),
    );
  }

  Widget _buildButtonList() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: listTitle.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == listTitle.length - 1) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  _button(context, index),
                  _bottomSub(),
                ],
              ),
            );
          } else {
            return _button(context, index);
          }
        }
    );
  }

  Widget _button(BuildContext context, index) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, index),
      child: Container(
        height: 60,
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top:4, bottom: 4),
        decoration: BoxDecoration(
            color: background != null ? background![index] : kColor.grey30,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            listIcon[index] != null
                ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SvgPicture.asset(listIcon[index]!, height: 20, width: 20),
                )
                : const SizedBox.shrink(),

            Text(listTitle[index], style: kTextStyle.headlineExtraBold18.copyWith(color: listColor[index])),
          ],
        ),
      ),
    );
  }

  Widget _bottomSub() {
    return bottomSub != null
        ? Container(
            margin: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 1, color: Colors.black))
            ),
        child: Text(bottomSub!, style: kTextStyle.subHeadlineBold14.copyWith(color: Colors.black))
    )
        : const SizedBox.shrink();
  }
}
