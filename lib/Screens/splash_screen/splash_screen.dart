
import 'dart:async';

import 'package:CuChat/Configs/app_constants.dart';
import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    new Future.delayed(const Duration(seconds: 2), (){
    });

    return IsSplashOnlySolidColor == true
        ? Scaffold(
            backgroundColor: SplashBackgroundSolidColor,
            body: Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(campusChatLight)),
            ))

        : Scaffold(

            backgroundColor: SplashBackgroundSolidColor,
            body: Center(
                child: Image.asset(
              '$SplashPath',
              fit: BoxFit.cover,
            )),
          );

  }
}
