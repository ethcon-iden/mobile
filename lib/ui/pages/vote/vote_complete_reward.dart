import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';

import '../../common_widget/custom_button.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';

class VoteCompleteReward extends StatefulWidget {
  const VoteCompleteReward({Key? key,
    this.totalVoteCount = 0,
    required this.emojis,
    required this.candidates,
    this.isPoll = false,
  }) : super(key: key);

  final int totalVoteCount;
  final bool isPoll;
  final List<String> emojis;
  final List<String> candidates;

  @override
  State<VoteCompleteReward> createState() => _VoteCompleteRewardState();
}

class _VoteCompleteRewardState extends State<VoteCompleteReward> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int reward = 5;

  @override
  void initState() {
    super.initState();
    print('---> emojis: ${widget.emojis}');
    print('---> candidates: ${widget.candidates}');
    _controller = AnimationController(
        vsync: this,
        lowerBound: 0.4,
        duration: const Duration(milliseconds: 2500)
    )..forward().then((value) => _controller.stop());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _completeVote() {
    service.updateCookieBalance();
    service.startCountdownTimer4Vote(null); // null -> start for 30 min
    service.saveVoteCountdownTime();
    _move2homeVote();
  }

  void _move2homeVote() => Navigator.pop(context, true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
      ),
      bottomSheet: SafeArea(child: _confirmButton()),
      body: SafeArea(
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 400),
          child: _rippleEffect(),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: _rewardSummary(),
            ),
            _listview(),
            const SizedBox(height: 30),
            Text('선택된 친구들에게 투표 카드 발송됨', style: kTextStyle.callOutMedium16.copyWith(color: kColor.grey300)),
            const SizedBox(height: 10),
            Text('5개 질문 모두 완료', style: kTextStyle.largeTitle28),
            const SizedBox(height: 120),
          ],
        ),
      ],
    );
  }

  Widget _rewardSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(child: Text('+5 IDEN', style: kTextStyle.largeTitle28.copyWith(fontWeight: FontWeight.w600))),
        const SizedBox(height: 20,),
        CustomButtonSmall(
          height: 37,
          width: 115,
          titleNorm: '내 자산 : 5 IDEN',
          colorNorm: kColor.grey300,
          backgroundNorm: kColor.grey30,
        )
      ],
    );
  }

  Widget _rippleEffect() {
    return AnimatedBuilder(
      animation: CurvedAnimation(
          parent: _controller,
          curve: Curves.fastOutSlowIn
      ),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildContainer(250 * _controller.value),
            _buildContainer(400 * _controller.value),
            _buildContainer(650 * _controller.value),
            Align(child: SvgPicture.asset(kImage.idenReward, height: 100, width: 100))
          ],
        );
      },
    );
  }

  Widget _listview() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: widget.emojis.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 20 : 0,
                right: index == widget.emojis.length - 1 ? 20 : 0
              ),
              child: _box(widget.emojis[index], widget.candidates[index]),
            );
          }),
    );
  }

  Widget _box(String emoji, String name) {
    return Stack(
      children: [
        Container(
          height: 72,
          width: 92,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(left: 4, right: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kColor.grey30
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 44)),
        ),

        Positioned(
            right: 10,
            bottom: 6,
            child: customCircleAvatar(name: name, size: 26, fontWeight: FontWeight.w800))
          ],
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1, color: Colors.grey.shade500.withOpacity(1 - _controller.value))
      ),
    );
  }

  Widget _confirmButton() {
    return CustomButtonWide(
      title: '확인',
      titleColor: Colors.white,
      background: Colors.black,
      hasBottomMargie: true,
      onTap: () => _completeVote(),
    );
  }
}
