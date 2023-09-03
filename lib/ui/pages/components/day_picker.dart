import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../resource/style.dart';

import '../../../controller/state_controller.dart';

Future<dynamic> showMonthYearPicker(BuildContext context) async {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  dynamic result;

  await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 250 + service.bottomMargin.value,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      selectedMonth = index + 1;
                    },
                    children: [
                      for (int i = 1; i <= 12; i++)
                        Center(
                            child: Text(
                              (i < 10) ? '0$i 월' : '$i 월',
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                            )
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      selectedYear = DateTime.now().year + index;
                    },
                    children: [
                      for (int i = DateTime.now().year; i <= DateTime.now().year + 20; i++)
                        Center(
                          child: Text('$i 년',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),

            CupertinoButton(
              child: Text('확인', style: kTextStyle.bodyMedium18),
              onPressed: () {
                Navigator.of(context).pop(DateTime(selectedYear, selectedMonth));
              },
            ),
            // SizedBox(height: service.bottomMargin.value)
          ],
        ),
      );
    },
  ).then((value) {
    result = value;
  });
  return Future.value(result);
}

Future<dynamic> showDayMonthYearPicker(BuildContext context) async {
  int thisYear = DateTime.now().year;
  int minYear = thisYear - 100;
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  dynamic result;

  await showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 250 + service.bottomMargin.value,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: CupertinoPicker.builder(
                      itemExtent: 40,
                      onSelectedItemChanged: (int index) {
                        // selectedYear = DateTime.now().year - index;
                        selectedYear = thisYear - index;
                      },
                      childCount: thisYear - minYear + 1,
                      itemBuilder: (context, index) {
                        final year = thisYear - index;
                        return Center(
                          child: Text('$year 년',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        );
                      }
                  ),
                  // child: CupertinoPicker(
                  //   itemExtent: 40,
                  //   onSelectedItemChanged: (int index) {
                  //     // selectedYear = DateTime.now().year - index;
                  //     selectedYear = thisYear - index;
                  //   },
                  //   children: [
                  //     for (int i = DateTime.now().year; i <= 100; i++)
                  //       Center(
                  //         child: Text('${years[i]} 년',
                  //           style: const TextStyle(fontSize: 20, color: Colors.black),
                  //         ),
                  //       )
                  //   ],
                  // ),
                ),

                SizedBox(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      selectedMonth = index + 1;
                    },
                    children: [
                      for (int i = 1; i <= 12; i++)
                        Center(
                            child: Text(
                              (i < 10) ? '0$i 월' : '$i 월',
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                            )
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 160,
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      selectedDay = index + 1;
                    },
                    children: [
                      for (int i = 1; i <= 31; i++)
                        Center(
                            child: Text(
                              (i < 10) ? '0$i 일' : '$i 일',
                              style: const TextStyle(fontSize: 20, color: Colors.black),
                            )
                        ),
                    ],
                  ),
                ),
              ],
            ),

            CupertinoButton(
              child: Text('확인', style: kTextStyle.bodyMedium18),
              onPressed: () {
                Navigator.of(context).pop(DateTime(selectedYear, selectedMonth, selectedDay));
              },
            ),
          ],
        ),
      );
    },
  ).then((value) {
    result = value;
  });
  return Future.value(result);
}