import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/RouteCustomer.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/model/User.dart';

class Steps extends StatefulWidget {
  final List<OrderDetail> item;
  final User userData;
  final Map<String, dynamic> data;
  Steps({Key key, @required this.item, this.data, this.userData})
      : super(key: key);

  @override
  _StepsState createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  @override
  void initState() {
    super.initState();
  }

  int current_step = 0;

  @override
  Widget build(BuildContext context) {
    List<Step> my_steps = [
      Step(
          // Title of the Step
          title: Text("Mua đồ"),
          content: Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildOrderReceive(),
                // new Text("Ức Gà Ta"),
                // new Text("Ức Gà Ta Gò Công"),
                // new Text("Xà Lách"),
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
          content: Text("Tổng tiền : " + " 300000 vnd"),
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
    return Scaffold(
      // Appbar
      appBar: AppBar(
        // Title
        title: Text("Tiến Trình"),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      // Body
      body: Container(
        child: Theme(
            data: ThemeData(canvasColor: Colors.lightGreenAccent),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // print(widget.data.toString());
          _updateOrder();
        },
        label: Text('Hoàn Tất Mua Hàng'),
        backgroundColor: Colors.green,
      ),
    );
  }

  _updateOrder() async {
    var url = API_ENDPOINT + 'orders/update';
    var response = await http.put(
      Uri.encodeFull(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      encoding: Encoding.getByName("utf-8"),
      body: '[' + jsonEncode(widget.data) + ']',
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RouteCustomer(data: widget.data, userData: widget.userData)),
      );
    } else {
      // If the server did not return a 200 OK response,
      // SweetAlert.show(context,
      //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
      // then throw an exception.
      throw Exception(response.body);
    }
  }

  Widget _buildOrderReceive() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.item.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.network(LAZY_IMAGE),
          title: Text(utf8.decode(latin1.encode(widget.item[index].food),
              allowMalformed: true)),
          trailing: Text(utf8.decode(
              latin1.encode(widget.item[index].weight.toString() + " kg"),
              allowMalformed: true)),
          subtitle: Text(utf8.decode(
              latin1
                  .encode(widget.item[index].priceOriginal.toString() + " vnd"),
              allowMalformed: true)),
        );
      },
    );
  }
}
