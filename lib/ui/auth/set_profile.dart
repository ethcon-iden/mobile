import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iden/services/utils.dart';
import 'package:iden/ui/common_widget/custom_profile_image_stack.dart';
import 'dart:io';

import '../../resource/kConstant.dart';
import '../../resource/style.dart';
import '../../controller/state_controller.dart';
import '../common_widget/bottom_modal.dart';
import '../common_widget/scroll_indicator._bar.dart';
import '../../services/image_handler.dart';
import 'set_profile_processing.dart';

class SetProfile extends StatefulWidget {
  const SetProfile({Key? key}) : super(key: key);

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> {
  bool isProfileImageSelected = false;

  @override
  void initState() {
    super.initState();
    service.profileImage.value = '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _modal4Option() {
    showCustomBottomSheet(context,
        const _Options(),
        300 + service.bottomMargin.value, true
    ).then((value) {
      if (value == 'album') {
       _pickImagerFromAlbum();
      } else if (value == 'default') {
        service.profileImage.value = '';
      }
    });
  }

  void _pickImagerFromAlbum() {
    ImageHandler.pickImageFromLocal().then((value) {
      if (value != null) {
        service.profileImage.value = value;
        isProfileImageSelected = true;
        setState(() {});
      }
    });
  }

  void _move2setProfileProcessing() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const SetProfileProcessing())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
        child: _body(),
      ),
      bottomSheet: SafeArea(child: _bottomButton()),
    );
  }

  Widget _bottomButton() {
    String title;
    if (isProfileImageSelected) {
      title = 'Create your profile image';
    } else {
      title = 'Select your profile image';
    }
    String sub = 'I will do it later';
    TextStyle subStyle = kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500);
    final Size subSize = getTextSize(sub, subStyle);

    return SizedBox(
      height: isProfileImageSelected ? 80 : 130,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isProfileImageSelected) {
                _move2setProfileProcessing();
              } else {
                _pickImagerFromAlbum();
              }
            },
            child: Container(
              height: 55,
              width: double.infinity,
              alignment: Alignment.center,
              margin: const EdgeInsets.only(left: 24, right: 24, bottom: 25),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Text(title, style: kTextStyle.buttonWhite),
            ),
          ),
          Visibility(
            visible: !isProfileImageSelected,
            child: GestureDetector(
              onTap: () => _move2setProfileProcessing(),
              child: Container(
                width: subSize.width,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(width: 1, color: kColor.grey500))
                ),
                margin: EdgeInsets.only(left: 16, right: 16, bottom: kConst.bottomButtonMargin),
                child: Text('I will do it later', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey500)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        _header1(),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: _addProfileImage()),
              Visibility(
                  maintainSize: true,
                  maintainState: true,
                  maintainAnimation: true,
                  visible: isProfileImageSelected,
                  child: _selectAgain()
              )
            ]
        )
      ]
    );
  }

  Widget _header1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('Add you profile image', style: kTextStyle.largeTitle28),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text('Your profile image will be shown to your friends.',
              style: kTextStyle.footnoteMedium14.copyWith(color: kColor.grey500)),
        ),
      ],
    );
  }

  Widget _addProfileImage() {
    return Obx(() => ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 136,
        width: 136,
        child: service.profileImage.value.isNotEmpty
            ? Image.file(File(service.profileImage.value), fit: BoxFit.cover)
            : customCircleAvatar(name: service.username.value, background: Colors.black, size: 136, fontSize: 60),
      ),
    ));
  }

  Widget _selectAgain() {
    return GestureDetector(
      onTap: () =>_modal4Option(),
      child: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 80),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          border: Border(bottom: BorderSide(color: Colors.black, width: 1))
        ),
        child: Text('Modify', style: kTextStyle.subHeadlineBold14),
      ),
    );
  }
}

class _Options extends StatefulWidget {
  const _Options({Key? key}) : super(key: key);

  @override
  State<_Options> createState() => _OptionsState();
}

class _OptionsState extends State<_Options> {

  void _onTap(String input) => Navigator.pop(context, input);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const ScrollIndicatorBar(),

        GestureDetector(
          onTap: () => _onTap('album'),
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 20, bottom: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Text('Pick image from photo album.', style: kTextStyle.callOutBold16.copyWith(color: kColor.blue100)),
          ),
        ),

        GestureDetector(
          onTap: () => _onTap('default'),
          child: Container(
            height: 60,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Text('change to default image', style: kTextStyle.callOutBold16),
          ),
        ),

        GestureDetector(
          onTap: () => _onTap('cancel'),
          child: Container(
            height: 60,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: kColor.grey30,
                borderRadius: BorderRadius.circular(16)
            ),
            child: Text('Cancel', style: kTextStyle.callOutBold16),
          ),
        ),
      ],
    );
  }
}
