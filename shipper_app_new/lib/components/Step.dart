import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/RouteCustomer.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/model/User.dart';
import 'package:intl/intl.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:sweetalert/sweetalert.dart';

class Steps extends StatefulWidget {
  final List<OrderDetail> item;
  final User userData;
  final String des;

  final oCcy = new NumberFormat("#,##0", "en_US");
  final List<Map<String, dynamic>> data;
  Steps({Key key, @required this.item, this.data, this.userData, this.des})
      : super(key: key);

  @override
  _StepsState createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  final oCcy = new NumberFormat("#,##0", "en_US");
  bool _isChecked = false;
  double totalCost = 0;
  int countChecked = 0;
  List<Map<String, dynamic>> tmp = new List();
  int totalItem = 0;

  @override
  void initState() {
    super.initState();
    tmp = widget.data;
    totalItem = widget.item.length;
    _getTotalCost();
  }

  _getTotalCost() {
    for (OrderDetail detail in widget.item) {
      totalCost += detail.priceOriginal;
    }
  }

  int current_step = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
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
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: tmp.length,
            itemBuilder: (BuildContext context, int indexSwipper) {
              return Container(
                  margin: new EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          leading: Text(
                            "Đơn hàng",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          title: Text(tmp[indexSwipper].values.toList()[6],
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                          trailing: TextButton(
                            child: Text('HỦY',
                                style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              SweetAlert.show(context,
                                  title: "Chú ý",
                                  subtitle: "Bạn có muốn hủy đơn hàng ? ",
                                  style: SweetAlertStyle.confirm,
                                  showCancelButton: true,
                                  onPress: (bool isConfirm) {
                                if (isConfirm) {
                                  http
                                      .delete(GlobalVariable.API_ENDPOINT +
                                          'delete/' +
                                          tmp[indexSwipper].values.toList()[6] +
                                          '/shipper/' +
                                          widget.userData.id)
                                      .then((response) {
                                    if (response.statusCode == 200) {
                                      setState(() {
                                        tmp.removeWhere((element) =>
                                            element.values.toList()[6] ==
                                            tmp[indexSwipper]
                                                .values
                                                .toList()[6]);
                                      });
                                    } else {
                                      // SweetAlert.show(context,
                                      //     title: '${response.statusCode}',
                                      //     style: SweetAlertStyle.error);
                                    }
                                  });
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: tmp[indexSwipper].values.toList()[5].length,
                        itemBuilder: (context, index) {
                          return CheckItem(
                              data: tmp[indexSwipper].values.toList()[5]
                                  [index]);
                        },
                      ),
                      _builTotalCost(indexSwipper),
                    ],
                  ));
            },

            // pagination: new SwiperPagination(
            //     alignment: Alignment.bottomLeft,
            //     builder: new DotSwiperPaginationBuilder(
            //       color: Colors.grey,
            //       activeColor: Colors.green,
            //       size: 20,
            //       activeSize: 20,
            //     )),
            // control: new SwiperControl(color: Colors.green),
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            int countItemCheck = 0;
            for (int i = 0; i < tmp.length; i++) {
              countItemCheck += tmp[i].values.toList()[5].length;
            }
            // // print(widget.data.toString());
            // print("So luong item la " + Global.number.toString());
            if (Global.number.round() == countItemCheck) {
              _updateOrder();
              // SweetAlert.show(context,
              //     title: "Chưa mua đủ đồ ${countItemCheck}",
              //     style: SweetAlertStyle.success);
            } else {
              SweetAlert.show(context,
                  title: "Chưa mua đủ đồ ${countItemCheck}",
                  style: SweetAlertStyle.error);
            }
          },
          label: Text('Hoàn Tất Mua Hàng'),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  _updateOrder() async {
    var url = GlobalVariable.API_ENDPOINT + 'orders/update';
    var response = await http.put(
      Uri.encodeFull(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(tmp),
    );

    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RouteCustomer(data: tmp, userData: widget.userData)),
      );
    } else {
      // If the server did not return a 200 OK response,
      // SweetAlert.show(context,
      //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
      // then throw an exception.
      throw Exception(response.body);
    }
  }

  Widget _buildOrderReceive(int indexListDetail) {
    // final patternFormat = new NumberFormat("#,##0", "en_US");

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.data[indexListDetail].values.toList()[5].length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: FadeInImage.assetNetwork(
              placeholder: GlobalVariable.LAZY_IMAGE,
              image: widget.data[indexListDetail].values
                  .toList()[5][index]['image']
                  .toString()),
          title: Text(utf8.decode(
              latin1.encode(widget.data[indexListDetail].values
                  .toList()[5][index]['foodId']
                  .toString()),
              allowMalformed: true)),
          trailing: Text(utf8.decode(
              latin1.encode(widget.data[indexListDetail].values
                      .toList()[5][index]['weight']
                      .toString() +
                  " kg"),
              allowMalformed: true)),
          subtitle: Text(utf8.decode(
              latin1.encode(oCcy.format(widget.data[indexListDetail].values
                      .toList()[5][index]['priceOriginal']) +
                  " vnd"),
              allowMalformed: true)),
        );
      },
    );
  }

  Widget _builTotalCost(int indexListDetail) {
    // final patternFormat = new NumberFormat("#,##0", "en_US");
    var arrayOrderDetail = widget.data[indexListDetail].values.toList()[5];
    double sum = arrayOrderDetail
        .map((expense) => expense['priceOriginal'])
        .fold(0, (prev, amount) => prev + amount);
    return Text("Tổng tiền : " + oCcy.format(sum) + " vnd");
  }
}

class Global {
  static int number = 0;
}

class CheckItem extends StatefulWidget {
  final data;
  CheckItem({Key key, this.data}) : super(key: key);

  @override
  _CheckItemState createState() => _CheckItemState();
}

class _CheckItemState extends State<CheckItem> {
  bool _checked = false;
  bool _selected = false;

  final oCcy = new NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(utf8.decode(
          latin1.encode(widget.data['foodId'].toString() +
              "     " +
              utf8.decode(
                  latin1.encode(widget.data['weight'].toString() + " kg"),
                  allowMalformed: true)),
          allowMalformed: true)),
      value: _checked,
      subtitle: Text(utf8.decode(
          latin1.encode(oCcy.format(widget.data['priceOriginal']) + " vnd"),
          allowMalformed: true)),
      activeColor: Colors.green,
      checkColor: Colors.white,
      onChanged: (bool value) {
        setState(() {
          if (value == false) {
            Global.number--;
          } else if (value == true) {
            Global.number++;
          }
          _checked = value;
        });
      },
      secondary: Image.network(widget.data['image'].toString()),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
