import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/Home.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:flutter_otp/flutter_otp.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

_postLogin(String username, String password, BuildContext context) async {
  if (username.isEmpty || password.isEmpty) {
    SweetAlert.show(context,
        title: "Lỗi",
        subtitle: "Tên tài khoản hoặc mật khẩu không được để trống !",
        style: SweetAlertStyle.error);
  } else {
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
          title: "Lỗi",
          subtitle: "Tên tài khoản hoặc mật khẩu không hợp lệ !",
          style: SweetAlertStyle.error);
    }
  }
}

class _State extends State<LoginPage> {
  TextEditingController newController = TextEditingController();
  String validatePass;
  int validatePhone;
  String phoneNumber = "5555215554";
  FlutterOtp otp = FlutterOtp();
  TextEditingController validController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController accountIdController = TextEditingController();
  TextEditingController validatePhoneController =
      TextEditingController(text: "5555215554");
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  String _text = "initial";
  TextEditingController _c;
  String newPass;
  String username;
  String password;
  TextEditingController nameController =
      TextEditingController(text: "0456789123");
  TextEditingController passwordController =
      TextEditingController(text: "12345678");
  int minNumber = 1000;
  int maxNumber = 6000;
  String countryCode = "+1";
  int enteredOtp;
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
                      labelText: 'Tên Tài Khoản',
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
                      labelText: 'Mật Khẩu',
                    ),
                    onChanged: (val) {
                      // (val) is looking at the value in the textbox.
                      password = val;
                    },
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Positioned(
                                  right: -40.0,
                                  top: -40.0,
                                  child: InkResponse(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: CircleAvatar(
                                      child: Icon(Icons.close),
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                                Form(
                                  key: _formKey1,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Tên tài khoản',
                                            icon: Icon(
                                                Icons.supervised_user_circle),
                                          ),
                                          controller: accountIdController,
                                          onChanged: (val) {
                                            // (val) is looking at the value in the textbox.
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText:
                                                'Nhập số điện thoại đã đăng kí ',
                                            icon: Icon(Icons.settings),
                                          ),
                                          controller: validatePhoneController,
                                          onChanged: (val) {
                                            // (val) is looking at the value in the textbox.
                                            validatePhone = int.parse(val);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RaisedButton(
                                          child: Text("Xác nhận"),
                                          onPressed: () async {
                                            if (int.parse(
                                                    validatePhoneController
                                                        .text) !=
                                                int.parse(phoneNumber)) {
                                              showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      new AlertDialog(
                                                        title: new Text("Lỗi"),
                                                        content: new Text(
                                                            "Số điện thoại không hợp lệ !"),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text('Ok'),
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          )
                                                        ],
                                                      ));
                                            } else {
                                              Navigator.of(context).pop();
                                              Random random = new Random();
                                              int value = random.nextInt(10000);
                                              otp.sendOtp(
                                                  phoneNumber,
                                                  'OTP is : ${value} ',
                                                  minNumber,
                                                  maxNumber,
                                                  countryCode);

                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      content: Stack(
                                                        overflow:
                                                            Overflow.visible,
                                                        children: <Widget>[
                                                          Positioned(
                                                            right: -40.0,
                                                            top: -40.0,
                                                            child: InkResponse(
                                                              onTap: () {},
                                                              child:
                                                                  CircleAvatar(
                                                                child: Icon(
                                                                    Icons
                                                                        .close),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ),
                                                          Form(
                                                            key: _formKey2,
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child:
                                                                      TextField(
                                                                   
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'OTP',
                                                                      icon: Icon(
                                                                          Icons
                                                                              .settings),
                                                                    ),
                                                                    controller:
                                                                        otpController,
                                                                    onChanged:
                                                                        (val) {
                                                                      // (val) is looking at the value in the textbox.
                                                                      enteredOtp =
                                                                          int.parse(
                                                                              val);
                                                                    },
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child:
                                                                      TextField(
                                                                    obscureText:
                                                                        true,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Mật khẩu mới',
                                                                      icon: Icon(
                                                                          Icons
                                                                              .security),
                                                                    ),
                                                                    controller:
                                                                        newController,
                                                                    onChanged:
                                                                        (val) {
                                                                      // (val) is looking at the value in the textbox.
                                                                      newPass =
                                                                          val;
                                                                    },
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child:
                                                                      TextField(
                                                                    obscureText:
                                                                        true,
                                                                    decoration:
                                                                        InputDecoration(
                                                                      labelText:
                                                                          'Xác nhận mật khẩu mới',
                                                                      icon: Icon(
                                                                          Icons
                                                                              .security),
                                                                    ),
                                                                    controller:
                                                                        validController,
                                                                    onChanged:
                                                                        (val) {
                                                                      // (val) is looking at the value in the textbox.
                                                                      validatePass =
                                                                          val;
                                                                    },
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child:
                                                                      RaisedButton(
                                                                    child: Text(
                                                                        "Xác nhận"),
                                                                    onPressed:
                                                                        () async {
                                                                      if (validatePass !=
                                                                          newPass) {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (_) =>
                                                                                new AlertDialog(
                                                                                  title: new Text("Lỗi"),
                                                                                  content: new Text("Mật khẩu mới chưa đúng !"),
                                                                                  actions: <Widget>[
                                                                                    FlatButton(
                                                                                      child: Text('Ok'),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                    )
                                                                                  ],
                                                                                ));
                                                                      } else if (value !=
                                                                          enteredOtp) {
                                                                        showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (_) =>
                                                                                new AlertDialog(
                                                                                  title: new Text("Lỗi"),
                                                                                  content: new Text("OTP không hợp lệ !"),
                                                                                  actions: <Widget>[
                                                                                    FlatButton(
                                                                                      child: Text('Ok'),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                    )
                                                                                  ],
                                                                                ));
                                                                      } else {
                                                                        var bodyUpdatePass =
                                                                            {
                                                                          "amount":
                                                                              0,
                                                                          "newPwd":
                                                                              newPass,
                                                                          "oldPwd":
                                                                              "12345678",
                                                                          "role":
                                                                              "shipper",
                                                                          "username":
                                                                              accountIdController.text,
                                                                        };

                                                                        var url =
                                                                            GlobalVariable.API_ENDPOINT +
                                                                                'account/password';
                                                                        var response =
                                                                            await http.put(
                                                                          Uri.encodeFull(
                                                                              url),
                                                                          headers: {
                                                                            'Content-type':
                                                                                'application/json',
                                                                            "Accept":
                                                                                "application/json",
                                                                          },
                                                                          encoding:
                                                                              Encoding.getByName("utf-8"),
                                                                          body:
                                                                              jsonEncode(bodyUpdatePass),
                                                                        );
                                                                        if (response.statusCode ==
                                                                            200) {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (_) => new AlertDialog(
                                                                                    title: new Text("Thông báo"),
                                                                                    content: new Text("Cập nhật mật khẩu thành công !"),
                                                                                    actions: <Widget>[
                                                                                      FlatButton(
                                                                                        child: Text('Ok'),
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      )
                                                                                    ],
                                                                                  ));
                                                                        } else {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (_) => new AlertDialog(
                                                                                    title: new Text("Thông báo"),
                                                                                    content: new Text("Có lỗi xảy ra"),
                                                                                    actions: <Widget>[
                                                                                      FlatButton(
                                                                                        child: Text('Ok'),
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      )
                                                                                    ],
                                                                                  ));
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                  child: Text('Quên mật khẩu ?'),
                  textColor: Colors.blue,
                ),

                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.green,
                      child: Text('Đăng Nhập'),
                      onPressed: () {
                        _postLogin(nameController.text, passwordController.text,
                            context);
                      },
                    )),
                // Container(
                //     child: Row(
                //   children: <Widget>[
                //     Text('Quên mật khẩu ?'),
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
