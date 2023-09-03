import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../resource/kConstant.dart';
import '../../../resource/images.dart';
import '../../../resource/style.dart';
import '../../../controller/state_controller.dart';
import '../../auth/components/header_icon.dart';

class SearchFriends extends StatefulWidget {
  const SearchFriends({Key? key}) : super(key: key);

  @override
  State<SearchFriends> createState() => _SearchFriendsState();
}

class _SearchFriendsState extends State<SearchFriends> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _nodeSearch = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: kStyle.setSystemOverlayStyle(kScreenBrightness.light),
        leading: const HeaderIcon(emoji: '🏫'),
        leadingWidth: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(CupertinoIcons.back, size: 40)
        ),
        _inputSearch()
      ],
    );
  }

  Widget _inputSearch() {
    return Expanded(
      child: TextFormField(
        controller: _controller,
        focusNode: _nodeSearch,
        autofocus: true,
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        style: kTextStyle.bodyMedium18,
        decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: kColor.grey30,
            hintText: '이름 또는 닉네임으로 친구 찾기',
            hintStyle: kTextStyle.hint,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.only(right: 10, bottom: 5),
            prefixIcon: const Icon(Icons.search, size: 30),
            prefixIconColor: _nodeSearch.hasFocus ? Colors.black : kColor.grey100
        ),
        onTap: () {},
        onTapOutside: (_) => setState(() {}),
      ),
    );
  }
}
