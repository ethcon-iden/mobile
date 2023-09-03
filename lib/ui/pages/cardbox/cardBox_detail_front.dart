import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:screenshot/screenshot.dart';

import '../../common_widget/custom_profile_image_stack.dart';
import '../../../services/extensions.dart';
import '../../../model/omg_card_model.dart';
import '../../../model/user.dart';
import '../../../resource/images.dart';
import '../../../resource/style.dart';
import '../../common_widget/bottom_modal.dart';
import '../../common_widget/custom_snackbar.dart';
import '../child/modal_user_profile.dart';
import '../../../services/image_handler.dart';

class CardBoxDetailFront extends StatefulWidget {
  const CardBoxDetailFront({Key? key,
    required this.omgCard,
    required this.direction,
    required this.isExpanded,
    required this.isAnimatedOn
  }) : super(key: key);

  final OmgCard omgCard;
  final CardDirection direction;
  final bool isExpanded;
  final bool isAnimatedOn;

@override
  State<CardBoxDetailFront> createState() => _CardBoxDetailFrontState();
}

class _CardBoxDetailFrontState extends State<CardBoxDetailFront> with SingleTickerProviderStateMixin{
  final GlobalKey _globalKey = GlobalKey();
  final ScreenshotController _screenshotController = ScreenshotController();
  late bool isCardReceive;
  User? omgUser;  // 보낸 친구 or 받는 친구
  int? whereIndex;
  /// for animate controller
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _animation1;
  double paddingSize = 0;
  double emojiSize = 100;

  @override
  void initState() {
    print('---> CardDetailFront > init state');
    super.initState();
    _setCardInfo();
    _setAnimation();
  }

  @override
  void didUpdateWidget(CardBoxDetailFront oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimatedOn) {
      if (widget.isExpanded) {  // 댓글 닫기
        _animationController.reverse();
      } else {  // 댓글 보기
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    final tween = Tween<double>(begin: 0.0, end: 40.0);
    final tween1 = Tween<double>(begin: 100.0, end: 120.0);

    _animation = tween.animate(_animationController)
      ..addListener(() {
        setState(() {
          paddingSize = _animation.value;
        });
      });
    _animation1 = tween1.animate(_animationController)
      ..addListener(() {
        setState(() {
          emojiSize = _animation1.value;
        });
      });
  }

  void _setCardInfo() {
    if (widget.direction == CardDirection.receive) {  // 받은 카드
      isCardReceive = true;
      CardReceiveFrom? info = widget.omgCard.cardReceiveFrom;
      if (info != null) {
        omgUser = info.whoSend;
        whereIndex = info.whereIndex;
      }
    } else {  // 보낸 카드
      isCardReceive = false;
      CardSendTo? info = widget.omgCard.cardSendTo;
      if (info != null) {
        omgUser = info.whoReceive;
        whereIndex = info.whereIndex;
      }
    }
  }

  void _showSnackbar(String emoji, String title) {
    customSnackbar(context, emoji, title, ToastPosition.top);
  }

  // void _modal2BuddyProfile(User user) => modalCupertino(context, ModalUserProfile(userId: user), true);

  @override
  Widget build(BuildContext context) {
    return _captureImage();
  }

  Widget _captureImage() {
    return RepaintBoundary(
        key: _globalKey,
        child: _body());
  }

  Widget _body() {
    double height = MediaQuery.of(context).size.height;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: widget.isExpanded ? height * 0.70 : height * 0.42,
        width: double.infinity,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28)
        ),
        child: widget.isExpanded
            ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _userInfo(),
            ),
            widget.isExpanded ? _candidates() : const SizedBox.shrink(),
            widget.isExpanded ? _snsShare() : const SizedBox.shrink()
          ],
        )
            : _userInfoEnlarge()
    );
  }

  Widget _userInfo() {
    String clue;
    if (isCardReceive) {
      String? who = widget.omgCard.sender?.clueWithDot;  // 보낸 친구
      clue = who != null ? '$who에게 받았아요.' : '';
    } else {
        String? who = widget.omgCard.receiver?.name; // 받는 친구
        clue = who != null ? '$who 님에게 보냈어요.' : '';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(clue, style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
        ),
        Text(widget.omgCard.question ?? '', maxLines: 2, textAlign: TextAlign.center,
            style: kTextStyle.title2ExtraBold22),
        Expanded(
          child: widget.omgCard.emoji != null
              // ? _cacheNetworkImage(widget.omgCard.emoji!, 100)
              ? CustomCacheNetworkEmoji(emojiUrl: widget.omgCard.emoji!, size: 100)
              : const Text('🤓', style: TextStyle(fontSize: 72)),
        )
      ],
    );
  }

  Widget _userInfoEnlarge() {
    String clue;
    String? tmp = omgUser?.clueWithoutDot;  // 보낸 친구
    clue = tmp != null ? '$tmp이 보냈어요' : '';

    return AnimatedPadding(
      padding: EdgeInsets.only(top: paddingSize),
      duration: const Duration(milliseconds: 150),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(clue, style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Text(widget.omgCard.question ?? '', maxLines: 2, textAlign: TextAlign.center,
                style: kTextStyle.title1ExtraBold24),
          ),
          widget.omgCard.emoji != null
              // ? _cacheNetworkImage(widget.omgCard.emoji!, emojiSize)
              ? CustomCacheNetworkEmoji(emojiUrl: widget.omgCard.emoji!, size: emojiSize)
              : const Text('🤓', style: TextStyle(fontSize: 84))
        ],
      ),
    );
  }

  Widget _candidates() {
    List<User> users = List.generate(4, (index) => User());

    if (widget.omgCard.candidates != null) {
      int i = 0;
      for (var e in widget.omgCard.candidates!) {
        if (e.user != null) {
          users[i] = e.user!;
        }
        i++;
      }
    }

    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1/0.8,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      children: List.generate(4, (index) {
        // return _item(names[index], grade[index], genders[index], index);
        return _gridItem(users[index], index);
      }),
    );
  }

  Widget _gridItem(User user, int index) {
    double width = MediaQuery.of(context).size.width;
    Color backgroundColor = '#FFBD27'.toColor();
    String? profileImage = user.profileImageKey;
    if (user.profileImageKey != null) {
      profileImage = user.profileImageKey!;
    }
    String avatar;
    if (user.gender == Gender.male) {
      avatar = kImage.noProfileMale;
    } else {
      avatar = kImage.noProfileFemale;
    }
    int? whereIndex;
    if (isCardReceive) {
      whereIndex = widget.omgCard.cardReceiveFrom?.whereIndex;
    } else {
      whereIndex = widget.omgCard.cardSendTo?.whereIndex;
    }

    return GestureDetector(
      onTap: () {
        if (isCardReceive && index == whereIndex) {
          print('---> user profile skip since it is me');
        } else {
          String? userId = user.id;
          if (userId?.isNotEmpty == true) {
            showCupertinoModal4userProfile(context, userId!);
          }
        }
      },
      child: Container(
        width: width * 0.4,
        height: 120,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        foregroundDecoration: index == whereIndex
            ? null
            : BoxDecoration(  // 모든 내용을 grey 로 만듬
                  color: Colors.grey,
                  backgroundBlendMode: BlendMode.saturation,
                  borderRadius: BorderRadius.circular(20),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: index == whereIndex ? backgroundColor : kColor.grey20,
            gradient: index == whereIndex
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      backgroundColor,
                      backgroundColor.withOpacity(0.5)
                    ]
                  )
                : null
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 40,
                width: 40,
                child: profileImage != null
                    ? CachedNetworkImage(imageUrl: profileImage, fit: BoxFit.cover,
                        // placeholder: (context, _) => SvgPicture.asset(avatar, fit: BoxFit.contain),
                        errorWidget: (context, _, err) => SvgPicture.asset(avatar, fit: BoxFit.cover),
                      )
                    : SvgPicture.asset(avatar, fit: BoxFit.contain),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(user.name ?? '', style: index == whereIndex
                      ? kTextStyle.callOutBold16
                      : kTextStyle.callOutBold16.copyWith(color: kColor.grey1000.withOpacity(0.5))
                  ),
                ),
                Text(user.clueWithDot ?? '', style: index == whereIndex
                    ? kTextStyle.caption2Medium12
                    : kTextStyle.caption2Medium12.copyWith(color: kColor.grey500.withOpacity(0.5)))
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _snsShare() {
    String message;
    String iconSvg;
    if (isCardReceive) {  // 받은
      message = '스토리에 공유하기';
      iconSvg = kIcon.instagram;
    } else {
      message = '이미지로 저장하기';
      iconSvg = kIcon.download;
    }
    return GestureDetector(
      onTap: () {   // todo
        HapticFeedback.mediumImpact();
        // if (isCardReceive) {    // 받은 카드
        //   // todo
        // } else {  // 보낸 카드
        //   _captureAndSaveImage();
        // }
        // Get.to(() => ShareScreenshot4card(omgCard: widget.omgCard));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(iconSvg, height: 18, width: 18,
                colorFilter: ColorFilter.mode(isCardReceive ? kColor.blue100 : kColor.grey900, BlendMode.srcIn)),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(message, style: kTextStyle.subHeadlineBold14
                  .copyWith(color: isCardReceive ? kColor.blue100 : kColor.grey900)),
            )
          ],
        ),
      ),
    );
  }
}

class CardShrink4CommentFront extends StatefulWidget {
  const CardShrink4CommentFront({Key? key,
    required this.omgCard,
    required this.direction,
  }) : super(key: key);

  final OmgCard omgCard;
  final CardDirection direction;

  @override
  State<CardShrink4CommentFront> createState() => _CardShrink4CommentFrontState();
}

class _CardShrink4CommentFrontState extends State<CardShrink4CommentFront> {
  late bool isReceived;
  String clue = '';
  String emoji = '';

  @override
  void initState() {
    super.initState();
    if (widget.direction == CardDirection.receive) {
      isReceived = true;
      CardReceiveFrom? info = widget.omgCard.cardReceiveFrom;
      if (info?.whoSend?.clueWithDot != null) {
        clue = '${info?.whoSend?.clueWithDot}이 보냈어요';
      }
    } else {
      isReceived = false;
      CardSendTo? info = widget.omgCard.cardSendTo;
      if (info?.whoReceive?.clueWithDot != null) {
        clue = '${info?.whoReceive?.clueWithDot}이 보냈어요';
      }
    }
    if (widget.omgCard.emoji != null) {
      emoji = widget.omgCard.emoji!;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Container(
      height: height * 0.35,
      width: double.infinity,
      margin: const EdgeInsets.only(left: 20, right: 20),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28)
      ),
      child: _userInfo(),
    );
  }

  Widget _userInfo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(clue, style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
        ),
        Text(widget.omgCard.question ?? '', maxLines: 2, textAlign: TextAlign.center,
            style: kTextStyle.title1ExtraBold24),
        Expanded(
          child: emoji.isNotEmpty
              ? _cacheNetworkImage(emoji)
              : const Text('🤓', style: TextStyle(fontSize: 72)),
        )
      ],
    );
  }

  Widget _cacheNetworkImage(String url) {
    double size = 100;
    return CachedNetworkImage(imageUrl: url, height: size, width: size,
      // placeholder: (context, _) => const Text('🤓', style: TextStyle(fontSize: 72)),
      errorWidget: (context, _, err) => const Text('🤓', style: TextStyle(fontSize: 72)),
    );
  }
}

class _ImageToBeSaved extends StatelessWidget {
  const _ImageToBeSaved({Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      padding: const EdgeInsets.all(10),
      child: child,
    );
  }
}
