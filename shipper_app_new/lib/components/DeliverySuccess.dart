import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/Home.dart';
import 'package:shipper_app_new/model/User.dart';

class SuccessScreen extends StatelessWidget {
  final User userData;
  final Map<String, dynamic> data;
  const SuccessScreen({Key key, this.data, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/shipper.png'),
          SizedBox(
            height: 50,
          ),
          Text(
            "GIAO HÀNG THÀNH CÔNG",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    MyHomeWidget(userData: userData)),
            ModalRoute.withName('/'),
          );
        },
        label: Text('Quay về màn hình chính'),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
