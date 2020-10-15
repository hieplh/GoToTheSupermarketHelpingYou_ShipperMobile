import 'package:flutter/material.dart';
import 'package:shipper3/screens/Camera.dart';
import 'package:shipper3/screens/ListCheck.dart';
import 'package:shipper3/screens/Location.dart';
import 'package:shipper3/screens/StepOne.dart';

import 'Profile.dart';
class Login extends StatefulWidget{
  _LoginState createState() => _LoginState();
}
class _LoginState extends State<Login>{
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      Center(child: GPSLocation()),
      Center(child: CheckList()),
      Center(child: StepOne()),
      Center(child: Avatar()),
    ];
    return Scaffold(
      body: Container(
        color: Color(0xfff4f4f4),
        child: Center(
          child: screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.location_on), backgroundColor: Colors.deepPurpleAccent , title: Text('Vị Trí')),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active), backgroundColor: Colors.deepPurpleAccent, title: Text('Thông báo')),
          BottomNavigationBarItem(icon: Icon(Icons.email),backgroundColor: Colors.deepPurpleAccent,title: Text('Lịch Sử')),
          BottomNavigationBarItem(icon: Icon(Icons.subject), backgroundColor: Colors.deepPurpleAccent, title: Text('Thông tin')),
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });

        },
      ),

    );
  }
}