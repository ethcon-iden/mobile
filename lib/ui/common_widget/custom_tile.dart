import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../resource/style.dart';

class CustomTile extends StatefulWidget {
  const CustomTile({Key? key,
    required this.title,
    this.actionType,
    this.route,
    this.page,
    this.symmetricPadding,
    this.leadingIcon,
    this.hasChecked,
    this.isToggleSwitchOn,
    this.isDeactivate,
    this.onChanged,
    this.asyncCallback,
    this.voidCallback
  }) : super(key: key);

  final String title;
  final double? symmetricPadding;
  final String? route;    // route to move page
  final Widget? page;
  final Widget? leadingIcon;
  final bool? hasChecked;   // variable for checkbox
  final bool? isToggleSwitchOn;   // variable for toggle switch
  final bool? isDeactivate;   // true -> disable checkbox
  final ActionType? actionType;
  final AsyncCallback? asyncCallback;
  final VoidCallback? voidCallback;
  final ValueChanged<bool>? onChanged;  // get value (ture or false) when state changed

  @override
  State<CustomTile> createState() => _CustomTileState();
}

class _CustomTileState extends State<CustomTile> {

  void _move2page() {
    Navigator.push(
        context,
        MaterialWithModalsPageRoute(builder: (BuildContext context) => widget.page!)
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget? action = _getAction();
    double padding;
    if (widget.symmetricPadding != null) {
      padding = widget.symmetricPadding!;
    } else {
      padding = 16;
    }
    return GestureDetector(
      onTap: () {
        if (widget.page != null) {
          _move2page();
        } else if (widget.asyncCallback != null) {
          widget.asyncCallback!();
        } else if (widget.voidCallback != null) {
          widget.voidCallback!();
        }
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(left: 12, right: 12),
        margin: EdgeInsets.only(left: padding, right: padding, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: widget.isDeactivate != null ? widget.isDeactivate!
              ? Colors.transparent : kColor.grey20 : kColor.grey20,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.leadingIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 14),
                          child: widget.leadingIcon!,
                        )
                      : const SizedBox.shrink(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(widget.title, style: widget.isDeactivate != null ? widget.isDeactivate!
                        ? kTextStyle.callOutBold16.copyWith(color: kColor.grey300)
                        : kTextStyle.callOutBold16 : kTextStyle.callOutBold16
                    ),
                  ),
                ],
              ),
            ),
            action ?? const SizedBox(width: 100)
          ],
        ),
      ),
    );
  }

  Widget? _getAction() {
    ActionType? action = widget.actionType;
    Widget? out;
    if (action != null) {
      if (action == ActionType.toggleSwitch) {
        out = _toggleSwitch();
      } else if (action == ActionType.arrowRight) {
        out = _arrowRight();
      } else if (action == ActionType.arrowDown) {
        out = _arrowDown();
      } else if (action == ActionType.checkRound) {
        out = _checkRound();
      }
    }
    return SizedBox(
        width: 60,
        child: out
    );
  }

  Widget _toggleSwitch() {
    bool isSelected = widget.isToggleSwitchOn!;

    return Transform.scale(
      scale: 1,
      child: CupertinoSwitch(
          activeColor: kColor.blue100,
          value: isSelected,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            setState(() {});
          }
      ),
    );
  }

  Widget _arrowRight() {
    return Container(
        width: 100,
        alignment: Alignment.centerRight,
        child: const Icon(CupertinoIcons.forward));
  }
  Widget _arrowDown() {
    return Container(
        width: 100,
        alignment: Alignment.centerRight,
        child: const Icon(CupertinoIcons.chevron_down)
    );
  }
  Widget _checkRound() {
    bool isSelected = widget.hasChecked!;

    return Container(
      width: 100,
      alignment: Alignment.centerRight,
      child: Transform.scale(
        scale: 1.2,
        child: Checkbox(
            value: isSelected,
            visualDensity: VisualDensity.compact,
            shape: const CircleBorder(),
            side: BorderSide(width: 1.5,
                color: widget.isDeactivate != null ? widget.isDeactivate!
                    ? kColor.grey100 : kColor.grey300 : kColor.grey300),
            activeColor: kColor.blue100,
            onChanged: (value) {
              if (widget.isDeactivate != null && widget.isDeactivate!) {  // true -> no action
              } else {
                if (widget.onChanged != null) {
                  widget.onChanged!(value!);
                }
                setState(() {});
              }
            }
        ),
      ),
    );
  }
}

enum ActionType {
  toggleSwitch,
  arrowRight,
  arrowDown,
  checkRound,
  radioButton
}
