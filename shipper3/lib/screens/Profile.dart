import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  @override
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  double screenHeight(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).height / dividedBy;
  }

  double screenWidth(BuildContext context, {double dividedBy = 1}) {
    return screenSize(context).width / dividedBy;
  }
  bool toggleValue = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    child: Icon(Icons.person, size: 60.0,),
                    width: screenWidth(context, dividedBy: 5),
                    height: screenHeight(context, dividedBy: 9),
                margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurpleAccent),
                    borderRadius: BorderRadius.all(Radius.circular(45.0))),
                  ),
                  Container(
                    width: screenWidth(context, dividedBy: 2),
                    height: screenHeight(context, dividedBy: 9),
                    margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurpleAccent)),
                    child: Column(
                      children: [
                        Container(
                          child: Text('Phan Cong Binh', style: TextStyle(fontSize: 20.0),),
                          margin: EdgeInsets.all(10.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(

                            child: Text('Profile  >'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon (Icons.check_circle,color: Colors.deepPurpleAccent,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text('Offline',style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,0,20,0),
                        child: Container(
                          child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon (Icons.question_answer,color: Colors.deepPurpleAccent,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text('Hỗ trợ',style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,0,20,0),
                        child: Container(
                          child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon (Icons.history,color: Colors.deepPurpleAccent,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text('Lịch Sử',style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,0,20,0),
                        child: Container(
                          child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon (Icons.border_color,color: Colors.deepPurpleAccent,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text('Chính Sách',style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,0,20,0),
                        child: Container(
                          child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon (Icons.info_outline,color: Colors.deepPurpleAccent,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text('Thông tin về chúng tôi',style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,0,20,0),
                        child: Container(
                          child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon (Icons.account_balance_wallet,color: Colors.deepPurpleAccent,),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10.0,0,0,0),
                            child: Text('Ví tiền',style: TextStyle(fontSize: 20),),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0,0,20,0),
                        child: Container(
                          child: Text('-------------------------------------------------------------------------------', style: TextStyle(color: Colors.deepPurpleAccent),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  toggleButton() {
    setState(() {
      toggleValue = !toggleValue;
    });
  }
}
