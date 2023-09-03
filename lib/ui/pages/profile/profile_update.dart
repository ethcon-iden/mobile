import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../pages/profile/profile_class.dart';
import 'dart:io';

import '../../../model/session.dart';
import '../../../rest_api/user_api.dart';
import '../../../model/user.dart';
import '../../../ui/common_widget/divider.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';
import '../../../resource/images.dart';
import '../../../services/image_handler.dart';
import '../../common_widget/dialog_popup.dart';
import '../../common_widget/custom_snackbar.dart';
import 'profile_name.dart';
import 'profile_nickname.dart';
import 'profile_school.dart';
import 'profile_grade.dart';
import 'profile_gender.dart';
import 'profile_bio.dart';
import '../../common_widget/bottom_modal.dart';
import '../../../services/extensions.dart';

class ProfileUpdate extends StatefulWidget {
  const ProfileUpdate({Key? key,
    required this.gotoBio
  }) : super(key: key);

  final bool gotoBio;

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  /// update history
  bool? hasNicknameLock;  // 닉네임
  bool? hasNameLock;    // 이름
  bool? hasSchoolLock;  // 학교
  bool? hasGradeLock;   // 학년
  bool? hasGenderLock;  // 성별
  bool? hasClassLock;   // 반

  @override
  void initState() {
    super.initState();
    _move2SelfIntro();
    _checkUpdateHistory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkUpdateHistory() async {
    final HttpsResponse res = await UserApi.getUpdateHistory();
    if (res.statusType == StatusType.success) {
      final String? nicknameAt = res.body['nicknameUpdatedAt'];
      final nameAt = res.body['nameUpdatedAt'];
      final schoolAt = res.body['schoolIdUpdatedAt'];
      final gradeAt = res.body['gradeUpdatedAt'];
      final genderAt = res.body['genderUpdatedAt'];
      final classAt = res.body['classUpdatedAt'];

      if (nameAt != null) {
        hasNameLock = true;
      } else {
        hasNameLock = false;
      }
      if (schoolAt != null) {
        hasSchoolLock = true;
      } else {
        hasSchoolLock = false;
      }
      if (gradeAt != null) {
        hasGradeLock = true;
      } else {
        hasGradeLock = false;
      }
      if (genderAt != null) {
        hasGenderLock = true;
      } else {
        hasGenderLock = false;
      }
      if (classAt != null) {
        hasClassLock = true;
      } else {
        hasClassLock = false;
      }
      if (nicknameAt != null && nicknameAt.isNotEmpty) {
        DateTime? dt = nicknameAt.toDateTime();
        if (dt != null) {
          Duration diff = DateTime.now().difference(dt);
          if (diff >= const Duration(days: 14)) {   // 14일 경과
            hasNicknameLock = false;
          } else {  // 수정 후 14일 이전 -> lock
            hasNicknameLock = true;
          }
        }
      } else {
        hasNicknameLock = false;
      }
    } else {
      hasNameLock = false;
      hasSchoolLock = false;
      hasGradeLock = false;
      hasGenderLock = false;
      hasClassLock = false;
      hasNicknameLock = false;
    }
    print('---> lock: $hasNicknameLock | $hasNameLock | $hasSchoolLock | $hasGradeLock | $hasGenderLock | $hasClassLock');
    setState(() {});
  }

  void _move2SelfIntro() {
    if (widget.gotoBio) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _modalProfile(context, 2);
      });
    }
  }

  Future<void> _modalProfile(context, int index) {
    List<dynamic> updateField = <dynamic>[
      const ProfileName(),      // index 0
      const ProfileNickname(),  // index 1
      const ProfileBio(),  // index 2
      const ProfileSchool(),    // index 3
      const ProfileGrade(),     // index 4
      const ProfileClass() ,    // index 5
      const ProfileGender()     // index 6
    ];
    return modalCupertino(context, updateField[index], true).then((value) {
      if (value) {  // 확인 누른 후 리턴 된 경우
        _checkUpdateHistory();
      }
    });
  }

  void _modal2ProfileImage() async {
    final feedback = await showCustomBottomSheet(
        context,
        _modalProfileImageOption(),
        320 + service.bottomMargin.value, true
    );
    print('---> profile image >res: $feedback');

    if (feedback != null) {
      final HttpsResponse res = await UserApi.updateProfileImage(feedback);
      if (res.statusType == StatusType.success) {
        final result = await service.updateUserMeInfo(res.body, true);
        if (result) {
          _showSnackbarSuccess();
          setState(() {});
        } else {
          _showError();
        }
      } else {
        _showError();
      }
    }
  }

  void _setDefaultProfileImage() async {
    Navigator.pop(context);
    final HttpsResponse res = await UserApi.updateProfileImage('');
    if (res.statusType == StatusType.success) {
      service.profileImage.value = '';
      service.userMe.value.profileImageKey = '';
      _showSnackbarSuccess();
      setState(() {});
    } else {
      _showError();
    }
  }

  void _showError() => showSomethingWrong(context);

  void _showSnackbarSuccess() => customSnackbar(context, '✨', '프로필 사진이 수정되었어요.', ToastPosition.bottom);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: kStyle.appBar(context, '프로필 설정'),
      body: SafeArea(
        child: _body(),
      ),
    );
  }

  Widget _myPicture() {
    return GestureDetector(
      onTap: () {
        _modal2ProfileImage();
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: service.profileImage.value.isNotEmpty
                ? Image.file(File(service.profileImage.value),
                    fit: BoxFit.cover, height: 120, width: 120)
                : service.userMe.value.gender == Gender.male  // 성별에 따라 이미지 다르게 표현
                  ? SvgPicture.asset(kImage.noProfileMale, fit: BoxFit.cover, height: 120, width: 120)
                  : SvgPicture.asset(kImage.noProfileFemale, fit: BoxFit.cover, height: 120, width: 120)
          ),
          Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 20),
            child: Text('사진 수정', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.blue100)),
          ),

          const DividerHorizontal(paddingTop: 1, paddingBottom: 1)
        ],
      ),
    );
  }

  Widget _body() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _myPicture(),

        const SizedBox(height: 20),
        _title('이름'),
        _dataField(service.userMe.value.name ?? '', 0, hasNameLock),

        _title('닉네임'),
        _nickname(),

        _title('한 줄 소개'),
        _dataField(service.userMe.value.bio != null
            ? '${service.userMe.value.bio}' : null, 2, false),

        _title('학교'),
        _dataField(service.userMe.value.school?.name ?? '', 3, hasSchoolLock),

        _title('학년'),
        _dataField(service.userMe.value.schoolGrade != null
            ? service.userMe.value.schoolGrade!.full : '', 4, hasGradeLock),

        _title('반'),
        _dataField(service.userMe.value.classNo != null
            ? '${service.userMe.value.classNo}반' : '', 5, hasClassLock),

        _title('성별'),
        _dataField(service.userMe.value.gender != null
            ? service.userMe.value.gender!.student : '', 6, hasGenderLock),
      ],
    );
  }

  Widget _title(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 6),
      child: Text(title, style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300)),
    );
  }

  Widget _nickname() {
    String? nickname = service.userMe.value.nickname;

    return GestureDetector(
      onTap: () {
        if (hasNicknameLock != null && !hasNicknameLock!) {
          _modalProfile(context, 1)
              .then((_) => setState(() {}));
        }
      },
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(left: 24, right:  24, bottom: 16),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: kColor.grey30, width: 2))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(text: TextSpan(
                  children: [
                    TextSpan(text: '@ ', style: kTextStyle.bodyMedium18.copyWith(color: kColor.grey300)),
                    TextSpan(text: nickname ?? ' ', style: kTextStyle.bodyMedium18.copyWith(
                        color: hasNicknameLock != null
                          ? hasNicknameLock!
                              ? kColor.grey100 : Colors.black
                          : kColor.grey100
                    ))
                  ]
              )
              )
            ),
            hasNicknameLock != null
                ? hasNicknameLock!
                  ? Icon(CupertinoIcons.lock_fill, size: 18, color: kColor.grey900)
                  : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.black)
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget _dataField(String? title, int index, bool? isLock) {
    return GestureDetector(
      onTap: () {
        if (isLock != null && !isLock) {
          _modalProfile(context, index)
              .then((_) => setState(() {}));
        }
      },
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(left: 24, right:  24, bottom: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: kColor.grey30, width: 2))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text(title ?? (index == 2 ? '한 줄 소개가 없어요' : ''),
                    overflow: TextOverflow.ellipsis, style: kTextStyle.bodyMedium18.copyWith(
                      color: title != null
                          ? isLock != null
                              ? isLock ? kColor.grey100 : Colors.black
                              : kColor.grey100
                          : kColor.grey100
                    ))
            ),
            isLock != null && isLock
                ? const SizedBox.shrink()
                : const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.black)
          ],
        ),
      ),
    );
  }

  Widget _modalProfileImageOption() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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

        GestureDetector(  // 앨범 사진 서택
          onTap: () async {
            await ImageHandler.pickImageFromLocal().then((value) {
              if (value != null) {
                Navigator.of(context).pop(value);
              }
            });
          },
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kColor.grey20,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Text('앨범에서 사진 선택', style: kTextStyle.callOutBold16.copyWith(color: kColor.blue100)),
          ),
        ),

        GestureDetector(    // 기본 이미지 변경
          onTap: () => _setDefaultProfileImage(),
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey20,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Text('기본 이미지로 변경', style: kTextStyle.callOutBold16.copyWith(color: kColor.grey900)),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey20,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Text('취소', style: kTextStyle.callOutBold16.copyWith(color: kColor.grey900)),
          ),
        ),
      ],
    );
  }
}

