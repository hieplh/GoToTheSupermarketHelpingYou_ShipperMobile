import 'package:flutter/material.dart';
import 'package:shipper3/screens/Login.dart';
class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0,200.0,10.0,30.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        border: Border.all(color: Colors.blueAccent)
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Nhập số điện thoại',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Container(
                          child: Icon(Icons.phone,color: Colors.deepPurpleAccent,),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    textColor: Colors.white,
                    color: Colors.deepPurpleAccent,
                    child: Text('Đăng nhập'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
}
}