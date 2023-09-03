import 'package:flutter/material.dart';
import '../common_widget/custom_profile_image_stack.dart';

import '../../model/user.dart';
import '../../resource/style.dart';

class CommonWidget {
  CommonWidget();

  static Widget emptyCase(context, String emoji, String title, {bool? isAlignCenter}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: isAlignCenter == false ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          if (isAlignCenter == false) const SizedBox(height: 20),
          Center(child:Text(emoji, style: const TextStyle(fontSize: 48))),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(title, textAlign: TextAlign.center,
                style: kTextStyle.headlineExtraBold18.copyWith(height: 1.3)),
          ),
        ],
      ),
    );
  }

  static Widget heroPage(BuildContext context, User user, String tag) {
    double ww = MediaQuery.of(context).size.width * 0.65;

    return Center(
      child: Hero(
        tag: tag,
        child: CircleAvatar(
            minRadius: ww/2,
            backgroundColor: Colors.transparent,
            child: CustomCacheNetworkImage(imageUrl: user.profileImageKey, gender: user.gender, size: ww)
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashGap;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashGap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double startX = 0.0;
    final double endX = size.width;

    // Draw the top dashed line
    double currentX = startX;
    while (currentX < endX) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += dashWidth + dashGap;
    }

    // Draw the bottom dashed line
    currentX = startX;
    while (currentX < endX) {
      canvas.drawLine(
        Offset(currentX, size.height),
        Offset(currentX + dashWidth, size.height),
        paint,
      );
      currentX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}