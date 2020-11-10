import 'package:flutter/material.dart';
import 'package:shipper_app_new/model/Orders.dart';
import 'package:shipper_app_new/model/User.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:shipper_app_new/components/RouteSupermarket.dart';
import 'package:shipper_app_new/constant/constant.dart';

class DetailScreen extends StatefulWidget {
  final User userData;
  final List<Orders> list;
  final oCcy = new NumberFormat("#,##0", "en_US");
  DetailScreen({Key key, this.list, this.userData}) : super(key: key);

  @override
  DetailScreenState createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> {
  updateOrders() async {
    List<Map<String, dynamic>> data = new List<Map<String, dynamic>>();
    for (Orders orders in widget.list) {
      Map<String, dynamic> order = {
        "costDelivery": orders.order.costDelivery,
        "addressDelivery": orders.order.addressDelivery,
        "costShopping": orders.order.costShopping,
        "cust": '${orders.order.cust}',
        "dateDelivery": "${orders.order.dateDelivery}",
        "details": [
          for (OrderDetail detail in orders.order.detail)
            {
              "foodName": utf8.decode(latin1.encode("${detail.foodId}"),
                  allowMalformed: true),
              "foodId": "${detail.foodId}",
              "id": "${detail.id}",
              "image": "${detail.image}",
              "priceOriginal": detail.priceOriginal,
              "pricePaid": detail.pricePaid,
              "saleOff": detail.saleOff,
              "weight": detail.weight
            },
        ],
        "id": "${orders.order.id}",
        "market": {
          "addr1": utf8.decode(latin1.encode("${orders.order.market.addr1}"),
              allowMalformed: true),
          "addr2": utf8.decode(latin1.encode("${orders.order.market.addr2}"),
              allowMalformed: true),
          "addr3": utf8.decode(latin1.encode("${orders.order.market.addr3}"),
              allowMalformed: true),
          "addr4": utf8.decode(latin1.encode("${orders.order.market.addr4}"),
              allowMalformed: true),
          "id": "${orders.order.market.id}",
          "lat": "${orders.order.market.lat}",
          "lng": "${orders.order.market.lng}",
          "name": utf8.decode(latin1.encode("${orders.order.market.name}"),
              allowMalformed: true),
        },
        "note": "phuong nguyen",
        "shipper": widget.userData.id,
        "status": 21,
        "timeDelivery": "12:12:12",
        "totalCost": orders.order.totalCost
      };
      data.add(order);
    }
    print(jsonEncode(data));

    var url = API_ENDPOINT + 'orders/update';
    var response = await http.put(
      Uri.encodeFull(url),
      headers: {
        'Content-type': 'application/json',
        "Accept": "application/json",
      },
      encoding: Encoding.getByName("utf-8"),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      List<OrderDetail> oD = new List<OrderDetail>();
      for (Orders orders in widget.list) {
        for (OrderDetail detail in orders.order.detail) {
          oD.add(detail);
        }
      }

      // If the server did return a 200 OK response,
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => RouteSupermarket(
                  orderDetails: oD, data: data, userData: widget.userData)),
          (Route<dynamic> route) => false);
    } else {
      // If the server did not return a 200 OK response,
      // SweetAlert.show(context,
      //     subtitle: "Xác nhận không thành công", style: SweetAlertStyle.error);
      // then throw an exception.
      throw Exception(
          utf8.decode(latin1.encode(response.body), allowMalformed: true));
    }
  }

  final oCcy = new NumberFormat("#,##0", "en_US");
  @override
  Widget build(BuildContext context) {
    List<double> listTotalWeight = new List<double>();
    for (Orders orders in widget.list) {
      double total = 0;
      for (OrderDetail details in orders.order.detail) {
        total += details.weight;
      }
      listTotalWeight.add(total);
    }

    // List<double> listTotalWeight = listOrderDetails.map((e.weight) => e.weight);
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Chi tiết đơn hàng"), backgroundColor: Colors.green),
      body: new Swiper(
          itemBuilder: (BuildContext context, int index) {
            return new SafeArea(
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.list[index].order.detail.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Image.network(LAZY_IMAGE),
                          title: Text(utf8.decode(
                              latin1.encode(widget
                                  .list[index].order.detail[index].foodId),
                              allowMalformed: true)),
                          trailing: Text(widget
                                  .list[index].order.detail[index].weight
                                  .toString() +
                              " kg"),
                          subtitle: Text(utf8.decode(
                              latin1.encode(widget.list[index].order
                                      .detail[index].priceOriginal
                                      .toString()
                                      .replaceAll(regex, "") +
                                  ' vnd'),
                              allowMalformed: true)),
                        );
                      },
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.settings_applications),
                        title: Text('Mã đơn hàng '),
                        trailing: Text(widget.list[index].order.id),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.money),
                        title: Text('Tổng tiền Sản Phẩm '),
                        trailing: Text(
                            oCcy.format(widget.list[index].order.totalCost) +
                                ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.local_shipping),
                        title: Text('Tiền vận chuyển '),
                        trailing: Text(
                            oCcy.format(widget.list[index].order.costDelivery) +
                                ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.book_outlined),
                        title: Text('Tiền công mua đồ '),
                        trailing: Text(
                            oCcy.format(widget.list[index].order.costShopping) +
                                ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.receipt),
                        title: Text('Tiền được nhận '),
                        trailing: Text(oCcy.format(
                                ((widget.list[index].order.costShopping +
                                        widget.list[index].order.costDelivery) /
                                    2)) +
                            ' vnd'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.shop),
                        title: Text('Tổng khối lượng '),
                        trailing:
                            Text(oCcy.format(listTotalWeight[index]) + " kg"),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.directions_train),
                        title: Text('Khoảng cách '),
                        trailing: Text((widget.list[index].value / 1000)
                                .round()
                                .toString() +
                            ' km'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.album),
                        title: Text('Đi Từ'),
                        subtitle: Text(utf8.decode(
                            latin1.encode(widget.list[index].order.market.name +
                                " " +
                                widget.list[index].order.market.addr1),
                            allowMalformed: true)),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.home),
                        title: Text('Đến'),
                        subtitle: Text(utf8.decode(
                            latin1.encode(
                                widget.list[index].order.addressDelivery),
                            allowMalformed: true)),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.access_alarm),
                        title: Text('Giao trước lúc'),
                        subtitle: Text(widget.list[index].order.timeDelivery),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: widget.list.length,
          pagination: new SwiperPagination(
              builder: new DotSwiperPaginationBuilder(
            color: Colors.grey,
            activeColor: Colors.green,
            size: 20,
            activeSize: 20,
          )),
          control: new SwiperControl(color: Colors.green),
          scale: 0.9),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          updateOrders();
        },
        label: Text('Nhận Đơn Hàng'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
