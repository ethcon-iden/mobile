import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../model/user.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';
import '../../../model/omg_card_model.dart';
import '../../common_widget/bottom_modal.dart';
import '../child/modal_user_profile.dart';

class CardBoxDetailBack extends StatefulWidget {
  const CardBoxDetailBack({Key? key,
    required this.omgCard,
  }) : super(key: key);

  final OmgCard? omgCard;

  @override
  State<CardBoxDetailBack> createState() => _CardBoxDetailBackState();
}

class _CardBoxDetailBackState extends State<CardBoxDetailBack> {
  bool isActivated = true;
  String? profileImage;
  User? omgUser;

  @override
  void initState() {
    super.initState();
    _setOmgUser();
  }

  void _setOmgUser() {
    User? user = widget.omgCard?.sender;
    omgUser = user;
    profileImage = user?.profileImageKey;
  }

  // void _modal2BuddyProfile(User user) => modalCupertino(context, ModalUserProfile(userId: user), true);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      decoration: BoxDecoration(
        color: kColor.blue10,
        borderRadius: BorderRadius.circular(28)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _profileImage(),
          _whoSendInfo(),
          _checkProfile()
        ],
      ),
    );
  }

  Widget _profileImage() {
    return Stack(
      children: [
        SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.7,
            child: SvgPicture.asset(kImage.flashSvg, fit: BoxFit.cover)
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width * 0.7,
          padding: const EdgeInsets.all(15),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.28,
                height: MediaQuery.of(context).size.width * 0.28,
                child: profileImage != null
                    ? Image.network(profileImage!, fit: BoxFit.contain)
                    : SvgPicture.asset(kImage.noProfileMale, fit: BoxFit.cover)
            ),
          ),
        )
      ],
    );
  }

  Widget _whoSendInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(omgUser?.name ?? ' ', style: kTextStyle.largeTitle28),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(omgUser?.nickname ?? ' ', style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey900)),
        ),
        Text(omgUser?.schoolInfo ?? ' ', style: kTextStyle.bodyMedium18.copyWith(color: kColor.grey500)),
      ],
    );
  }

  Widget _checkProfile() {
    return GestureDetector(
      onTap: () {
        String? userId = omgUser?.id;
        if (userId?.isNotEmpty == true) {
          showCupertinoModal4userProfile(context, userId!);
        }
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
        child: Text('프로필 보기', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.blue100)),
      ),
    );
  }
}

class CardShrink4CommentBack extends StatelessWidget {
  const CardShrink4CommentBack({Key? key}) : super(key: key);

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
    );
  }
}
