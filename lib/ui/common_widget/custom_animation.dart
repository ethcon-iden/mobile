import 'package:flutter/material.dart';

class CustomAnimation {
  CustomAnimation();

  static Widget textSlide({
    double? width,
    EdgeInsets? padding,
    int duration = 50,
    required String title1,
    required String title2,
    required TextStyle textStyle,
    required bool isTriggerOn
  }) {
    return Container(
      width: width,
      padding: padding,
      child: Stack(
        children: [
          AnimatedSwitcher(
              duration: Duration(milliseconds: duration),
              child: Text(isTriggerOn ? '' : title1,
                  key: ValueKey<String>(isTriggerOn ? '1' : title1), style: textStyle)
          ),
          AnimatedSwitcher(
              duration: Duration(milliseconds: duration * 3),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: const Offset(0, 0),
                  ).animate(animation),
                  child: child,
                );
              },
              child: Text(isTriggerOn ? title2 : '',
                  key: ValueKey<String>(isTriggerOn ? title1 : '2'), style: textStyle)
          ),
        ],
      ),
    );
  }

  static Widget widgetSlide({
    double? width,
    double? height,
    EdgeInsets? padding,
    int durationPadeOut = 50,
    int durationSlide = 300,
    required Widget firstChild,
    required Widget secondChild,
    required bool isTriggerOn4first,
    required bool isTriggerOn4second,
  }) {
    return Container(
      height: height,
      width: width,
      padding: padding,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: AnimatedSwitcher(
                key: const ValueKey<String>('first'),
                duration: Duration(milliseconds: durationPadeOut),
                child: isTriggerOn4first
                    ? firstChild
                    : const SizedBox.shrink()
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: AnimatedSwitcher(
                key: const ValueKey<String>('third'),
                duration: Duration(milliseconds: durationSlide),
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.7),
                      end: const Offset(0, 0),
                    ).animate(animation),
                    child: child,
                  );
                },
                child: isTriggerOn4second
                    ? secondChild
                    : const SizedBox.shrink()
            ),
          )
        ],
      ),
    );
  }
}