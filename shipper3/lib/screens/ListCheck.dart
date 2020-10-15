import 'package:flutter/material.dart';


class CheckList extends StatefulWidget {
  @override
  _CheckListState createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> {
  final List<String> names = <String>['Thịt Bò','Thịt Heo'];
  final List<int> msgCount = <int>[300,200];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: names.length,
                      itemBuilder: (BuildContext context, int index) {
                        return SingleChildScrollView(
                          child: Container(
                            height: 100,
                            margin: EdgeInsets.all(2),
                            child: Container(
                                child: Column(
                                  children: [
                                    Container(
                                      child: Column(
                                        children: [
                                          Text('Sản Phẩm : ${names[index]}',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Text('Số lương : ${msgCount[index]} Gam'),
                                         // FlatButton.icon(onPressed: null, icon: Icon(Icons.check_circle), label: )
                                        ],
                                      ),
                                    ),
                                    IconButton(iconSize: 12, icon: Icon(Icons.check_circle),)
                                  ],
                                )
                            ),
                          ),
                        );
                      }
                  )
              )
            ]
        )
    );
  }
}