import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shipper3/screens/Login.dart';
import 'package:shipper3/screens/Notifi.Dart.dart';
import 'package:shipper3/screens/Profile.dart';

import 'StepOne.dart';

class Oders extends StatefulWidget {

  @override
  _OderState createState() => _OderState();
}

class _OderState extends State<Oders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        padding :EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurpleAccent),
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),

          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                child: Container(
                  child: Row(
                    children: [
                      Container(
                          width: 100.0,
                          height: 100.0,
                          child: Image.asset('assets/motomini.png')),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Thit bo 300g',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'So luong : x1',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Text('135,000 VND', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),)
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: Row(
                    children: [
                      Container(
                          width: 100.0,
                          height: 100.0,
                          child: Image.asset('assets/motomini.png')),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Thit bo 300g',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'So luong : x1',
                                  style: TextStyle(fontSize: 15.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Text('135,000 VND', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),)
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('-  Đơn hàng ', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20,0,0,0),
                    child: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('Tổng tiền ', style: TextStyle(fontSize: 15.0),),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(65.0,0,0,0),
                                child: Container(child: Text('270000 VND',textAlign: TextAlign.end, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('Tổng Khối Lượng', style: TextStyle(fontSize: 15.0),),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16.0,0,0,0),
                                child: Container(child: Text('600 G',textAlign: TextAlign.end, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('Khoảng cách'),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(45.0,0,0,0),
                                child: Text('3,5 Km',style: TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('Địa chỉ'
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(85.0,0,0,0),
                                child: Text('250/66 Bau Cat F11',style: TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text('Nơi mua'
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(75.0,0,0,0),
                                child: Text('Bách Hoá Xanh Bàu Cát',style: TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text('-  Chi Phí ', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 20),),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurpleAccent),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(17.0,0,0,0),
                          child: Row(
                            children: [
                              Text('Phí vận chuyển '),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(40.0,0,0,0),
                                child: Text('20000 VND',style: TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),

                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(17,0,0,0),
                              child: Text('Phí đi chợ '),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(70.0,0,0,0),
                              child: Text('15000 VND', style: TextStyle(fontWeight: FontWeight.bold),),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(17,0,0,0),
                              child: Text('Tổng chi phí '),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(55.0,0,0,0),
                              child: Text('15000 VND', style: TextStyle(fontWeight: FontWeight.bold),),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RaisedButton(
                    child: Text('Dong Y'),
                    color: Colors.deepPurpleAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StepOne()),
                      );
                    },
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
