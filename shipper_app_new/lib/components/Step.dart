import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/RouteCustomer.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:http/http.dart' as http;
import 'package:shipper_app_new/model/User.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sweetalert/sweetalert.dart';

import 'Home.dart';

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
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  double totalCost = 0;
  Timer getOrdersTimer;
  int countChecked = 0;
  var listOrders = new List<Order>();
  var listOrdersRemove = new List<String>();
  List<Map<String, dynamic>> tmp = new List();
  int totalItem = 0;

  Future<String> _getOrders() async {
    await http
        .get(GlobalVariable.API_ENDPOINT +
            "shipper/" +
            '${widget.userData.username}')
        .then((response) {
      print("Response don hang Step");
      if (response.body.isNotEmpty) {
        setState(() {
          Iterable list = json.decode(response.body);
          listOrders = list.map((model) => Order.fromJson(model)).toList();
        });
        if (listOrdersRemove.length > 0) {
          for (var id in listOrdersRemove) {
            setState(() {
              listOrders.removeWhere((item) => item.id == id);
            });
          }
        }
        if (listOrders.length > tmp.length) {
          _setNewListOrder();
          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    title: new Text("Thông báo"),
                    content: new Text('Có đơn hàng mới'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () async {
                          await Navigator.of(context).pop();
                        },
                      )
                    ],
                  ));
        }
      } else {}
    });
    return 'Success';
  }

  _setNewListOrder() async {
    List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
    for (Order orderInList in listOrders) {
      Map<String, dynamic> order = {
        "costDelivery": orderInList.costDelivery,
        "addressDelivery": {
          "address": '${orderInList.addressDelivery.address}',
          "lng": '${orderInList.addressDelivery.lng}',
          "lat": '${orderInList.addressDelivery.lat}',
        },
        "costShopping": orderInList.costShopping,
        "cust": '${orderInList.cust}',
        "dateDelivery": "${orderInList.dateDelivery}",
        "details": [
          for (OrderDetail detail in orderInList.detail)
            {
              "id": "${detail.id}",
              "food": {
                "id": "${detail.food.id}",
                "name": "${detail.food.name}",
                "image": "${detail.food.image}",
                "description": "${detail.food.description}",
                "price": detail.food.price,
                "saleOff": {
                  "startDate": "${detail.food.saleOff.startDate}",
                  "endDate": "${detail.food.saleOff.endDate}",
                  "startTime": "${detail.food.saleOff.startTime}",
                  "endTime": "${detail.food.saleOff.endTime}",
                  "saleOff": detail.food.saleOff.saleOff
                }
              },
              "priceOriginal": detail.priceOriginal,
              "pricePaid": detail.pricePaid,
              "saleOff": detail.saleOff,
              "weight": detail.weight
            },
        ],
        "id": "${orderInList.id}",
        "market": {
          "addr1": utf8.decode(latin1.encode("${orderInList.market.addr1}"),
              allowMalformed: true),
          "addr2": utf8.decode(latin1.encode("${orderInList.market.addr2}"),
              allowMalformed: true),
          "addr3": utf8.decode(latin1.encode("${orderInList.market.addr3}"),
              allowMalformed: true),
          "addr4": utf8.decode(latin1.encode("${orderInList.market.addr4}"),
              allowMalformed: true),
          "id": "${orderInList.market.id}",
          "lat": "${orderInList.market.lat}",
          "lng": "${orderInList.market.lng}",
          "name": utf8.decode(latin1.encode("${orderInList.market.name}"),
              allowMalformed: true),
        },
        "note": "phuong nguyen",
        "shipper": widget.userData.username,
        "status": 21,
        "timeDelivery": "12:12:12",
        "totalCost": orderInList.totalCost
      };
      data.add(order);
    }
    setState(() {
      tmp = data;
    });
  }

  @override
  void initState() {
    super.initState();
    tmp = widget.data;
    totalItem = widget.item.length;
    _getTotalCost();

    _firebaseMessaging.configure(
      onMessage: (message) async {
        if (message['data']['isCancel'] == 'true') {
          listOrdersRemove.add(message['data']['orderId']);
          setState(() {
            listOrders
                .removeWhere((item) => item.id == message['data']['orderId']);
          });

          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    title: new Text("Thông báo"),
                    content: new Text(
                        'Đơn hàng ${message['data']['orderId']} đã bị hủy'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('OK'),
                        onPressed: () async {
                          await Navigator.of(context).pop();
                        },
                      )
                    ],
                  ));
          if (listOrders.length > 0) {
            _setNewListOrder();
          } else if (listOrders.length == 0) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => new AlertDialog(
                      title: new Text("Thông báo"),
                      content: new Text(
                        "Tất cả đơn hàng đã bị hủy",
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Quay về màn hình chính!'),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      MyHomeWidget(userData: widget.userData)),
                              ModalRoute.withName('/'),
                            );
                          },
                        )
                      ],
                    ));
          }
        }
      },
      onResume: (message) async {
        // setState(() {
        //   title = message["data"]["title"];
        //   helper = "You have open the application from notification";
        // });
      },
    );

    getOrdersTimer = Timer.periodic(new Duration(seconds: 5), (timer) {
      _getOrders();
    });
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
          title: Text("Sản phẩm cần mua"),
          backgroundColor: Colors.green,
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        // Body
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
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
                                          widget.userData.username)
                                      .then((response) {
                                    if (response.statusCode == 200) {
                                      listOrdersRemove.add(
                                          tmp[indexSwipper].values.toList()[6]);
                                      setState(() {
                                        tmp.removeWhere((element) =>
                                            element.values.toList()[6] ==
                                            tmp[indexSwipper]
                                                .values
                                                .toList()[6]);
                                      });
                                      if (tmp.length == 0) {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => new AlertDialog(
                                                  title: new Text("Thông báo"),
                                                  content: new Text(
                                                    "Tất cả đơn hàng đã bị hủy",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 20),
                                                  ),
                                                  actions: <Widget>[
                                                    FlatButton(
                                                      child: Text(
                                                          'Quay về màn hình chính!'),
                                                      onPressed: () {
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  MyHomeWidget(
                                                                      userData:
                                                                          widget
                                                                              .userData)),
                                                          ModalRoute.withName(
                                                              '/'),
                                                        );
                                                      },
                                                    )
                                                  ],
                                                ));
                                      }
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
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
              getOrdersTimer.cancel();
              // SweetAlert.show(context,
              //     title: "Chưa mua đủ đồ ${countItemCheck}",
              //     style: SweetAlertStyle.success);
            } else {
              SweetAlert.show(context,
                  title: "Chưa mua đủ đồ", style: SweetAlertStyle.error);
            }
          },
          label: Text('Hoàn Tất'),
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
      Global.number = 0;
    } else {
      // If the server did not return a 200 OK response,
      // SweetAlert.show(context,
      //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
      // then throw an exception.
      throw Exception(response.body);
    }
  }

  Widget _builTotalCost(int indexListDetail) {
    // final patternFormat = new NumberFormat("#,##0", "en_US");
    var arrayOrderDetail = tmp[indexListDetail].values.toList()[5];
    double sum = arrayOrderDetail
        .map((expense) => expense['priceOriginal'])
        .fold(0, (prev, amount) => prev + amount);
    return RichText(
      text: TextSpan(
          text: 'Tổng tiền : ',
          style: TextStyle(fontSize: 20, color: Colors.black),
          children: <TextSpan>[
            TextSpan(
              text: oCcy.format(sum) + " vnd",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ]),
    );
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
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(_getNameFood(widget.data['food']['id']) +
          "      " +
          widget.data['weight'].toString() +
          " kg"),
      value: _checked,
      subtitle: Text(
          utf8.decode(
              latin1.encode(oCcy.format(widget.data['priceOriginal']) + " vnd"),
              allowMalformed: true),
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
      activeColor: Colors.green,
      checkColor: Colors.white,
      onChanged: (bool value) {
        print("Image network la ${widget.data['image']}");
        setState(() {
          if (value == false) {
            Global.number--;
          } else if (value == true) {
            Global.number++;
          }
          _checked = value;
        });
      },
      secondary: widget.data['food']['image'] == 'null'
          ? Image.network(GlobalVariable.LAZY_IMAGE)
          : Image.network(widget.data['food']['image']),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

class CheckIntervalStep {
  static bool isHasOrderStep = false;
}
