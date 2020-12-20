import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';

import 'CustomerDetail.dart';

class HistoryDetail extends StatefulWidget {
  final orderID;
  final userId;
  final supAdd;
  final deAdd;
  final costShopping;
  final costShipping;
  final totalCost;
  const HistoryDetail({
    Key key,
    this.orderID,
    this.userId,
    this.supAdd,
    this.deAdd,
    this.costShipping,
    this.costShopping,
    this.totalCost,
  }) : super(key: key);

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

  _getNameFood(String foodId) {
    switch (foodId) {
      case "BACHIHEO":
        {
          // statements;
          return 'Thịt Ba Chỉ Heo';
        }
        break;

      case "BIHATDAU":
        {
          // statements;
          return 'Bí Hạt Đậu';
        }
        break;

      case "BONGCAIXANH":
        {
          // statements;
          return 'Bông Cải Xanh';
        }
        break;
      case "CAIDUNHUUCO":
        {
          // statements;
          return 'Cải Dún Hữu Cơ';
        }
        break;
      case "CUCAITRANG_1":
        {
          // statements;
          return 'Củ Cái Trắng';
        }
        break;
      case "DAUCOVE":
        {
          // statements;
          return 'Đậu cove Đà Lạt';
        }
        break;
      case "DAUHUCHIEN":
        {
          // statements;
          return 'Đậu Hũ Chiên';
        }
        break;
      case "DAUHUTRANG":
        {
          // statements;
          return 'Đậu Hũ Trắng';
        }
        break;
      case "DUIGA":
        {
          // statements;
          return 'Đùi Gà';
        }
        break;
      case "NAMBAONGUXAM":
        {
          // statements;
          return 'Nấm Bào Ngư Xám';
        }
        break;
      case "THANBO":
        {
          // statements;
          return 'Thăn Bò';
        }
        break;
      case "THITBAROI":
        {
          // statements;
          return 'Thịt Ba Rọi';
        }
        break;
      case "UCGATA":
        {
          // statements;
          return 'Ức Gà Ta';
        }
        break;
      case "UCGATAGACONG":
        {
          // statements;
          return 'Ức Gà Ta Gò Công';
        }
        break;
      case "XALACH_1":
        {
          // statements;
          return 'Xà Lách';
        }
        break;
      default:
        {
          return foodId;
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    listOrderDetail = new List();
    _getDetails();
    print("${GlobalVariable.API_ENDPOINT}" +
        "image/" +
        "${widget.orderID}" +
        "_1.png/shipper/" +
        "${widget.userId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Chi tiết lịch sử"),
          centerTitle: true,
          backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Text('Mã đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              title: Text('${widget.orderID}',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Text(
                'Siêu thị ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Text(
                widget.supAdd,
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
            ListTile(
              leading: Text(
                'Địa chỉ giao hàng ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Text(
                widget.deAdd,
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
            ),
            ListTile(
              leading: Text('Mặt hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: listOrderDetail.length,
              itemBuilder: (context, indexList) {
                return ListTile(
                  leading: Image.network(listOrderDetail[indexList].image),
                  title: Text(_getNameFood(listOrderDetail[indexList].foodId)),
                  trailing: Text(
                      listOrderDetail[indexList].weight.toString() + " kg"),
                  subtitle: Text(
                      oCcy.format(listOrderDetail[indexList].priceOriginal) +
                          " vnd",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                );
              },
            ),
            ListTile(
              leading: Text('Tiền công mua đồ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Text(oCcy.format(widget.costShopping) + " " + " vnd",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            ListTile(
              leading: Text('Tiền vận chuyển',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Text(oCcy.format(widget.costShipping) + " " + " vnd",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            ListTile(
              leading: Text('Tổng tiền đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Text(oCcy.format(widget.totalCost) + " " + " vnd",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            ListTile(
              leading: Text('Hình xác nhận',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Image.network(
                "${GlobalVariable.API_ENDPOINT}" +
                    "image/" +
                    "${widget.orderID}" +
                    "_1.png/shipper/" +
                    "${widget.userId}",
                height: 150,
                width: 200,
                fit: BoxFit.fill),
            ListTile(
              leading: Text(
                "Thông tin khách hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CustomerPage(orderID: widget.orderID)),
                    );
                  },
                  child: Text(
                    'Xem Thông tin',
                    style: TextStyle(color: Colors.green),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
