import 'package:flutter/material.dart';

import '../common_widget/lotti_animation.dart';
import '../../controller/state_controller.dart';
import '../../resource/style.dart';
import '../../resource/kConstant.dart';

class CustomButtonWide extends StatefulWidget {
  const CustomButtonWide({Key? key,
    required this.title,
    this.height = 56,
    this.horizontalMargin = 16,
    this.bottomMargin = 20,
    this.background,
    this.titleColor,
    this.leadingIcon,
    this.isLoadingOn = false,
    this.isAnimationOn,
    this.isGradientOn = false,
    this.hasBottomMargie = false,
    this.onTap,
  }) : super(key: key);

  final String title;
  final double height;
  final double horizontalMargin;
  final double bottomMargin;
  final Color? background;
  final Color? titleColor;
  final Widget? leadingIcon;
  final bool isLoadingOn;
  final bool? isAnimationOn;
  final bool isGradientOn;
  final bool hasBottomMargie;
  final VoidCallback? onTap;

  @override
  State<CustomButtonWide> createState() => _CustomButtonWideState();
}

class _CustomButtonWideState extends State<CustomButtonWide> {

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: widget.hasBottomMargie ? EdgeInsets.only(bottom: kConst.bottomButtonMargin + service.bottomMargin.value) : null,
      padding: EdgeInsets.only(top: widget.isGradientOn ? 44 : 0, bottom: widget.bottomMargin
          + service.bottomMargin.value),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
          gradient: widget.isGradientOn
              ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white,
                      Colors.white,
                    ]
                )
              : null
      ),
      height: widget.isAnimationOn == false
          ? 0.0
          : widget.isGradientOn
            ? widget.height + widget.bottomMargin + 44 + service.bottomMargin.value
            : widget.height + widget.bottomMargin,
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) widget.onTap!();
        },
        child: Container(
          height: widget.height,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: widget.horizontalMargin, right: widget.horizontalMargin),
          decoration: BoxDecoration(
            color: widget.background ?? kColor.blue100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: widget.isLoadingOn
              ? LottieAnimation.loading(30, color: Colors.white)
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.leadingIcon != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: widget.leadingIcon!,
                          )
                        : const SizedBox.shrink(),

                    Text(widget.title, style: widget.titleColor != null
                        ? kTextStyle.headlineExtraBold18.copyWith(color: widget.titleColor)
                        : kTextStyle.headlineExtraBold18.copyWith(color: Colors.white)
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomButtonSmall extends StatefulWidget {
  const CustomButtonSmall({Key? key,
    required this.titleNorm,
    this.titleOn,
    this.height = 36,
    this.width = 76,
    this.margin,
    this.isToggleOn = false,
    this.iconNorm,
    this.iconOn,
    this.colorNorm,
    this.colorOn,
    this.backgroundNorm,
    this.backgroundOn,
    this.onClick,
  }) : super(key: key);

  final String titleNorm;
  final String? titleOn;
  final double height;
  final double width;
  final EdgeInsets? margin;
  final bool isToggleOn;
  final Widget? iconNorm;
  final Widget? iconOn;
  final Color? colorNorm;
  final Color? colorOn;
  final Color? backgroundOn;
  final Color? backgroundNorm;
  final VoidCallback? onClick;
  
  @override
  State<CustomButtonSmall> createState() => _CustomButtonSmallState();
}

class _CustomButtonSmallState extends State<CustomButtonSmall> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onClick != null) widget.onClick!();
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: widget.isToggleOn
                ? widget.backgroundOn ?? kColor.grey30
                : widget.backgroundNorm ?? kColor.blue100,
            borderRadius: BorderRadius.circular(10)
        ),
        child: widget.isToggleOn
            ? _selected()
            : _normal()
      ),
    );
  }
  
  Widget _selected() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.iconOn != null) widget.iconOn!,
        Text(widget.titleOn ?? ' ', style: kTextStyle.subHeadlineBold14
            .copyWith(color: widget.colorOn ?? Colors.black)),
      ],
    );
  }

  Widget _normal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.iconNorm != null) widget.iconNorm!,
        Text(widget.titleNorm, style: kTextStyle.subHeadlineBold14
            .copyWith(color: widget.colorNorm ?? Colors.white)),
      ],
    );
  }
}
