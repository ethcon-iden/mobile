import 'package:flutter/material.dart';

import '../../resource/style.dart';

class EndOfList extends StatefulWidget {
  const EndOfList({Key? key}) : super(key: key);

  @override
  State<EndOfList> createState() => _EndOfListState();
}

class _EndOfListState extends State<EndOfList> {
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _triggerOn();
  }

  void _triggerOn() async {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => isVisible = true);
    }) ;
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: _content(),
    );
  }

  Widget _content() {
    return Container(
        padding: const EdgeInsets.only(top: 30, bottom: 60),
        alignment: Alignment.center,
        child: Text('모두 확인했어요!', style: kTextStyle.headlineExtraBold18.copyWith(color: kColor.grey500))
    );
  }
}
