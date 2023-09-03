import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iden/services/extensions.dart';

import '../../../model/user.dart';
import '../../common_widget/custom_profile_image_stack.dart';
import '../../../model/omg_card_model.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';

class BestCards extends StatefulWidget {
  const BestCards({Key? key,
    required this.user
  }) : super(key: key);

  final User user;

  @override
  State<BestCards> createState() => _BestCardsState();
}

class _BestCardsState extends State<BestCards> {
  bool isLoading = true;
  List<OmgCard> bestCards = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return _myIden();
  }

  Widget _myIden() {
    String? rel;
    if (widget.user.identityReliability != null) {
      rel = '${widget.user.identityReliability}%';
    }

    return Container(
      // height: 158,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: kColor.grey20,
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                '#34343A'.toColor(),
                '#131314'.toColor()
              ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(kIcon.idenLogoSvg, height: 14, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                Column(
                  children: [
                    widget.user.profileImageKey != null
                        ? CustomCacheNetworkImage(imageUrl: widget.user.profileImageKey, size: 40)
                        : customCircleAvatar(name: widget.user.name ?? '-', size: 40, fontSize: 22),
                    Text(widget.user.name ?? '-', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey100))
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('신뢰도', style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey300)),
                    Text(rel ?? '-', style: kTextStyle.caption2Medium12.copyWith(color: kColor.grey300))
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(widget.user.identityTitle ?? '-', textAlign: TextAlign.center,
                  style: kTextStyle.title1ExtraBold24.copyWith(color: Colors.white)),
            ),
            Text(widget.user.identityContent ?? '-', style: kTextStyle.footnoteMedium14.copyWith(color: Colors.white, height: 1.5)),
            const SizedBox(height: 15),
            Text(widget.user.createdAt!.toTimeFormatSimple(), style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
            const SizedBox(height: 10),
          ],
        )
    );
  }
}
