import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iden/rest_api/api.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../model/session.dart';
import '../../resource/style.dart';
import '../../controller/state_controller.dart';
import '../common_widget/custom_profile_image_stack.dart';
import '../iden_main.dart';

class SetProfileProcessing extends StatefulWidget {
  const SetProfileProcessing({Key? key}) : super(key: key);

  @override
  State<SetProfileProcessing> createState() => _SetProfileProcessingState();
}

class _SetProfileProcessingState extends State<SetProfileProcessing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        lowerBound: 0.4,
        duration: const Duration(milliseconds: 1000)
    )..repeat();
    _updateProfileImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateProfileImage() async {
    if (service.profileImage.value.isNotEmpty) {
      bool isVerified = await _postProfileImage();
      if (isVerified) {
        _next2proceed();
      } else {
        print('---> update profile image > error');
      }
    } else {
      _next2proceed();
    }
  }

  Future<bool> _postProfileImage() async {
    bool out;
    final HttpsResponse res = await IdenApi.updateProfileImage(service.profileImage.value);
    if (res.statusType == StatusType.success) {
      final result = await service.updateUserMeInfo(res.body, true);
      if (result) {
        out = true;
        setState(() {});
      } else {
        out = true;
        print('---> update profile image > error');
      }
    } else {
      out = true;
      print('---> update profile image > error');
    }
    return out;
  }

  void _next2proceed() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => hasCompleted = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    _move2setProfileComplete();
  }

  void _move2setProfileComplete() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialWithModalsPageRoute(builder: (BuildContext context) => const IdenMain()),
            (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    String title;
    String sub;
    if (!hasCompleted) {
      title = '프로필 생성 중...';
      sub = 'IDEN에서 사용할 프로필을 생성하고 있습니다';
    } else {
      title = '완료';
      sub = 'IDEN에서 사용할 프로필이 생성됨';
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 150),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(title, style: kTextStyle.largeTitle28),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Text(sub, style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
            )
          ],
        ),

        hasCompleted ? _profileCompleted() : _rippleEffect()
      ]
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
            _buildContainer(200 * _controller.value),
            _buildContainer(300 * _controller.value),
            _buildContainer(400 * _controller.value),
            Align(child: _profileImage())
          ],
        );
      },
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

  Widget _profileImage() {
    return Obx(() => ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 70,
        width: 70,
        child: service.profileImage.value.isNotEmpty
            ? Image.file(File(service.profileImage.value), fit: BoxFit.cover)
            : customCircleAvatar(name: service.username.value, background: Colors.black, size: 70, fontSize: 42),
          ),
    ));
  }

  Widget _profileCompleted() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        height: 330,
        padding: const EdgeInsets.only(left: 15, right: 15),
        margin: const EdgeInsets.only(bottom: 50),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              height: MediaQuery.of(context).size.width * 0.35,
              child:  service.profileImage.value.isNotEmpty
                  ? Image.file(File(service.profileImage.value), fit: BoxFit.cover)
                  : customCircleAvatar(name: service.username.value, background: Colors.black,
                  size: MediaQuery.of(context).size.width * 0.35, fontSize: 72),
          ),
        ),
      ),
    );
  }
}
