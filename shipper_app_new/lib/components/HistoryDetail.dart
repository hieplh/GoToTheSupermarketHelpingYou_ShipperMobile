import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';

import 'CustomerDetail.dart';

class HistoryDetail extends StatefulWidget {
  final orderID;
  const HistoryDetail({Key key, this.orderID}) : super(key: key);

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  List<OrderDetail> listOrderDetail;
  final oCcy = new NumberFormat("#,##0", "en_US");
  Future<OrderDetail> futureOrderDetails;
  _getDetails() async {
    final response = await http
        .get(GlobalVariable.API_ENDPOINT + 'history/' + widget.orderID);
    Iterable listResponse = await json.decode(response.body);
    setState(() {
      listOrderDetail =
          listResponse.map((model) => OrderDetail.fromJson(model)).toList();
      ;
    });
  }

  @override
  void initState() {
    super.initState();
    listOrderDetail = new List();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Chi tiết lịch sử"),
          centerTitle: true,
          backgroundColor: Colors.green),

      body: Column(
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Text('${widget.orderID}',style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold)),

            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: listOrderDetail.length,
            itemBuilder: (context, indexList) {
              return ListTile(
                leading: Image.network(listOrderDetail[indexList].image),
                title: Text(utf8.decode(
                    latin1.encode(listOrderDetail[indexList].foodId),
                    allowMalformed: true)),
                trailing:
                Text(listOrderDetail[indexList].weight.toString() + " kg"),
                subtitle: Text(
                    oCcy.format(listOrderDetail[indexList].priceOriginal) + " vnd"),
              );
            },
          ),
          TextButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CustomerPage(
                      orderID: widget.orderID)),
            );
          }, child: Text('Xem Thông tin khách hàng',style: TextStyle(color: Colors.green),)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Quay lại',
        child: const Icon(Icons.arrow_back),
        backgroundColor: Colors.green,
      ),
    );
  }
}
