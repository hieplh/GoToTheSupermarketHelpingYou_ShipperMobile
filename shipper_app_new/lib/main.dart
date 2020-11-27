import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shipper_app_new/components/Login.dart';
import 'package:splashscreen/splashscreen.dart';
import 'dart:async';
import 'components/RestarApp.dart';

void main() {
  runApp(RestarApp(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(

        debugShowCheckedModeBanner: false,
        title: 'Shipper App',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Splash());
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: new LoginPage(),
      image: Image.asset('assets/logo.png'),
      loadingText: Text("Loading"),
      photoSize: 150.0,
      loaderColor: Colors.blue,
    );
  }
}