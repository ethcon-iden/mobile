import 'package:flutter/material.dart';

import '../../../services/extensions.dart';
import '../../../controller/state_controller.dart';
import '../../../resource/style.dart';

class UserSchool extends StatelessWidget {
  const UserSchool({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    String school = service.userSchoolName.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 15),
          child: Text('학교', style: kTextStyle.subHeadlineBold14.copyWith(color: kColor.grey300)),
        ),
        Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                    width: 2, color: '#EEEEEE'.toColor()
                ))
            ),
            child: Text(school, style: kTextStyle.bodyMedium18)
        ),
      ],
    );
  }

}
