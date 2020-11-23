import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/Login.dart';

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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shipper App',
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginPage());
  }
}
