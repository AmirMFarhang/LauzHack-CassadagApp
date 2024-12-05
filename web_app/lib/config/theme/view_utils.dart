import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showLoadingWithBlur() async {
  var height = MediaQuery.of(Get.context!).size.height;
  return showDialog<void>(
    context: Get.context!,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => true,
        child: Container(
            color: Colors.transparent,
            child: Center(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 2.0,
                        sigmaY: 2.0,
                      ),
                      child: Container(
                        height: height / 3,
                        alignment: Alignment.center,
                        child: Container(
                            color: Colors.transparent,
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF00001A).withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0))),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      );
    },
  );
}
