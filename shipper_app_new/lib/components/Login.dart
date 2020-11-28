import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/Home.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:sweetalert/sweetalert.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}



_postLogin(String username, String password, BuildContext context) async {
  User user = null;
  var url = GlobalVariable.API_ENDPOINT + 'account/username';
  var response = await http.post(Uri.parse(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      body: json.encode(
          {"password": password, "role": "shipper", "username": username}));

  if (response.statusCode == 200) {
    user = User.fromJson(json.decode(response.body));
    // If the server did return a 200 OK response,
    GlobalVariable.IS_LOG_OUT = false;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomeWidget(userData: user)),
    );
  } else {
    // If the server did not return a 200 OK response,
    // SweetAlert.show(context,
    //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
    // then throw an exception.
    SweetAlert.show(context,
        title: "Login Failed",
        subtitle: "Invalid username or password",
        style: SweetAlertStyle.error);
  }
}

class _State extends State<LoginPage> {
  String _text = "initial";
  TextEditingController _c;
  String username;
  String password;
  TextEditingController nameController =
      TextEditingController(text: "shipper123");
  TextEditingController passwordController =
      TextEditingController(text: "12345678");
  @override
  initState() {
    _c = new TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Image.asset('assets/logo.png')),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                    ),
                    onChanged: (val) {
                      // (val) is looking at the value in the textbox.
                      username = val;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    onChanged: (val) {
                      // (val) is looking at the value in the textbox.
                      password = val;
                    },
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    //forgot password screen

                  },
                  textColor: Colors.blue,
                  child: Text('Forgot Password'),
                ),
                FlatButton(
                  onPressed: () {
                    //forgot password screen
                    showDialog(
                        child: new Dialog(
                          child: new Column(
                            children: <Widget>[
                              new TextField(
                                decoration:
                                new InputDecoration(hintText: "Update IP"),
                                controller: _c,
                              ),
                              new FlatButton(
                                child: new Text("Save"),
                                onPressed: () {
                                  setState(() {
                                    this._text = _c.text;
                                  });
                                  GlobalVariable.API_ENDPOINT = this._text;
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                        ),
                        context: context);
                  },
                  textColor: Colors.blue,
                  child: Text('Update IP'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Login'),
                      onPressed: () {
                        _postLogin(nameController.text, passwordController.text,
                            context);
                      },
                    )),
                // Container(
                //     child: Row(
                //   children: <Widget>[
                //     Text('Does not have account?'),
                //     FlatButton(
                //       textColor: Colors.blue,
                //       child: Text(
                //         'Sign in',
                //         style: TextStyle(fontSize: 20),
                //       ),
                //       onPressed: () {
                //         //signup screen
                //       },
                //     )
                //   ],
                //   mainAxisAlignment: MainAxisAlignment.center,
                // ))
              ],
            )));
  }
}
