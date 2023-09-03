import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../model/user.dart';
import '../../resource/images.dart';
import '../../resource/style.dart';
import '../../resource/kConstant.dart';

class CustomProfileImageStack extends StatelessWidget {
  const CustomProfileImageStack({Key? key,
    required this.imageUrl,
    required this.size
  }) : super(key: key);

  final List<String?> imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    bool hasMoreThanTwoImages = false;
    List<String> images = [];   // 이미지 URL 존재하는 리스트
    String? imageUrl1;
    String? imageUrl2;

    /// 프로필 이미지가 있는 경우만 추출 -> 새로 리스트 생성
    if (imageUrl.isNotEmpty) {
      for (String? e in imageUrl) {
        if (e != null) images.add(e);
      }
      if (imageUrl.length >= 2) hasMoreThanTwoImages = true;
    }

    if (images.length >= 2) {
      imageUrl1 = images.first;
      imageUrl2 = images[1];
    } else if (images.length == 1) {
      imageUrl1 = images.first;
    }

    return SizedBox(
      width: 45,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          SizedBox(
              height: size,
              width: size,
              child: CustomCacheNetworkImage(imageUrl: imageUrl2, size: size)),

          if (hasMoreThanTwoImages)
            Positioned(
              left: size / 2,
              child: Container(
                  height: size + 6,
                  width: size + 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(width: 3, color: kColor.blue10)
                  ),
                  child: CustomCacheNetworkImage(imageUrl: imageUrl1, size: size)),
            ),
        ],
      ),
    );
  }
}

class CustomAvatarStack extends StatelessWidget {
  const CustomAvatarStack({Key? key,
    required this.users,
    required this.size,
    required this.background
  }) : super(key: key);

  final List<User> users;
  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    bool hasMoreThanTwo = false;
    List<String> names = []; // 이름 리스트
    String name1 = '';
    String name2 = '';

    /// 프로필 이미지가 있는 경우만 추출 -> 새로 리스트 생성
    if (users.isNotEmpty) {
      for (var e in users) {
        if (e.name != null) names.add(e.name!);
      }
    }

    names = ['최수정','박별', '김사랑'];
    if (names.length >= 2) {
      hasMoreThanTwo = true;
      name1 = names.first;
      name2 = names[1];
    } else if (names.length == 1) {
      name1 = names.first;
    }

    return SizedBox(
        width: size * 2,
        child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              customCircleAvatar(name: name1, background: background),
              if (hasMoreThanTwo)
                Positioned(
                  left: size / 1.3,
                  child: Container(
                      height: size + 6,
                      width: size + 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(width: 3, color: kColor.blue10)
                      ),
                      child: customCircleAvatar(name: name2, background: background)
                  ),
                ),
            ])
    );
  }
}

Widget customCircleAvatar({required String name, Color? background, double? size, double? fontSize, FontWeight? fontWeight}) {
  String firstName = name.substring(0, 1);
  return Container(
    height: size ?? 40,
    width: size ?? 40,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: background ?? Colors.black
    ),
    child: Text(firstName, style: TextStyle(fontFamily: 'Pretendard',
      fontSize: fontSize ?? 14, fontWeight: fontWeight ?? FontWeight.w900, color: Colors.white)
    ),
  );
}

class CustomCacheNetworkImage extends StatelessWidget {
  const CustomCacheNetworkImage({Key? key,
    this.imageUrl,
    this.gender,
    this.isNew,
    required this.size
  }) : super(key: key);

  final String? imageUrl;
  final Gender? gender;
  final bool? isNew;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(size/2),
            child: _getImage()
        ),
        if (isNew == true)
          Positioned(   // red dot -> 새로 추가된 친구들 일 경우 표시
            top: 0,
            right: 0,
            child: Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kColor.red100
              ),
            ),
          )
      ],
    );
  }

  Widget _getImage() {
    return imageUrl != null
        ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover, height: size, width: size,
            placeholder: (context, _) => SizedBox(height: size, width: size),
          )
        : gender != null
            ? gender == Gender.female
              ? SvgPicture.asset(kImage.noProfileFemale, fit: BoxFit.cover, height: size, width: size)
              : SvgPicture.asset(kImage.noProfileMale, fit: BoxFit.cover, height: size, width: size)
            : SvgPicture.asset(kIcon.noProfileContact, fit: BoxFit.cover, height: size, width: size);
  }
}

class CustomCacheNetworkEmoji extends StatelessWidget {
  const CustomCacheNetworkEmoji({Key? key,
    required this.emojiUrl,
    required this.size,
  }) : super(key: key);

  final String emojiUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(imageUrl: emojiUrl, height: size, width: size,
      placeholder: (context, _) => const SizedBox(height: 100, width: 100),
      // errorWidget: (context, _, err) => const Text('🤓', style: TextStyle(fontSize: 72)),
    );
  }
}