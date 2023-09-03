import 'package:flutter/material.dart';

import '../../../resource/style.dart';
import '../../common_widget/custom_tile.dart';
import 'friends_hide.dart';
import 'friends_block.dart';

class FriendsHideBlock extends StatefulWidget {
  const FriendsHideBlock({Key? key}) : super(key: key);

  @override
  State<FriendsHideBlock> createState() => _FriendsHideBlockState();
}

class _FriendsHideBlockState extends State<FriendsHideBlock> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: kStyle.appBar(context, '보관된 친구들'),
      body: SafeArea(
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: const [
              CustomTile(title: '숨긴 친구들', actionType: ActionType.arrowRight,
                  page: FriendsHide()),
              CustomTile(title: '차단한 친구들', actionType: ActionType.arrowRight,
                  page: FriendsBlock()),
            ],
          ),
        ),
      ],
    );
  }
}

