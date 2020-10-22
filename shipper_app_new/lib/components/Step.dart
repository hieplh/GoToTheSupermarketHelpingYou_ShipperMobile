import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/Home.dart';
import 'package:shipper_app_new/model/Orders.dart';

class Steps extends StatefulWidget {
  final List<OrderDetail> item;
  Steps({Key key, @required this.item}) : super(key: key);

  @override
  _StepsState createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  static List<OrderDetail> tmp;
  @override
  void initState() {
    super.initState();

    _test();
  }

  _test() {
    tmp = widget.item;
    print(tmp.length.toString());
  }

  int current_step = 0;

  List<Step> my_steps = [
    Step(
        // Title of the Step
        title: Text("Mua đồ"),
        content: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Ức Gà Ta"),
              new Text("Ức Gà Ta Gò Công"),
              new Text("Xà Lách"),
            ],
          ),
        ),
        // ListView.builder(
        //   itemCount: tmp.length,
        //   itemBuilder: (context, index) {
        //     return ListTile(
        //       leading: Icon(Icons.home),
        //       title: Text(utf8.decode(latin1.encode(tmp[index].food),
        //           allowMalformed: true)),
        //       trailing: Text(utf8.decode(
        //           latin1.encode(tmp[index].weight.toString()),
        //           allowMalformed: true)),
        //       subtitle: Text(utf8.decode(
        //           latin1.encode(tmp[index].priceOriginal.toString()),
        //           allowMalformed: true)),
        //     );
        //   },
        // ),
        isActive: true),
    Step(
        title: Text("Thanh Toán"),
        content: Text("Tổng tiền : " + "90000"),
        state: StepState.indexed,
        isActive: true),
    // Step(
    //     title: Text("Select the product"),
    //     content: Text("Laptop"),
    //     isActive: true),
    // Step(
    //     title: Text("Make the payment"),
    //     content: Text("Enter transaction details..."),
    //     isActive: true),
    // Step(
    //     title: Text("Exit the app!!!"),
    //     content: Text("Purchase done successfully"),
    //     isActive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar
      appBar: AppBar(
        // Title
        title: Text("Tiến Trình"),
      ),
      // Body
      body: Container(
          child: Stepper(
        currentStep: this.current_step,
        steps: my_steps,
        type: StepperType.vertical,
        onStepTapped: (step) {
          setState(() {
            current_step = step;
          });
          print("onStepTapped : " + step.toString());
        },
        onStepCancel: () {
          setState(() {
            if (current_step > 0) {
              current_step = current_step - 1;
            } else {
              current_step = 0;
            }
          });
          print("onStepCancel : " + current_step.toString());
        },
        onStepContinue: () {
          setState(() {
            if (current_step < my_steps.length - 1) {
              current_step = current_step + 1;
            } else {
              current_step = 0;
            }
          });
          print("onStepContinue : " + current_step.toString());
        },
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomeWidget()),
          );
        },
        label: Text('Hoàn Tất'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildOrderReceive() {
    return ListView.builder(
      itemCount: widget.item.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.home),
          title: Text(utf8.decode(latin1.encode(widget.item[index].food),
              allowMalformed: true)),
          trailing: Text(utf8.decode(
              latin1.encode(widget.item[index].weight.toString()),
              allowMalformed: true)),
          subtitle: Text(utf8.decode(
              latin1.encode(widget.item[index].priceOriginal.toString()),
              allowMalformed: true)),
        );
      },
    );
  }
}
