import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../resource/style.dart';

class CustomSkeleton {
  CustomSkeleton();

  static Widget searchingUsers(context, {bool? isTopShort, int? itemCount = 12}) {
    double wd = MediaQuery.of(context).size.width;

    return ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: kColor.grey30,
            highlightColor: Colors.white,
            child: Container(
              height: 56,
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: kColor.grey30),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 10,
                        width: wd * 0.2 + (isTopShort != null ? isTopShort ? 0 : 100 : 0),
                        color: kColor.grey30,
                      ),
                      const SizedBox(height: 10),

                      Container(
                        height: 10,
                        width: wd * 0.2 + (isTopShort != null ? isTopShort ? 100 : 0 : 100),
                        color: kColor.grey30,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  static Widget searchingShort(context, {bool? isTopShort}) {
    double wd = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 56 * 3 + 20,
      child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: kColor.grey30,
              highlightColor: Colors.white,
              child: Container(
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundColor: kColor.grey30),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 10,
                          width: wd * 0.2 + (isTopShort != null ? isTopShort ? 0 : 100 : 0),
                          color: kColor.grey30,
                        ),
                        const SizedBox(height: 10),

                        Container(
                          height: 10,
                          width: wd * 0.2 + (isTopShort != null ? isTopShort ? 100 : 0 : 100),
                          color: kColor.grey30,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}
