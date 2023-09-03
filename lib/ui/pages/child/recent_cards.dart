import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iden/rest_api/api.dart';

import '../../common_widget/custom_profile_image_stack.dart';
import '../../common_widget/common_widget.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/lotti_animation.dart';
import '../../../model/omg_card_model.dart';
import '../../../model/session.dart';
import '../../../model/user.dart';
import '../../../resource/style.dart';
import '../../../controller/state_controller.dart';
import '../../../rest_api/card_api.dart';

class RecentCards extends StatefulWidget {
  const RecentCards({Key? key,
    required this.userId
  }) : super(key: key);

  final String? userId;

  @override
  State<RecentCards> createState() => _RecentCardsState();
}

class _RecentCardsState extends State<RecentCards> {
  /// 실시간 카드
  late StreamController<dynamic> _streamController;
  bool isLoading4recentCard = true;
  List<OmgCard> recentCards = [];
  Paging paging = Paging();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<dynamic>();
    _getBestCard();
  }

  void _getBestCard() async {
    List<OmgCard> cards = [];
    List<OmgCard> all = recentCards;
    String? userId = widget.userId;

    if (userId?.isNotEmpty == true) {
      final HttpsResponse res = await IdenApi.getBestCard(userId!);
      isLoading = false;

      if (res.statusType == StatusType.success || res.statusType == StatusType.empty) {
        if (res.body?.isNotEmpty == true) {
          for (var e in res.body) {
            cards.add(OmgCard.fromJson(e));
          }
        }

        all += cards;
        recentCards = all;

      } else {  // 에러
        ErrorResponse error = res.body;
        _showError(error.message);
      }
    }

    if (!_streamController.isClosed) _streamController.add(recentCards);
    if (mounted) setState(() {});
  }

  void _showError(String? message) => showErrorMessage(context, message);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Column(   // 실시간 카드들
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 12),
          child: Text('가장 많이 받은 평가', style: kTextStyle.title2ExtraBold22),
        ),

        if (!isLoading)  // false -> 데이터 표시
          if (recentCards.isNotEmpty)
            _buildItems(recentCards)    // 최고의 카드 보이기
          else CommonWidget.emptyCase(context, '🕳️', '받은 카드 없음')   // 카드 없음
        else LottieAnimation.loading(40)   // 로딩
      ],
    );
  }

  Widget _buildItems(List<OmgCard> cards) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: cards.length,
        itemBuilder: (BuildContext context, int index) {
          return _card(cards[index]);
        }
    );
  }

  Widget _card(OmgCard card) {
    TextStyle styleGrey = kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500);
    TextStyle styleBold = kTextStyle.subHeadlineBold14;

    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: kColor.grey20,
            borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          children: [
            card.emoji != null
                ? Text(card.emoji!, style: const TextStyle(fontSize: 72))
                : const SizedBox(height: 72),   // todo > default emoji in case empty

            Padding(    // 질문
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(card.question ?? '-', textAlign: TextAlign.center,
                  style: kTextStyle.headlineExtraBold18),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RichText(text: TextSpan(
                children: [   //이 카드를 97번 받았고, 152명이 공감했어요.
                  TextSpan(text: '이 카드를 ', style: styleGrey),
                  TextSpan(text: '${card.cardCount ?? '-'}번', style: styleBold),
                  TextSpan(text: ' 받았고, ', style: styleGrey),
                  TextSpan(text: '${card.likeCount ?? '-'}명', style: styleBold),
                  TextSpan(text: '이 공감했어요.', style: styleGrey),
                ]
              )),
            )
          ],
        )
    );
  }
}
