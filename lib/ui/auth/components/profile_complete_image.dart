import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';

import '../../../model/user.dart';
import '../../../resource/images.dart';
import '../../../controller/state_controller.dart';

class ProfileCompleteImage extends StatelessWidget {
  const ProfileCompleteImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            width: double.infinity,
            height: 330,
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: SvgPicture.asset(kImage.flashSvg, fit: BoxFit.cover)
        ),
        Container(
          width: double.infinity,
          height: 330,
          padding: const EdgeInsets.only(left: 15, right: 15),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                child:  service.profileImage.value.isNotEmpty
                    ? Image.file(File(service.profileImage.value), fit: BoxFit.cover)
                    : SvgPicture.asset(
                        service.userMe.value.gender == Gender.male
                            ? kImage.noProfileMale : kImage.noProfileFemale, fit: BoxFit.cover)
            ),
          ),
        )
      ],
    );
  }
}