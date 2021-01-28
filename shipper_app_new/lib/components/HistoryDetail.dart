import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Feedback.dart';

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
  FeedbackOrder feedback = null;
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

  double getTotalCostInOrderDetail(List<OrderDetail> details) {
    double result = 0;
    for (OrderDetail detail in details) {
      result += detail.weight * detail.pricePaid;
    }
    return result;
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

  _getFeecBack() async {
    var responseFeedBack = await http
        .get(GlobalVariable.API_ENDPOINT + "feedback/${widget.orderID}");
    if (responseFeedBack.statusCode == 200) {
      feedback = FeedbackOrder.fromJson(jsonDecode(responseFeedBack.body));
    }
  }

  @override
  void initState() {
    super.initState();
    listOrderDetail = new List();
    _getDetails();
    _getFeecBack();
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
                  leading: Image.network(listOrderDetail[indexList].food.image),
                  title: Text(_getNameFood(listOrderDetail[indexList].food.id)),
                  trailing: Text(
                      listOrderDetail[indexList].weight.toInt().toString() +
                          " x"),
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
              leading: Text('Tổng tiền sản phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Text(
                  oCcy.format(getTotalCostInOrderDetail(listOrderDetail)) +
                      " " +
                      " vnd",
                  style: TextStyle(
                    fontSize: 16,
                  )),
            ),
            ListTile(
                leading: Text('Rating từ khách',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: feedback == null
                    ? Text('Chưa có')
                    : RatingBar.builder(
                        initialRating: double.parse(feedback.rating.toString()),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      )),
            ListTile(
                leading: Text('Feedback từ khách',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: feedback == null
                    ? Text('Chưa có')
                    : Text(utf8.decode(latin1.encode(feedback.feedback),
                        allowMalformed: true))),
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
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
