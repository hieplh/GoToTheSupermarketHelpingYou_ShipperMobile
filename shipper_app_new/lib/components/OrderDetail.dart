import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:shipper_app_new/components/RouteSupermarket.dart';
import 'package:shipper_app_new/constant/constant.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatelessWidget {
  // Declare a field that holds the Todo.
  final Orders orderObject;
  final List<OrderDetail> detailObject;
  final User userData;
  // In the constructor, require a Todo.
  DetailScreen(
      {Key key, @required this.orderObject, this.detailObject, this.userData})
      : super(key: key);

  updateOrders(BuildContext context) async {
    String jsonTags = jsonEncode(detailObject);

    Map<String, dynamic> data = {
      "costDelivery": orderObject.order.costDelivery,
      "addressDelivery": orderObject.order.addressDelivery,
      "costShopping": orderObject.order.costShopping,
      "cust": '${orderObject.order.cust}',
      "dateDelivery": "${orderObject.order.dateDelivery}",
      "details": [
        for (OrderDetail detail in orderObject.order.detail)
          {
            "food": utf8.decode(latin1.encode("${detail.food}"),
                allowMalformed: true),
            "id": "${detail.id}",
            "image": "${detail.image}",
            "priceOriginal": detail.priceOriginal,
            "pricePaid": detail.pricePaid,
            "saleOff": detail.saleOff,
            "weight": detail.weight
          }
      ],
      "id": "${orderObject.order.id}",
      "lat": "10.780539",
      "lng": "106.651088",
      "market": {
        "addr1": utf8.decode(latin1.encode("${orderObject.order.market.addr1}"),
            allowMalformed: true),
        "addr2": utf8.decode(latin1.encode("${orderObject.order.market.addr2}"),
            allowMalformed: true),
        "addr3": utf8.decode(latin1.encode("${orderObject.order.market.addr3}"),
            allowMalformed: true),
        "addr4": utf8.decode(latin1.encode("${orderObject.order.market.addr4}"),
            allowMalformed: true),
        "id": "${orderObject.order.market.id}",
        "lat": "${orderObject.order.market.lat}",
        "lng": "${orderObject.order.market.lng}",
        "name": utf8.decode(latin1.encode("${orderObject.order.market.name}"),
            allowMalformed: true),
      },
      "note": "phuong nguyen",
      "shipper": userData.id,
      "status": 21,
      "timeDelivery": "12:12:12",
      "totalCost": orderObject.order.totalCost
    };

    // List<Orders> list;
    // final response = await http.get('http://172.16.191.127:1234/smhu/api/shipper/98765/lat/10.780539/lng/106.651088');
    // for (OrderDetail detail in orderObject.order.detail) {
    //   listOrderDetails.add(detail);
    // }
    // http: //25.72.134.12:1234/smhu/api/orders/update
    // http: //smhu.ddns.net/smhu/api/orders/update
    var url = API_ENDPOINT + 'orders/update';
    var response = await http.put(
      Uri.encodeFull(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      encoding: Encoding.getByName("utf-8"),
      body: '[' + jsonEncode(data) + ']',
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RouteSupermarket(
                orderDetails: orderObject.order.detail,
                data: data,
                userData: userData)),
      );
    } else {
      // If the server did not return a 200 OK response,
      // SweetAlert.show(context,
      //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
      // then throw an exception.
      throw Exception(
          utf8.decode(latin1.encode(response.body), allowMalformed: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    print(userData);
    TimeOfDay now = TimeOfDay.now();
    var totalWeight = 0.0;
    var distanceString =
        orderObject.distance.replaceAll(new RegExp(r'[^0-9]'), '');
    var distanceKm = (orderObject.value / 1000.0).round();
    final fromCoordinates = new Coordinates(
        double.parse(orderObject.order.market.lat),
        double.parse(orderObject.order.market.lng));
    var fromPlace =
        Geocoder.local.findAddressesFromCoordinates(fromCoordinates);
    for (OrderDetail detail in this.orderObject.order.detail) {
      totalWeight += detail.weight;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Thông Tin Đơn Hàng"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderObject.order.detail.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(LAZY_IMAGE),
                    title: Text(utf8.decode(
                        latin1.encode(orderObject.order.detail[index].food),
                        allowMalformed: true)),
                    trailing: Text(
                        orderObject.order.detail[index].weight.toString() +
                            " kg"),
                    subtitle: Text(utf8.decode(
                        latin1.encode(orderObject
                                .order.detail[index].priceOriginal
                                .toString() +
                            ' vnd'),
                        allowMalformed: true)),
                  );
                },
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.money),
                  title: Text('Tổng tiền Sản Phẩm '),
                  trailing: Text(
                      orderObject.order.totalCost.round().toString() + ' vnd'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.local_shipping),
                  title: Text('Tiền vận chuyển '),
                  trailing: Text(
                      orderObject.order.costDelivery.round().toString() +
                          ' vnd'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.book_outlined),
                  title: Text('Tiền công mua đồ '),
                  trailing: Text(
                      orderObject.order.costShopping.round().toString() +
                          ' vnd'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('Tiền được nhận '),
                  trailing: Text(((orderObject.order.costShopping +
                                  orderObject.order.costDelivery) /
                              2)
                          .round()
                          .toString() +
                      ' vnd'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.shop),
                  title: Text('Tổng khối lượng '),
                  trailing: Text(totalWeight.toString() + 'kg'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.directions_train),
                  title: Text('Khoảng cách '),
                  trailing: Text(distanceKm.toString() + ' km'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.album),
                  title: Text('Đi Từ'),
                  subtitle: Text(utf8.decode(
                      latin1.encode(orderObject.order.market.name +
                          " " +
                          orderObject.order.market.addr1),
                      allowMalformed: true)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Đến'),
                  subtitle: Text(utf8.decode(
                      latin1.encode(orderObject.order.market.addr2 +
                          " " +
                          orderObject.order.market.addr3),
                      allowMalformed: true)),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.access_alarm),
                  title: Text('Giao trước lúc'),
                  subtitle: Text(orderObject.order.timeDelivery),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          SweetAlert.show(context,
              title: "Tiếp nhận đơn hàng",
              style: SweetAlertStyle.confirm,
              showCancelButton: true, onPress: (bool isConfirm) {
            if (isConfirm) {
              updateOrders(context);
            }
          });
        },
        label: Text('Nhận Đơn Hàng'),
        backgroundColor: Colors.green,
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {},
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text(
          "Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
